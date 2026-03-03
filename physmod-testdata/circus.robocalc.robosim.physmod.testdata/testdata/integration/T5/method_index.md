# T5 sourceCodeGen test method index

[Back to T5 integration README](README.md)

Each method listed here maps to the data directory it uses. Data directories contain the input/, expected/, and manual/ subfolders used by the tests.

## Unit tests

| Test class | Test method | Data directory |
| --- | --- | --- |
| [SolutionToCppGeneratorTest] | testSimpleFunctionGeneration | [SKO/default/](SKO/default/) |
| [SolutionToCppGeneratorTest] | testCustomStructs | [SKO/default/](SKO/default/) |
| [SolutionToCppGeneratorTest] | testFunctionLoopsAndConditionals | [SKO/default/](SKO/default/) |
| [SolutionToCppGeneratorTest] | testFunctionMatrixOperations | [SKO/default/](SKO/default/) |
| [SolutionToCppGeneratorTest] | testProcedureParameterModes | [SKO/default/](SKO/default/) |
| [SolutionToCppGeneratorTest] | testProcedureSubmatrixOperations | [SKO/default/](SKO/default/) |
| [SolutionToCppGeneratorTest] | testForLoops | [SKO/default/](SKO/default/) |
| [SolutionToCppGeneratorTest] | testIfThenElse | [SKO/default/](SKO/default/) |
| [SolutionToCppGeneratorTest] | testAssignments | [SKO/default/](SKO/default/) |
| [SolutionToCppGeneratorTest] | testArithmeticExpressions | [SKO/default/](SKO/default/) |
| [SolutionToCppGeneratorTest] | testDataStructureExpressions | [SKO/default/](SKO/default/) |
| [SolutionToCppGeneratorTest] | testAllGeneratedCodeCompiles | [SKO/default/](SKO/default/) |

## Integration tests

| Test class | Test method | Data directory |
| --- | --- | --- |
| [TestSKO_T5FullSimulation] | testFullSimulation | [SKO/fullSimulation/](SKO/fullSimulation/) |
| [TestSKO_T5FullSimulation_Visualisation] | testFullSimulationWithVisualisation | [SKO/fullSimulation_visualisation/](SKO/fullSimulation_visualisation/) |
| [TestSKO_T5Standalone] | testStandaloneModeWithTrajectory | [SKO/standalone/](SKO/standalone/) |
| [TestSKO_T5Standalone_Visualisation] | testStandaloneVisualisationMode | [SKO/standalone_visualisation/](SKO/standalone_visualisation/) |
| [TestSKO_T5Latex] | testLatexGeneration | [SKO/latex/](SKO/latex/) |
| [TestSKO_Acrobot_Latex] | testAcrobotLatexGeneration | [RobotExamples/Acrobot/SKO/](RobotExamples/Acrobot/SKO/) |
| [TestIsabelle_T5Equations] | testIsabelleEquationsGeneration | [SKO/integrated/](SKO/integrated/) |
| [TestIsabelle_SKO_WithProof] | testIsabelleWithProofBlock | [SKO_proof/](SKO_proof/) |
| [TestIsabelle_AcrobotControlled_RegularProof] | testIsabelleEquationsFromRegularSolution_AcrobotControlled | [AcrobotControlled/SKO/](AcrobotControlled/SKO/) |
| [TestAcrobot_CGA] | testCGAFormulation | [Acrobot/CGA/](Acrobot/CGA/) |
| [TestAcrobot_T5Standalone_Visualisation] | testStandaloneVisualisationMode | [Acrobot/SKO/standalone_visualisation/](Acrobot/SKO/standalone_visualisation/) |
| [TestAcrobot_T5FullSimulation_Visualisation] | testFullSimulationWithVisualisation | [RobotExamples/Acrobot/SKO/fullSimulation_visualisation/](RobotExamples/Acrobot/SKO/fullSimulation_visualisation/) |
| [TestAcrobotControlled_T5FullSimulation_Visualisation] | testFullSimulationWithVisualisation | [AcrobotControlled/SKO/FullSimulation_Visualisation/](AcrobotControlled/SKO/FullSimulation_Visualisation/) |
| [TestSimpleArm_T5Standalone_Visualisation] | testStandaloneVisualisationMode | [RobotExamples/SimpleArm/SKO/](RobotExamples/SimpleArm/SKO/) |
| [FourBarClosedChainSourceCodeGenTest] | testClosedChainSlnRefGeneratesSolutionDsl | [ClosedChain/SKO/](ClosedChain/SKO/) |
| [FourBarClosedChainStandaloneVisualisationTest] | testStandaloneVisualisationMode | [ClosedChain/SKO/standalone_visualisation/](ClosedChain/SKO/standalone_visualisation/) |

