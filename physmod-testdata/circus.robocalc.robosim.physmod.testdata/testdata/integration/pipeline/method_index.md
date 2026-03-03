# Pipeline test method index

[Back to Pipeline README](README.md)

Each method listed here maps to the data directory it uses. Pipeline tests exercise the full T3→T4→T5 chain end-to-end.

| Test class | Test method | Data directory |
| --- | --- | --- |
| [SKO_PipelineIntegrationTest] | integratedTrajectoryMatchesBaseline | `pipeline/SKO/` |
| [SKO_PipelineIntegrationTest_LibRefs] | testSKOPipeline_EndToEnd_LibRefs | `pipeline/SKO/` |
| [RobotExamples_Acrobot_PipelineTest] | acrobotFullSimulationPipeline | `pipeline/RobotExamples/acrobot/` |
| [RobotExamples_Acrobot_FEATHERSTONE_PipelineTest] | acrobotFeatherstoneFullSimulationPipeline | `pipeline/RobotExamples/acrobot/` |
| [RobotExamples_Acrobot_CGA_PipelineTest] | acrobotCgaFullSimulationPipeline | `pipeline/RobotExamples/acrobot/` |
| [AcrobotControlled_PipelineIntegrationTest] | measureGeneratorTimings | `pipeline/AcrobotControlled/` |
| [AcrobotControlled_PipelineIntegrationTest] | integratedTrajectoryMatchesBaseline | `pipeline/AcrobotControlled/` |
| [AcrobotControlled_MappingPipelineIntegrationTest] | mappingPipelineT4ToT5 | `pipeline/AcrobotControlled/Mapping/` |
| [SKOVis_PipelineIntegrationTest] | integratedTrajectoryMatchesBaseline | `pipeline/visualisation/SKOVis/` |
| [FourBarClosedChainPipelineTest] | fourBarClosedChainPipelineGeneratesSolutions | `pipeline/ClosedChain/FourBar/` |
| [MobileRobot_MappingPipelineIntegrationTest] | runMappingPipeline | `pipeline/MobileRobot/Mapping/` |
| [MobileRobot_IsabelleProofGenerationTest] | generateMobileRobotProof | `pipeline/MobileRobot/IsabelleProof/` |
| [AcrobotSerial20PipelineGenerateTest] | generateAcrobotSerial20Pipeline | `Examples/Benchmarking/` (external) |

[SKO_PipelineIntegrationTest]: ../../../../IntegrationTests/circus.robocalc.robosim.physmod.generator.pipeline.tests/src/circus/robocalc/robosim/physmod/generator/pipeline/tests/integrationTests/SKO/SKO_PipelineIntegrationTest.java
[SKO_PipelineIntegrationTest_LibRefs]: ../../../../IntegrationTests/circus.robocalc.robosim.physmod.generator.pipeline.tests/src/circus/robocalc/robosim/physmod/generator/pipeline/tests/integrationTests/SKO/SKO_PipelineIntegrationTest_LibRefs.java
[RobotExamples_Acrobot_PipelineTest]: ../../../../IntegrationTests/circus.robocalc.robosim.physmod.generator.pipeline.tests/src/circus/robocalc/robosim/physmod/generator/pipeline/tests/integrationTests/RobotExamples/RobotExamples_Acrobot_PipelineTest.java
[RobotExamples_Acrobot_FEATHERSTONE_PipelineTest]: ../../../../IntegrationTests/circus.robocalc.robosim.physmod.generator.pipeline.tests/src/circus/robocalc/robosim/physmod/generator/pipeline/tests/integrationTests/RobotExamples/RobotExamples_Acrobot_FEATHERSTONE_PipelineTest.java
[RobotExamples_Acrobot_CGA_PipelineTest]: ../../../../IntegrationTests/circus.robocalc.robosim.physmod.generator.pipeline.tests/src/circus/robocalc/robosim/physmod/generator/pipeline/tests/integrationTests/RobotExamples/RobotExamples_Acrobot_CGA_PipelineTest.java
[AcrobotControlled_PipelineIntegrationTest]: ../../../../IntegrationTests/circus.robocalc.robosim.physmod.generator.pipeline.tests/src/circus/robocalc/robosim/physmod/generator/pipeline/tests/integrationTests/AcrobotControlled/AcrobotControlled_PipelineIntegrationTest.java
[AcrobotControlled_MappingPipelineIntegrationTest]: ../../../../IntegrationTests/circus.robocalc.robosim.physmod.generator.pipeline.tests/src/circus/robocalc/robosim/physmod/generator/pipeline/tests/integrationTests/AcrobotControlled/AcrobotControlled_MappingPipelineIntegrationTest.java
[SKOVis_PipelineIntegrationTest]: ../../../../IntegrationTests/circus.robocalc.robosim.physmod.generator.pipeline.tests/src/circus/robocalc/robosim/physmod/generator/pipeline/tests/integrationTests/visualisation/SKOVis/SKOVis_PipelineIntegrationTest.java
[FourBarClosedChainPipelineTest]: ../../../../IntegrationTests/circus.robocalc.robosim.physmod.generator.pipeline.tests/src/circus/robocalc/robosim/physmod/generator/pipeline/tests/integrationTests/RobotExamples/ClosedChain/FourBarClosedChainPipelineTest.java
[MobileRobot_MappingPipelineIntegrationTest]: ../../../../IntegrationTests/circus.robocalc.robosim.physmod.generator.pipeline.tests/src/circus/robocalc/robosim/physmod/generator/pipeline/tests/integrationTests/MobileRobot/MobileRobot_MappingPipelineIntegrationTest.java
[MobileRobot_IsabelleProofGenerationTest]: ../../../../IntegrationTests/circus.robocalc.robosim.physmod.generator.pipeline.tests/src/circus/robocalc/robosim/physmod/generator/pipeline/tests/integrationTests/MobileRobot/MobileRobot_IsabelleProofGenerationTest.java
[AcrobotSerial20PipelineGenerateTest]: ../../../../IntegrationTests/circus.robocalc.robosim.physmod.generator.pipeline.tests/src/circus/robocalc/robosim/physmod/generator/pipeline/tests/integrationTests/Benchmarking/AcrobotSerial20PipelineGenerateTest.java
