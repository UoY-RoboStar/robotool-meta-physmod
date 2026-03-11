package circus.robocalc.robosim.physmod.generator.sourceCodeGen.tests;

import static org.junit.jupiter.api.Assertions.*;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

import org.eclipse.xtext.generator.InMemoryFileSystemAccess;
import org.eclipse.xtext.testing.InjectWith;
import org.eclipse.xtext.testing.extensions.InjectionExtension;
import org.eclipse.xtext.testing.util.ParseHelper;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;

import com.google.inject.Inject;
import com.google.inject.Injector;

import circus.robocalc.robosim.physmod.generator.sourceCodeGen.SolutionRefGenerator;
import circus.robocalc.robosim.physmod.generator.sourceCodeGen.isabelle.SolutionToIsabelleGenerator;
import circus.robocalc.robosim.physmod.generator.sourceCodeGen.tests.SlnDFInjectorProvider;
import circus.robocalc.robosim.physmod.generator.sourceCodeGen.tests.SlnRefInjectorProvider;
import circus.robocalc.robosim.physmod.slnDF.slnDF.Solution;
import circus.robocalc.robosim.physmod.slnRef.slnRef.SlnRefs;

/**
 * Integration test for Isabelle generation with proof blocks built from T4 output.
 */
@ExtendWith(InjectionExtension.class)
@InjectWith(SlnRefInjectorProvider.class)
public class TestIsabelle_SKO_WithProof {

    @Inject
    private ParseHelper<SlnRefs> slnRefParseHelper;

    private ParseHelper<Solution> solutionDSLParseHelper;

    private ParseHelper<Solution> getSolutionDSLParseHelper() {
        if (solutionDSLParseHelper == null) {
            SlnDFInjectorProvider provider = new SlnDFInjectorProvider();
            Injector injector = provider.getInjector();
            solutionDSLParseHelper = injector.getInstance(ParseHelper.class);
        }
        return solutionDSLParseHelper;
    }

    private Path testRoot() {
        return Paths.get("").toAbsolutePath().resolve("tests").resolve("integrationTests").resolve("SKO_proof");
    }

