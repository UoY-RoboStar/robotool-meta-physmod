package circus.robocalc.robosim.physmod.generator.sourceCodeGen.tests;

import static org.junit.jupiter.api.Assertions.*;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;
import java.util.Map;

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
 * Integration-style test for the Isabelle "equations" generation option.
 */
@ExtendWith(InjectionExtension.class)
@InjectWith(SlnRefInjectorProvider.class)
public class TestIsabelle_T5Equations {

    @Inject
    private ParseHelper<SlnRefs> slnRefParseHelper;
    private static final String TESTDATA_PROJECT_PATH =
        "../../physmod-testdata/circus.robocalc.robosim.physmod.testdata/testdata/integration/T5/SKO/";

    private ParseHelper<Solution> solutionDSLParseHelper;

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

    private Path testdataRoot() {
        return Paths.get("").toAbsolutePath().resolve(TESTDATA_PROJECT_PATH);
    }

    private Path isabelleRoot() {
        return integrationRoot().resolve("isabelle");
    }

    @Test
    public void testIsabelleEquationsGeneration() throws Exception {
        Path input = testdataRoot().resolve("integrated").resolve("input").resolve("SimpleArmSerial.slnRef");
        assertTrue(Files.exists(input), "Missing input slnRef: " + input);

        String slnRefText = Files.readString(input);
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

            // Normalize the solution name to keep Isabelle artefacts stable.
            solutionDSL = solutionDSL.replaceFirst(
                "Solution\\s+\\S+\\s*\\{",
                "Solution SimpleArmSerial {");

            Solution solution = getSolutionDSLParseHelper().parse(solutionDSL);
            assertNotNull(solution, "Generated Solution DSL failed to parse");
            assertTrue(solution.eResource().getErrors().isEmpty(),
                "Solution DSL parse errors: " + solution.eResource().getErrors());

            SolutionToIsabelleGenerator isabelleGen = new SolutionToIsabelleGenerator("equations");
            InMemoryFileSystemAccess fsa = new InMemoryFileSystemAccess();
            isabelleGen.generate(solution, solutionDSL, fsa);

            Map<String, Object> generatedFiles = fsa.getAllFiles();
            assertFalse(generatedFiles.isEmpty(), "No Isabelle files generated");

            String theoryKey = generatedFiles.keySet().stream()
                .filter(k -> k.endsWith("_EQUATIONS.thy") || k.endsWith("_equations.thy"))
                .findFirst()
                .orElseThrow(() -> new AssertionError("Missing _equations.thy output"));

            String theoryContent = generatedFiles.get(theoryKey).toString();
            assertNotNull(theoryContent, "Theory content is null");
            assertTrue(theoryContent.contains("theory SimpleArmSerial_EQUATIONS"),
                "Theory header missing expected name");

            // Equations mode always uses the ISAVodes / Hybrid-Verification format.
            assertTrue(theoryContent.contains("Hybrid-Verification.Hybrid_Verification"),
                "Theory should import Hybrid-Verification for ISAVodes support");
            assertTrue(theoryContent.contains("dataspace"),
                "Theory should contain dataspace block for ISAVodes format");
            assertTrue(theoryContent.contains("variables"),
                "Theory should contain variables section in dataspace");

            // Persist artefact for manual inspection
            Path outputDir = isabelleRoot().resolve("temp");
            Files.createDirectories(outputDir);
            String fileName = theoryKey.replace('\\', '/');
            int slashIdx = fileName.lastIndexOf('/');
            if (slashIdx >= 0) {
                fileName = fileName.substring(slashIdx + 1);
            }
            Path theoryFile = outputDir.resolve(fileName);
            Files.writeString(theoryFile, theoryContent);
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
