# T4 guidedChoice integration test method index

[Back to T4 integration README](README.md)

Each method listed here maps to the data directory it uses. Data directories contain the input/ and expected/ subfolders used by the tests.

| Test class | Test method | Data directory |
| --- | --- | --- |
| [SKO_integrationTest] | testExpectedFileValidates | [SKO/](SKO/) |
| [SKO_integrationTest] | testT3ToT4Pipeline | [SKO/](SKO/) |
| [SKO_integrationTest] | testT3ToT4PipelineWithProof | [SKO_proof/](SKO_proof/) |
| [SKO_integrationTest] | testMinimal_SNameBindingIssue | Inline |
| [SKO_integrationTest_AcrobotFromT3] | testT3ToT4_AcrobotSerial | T3 eqnComp temp output |
| [SKO_integrationTest_LibRefs] | testT3ToT4Pipeline_LibRefs | [SKO/](SKO/) |
| [AcrobotControlledProofTest] | testT4ProofOutput_AcrobotControlled_ContainsBCtrl | [AcrobotControlled/SKO/FullSimulation_Visual_Proof/](AcrobotControlled/SKO/FullSimulation_Visual_Proof/) |
| [AcrobotControlledProofTest] | testT4_GeneralisedPosition_Solution | [AcrobotControlled/SKO/FullSimulation_Visual_Proof/](AcrobotControlled/SKO/FullSimulation_Visual_Proof/) |
| [AcrobotControlledProofTest] | testT4_PlatformMapping_Solution | [AcrobotControlled/SKO/FullSimulation_Visual_Proof/](AcrobotControlled/SKO/FullSimulation_Visual_Proof/) |
| [AcrobotControlledProofTest] | testT4_GenerateOutput_AcrobotControlled | [AcrobotControlled/SKO/FullSimulation_Visual_Proof/](AcrobotControlled/SKO/FullSimulation_Visual_Proof/) |
| [AcrobotControlledProofTest] | testT4_GenerateOutput_AcrobotControlled_WithProof | [AcrobotControlled/SKO/FullSimulation_Visual_Proof/](AcrobotControlled/SKO/FullSimulation_Visual_Proof/) |
| [AcrobotControlledProofTest] | testT4_CombinedSolutions_GeneralisedPosition_PlatformMapping_Proof | [AcrobotControlled/SKO/FullSimulation_Visual_Proof/](AcrobotControlled/SKO/FullSimulation_Visual_Proof/) |
| [AcrobotControlledMappingTest] | testLoadAcrobotControlledT3 | [AcrobotControlled/SKO/FullSimulation_Visualisation_Mapping/](AcrobotControlled/SKO/FullSimulation_Visualisation_Mapping/) |
| [AcrobotControlledMappingTest] | testMappingPmExists | [AcrobotControlled/SKO/FullSimulation_Visualisation_Mapping/](AcrobotControlled/SKO/FullSimulation_Visualisation_Mapping/) |
| [AcrobotControlledMappingTest] | testT4_PlatformMapping_Solution | [AcrobotControlled/SKO/FullSimulation_Visualisation_Mapping/](AcrobotControlled/SKO/FullSimulation_Visualisation_Mapping/) |
| [AcrobotControlledMappingTest] | testT4_GenerateOutput_AcrobotControlled_Mapping | [AcrobotControlled/SKO/FullSimulation_Visualisation_Mapping/](AcrobotControlled/SKO/FullSimulation_Visualisation_Mapping/) |
| [AcrobotControlledMappingTest] | testT4_CompareWithExpected | [AcrobotControlled/SKO/FullSimulation_Visualisation_Mapping/](AcrobotControlled/SKO/FullSimulation_Visualisation_Mapping/) |
| [MappingPMIntegrationTest] | testParseMappingPm_AcrobotControlled | [AcrobotControlled/SKO/FullSimulation_Visualisation_Mapping/](AcrobotControlled/SKO/FullSimulation_Visualisation_Mapping/) |
| [MappingPMIntegrationTest] | testExtractOperationMappings | [AcrobotControlled/SKO/FullSimulation_Visualisation_Mapping/](AcrobotControlled/SKO/FullSimulation_Visualisation_Mapping/) |
| [MappingPMIntegrationTest] | testExtractInputEventMappings | [AcrobotControlled/SKO/FullSimulation_Visualisation_Mapping/](AcrobotControlled/SKO/FullSimulation_Visualisation_Mapping/) |
| [MappingPMIntegrationTest] | testGetMissingMappingPMSolutions | [AcrobotControlled/SKO/FullSimulation_Visualisation_Mapping/](AcrobotControlled/SKO/FullSimulation_Visualisation_Mapping/) |
| [MappingPMIntegrationTest] | testAddMappingPMSolutions_AcrobotControlled | [AcrobotControlled/SKO/FullSimulation_Visualisation_Mapping/](AcrobotControlled/SKO/FullSimulation_Visualisation_Mapping/) |
| [MappingPMIntegrationTest] | testMappingPMOperation_ApplyTorque | [AcrobotControlled/SKO/FullSimulation_Visualisation_Mapping/](AcrobotControlled/SKO/FullSimulation_Visualisation_Mapping/) |
| [MappingPMIntegrationTest] | testMappingPMInputEvent_sensorUpdate | [AcrobotControlled/SKO/FullSimulation_Visualisation_Mapping/](AcrobotControlled/SKO/FullSimulation_Visualisation_Mapping/) |
| [MappingGeneratorTest] | testLoadAcrobotMappingPm | [Examples/RobotExamples/Acrobot_SKO_controlled/](../../../../../Examples/RobotExamples/Acrobot_SKO_controlled/) |
| [MappingGeneratorTest] | testGenerateMappingSlnRef | [Examples/RobotExamples/Acrobot_SKO_controlled/](../../../../../Examples/RobotExamples/Acrobot_SKO_controlled/) |
| [Vis_integrationTest] | test_Visual_Appended_SlnRef | [vis/](vis/) |
| [Vis_AlgebraicConstraints_Test] | test_Algebraic_Constraints_T_Eq_T | [vis/](vis/) |
| [ClosedChainSKOIntegrationTest] | testClosedChainGuidedChoice | [../T3/ClosedChain/SKO/](../T3/ClosedChain/SKO/) |
| [CGA_integrationTest_AcrobotFromT3] | testT3ToT4_AcrobotCGA | T3 eqnComp temp output |
| [FEATHERSTONE_integrationTest_AcrobotFromT3] | testT3ToT4_AcrobotFeatherstone | [../T3/RobotExamples/acrobot/Featherstone/](../T3/RobotExamples/acrobot/Featherstone/) |

