package circus.robocalc.robosim.physmod.generator.sourceCodeGen.tests;

import static org.junit.jupiter.api.Assertions.*;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Map;
import java.util.concurrent.TimeUnit;

import org.eclipse.xtext.generator.InMemoryFileSystemAccess;
import org.eclipse.xtext.testing.util.ParseHelper;
import org.eclipse.xtext.testing.InjectWith;
import org.eclipse.xtext.testing.extensions.InjectionExtension;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;

import com.google.inject.Inject;
import com.google.inject.Injector;

import circus.robocalc.robosim.physmod.generator.sourceCodeGen.SolutionRefGenerator;
import circus.robocalc.robosim.physmod.generator.sourceCodeGen.latex.SolutionToLatexGenerator;
import circus.robocalc.robosim.physmod.generator.sourceCodeGen.tests.SlnRefInjectorProvider;
import circus.robocalc.robosim.physmod.generator.sourceCodeGen.tests.SlnDFInjectorProvider;
import circus.robocalc.robosim.physmod.slnRef.slnRef.SlnRefs;
import circus.robocalc.robosim.physmod.slnDF.slnDF.Solution;

/**
 * LaTeX generation integration test:
 * - Generates LaTeX document from SlnRef input
 * - Verifies LaTeX structure and content
 * - Optionally compiles with pdflatex if available
 */
@ExtendWith(InjectionExtension.class)
@InjectWith(SlnRefInjectorProvider.class)
public class TestSKO_T5Latex {

    @Inject
    private ParseHelper<SlnRefs> slnRefParseHelper;
    private static final String TESTDATA_PROJECT_PATH =
        "../../physmod-testdata/circus.robocalc.robosim.physmod.testdata/testdata/integration/T5/SKO/";

    // For SolutionDSL, we'll get the injector from SlnDFInjectorProvider
    private ParseHelper<Solution> solutionDSLParseHelper;

    // Initialize SolutionDSL parser on first use
    private ParseHelper<Solution> getSolutionDSLParseHelper() {
        if (solutionDSLParseHelper == null) {
            SlnDFInjectorProvider provider = new SlnDFInjectorProvider();
            Injector injector = provider.getInjector();
            solutionDSLParseHelper = injector.getInstance(ParseHelper.class);
        }
        return solutionDSLParseHelper;
    }

    private Path integrationRoot() {
        return Paths.get("").toAbsolutePath().resolve("tests").resolve("integrationTests").resolve("SKO");
    }

    private Path latexRoot() {
        return integrationRoot().resolve("latex");
    }

    private Path testdataRoot() {
        return Paths.get("").toAbsolutePath().resolve(TESTDATA_PROJECT_PATH);
    }

