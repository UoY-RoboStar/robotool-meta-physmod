# T3 eqnComp integration test method index

[Back to T3 integration README](README.md)

Each method listed here maps to the data directory it uses. Data directories contain the input/ and expected/ subfolders used by the tests.

| Test class | Test method | Data directory |
| --- | --- | --- |
| [SimpleArmSKOTest] | testSKOGenerator | [SKO/](SKO/) |
| [SimpleArmLibRefsTest] | testSKOGenerator_LibRefs | [RobotExamples/SimpleArm/SKO/](RobotExamples/SimpleArm/SKO/) |
| [AcrobotSKOTest] | testSKOGenerator_Acrobot | [RobotExamples/acrobot/SKO/](RobotExamples/acrobot/SKO/) |
| [AcrobotCGATest] | testCGAGenerator_Acrobot | [RobotExamples/acrobot/CGA/](RobotExamples/acrobot/CGA/) |
| [AcrobotFeatherstoneTest] | testFeatherstoneGenerator_Acrobot | [RobotExamples/acrobot/Featherstone/](RobotExamples/acrobot/Featherstone/) |
| [AcrobotFeatherstoneTest] | testFeatherstoneFormulationDetection | [RobotExamples/acrobot/Featherstone/](RobotExamples/acrobot/Featherstone/) |
| [AcrobotControlledTest] | testSKOGenerator_AcrobotWithControlledMotor | [RobotExamples/acrobot_controlled/SKO/](RobotExamples/acrobot_controlled/SKO/) |
| [MobileRobotSKOTest] | testSKOGenerator_TurtlebotMesh | [RobotExamples/MobileRobot/SKO/](RobotExamples/MobileRobot/SKO/) |
| [ClosedChainSKOTest] | testClosedChainTopologyDetection | [ClosedChain/SKO/](ClosedChain/SKO/) |
| [ClosedChainSKOTest] | testClosedChainFormulationDetection | [ClosedChain/SKO/](ClosedChain/SKO/) |
| [ClosedChainSKOTest] | testClosedChainSKOGenerator | [ClosedChain/SKO/](ClosedChain/SKO/) |
| [MetamodelCoverageGeneratorTest] | generateDefaultModels | [metamodelCoverage/Default/](metamodelCoverage/Default/) |
| [MetamodelCoverageSKOGeneratorTest] | generateSKOModels | [metamodelCoverage/SKO/](metamodelCoverage/SKO/) |

<!-- Integration test source files -->
[SimpleArmSKOTest]: ../../../../../physmod-eqnComp/circus.robocalc.robosim.physmod.generator.eqnComp.tests/src/circus/robocalc/robosim/physmod/generator/eqnComp/tests/integrationTests/RobotExamples/SimpleArm/SimpleArmSKOTest.java
[SimpleArmLibRefsTest]: ../../../../../physmod-eqnComp/circus.robocalc.robosim.physmod.generator.eqnComp.tests/src/circus/robocalc/robosim/physmod/generator/eqnComp/tests/integrationTests/RobotExamples/SimpleArm/SimpleArmLibRefsTest.java
[AcrobotSKOTest]: ../../../../../physmod-eqnComp/circus.robocalc.robosim.physmod.generator.eqnComp.tests/src/circus/robocalc/robosim/physmod/generator/eqnComp/tests/integrationTests/RobotExamples/acrobot/AcrobotSKOTest.java
[AcrobotCGATest]: ../../../../../physmod-eqnComp/circus.robocalc.robosim.physmod.generator.eqnComp.tests/src/circus/robocalc/robosim/physmod/generator/eqnComp/tests/integrationTests/RobotExamples/acrobot/AcrobotCGATest.java
[AcrobotFeatherstoneTest]: ../../../../../physmod-eqnComp/circus.robocalc.robosim.physmod.generator.eqnComp.tests/src/circus/robocalc/robosim/physmod/generator/eqnComp/tests/integrationTests/RobotExamples/acrobot/AcrobotFeatherstoneTest.java
[AcrobotControlledTest]: ../../../../../physmod-eqnComp/circus.robocalc.robosim.physmod.generator.eqnComp.tests/src/circus/robocalc/robosim/physmod/generator/eqnComp/tests/integrationTests/RobotExamples/acrobot_controlled/AcrobotControlledTest.java
[MobileRobotSKOTest]: ../../../../../physmod-eqnComp/circus.robocalc.robosim.physmod.generator.eqnComp.tests/src/circus/robocalc/robosim/physmod/generator/eqnComp/tests/integrationTests/RobotExamples/MobileRobot/MobileRobotSKOTest.java
[ClosedChainSKOTest]: ../../../../../physmod-eqnComp/circus.robocalc.robosim.physmod.generator.eqnComp.tests/src/circus/robocalc/robosim/physmod/generator/eqnComp/tests/integrationTests/RobotExamples/ClosedChain/ClosedChainSKOTest.java
[MetamodelCoverageGeneratorTest]: ../../../../../physmod-eqnComp/circus.robocalc.robosim.physmod.generator.eqnComp.tests/src/circus/robocalc/robosim/physmod/generator/eqnComp/tests/integrationTests/metamodelCoverage/MetamodelCoverageGeneratorTest.java
[MetamodelCoverageSKOGeneratorTest]: ../../../../../physmod-eqnComp/circus.robocalc.robosim.physmod.generator.eqnComp.tests/src/circus/robocalc/robosim/physmod/generator/eqnComp/tests/integrationTests/metamodelCoverage/MetamodelCoverageSKOGeneratorTest.java
