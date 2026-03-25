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

import circus.robocalc.robosim.physmod.generator.sourceCodeGen.isabelle.SolutionToIsabelleGenerator;
import circus.robocalc.robosim.physmod.generator.sourceCodeGen.tests.SlnDFInjectorProvider;
import circus.robocalc.robosim.physmod.generator.sourceCodeGen.tests.SlnRefInjectorProvider;
import circus.robocalc.robosim.physmod.slnDF.slnDF.Solution;
import circus.robocalc.robosim.physmod.slnRef.slnRef.SlnRefs;

@ExtendWith(InjectionExtension.class)
@InjectWith(SlnRefInjectorProvider.class)
public class TestIsabelle_Acrobot_WithProof {

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
        Path local = Paths.get("").toAbsolutePath()
            .resolve("tests")
            .resolve("integrationTests")
            .resolve("RobotExamples")
            .resolve("acrobot")
            .resolve("SKO_proof");
        if (Files.exists(local)) {
            return local;
        }
        Path fromTestdata = resolveTestdataPath("RobotExamples/Acrobot/SKO_proof");
        if (fromTestdata != null) {
            return fromTestdata;
        }
        return local;
    }

    private Path tempOutputRoot() {
        try {
            return Files.createTempDirectory("TestIsabelle_Acrobot");
        } catch (java.io.IOException e) {
            throw new RuntimeException("Failed to create temp directory", e);
        }
    }

    private Path resolveTestdataPath(String relativePath) {
        Path cwd = Paths.get("").toAbsolutePath();
        String testdataRel = "physmod-testdata/circus.robocalc.robosim.physmod.testdata/testdata/integration/T5/" + relativePath;
        for (Path base : java.util.List.of(cwd, cwd.resolve(".."), cwd.resolve("../.."), cwd.resolve("../../.."))) {
            Path candidate = base.resolve(testdataRel);
            if (Files.exists(candidate)) {
                return candidate.normalize();
            }
        }
        return null;
    }

    @Test
    public void testIsabelleWithProofBlock_Acrobot() throws Exception {
        Path inputPath = testRoot().resolve("input").resolve("acrobot_WithProof.slnRef");
        assertTrue(Files.exists(inputPath), "Missing proof input: " + inputPath);

        String slnRefText = Files.readString(inputPath);
        SlnRefs slnRefs = slnRefParseHelper.parse(slnRefText);
        assertNotNull(slnRefs, "Failed to parse SlnRefs with proof block");
        assertTrue(slnRefs.eResource().getErrors().isEmpty(),
            "Parsing errors: " + slnRefs.eResource().getErrors());

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

            String originalMethod = proofSlnRef.getMethod();
            String methodName = originalMethod;
            if (originalMethod != null && originalMethod.contains("::")) {
                String[] parts = originalMethod.split("::");
                if (parts.length == 2) {
                    methodName = parts[1];
                }
            }
            proofSlnRef.setMethod(methodName);

            String solutionDSL = circus.robocalc.robosim.physmod.libs.sourceCodeGen.solutionLib.SolutionLib.returnSolution(
                circus.robocalc.robosim.physmod.libs.sourceCodeGen.solutionLib.Formulation.SKO,
                proofSlnRef);

            proofSlnRef.setMethod(originalMethod);

            assertNotNull(solutionDSL, "Generated Solution DSL from proof is null");
            assertFalse(solutionDSL.trim().isEmpty(), "Generated Solution DSL from proof is empty");

            Path outputDir = tempOutputRoot();
            Files.createDirectories(outputDir);
            Path slnFile = outputDir.resolve("proof_solution.sln");
            Files.writeString(slnFile, solutionDSL);

            Solution solution = getSolutionDSLParseHelper().parse(solutionDSL);
            assertNotNull(solution, "Generated Solution DSL failed to parse");
            assertTrue(solution.eResource().getErrors().isEmpty(),
                "Solution DSL parse errors: " + solution.eResource().getErrors());

            assertNotNull(solution.getProof(), "Solution should have a proof block");
            assertFalse(solution.getProof().getExpressions().isEmpty(), "Proof block should contain expressions");

            SolutionToIsabelleGenerator isabelleGen = new SolutionToIsabelleGenerator("equations");
            InMemoryFileSystemAccess fsa = new InMemoryFileSystemAccess();
            isabelleGen.generate(solution, solutionDSL, fsa);

            var generatedFiles = fsa.getAllFiles();
            assertFalse(generatedFiles.isEmpty(), "No Isabelle files generated");

            String theoryKey = generatedFiles.keySet().stream()
                .filter(k -> k.endsWith("_EQUATIONS.thy"))
                .findFirst()
                .orElseThrow(() -> new AssertionError("Missing _EQUATIONS.thy output"));

            String theoryContent = generatedFiles.get(theoryKey).toString();
            assertNotNull(theoryContent, "Theory content is null");

            assertTrue(theoryContent.contains("theory Proof_solution_EQUATIONS") ||
                       theoryContent.contains("theory Physics_EQUATIONS"),
                "Theory header missing expected name");

            assertTrue(theoryContent.contains("Hybrid-Verification.Hybrid_Verification"),
                "Theory should import Hybrid-Verification for ISAVodes support");

            assertTrue(theoryContent.contains("dataspace"),
                "Theory should contain dataspace block for ISAVodes format");

            assertTrue(theoryContent.contains("variables"),
                "Theory should contain variables section in dataspace");

            // Persist the Isabelle theory output for manual inspection
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

            System.out.println("Generated Isabelle theory written to: " + theoryFile);

        } finally {
            if (oldFormat == null) System.clearProperty("physmod.output.format");
            else System.setProperty("physmod.output.format", oldFormat);
            if (oldMode == null) System.clearProperty("physmod.isabelle.mode");
            else System.setProperty("physmod.isabelle.mode", oldMode);
        }
    }
}