    @Test
    public void testLatexGeneration() throws Exception {
        // Use input from latex test folder
        Path input = testdataRoot().resolve("latex").resolve("input").resolve("SimpleArmSerial.slnRef");
        assertTrue(Files.exists(input), "Missing input slnRef: " + input);

        String slnRefText = Files.readString(input);

        // Parse slnRef using injected parser
        SlnRefs slnRefs = slnRefParseHelper.parse(slnRefText);
        assertNotNull(slnRefs, "Failed to parse SlnRefs");
        assertTrue(slnRefs.eResource().getErrors().isEmpty(), "Parsing errors: " + slnRefs.eResource().getErrors());

        // Set system properties for LaTeX generation
        String oldFormat = System.getProperty("physmod.output.format");
        String oldStyle = System.getProperty("physmod.latex.style");
        try {
            System.setProperty("physmod.output.format", "latex");
            System.setProperty("physmod.latex.style", "SKO");  // Use SKO layout

            // STAGE 1: SlnRef -> Solution DSL
            System.out.println("=== STAGE 1: SlnRef -> Solution DSL ===");
            SolutionRefGenerator gen = new SolutionRefGenerator();
            String solutionDSL = gen.compile(slnRefs);

            assertNotNull(solutionDSL, "Generated Solution DSL is null");
            assertFalse(solutionDSL.trim().isEmpty(), "Generated Solution DSL is empty");

            // Verify the DSL contains expected sections
            assertTrue(solutionDSL.contains("Solution"), "Missing 'Solution' keyword");
            assertTrue(solutionDSL.contains("state"), "Missing 'state' block");
            assertTrue(solutionDSL.contains("computation"), "Missing 'computation' block");

            // Parse Solution DSL
            Solution solution = getSolutionDSLParseHelper().parse(solutionDSL);
            assertNotNull(solution, "Generated Solution DSL failed to parse");
            assertTrue(solution.eResource().getErrors().isEmpty(),
                "Solution DSL parse errors: " + solution.eResource().getErrors());
            System.out.println("✓ Stage 1: Solution DSL validated");

            // STAGE 2: Solution DSL -> LaTeX
            System.out.println("\n=== STAGE 2: Solution DSL -> LaTeX ===");
            SolutionToLatexGenerator latexGen = new SolutionToLatexGenerator();
            InMemoryFileSystemAccess fsa = new InMemoryFileSystemAccess();
            latexGen.doGenerate(solution.eResource(), fsa, null);

            Map<String, Object> files = fsa.getAllFiles();
            assertFalse(files.isEmpty(), "No files generated by LaTeX generator");

            // Find the LaTeX file
            String latexKey = files.keySet().stream()
                .filter(k -> k.endsWith("solution.tex"))
                .findFirst()
                .orElseThrow(() -> new AssertionError("Missing solution.tex"));

            String latexContent = files.get(latexKey).toString();
            assertNotNull(latexContent, "LaTeX content is null");
            assertFalse(latexContent.trim().isEmpty(), "LaTeX content is empty");

            System.out.println("LaTeX content size: " + latexContent.length() + " characters");

            // Write LaTeX output
            Path outDir = latexRoot().resolve("temp");
            Files.createDirectories(outDir);
            Path latexFile = outDir.resolve("solution.tex");
            Files.writeString(latexFile, latexContent);
            System.out.println("LaTeX output: " + latexFile);

            // Verify LaTeX structure
            verifyLatexStructure(latexContent);
            System.out.println("✓ Stage 2: LaTeX structure validated");

            // Verify LaTeX contains SKO-specific notation
            verifyLatexContent(latexContent);
            System.out.println("✓ Stage 2: LaTeX content validated");

            // Compare with expected output if it exists (from centralized test data)
            Path expectedLatex = testdataRoot().resolve("latex").resolve("expected").resolve("solution.tex");
            if (Files.exists(expectedLatex)) {
                String expectedContent = Files.readString(expectedLatex);
                // Normalize whitespace for comparison
                String normalizedExpected = normalizeWhitespace(expectedContent);
                String normalizedActual = normalizeWhitespace(latexContent);
                assertEquals(normalizedExpected, normalizedActual,
                    "LaTeX output differs from expected");
                System.out.println("✓ LaTeX output matches expected");
            } else {
                System.out.println("⚠ No expected LaTeX output for comparison");
            }

            // Optional: Try to compile with pdflatex if available
            if (isPdflatexAvailable()) {
                System.out.println("\n=== OPTIONAL: Compiling LaTeX with pdflatex ===");
                boolean compiled = compilePdflatex(latexFile);
                if (compiled) {
                    System.out.println("✓ LaTeX compiled successfully with pdflatex");
                    Path pdfFile = outDir.resolve("solution.pdf");
                    assertTrue(Files.exists(pdfFile), "PDF file not created");
                    assertTrue(Files.size(pdfFile) > 0, "PDF file is empty");
                } else {
                    System.out.println("⚠ pdflatex compilation failed (non-fatal)");
                }
            } else {
                System.out.println("⚠ pdflatex not available, skipping PDF compilation");
            }

            System.out.println("\n=== LaTeX generation test passed ===");

        } finally {
            // Restore original system properties
            if (oldFormat != null) {
                System.setProperty("physmod.output.format", oldFormat);
            } else {
                System.clearProperty("physmod.output.format");
            }
            if (oldStyle != null) {
                System.setProperty("physmod.latex.style", oldStyle);
            } else {
                System.clearProperty("physmod.latex.style");
            }
        }
    }

