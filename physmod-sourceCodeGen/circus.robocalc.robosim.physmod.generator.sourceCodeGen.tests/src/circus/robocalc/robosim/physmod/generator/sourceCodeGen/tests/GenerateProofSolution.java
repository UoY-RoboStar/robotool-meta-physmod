package circus.robocalc.robosim.physmod.generator.sourceCodeGen.tests;

import java.nio.file.Files;

import org.eclipse.xtext.testing.InjectWith;
import org.eclipse.xtext.testing.extensions.InjectionExtension;
import org.eclipse.xtext.testing.util.ParseHelper;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;

import com.google.inject.Inject;

import circus.robocalc.robosim.physmod.libs.sourceCodeGen.solutionLib.Formulation;
import circus.robocalc.robosim.physmod.libs.sourceCodeGen.solutionLib.SolutionLib;
import circus.robocalc.robosim.physmod.slnRef.slnRef.SlnRefs;
import circus.robocalc.robosim.physmod.testdata.TestData;

/** Generates the proof solution from the Simple Arm's proof input and compares it with the expected file. */
@ExtendWith(InjectionExtension.class)
@InjectWith(SlnRefInjectorProvider.class)
public class GenerateProofSolution {

    private static final String INPUT = "integration/T5/SKO_proof/input/SimpleArmSerial_WithProof.slnRef";
    private static final String EXPECTED = "integration/T5/SKO_proof/expected/proof_solution.sln";

    @Inject
    private ParseHelper<SlnRefs> slnRefParseHelper;

    @Test
    public void testExpectedOutputIsValid() {
        InputCheck.valid(TestData.path(EXPECTED));
    }

    @Test
    @org.junit.jupiter.api.Tag("generator-backlog")
    public void generateProofSolutionDSL() throws Exception {
        SlnRefs slnRefs = slnRefParseHelper.parse(Files.readString(InputCheck.valid(TestData.path(INPUT))));
        var proof = slnRefs.getSolutionRefs().stream()
            .filter(ref -> "SKO::proof".equals(ref.getMethod()))
            .findFirst()
            .orElseThrow(() -> new AssertionError("No proof block in " + INPUT));

        // The library looks a method up by its name without the formulation, as the generator's entry point does.
        proof.setMethod("proof");
        String solution = SolutionLib.returnSolution(Formulation.SKO, proof);

        TestData.assertMatchesExpected(EXPECTED, solution);
    }
}
