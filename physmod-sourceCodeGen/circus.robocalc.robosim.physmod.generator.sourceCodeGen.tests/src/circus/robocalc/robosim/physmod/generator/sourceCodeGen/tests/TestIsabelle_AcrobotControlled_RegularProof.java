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

@ExtendWith(InjectionExtension.class)
@InjectWith(SlnRefInjectorProvider.class)
public class TestIsabelle_AcrobotControlled_RegularProof {

    @Inject
    private ParseHelper<SlnRefs> slnRefParseHelper;

    private ParseHelper<Solution> solutionDSLParseHelper;

    private static final String TESTDATA_PROJECT_PATH =
        "../../physmod-testdata/circus.robocalc.robosim.physmod.testdata/testdata/integration/T5/AcrobotControlled/SKO/FullSimulation_Visualisation/";

    private ParseHelper<Solution> getSolutionDSLParseHelper() {
        if (solutionDSLParseHelper == null) {
            SlnDFInjectorProvider provider = new SlnDFInjectorProvider();
            Injector injector = provider.getInjector();
            solutionDSLParseHelper = injector.getInstance(ParseHelper.class);
        }
        return solutionDSLParseHelper;
    }

    private Path repoRoot() {
        // .../T5_sourceCodeGen/<this-project> -> .../T5_sourceCodeGen -> .../physmod-physics-engine-private
        Path here = Paths.get("").toAbsolutePath();
        return here.getParent().getParent();
    }

    private Path testdataRoot() {
        return Paths.get("").toAbsolutePath().resolve(TESTDATA_PROJECT_PATH);
    }

    private Path inputSlnRef() {
        Path pipelineOutput = repoRoot()
            .resolve("IntegrationTests")
            .resolve("circus.robocalc.robosim.physmod.generator.pipeline.tests")
            .resolve("tests")
            .resolve("integrationTests")
            .resolve("AcrobotControlled")
            .resolve("temp")
            .resolve("T4")
            .resolve("guidedChoice_GENERATORAcrobotControlled.slnRef");
        if (Files.exists(pipelineOutput)) {
            return pipelineOutput;
        }

        return testdataRoot().resolve("input").resolve("AcrobotControlled.slnRef");
    }

    private Path outputDir() {
        return Paths.get("").toAbsolutePath()
            .resolve("tests")
            .resolve("integrationTests")
            .resolve("RobotExamples")
            .resolve("acrobot_controlled")
            .resolve("REGULAR_proof")
            .resolve("temp");
    }

    @Test
    public void testIsabelleEquationsFromRegularSolution_AcrobotControlled() throws Exception {
        Path inputPath = inputSlnRef();
        assertTrue(Files.exists(inputPath), "Missing input slnRef: " + inputPath);

        String slnRefText = Files.readString(inputPath);
        SlnRefs slnRefs = slnRefParseHelper.parse(slnRefText);
        assertNotNull(slnRefs, "Failed to parse SlnRefs");
        assertTrue(slnRefs.eResource().getErrors().isEmpty(),
            "Parsing errors: " + slnRefs.eResource().getErrors());

        String oldFormat = System.getProperty("physmod.output.format");
        String oldMode = System.getProperty("physmod.isabelle.mode");
        try {
            System.setProperty("physmod.output.format", "isabelle");
            System.setProperty("physmod.isabelle.mode", "equations");

            SolutionRefGenerator gen = new SolutionRefGenerator();
            String solutionDSL = gen.compile(slnRefs);
            assertNotNull(solutionDSL, "Generated Solution DSL is null");
            assertFalse(solutionDSL.trim().isEmpty(), "Generated Solution DSL is empty");

            // Normalize the solution name so downstream Isabelle artefacts are stable.
            solutionDSL = solutionDSL.replaceFirst("Solution\\s+__synthetic\\d+\\s*\\{", "Solution proof_solution {");

            Solution solution = getSolutionDSLParseHelper().parse(solutionDSL);
            assertNotNull(solution, "Generated Solution DSL failed to parse");
            assertTrue(solution.eResource().getErrors().isEmpty(),
                "Solution DSL parse errors: " + solution.eResource().getErrors());

            SolutionToIsabelleGenerator isabelleGen = new SolutionToIsabelleGenerator("equations");
            InMemoryFileSystemAccess fsa = new InMemoryFileSystemAccess();
            isabelleGen.generate(solution, solutionDSL, fsa);

            var generatedFiles = fsa.getAllFiles();
            assertFalse(generatedFiles.isEmpty(), "No Isabelle files generated");

            String theoryKey = generatedFiles.keySet().stream()
                .filter(k -> k.endsWith("_EQUATIONS.thy") || k.endsWith("_equations.thy"))
                .findFirst()
                .orElseThrow(() -> new AssertionError("Missing _EQUATIONS.thy output"));

            String theoryContent = generatedFiles.get(theoryKey).toString();
            assertNotNull(theoryContent, "Theory content is null");

            // Sanity checks: include geometric transform variables.
            assertTrue(theoryContent.contains("T_offset") || theoryContent.contains("T_geom"),
                "Expected geometric transform variables (T_offset/T_geom) in generated theory");

            Files.createDirectories(outputDir());
            String fileName = theoryKey.replace('\\', '/');
            int slashIdx = fileName.lastIndexOf('/');
            if (slashIdx >= 0) {
                fileName = fileName.substring(slashIdx + 1);
            }
            if (fileName.startsWith("DEFAULT_OUTPUT")) {
                fileName = fileName.substring("DEFAULT_OUTPUT".length());
            }

            Path outFile = outputDir().resolve(fileName);
            Files.writeString(outFile, theoryContent);
            System.out.println("Generated Isabelle theory written to: " + outFile);

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
}