    /**
     * Verify basic LaTeX document structure.
     * For flat mode, checks for lstlisting instead of sections.
     */
    private void verifyLatexStructure(String latexContent) {
        // Document class and packages
        assertTrue(latexContent.contains("\\documentclass"), "Missing \\documentclass");
        assertTrue(latexContent.contains("amsmath") || latexContent.contains("\\usepackage{amsmath"), "Missing amsmath package");
        assertTrue(latexContent.contains("amssymb") || latexContent.contains("\\usepackage{amssymb"), "Missing amssymb package");
        assertTrue(latexContent.contains("\\begin{document}"), "Missing \\begin{document}");
        assertTrue(latexContent.contains("\\end{document}"), "Missing \\end{document}");
        
        // Check if flat mode (lstlisting) or structured mode (sections)
        boolean isFlatMode = latexContent.contains("\\begin{lstlisting");
        if (isFlatMode) {
            // Flat mode: should have lstlisting, no sections
            assertTrue(latexContent.contains("\\begin{lstlisting"), "Missing lstlisting in flat mode");
            assertTrue(latexContent.contains("\\end{lstlisting"), "Missing end lstlisting in flat mode");
            assertTrue(latexContent.contains("mathescape"), "Missing mathescape in lstlisting");
            assertTrue(latexContent.contains("listings") || latexContent.contains("\\usepackage{listings"), "Missing listings package in flat mode");
            assertFalse(latexContent.contains("\\section{"), "Flat mode should not have sections");
            assertFalse(latexContent.contains("\\subsection{"), "Flat mode should not have subsections");
            // Should start with "Solution" text
            assertTrue(latexContent.contains("Solution"), "Flat mode should contain 'Solution' keyword");
        } else {
            // Structured mode: should have sections
            assertTrue(latexContent.contains("\\title{"), "Missing title");
            assertTrue(latexContent.contains("\\maketitle"), "Missing maketitle");
            assertTrue(latexContent.contains("\\section{State Variables}") ||
                       latexContent.contains("\\section{Functions}") ||
                       latexContent.contains("\\section{Procedures}") ||
                       latexContent.contains("\\section{Computation}"),
                       "Missing at least one content section");
            assertTrue(latexContent.contains("\\begin{align") || latexContent.contains("\\begin{equation"),
                       "Missing math environment");
        }
    }

    /**
     * Verify LaTeX contains expected SKO-specific content.
     */
    private void verifyLatexContent(String latexContent) {
        // Check for SKO variables in LaTeX notation (should be in math mode: $...$)
        assertTrue(latexContent.contains("$\\theta$") || latexContent.contains("theta"),
                   "Missing theta variable in SKO notation");
        
        // Check for SKO constructs
        assertTrue(latexContent.contains("$\\Phi$") || latexContent.contains("phi") || latexContent.contains("Phi"),
                   "Missing phi/Phi variable");
        
        // For flat mode, should have Solution text structure
        boolean isFlatMode = latexContent.contains("\\begin{lstlisting");
        if (isFlatMode) {
            // Flat mode should have the .sln structure
            assertTrue(latexContent.contains("Solution"), "Flat mode should contain 'Solution' keyword");
            assertTrue(latexContent.contains("state") || latexContent.contains("state"),
                       "Flat mode should contain state section");
        } else {
            // Structured mode checks
            assertTrue(latexContent.contains("\\begin{itemize}") || latexContent.contains("\\begin{enumerate}"),
                       "Missing itemized/enumerated list in state variables");
            assertTrue(latexContent.contains("\\mathbb{R}") || latexContent.contains("\\in"),
                       "Missing mathematical set notation");
        }
    }

    /**
     * Normalize whitespace for comparison (collapse multiple spaces/newlines).
     */
    private String normalizeWhitespace(String text) {
        return text.replaceAll("\\s+", " ").trim();
    }

    /**
     * Check if pdflatex is available on the system.
     */
    private boolean isPdflatexAvailable() {
        try {
            ProcessBuilder pb = new ProcessBuilder("pdflatex", "--version");
            pb.redirectErrorStream(true);
            Process process = pb.start();
            boolean finished = process.waitFor(5, TimeUnit.SECONDS);
            if (!finished) {
                process.destroyForcibly();
                return false;
            }
            return process.exitValue() == 0;
        } catch (Exception e) {
            return false;
        }
    }

    /**
     * Compile LaTeX file with pdflatex.
     */
    private boolean compilePdflatex(Path latexFile) {
        try {
            Path outDir = latexFile.getParent();

            ProcessBuilder pb = new ProcessBuilder(
                "pdflatex",
                "-interaction=nonstopmode",
                "-output-directory=" + outDir.toString(),
                latexFile.getFileName().toString()
            );
            pb.directory(outDir.toFile());
            pb.redirectErrorStream(true);

            Process process = pb.start();

            // Capture output
            StringBuilder output = new StringBuilder();
            try (BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()))) {
                String line;
                while ((line = reader.readLine()) != null) {
                    output.append(line).append("\n");
                }
            }

            boolean finished = process.waitFor(60, TimeUnit.SECONDS);
            if (!finished) {
                process.destroyForcibly();
                System.err.println("pdflatex compilation timed out");
                return false;
            }

            int exitCode = process.exitValue();
            if (exitCode != 0) {
                System.err.println("pdflatex failed with exit code: " + exitCode);
                // Show last 20 lines of output for debugging
                String[] lines = output.toString().split("\n");
                int start = Math.max(0, lines.length - 20);
                System.err.println("Last 20 lines of pdflatex output:");
                for (int i = start; i < lines.length; i++) {
                    System.err.println(lines[i]);
                }
                return false;
            }

            return true;

        } catch (Exception e) {
            System.err.println("pdflatex compilation error: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
}