<!-- Test source files -->
[SolutionToCppGeneratorTest]: ../../../../../physmod-sourceCodeGen/circus.robocalc.robosim.physmod.generator.sourceCodeGen.tests/src/circus/robocalc/robosim/physmod/generator/sourceCodeGen/tests/SolutionToCppGeneratorTest.java
[TestSKO_T5FullSimulation]: ../../../../../physmod-sourceCodeGen/circus.robocalc.robosim.physmod.generator.sourceCodeGen.tests/src/circus/robocalc/robosim/physmod/generator/sourceCodeGen/tests/TestSKO_T5FullSimulation.java
[TestSKO_T5FullSimulation_Visualisation]: ../../../../../physmod-sourceCodeGen/circus.robocalc.robosim.physmod.generator.sourceCodeGen.tests/src/circus/robocalc/robosim/physmod/generator/sourceCodeGen/tests/TestSKO_T5FullSimulation_Visualisation.java
[TestSKO_T5Standalone]: ../../../../../physmod-sourceCodeGen/circus.robocalc.robosim.physmod.generator.sourceCodeGen.tests/src/circus/robocalc/robosim/physmod/generator/sourceCodeGen/tests/TestSKO_T5Standalone.java
[TestSKO_T5Standalone_Visualisation]: ../../../../../physmod-sourceCodeGen/circus.robocalc.robosim.physmod.generator.sourceCodeGen.tests/src/circus/robocalc/robosim/physmod/generator/sourceCodeGen/tests/TestSKO_T5Standalone_Visualisation.java
[TestSKO_T5Latex]: ../../../../../physmod-sourceCodeGen/circus.robocalc.robosim.physmod.generator.sourceCodeGen.tests/src/circus/robocalc/robosim/physmod/generator/sourceCodeGen/tests/TestSKO_T5Latex.java
[TestSKO_Acrobot_Latex]: ../../../../../physmod-sourceCodeGen/circus.robocalc.robosim.physmod.generator.sourceCodeGen.tests/src/circus/robocalc/robosim/physmod/generator/sourceCodeGen/tests/TestSKO_Acrobot_Latex.java
[TestIsabelle_T5Equations]: ../../../../../physmod-sourceCodeGen/circus.robocalc.robosim.physmod.generator.sourceCodeGen.tests/src/circus/robocalc/robosim/physmod/generator/sourceCodeGen/tests/TestIsabelle_T5Equations.java
[TestIsabelle_SKO_WithProof]: ../../../../../physmod-sourceCodeGen/circus.robocalc.robosim.physmod.generator.sourceCodeGen.tests/src/circus/robocalc/robosim/physmod/generator/sourceCodeGen/tests/TestIsabelle_SKO_WithProof.java
[TestIsabelle_AcrobotControlled_RegularProof]: ../../../../../physmod-sourceCodeGen/circus.robocalc.robosim.physmod.generator.sourceCodeGen.tests/src/circus/robocalc/robosim/physmod/generator/sourceCodeGen/tests/TestIsabelle_AcrobotControlled_RegularProof.java
[TestAcrobot_CGA]: ../../../../../physmod-sourceCodeGen/circus.robocalc.robosim.physmod.generator.sourceCodeGen.tests/src/circus/robocalc/robosim/physmod/generator/sourceCodeGen/tests/RobotExamples/TestAcrobot_CGA.java
[TestAcrobot_T5Standalone_Visualisation]: ../../../../../physmod-sourceCodeGen/circus.robocalc.robosim.physmod.generator.sourceCodeGen.tests/src/circus/robocalc/robosim/physmod/generator/sourceCodeGen/tests/RobotExamples/TestAcrobot_T5Standalone_Visualisation.java
[TestAcrobot_T5FullSimulation_Visualisation]: ../../../../../physmod-sourceCodeGen/circus.robocalc.robosim.physmod.generator.sourceCodeGen.tests/src/circus/robocalc/robosim/physmod/generator/sourceCodeGen/tests/RobotExamples/TestAcrobot_T5FullSimulation_Visualisation.java
[TestAcrobotControlled_T5FullSimulation_Visualisation]: ../../../../../physmod-sourceCodeGen/circus.robocalc.robosim.physmod.generator.sourceCodeGen.tests/src/circus/robocalc/robosim/physmod/generator/sourceCodeGen/tests/RobotExamples/TestAcrobotControlled_T5FullSimulation_Visualisation.java
[TestSimpleArm_T5Standalone_Visualisation]: ../../../../../physmod-sourceCodeGen/circus.robocalc.robosim.physmod.generator.sourceCodeGen.tests/src/circus/robocalc/robosim/physmod/generator/sourceCodeGen/tests/RobotExamples/TestSimpleArm_T5Standalone_Visualisation.java
[FourBarClosedChainSourceCodeGenTest]: ../../../../../physmod-sourceCodeGen/circus.robocalc.robosim.physmod.generator.sourceCodeGen.tests/src/circus/robocalc/robosim/physmod/generator/sourceCodeGen/tests/RobotExamples/ClosedChain/FourBarClosedChainSourceCodeGenTest.java
[FourBarClosedChainStandaloneVisualisationTest]: ../../../../../physmod-sourceCodeGen/circus.robocalc.robosim.physmod.generator.sourceCodeGen.tests/src/circus/robocalc/robosim/physmod/generator/sourceCodeGen/tests/RobotExamples/ClosedChain/FourBarClosedChainStandaloneVisualisationTest.java