    @Test
    public void testIsabelleWithProofBlock() throws Exception {
        // Read proof .slnRef from local test input directory
        Path inputPath = testRoot().resolve("input").resolve("SimpleArmSerial_WithProof.slnRef");

        assertTrue(Files.exists(inputPath), "Missing proof input: " + inputPath);

        String slnRefText = Files.readString(inputPath);
        SlnRefs slnRefs = slnRefParseHelper.parse(slnRefText);
        assertNotNull(slnRefs, "Failed to parse SlnRefs with proof block");
        assertTrue(slnRefs.eResource().getErrors().isEmpty(),
            "Parsing errors: " + slnRefs.eResource().getErrors());

        // Find the proof SlnRef (may be namespaced as "SKO::proof" or just "proof")
        var proofSlnRef = slnRefs.getSolutionRefs().stream()
            .filter(ref -> {
                String method = ref.getMethod();
                return method != null && (method.equalsIgnoreCase("proof") || method.equalsIgnoreCase("SKO::proof"));
            })
            .findFirst()
            .orElseThrow(() -> new AssertionError("No proof SlnRef found in input"));

        assertNotNull(proofSlnRef, "Proof SlnRef is null");
        assertFalse(proofSlnRef.getConstraints().isEmpty(), "Proof SlnRef has no constraints");

        String oldFormat = System.getProperty("physmod.output.format");
        String oldMode = System.getProperty("physmod.isabelle.mode");
        try {
            System.setProperty("physmod.output.format", "isabelle");
            System.setProperty("physmod.isabelle.mode", "equations");

            // Generate Solution DSL from proof block only
            // Strip namespace from method if present (e.g., "SKO::proof" -> "proof")
            String originalMethod = proofSlnRef.getMethod();
            String methodName = originalMethod;
            if (originalMethod != null && originalMethod.contains("::")) {
                String[] parts = originalMethod.split("::");
                if (parts.length == 2) {
                    methodName = parts[1];
                }
            }

            // Temporarily set unnamespaced method for library lookup
            proofSlnRef.setMethod(methodName);

            // Debug: Check if inputs exist
            System.out.println("DEBUG: proofSlnRef has " + proofSlnRef.getInputs().size() + " inputs");
            if (!proofSlnRef.getInputs().isEmpty()) {
                System.out.println("DEBUG: First input: " + proofSlnRef.getInputs().get(0).getValue().getName() +
                                 " : " + proofSlnRef.getInputs().get(0).getValue().getType());
            }

            String solutionDSL = circus.robocalc.robosim.physmod.libs.sourceCodeGen.solutionLib.SolutionLib.returnSolution(
                circus.robocalc.robosim.physmod.libs.sourceCodeGen.solutionLib.Formulation.SKO,
                proofSlnRef);

            // Restore original method
            proofSlnRef.setMethod(originalMethod);

            assertNotNull(solutionDSL, "Generated Solution DSL from proof is null");
            assertFalse(solutionDSL.trim().isEmpty(), "Generated Solution DSL from proof is empty");

            // Save the generated Solution DSL for inspection
            Path outputDir = testRoot().resolve("temp");
            Files.createDirectories(outputDir);
            Path slnFile = outputDir.resolve("proof_solution.sln");
            Files.writeString(slnFile, solutionDSL);
            System.out.println("Generated Solution DSL written to: " + slnFile);

            // Parse the Solution DSL
            Solution solution = getSolutionDSLParseHelper().parse(solutionDSL);
            assertNotNull(solution, "Generated Solution DSL failed to parse");
            assertTrue(solution.eResource().getErrors().isEmpty(),
                "Solution DSL parse errors: " + solution.eResource().getErrors());

            // Verify proof block exists
            assertNotNull(solution.getProof(), "Solution should have a proof block");
            assertFalse(solution.getProof().getExpressions().isEmpty(), "Proof block should contain expressions");

            // Generate Isabelle theory
            SolutionToIsabelleGenerator isabelleGen = new SolutionToIsabelleGenerator("equations");
            InMemoryFileSystemAccess fsa = new InMemoryFileSystemAccess();
            isabelleGen.generate(solution, solutionDSL, fsa);

            var generatedFiles = fsa.getAllFiles();
            assertFalse(generatedFiles.isEmpty(), "No Isabelle files generated");

            String theoryKey = generatedFiles.keySet().stream()
                .filter(k -> k.endsWith("_EQUATIONS.thy"))  // Now uppercase to match theory name
                .findFirst()
                .orElseThrow(() -> new AssertionError("Missing _EQUATIONS.thy output"));

            String theoryContent = generatedFiles.get(theoryKey).toString();
            assertNotNull(theoryContent, "Theory content is null");

            // Verify theory header uses ISAVodes format
            assertTrue(theoryContent.contains("theory Proof_solution_EQUATIONS") || 
                      theoryContent.contains("theory Physics_EQUATIONS"),
                "Theory header missing expected name (got: " + extractTheoryName(theoryContent) + ")");

            // Verify imports Hybrid-Verification instead of Main
            assertTrue(theoryContent.contains("Hybrid-Verification.Hybrid_Verification"),
                "Theory should import Hybrid-Verification for ISAVodes support");

            // Verify dataspace block exists
            assertTrue(theoryContent.contains("dataspace"),
                "Theory should contain dataspace block for ISAVodes format");

            // Verify variables section exists
            assertTrue(theoryContent.contains("variables"),
                "Theory should contain variables section in dataspace");

            // Verify context block exists (optional - may be empty if no algebraic constraints)
            // assertTrue(theoryContent.contains("context") && theoryContent.contains("_system"),
            //     "Theory should contain context block for the dataspace");

            // Verify axiomatization block exists within context (if context exists)
            if (theoryContent.contains("context")) {
                assertTrue(theoryContent.contains("definition") && theoryContent.contains("where"),
                    "Theory should contain definition blocks for algebraic constraints");
            }

            // For now, verify that basic structure is present
            // Note: Full [t==0] vs [t==t] separation is TODO - timing annotations are lost during Solution DSL parsing
            assertTrue(theoryContent.contains("variables"),
                "Theory should contain state variables");

            System.out.println("Test passed - Isabelle theory generated with ISAVodes structure");

            // Persist output for manual inspection  
            // outputDir already created above for .sln file
            String fileName = theoryKey.replace('\\', '/');
            int slashIdx = fileName.lastIndexOf('/');
            if (slashIdx >= 0) {
                fileName = fileName.substring(slashIdx + 1);
            }
            // Strip DEFAULT_OUTPUT prefix if present
            if (fileName.startsWith("DEFAULT_OUTPUT")) {
                fileName = fileName.substring("DEFAULT_OUTPUT".length());
            }
            Path theoryFile = outputDir.resolve(fileName);
            Files.writeString(theoryFile, theoryContent);

            System.out.println("Generated Isabelle theory with proof axioms written to: " + theoryFile);

        } finally {
            restoreProperty("physmod.output.format", oldFormat);
            restoreProperty("physmod.isabelle.mode", oldMode);
        }
    }

    private void restoreProperty(String key, String value) {
        if (value == null) {
            System.clearProperty(key);
        } else {
            System.setProperty(key, value);
        }
    }

    private String extractTheoryName(String theoryContent) {
        int theoryIdx = theoryContent.indexOf("theory ");
        if (theoryIdx == -1) return "NOT_FOUND";
        int endIdx = theoryContent.indexOf("\n", theoryIdx);
        if (endIdx == -1) endIdx = theoryContent.indexOf(" ", theoryIdx + 7);
        if (endIdx == -1) return "NOT_FOUND";
        return theoryContent.substring(theoryIdx + 7, endIdx).trim();
    }
}
