package circus.robocalc.robosim.physmod.generator.sourceCodeGen.tests;

import static org.junit.jupiter.api.Assertions.*;

import java.nio.charset.StandardCharsets;
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
import circus.robocalc.robosim.physmod.libs.sourceCodeGen.solutionLib.Formulation;
import circus.robocalc.robosim.physmod.libs.sourceCodeGen.solutionLib.SolutionLib;
import circus.robocalc.robosim.physmod.slnDF.slnDF.Solution;
import circus.robocalc.robosim.physmod.slnRef.slnRef.SlnRefs;

@ExtendWith(InjectionExtension.class)
@InjectWith(SlnRefInjectorProvider.class)
public class TestIsabelle_MobileRobot_WithProof {

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

    private Path proofInputPath() {
        return repoRoot()
            .resolve(Paths.get("Examples", "IsabelleProofs", "MobileRobot", "MobileRobot_WithProof.slnRef"));
    }

    @Test
    public void testIsabelleWithProofBlock_MobileRobot() throws Exception {
        Path inputPath = proofInputPath();
        assertTrue(Files.exists(inputPath), "Missing MobileRobot proof slnRef: " + inputPath);

        String slnRefText = Files.readString(inputPath);
        SlnRefs slnRefs = slnRefParseHelper.parse(slnRefText);
        assertNotNull(slnRefs, "Failed to parse MobileRobot proof slnRef");
        assertTrue(slnRefs.eResource().getErrors().isEmpty(),
            "Parsing errors: " + slnRefs.eResource().getErrors());

        var proofSlnRef = slnRefs.getSolutionRefs().stream()
            .filter(ref -> {
                String method = ref.getMethod();
                return method != null && (method.equalsIgnoreCase("proof") || method.equalsIgnoreCase("SKO::proof"));
            })
            .findFirst()
            .orElseThrow(() -> new AssertionError("No proof SlnRef found in input"));

        String originalMethod = proofSlnRef.getMethod();
        String methodName = originalMethod;
        if (originalMethod != null && originalMethod.contains("::")) {
            String[] parts = originalMethod.split("::");
            if (parts.length == 2) {
                methodName = parts[1];
            }
        }
        proofSlnRef.setMethod(methodName);

        String solutionDSL = SolutionLib.returnSolution(Formulation.SKO, proofSlnRef);

        proofSlnRef.setMethod(originalMethod);
        assertNotNull(solutionDSL, "Generated Solution DSL from proof is null");
        assertFalse(solutionDSL.trim().isEmpty(), "Generated Solution DSL from proof is empty");

        String renamedSolution = solutionDSL.replaceFirst("Solution\\s+[^\\s\\{]+\\s*\\{", "Solution MobileRobot {");
        renamedSolution = renamedSolution.replace("= seq();", "= <>;");
        Path outputDir = repoRoot().resolve(Paths.get("Examples", "IsabelleProofs", "MobileRobot"));
        Files.createDirectories(outputDir);
        Files.writeString(outputDir.resolve("MobileRobot_proof_solution.sln"),
            renamedSolution, StandardCharsets.UTF_8);
        Solution solution = getSolutionDSLParseHelper().parse(renamedSolution);
        assertNotNull(solution, "Generated Solution DSL failed to parse");
        assertTrue(solution.eResource().getErrors().isEmpty(),
            "Solution DSL parse errors: " + solution.eResource().getErrors());

        assertNotNull(solution.getProof(), "Solution should have a proof block");
        assertFalse(solution.getProof().getExpressions().isEmpty(), "Proof block should contain expressions");

        SolutionToIsabelleGenerator isabelleGen = new SolutionToIsabelleGenerator("equations");
        InMemoryFileSystemAccess fsa = new InMemoryFileSystemAccess();
        isabelleGen.generate(solution, renamedSolution, fsa);

        String theoryKey = fsa.getAllFiles().keySet().stream()
            .filter(k -> k.endsWith("_EQUATIONS.thy"))
            .findFirst()
            .orElseThrow(() -> new AssertionError("Missing _EQUATIONS.thy output"));

        String theoryContent = fsa.getAllFiles().get(theoryKey).toString();
        assertNotNull(theoryContent, "Theory content is null");
        assertTrue(theoryContent.contains("theory MobileRobot_EQUATIONS"),
            "Theory header missing expected name");

        Path theoryFile = outputDir.resolve("MobileRobot_EQUATIONS.thy");
        Files.writeString(theoryFile, theoryContent, StandardCharsets.UTF_8);
    }

    private static Path repoRoot() {
        return Paths.get("").toAbsolutePath().resolve("..").resolve("..").normalize();
    }
}