<!-- Integration test source files -->
[SKO_integrationTest]: ../../../../../physmod-guidedChoice/circus.robocalc.robosim.physmod.generator.guidedChoice.tests/src/circus/robocalc/robosim/physmod/generator/guidedChoice/tests/integrationTests/SKO/SKO_integrationTest.java
[SKO_integrationTest_AcrobotFromT3]: ../../../../../physmod-guidedChoice/circus.robocalc.robosim.physmod.generator.guidedChoice.tests/src/circus/robocalc/robosim/physmod/generator/guidedChoice/tests/integrationTests/SKO/SKO_integrationTest_AcrobotFromT3.java
[SKO_integrationTest_LibRefs]: ../../../../../physmod-guidedChoice/circus.robocalc.robosim.physmod.generator.guidedChoice.tests/src/circus/robocalc/robosim/physmod/generator/guidedChoice/tests/integrationTests/SKO/SKO_integrationTest_LibRefs.java
[AcrobotControlledProofTest]: ../../../../../physmod-guidedChoice/circus.robocalc.robosim.physmod.generator.guidedChoice.tests/src/circus/robocalc/robosim/physmod/generator/guidedChoice/tests/integrationTests/SKO_proof/AcrobotControlledProofTest.java
[AcrobotControlledMappingTest]: ../../../../../physmod-guidedChoice/circus.robocalc.robosim.physmod.generator.guidedChoice.tests/src/circus/robocalc/robosim/physmod/generator/guidedChoice/tests/integrationTests/SKO_mapping/AcrobotControlledMappingTest.java
[MappingPMIntegrationTest]: ../../../../../physmod-guidedChoice/circus.robocalc.robosim.physmod.generator.guidedChoice.tests/src/circus/robocalc/robosim/physmod/generator/guidedChoice/tests/integrationTests/MappingPM/MappingPMIntegrationTest.java
[MappingGeneratorTest]: ../../../../../physmod-guidedChoice/circus.robocalc.robosim.physmod.generator.guidedChoice.tests/src/circus/robocalc/robosim/physmod/generator/guidedChoice/tests/integrationTests/MappingGeneratorTest.java
[Vis_integrationTest]: ../../../../../physmod-guidedChoice/circus.robocalc.robosim.physmod.generator.guidedChoice.tests/src/circus/robocalc/robosim/physmod/generator/guidedChoice/tests/integrationTests/vis/Vis_integrationTest.java
[Vis_AlgebraicConstraints_Test]: ../../../../../physmod-guidedChoice/circus.robocalc.robosim.physmod.generator.guidedChoice.tests/src/circus/robocalc/robosim/physmod/generator/guidedChoice/tests/integrationTests/vis/Vis_AlgebraicConstraints_Test.java
[ClosedChainSKOIntegrationTest]: ../../../../../physmod-guidedChoice/circus.robocalc.robosim.physmod.generator.guidedChoice.tests/src/circus/robocalc/robosim/physmod/generator/guidedChoice/tests/integrationTests/ClosedChain/ClosedChainSKOIntegrationTest.java
[CGA_integrationTest_AcrobotFromT3]: ../../../../../physmod-guidedChoice/circus.robocalc.robosim.physmod.generator.guidedChoice.tests/src/circus/robocalc/robosim/physmod/generator/guidedChoice/tests/integrationTests/CGA/CGA_integrationTest_AcrobotFromT3.java
[FEATHERSTONE_integrationTest_AcrobotFromT3]: ../../../../../physmod-guidedChoice/circus.robocalc.robosim.physmod.generator.guidedChoice.tests/src/circus/robocalc/robosim/physmod/generator/guidedChoice/tests/integrationTests/Featherstone/FEATHERSTONE_integrationTest_AcrobotFromT3.java
