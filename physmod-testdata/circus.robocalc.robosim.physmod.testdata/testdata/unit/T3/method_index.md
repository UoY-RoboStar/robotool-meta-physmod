# T3 eqnComp unit test method index

[Back to T3 unit README](README.md)

Each method listed here maps to the data directory it uses. Data directories contain the input/ and expected/ subfolders used by the tests.

| Test class | Test method | Data directory |
| --- | --- | --- |
| [AssignNumberingTest] | testTwoLinkSKO | [assignNumbering/](assignNumbering/) |
| [AssignNumberingTest] | testTwoLinkFeatherstone | [assignNumbering/](assignNumbering/) |
| [AssignNumberingTest] | testThreeLinkChainSKO | [assignNumbering/](assignNumbering/) |
| [AssignNumberingTest] | testThreeLinkChainFeatherstone | [assignNumbering/](assignNumbering/) |
| [AssignNumberingTest] | testTreeTopologySKO | [assignNumbering/](assignNumbering/) |
| [AssignNumberingTest] | testClosedChainSKO | [assignNumbering/](assignNumbering/) |
| [AssignNumberingTest] | testOrderedLinksBasic | [assignNumbering/orderPmodel/](assignNumbering/orderPmodel/) |
| [AssignNumberingTest] | testOrderedLinksFourLinks | [assignNumbering/orderPmodel/](assignNumbering/orderPmodel/) |
| [AssignNumberingTest] | testOrderedLinksSingleLink | [assignNumbering/orderPmodel/](assignNumbering/orderPmodel/) |
| [AssignNumberingTest] | testGetBaseLinkSerialChain | [assignNumbering/](assignNumbering/) |
| [AssignNumberingTest] | testGetBaseLinkThreeLinkChain | [assignNumbering/](assignNumbering/) |
| [AssignNumberingTest] | testGetBaseLinkTreeTopology | [assignNumbering/](assignNumbering/) |
| [AssignNumberingTest] | testGetBaseLinkClosedChain | [assignNumbering/](assignNumbering/) |
| [AssignNumberingTest] | testGetChildLinksSerialChain | [assignNumbering/](assignNumbering/) |
| [AssignNumberingTest] | testGetChildLinksLeafLink | [assignNumbering/](assignNumbering/) |
| [AssignNumberingTest] | testGetChildLinksTreeTopology | [assignNumbering/](assignNumbering/) |
| [AssignNumberingTest] | testGetChildLinksClosedChain | [assignNumbering/](assignNumbering/) |
| [CalculateEquationsTest] | testPhiEqnsN1 | [calculateEquations/generatePhiEquations/](calculateEquations/generatePhiEquations/) |
| [CalculateEquationsTest] | testPhiEqnsN2 | [calculateEquations/generatePhiEquations/](calculateEquations/generatePhiEquations/) |
| [CalculateEquationsTest] | testPhiEqnsN3 | [calculateEquations/generatePhiEquations/](calculateEquations/generatePhiEquations/) |
| [CalculateEquationsTest] | testPhiEqnsEdgeCases | [calculateEquations/generatePhiEquations/](calculateEquations/generatePhiEquations/) |
| [CalculateEquationsTest] | testCreateInertiaVariableWithMixedTypes | [calculateEquations/createInertiaVariable/](calculateEquations/createInertiaVariable/) |
| [CalculateEquationsTest] | testClassCastExceptionFix | [calculateEquations/createInertiaVariable/](calculateEquations/createInertiaVariable/) |
| [CalculateEquationsTest] | testCreateInertiaVariableWithRealData | [calculateEquations/createInertiaVariable/](calculateEquations/createInertiaVariable/) |
| [CalculateEquationsTest] | testCreateGeometryVariable | [calculateEquations/createGeometryVariable/](calculateEquations/createGeometryVariable/) |
| [CalculateEquationsTest] | testCreateGeometryVariableErrorHandling | [calculateEquations/createGeometryVariable/](calculateEquations/createGeometryVariable/) |
| [CalculateEquationsTest] | testFindSensorValidFQN | [calculateEquations/findSensorByFQN/](calculateEquations/findSensorByFQN/) |
| [CalculateEquationsTest] | testFindSensorDifferentLink | [calculateEquations/findSensorByFQN/](calculateEquations/findSensorByFQN/) |
| [CalculateEquationsTest] | testFindSensorInvalidFQN | [calculateEquations/findSensorByFQN/](calculateEquations/findSensorByFQN/) |
| [CalculateEquationsTest] | testFindSensorNonExistentLink | [calculateEquations/findSensorByFQN/](calculateEquations/findSensorByFQN/) |
| [CalculateEquationsTest] | testFindSensorNonExistentSensor | [calculateEquations/findSensorByFQN/](calculateEquations/findSensorByFQN/) |
| [CalculateEquationsTest] | testFindActuatorValidFQN | [calculateEquations/findActuatorByFQN/](calculateEquations/findActuatorByFQN/) |
| [CalculateEquationsTest] | testFindActuatorDifferentLink | [calculateEquations/findActuatorByFQN/](calculateEquations/findActuatorByFQN/) |
| [CalculateEquationsTest] | testFindActuatorInvalidFQN | [calculateEquations/findActuatorByFQN/](calculateEquations/findActuatorByFQN/) |
| [CalculateEquationsTest] | testFindActuatorNonExistentLink | [calculateEquations/findActuatorByFQN/](calculateEquations/findActuatorByFQN/) |
| [CalculateEquationsTest] | testFindActuatorNonExistentActuator | [calculateEquations/findActuatorByFQN/](calculateEquations/findActuatorByFQN/) |
| [CalculateEquationsTest] | testTrivialSensorHasEquation | [calculateEquations/sensorEquations/](calculateEquations/sensorEquations/) |
| [CalculateEquationsTest] | testMultipleSensors | [calculateEquations/sensorEquations/](calculateEquations/sensorEquations/) |
| [CalculateEquationsTest] | testNoSensors | [calculateEquations/sensorEquations/](calculateEquations/sensorEquations/) |
| [CalculateEquationsTest] | testTrivialActuatorHasEquation | [calculateEquations/actuatorEquations/](calculateEquations/actuatorEquations/) |
| [CalculateEquationsTest] | testMultipleActuators | [calculateEquations/actuatorEquations/](calculateEquations/actuatorEquations/) |
| [CalculateEquationsTest] | testNoActuators | [calculateEquations/actuatorEquations/](calculateEquations/actuatorEquations/) |
| [CalculateEquationsTest] | testFullPipelineWithSensorsActuatorsDynamics | [calculateEquations/calculateEquationsIntegration/](calculateEquations/calculateEquationsIntegration/) |
| [CalculateEquationsTest] | testDynamicsOnlyNoSensorsActuators | [calculateEquations/calculateEquationsIntegration/](calculateEquations/calculateEquationsIntegration/) |
| [CalculateEquationsTest] | testSensorsActuatorsOnlyNoDynamics | [calculateEquations/calculateEquationsIntegration/](calculateEquations/calculateEquationsIntegration/) |
| [CalculateFormulationsTest] | testMixedFormulations | [formulations/](formulations/) |
| [CalculateFormulationsTest] | testEmptyMaps | [formulations/](formulations/) |
| [CalculateFormulationsTest] | testSKOLocalJoint | [formulations/findDynamicsFormulation/](formulations/findDynamicsFormulation/) |
| [CalculateFormulationsTest] | testSKOReferenceJoint | [formulations/findDynamicsFormulation/](formulations/findDynamicsFormulation/) |
| [CalculateFormulationsTest] | testFeatherstoneLocalJoint | [formulations/findDynamicsFormulation/](formulations/findDynamicsFormulation/) |
| [CalculateFormulationsTest] | testFeatherstoneReferenceJoint | [formulations/findDynamicsFormulation/](formulations/findDynamicsFormulation/) |
| [CalculateFormulationsTest] | testTESTFormulation | [formulations/findDynamicsFormulation/](formulations/findDynamicsFormulation/) |
| [CalculateFormulationsTest] | testNoJoints | [formulations/findDynamicsFormulation/](formulations/findDynamicsFormulation/) |
| [CalculateFormulationsTest] | testTrivialSensor | [formulations/findSensorFormulations/](formulations/findSensorFormulations/) |
| [CalculateFormulationsTest] | testTrivialSensorLibraryImport | [formulations/findSensorFormulations/](formulations/findSensorFormulations/) |
| [CalculateFormulationsTest] | testUnknownSensor | [formulations/findSensorFormulations/](formulations/findSensorFormulations/) |
| [CalculateFormulationsTest] | testTrivialActuator | [formulations/findActuatorFormulations/](formulations/findActuatorFormulations/) |
| [CalculateFormulationsTest] | testTrivialActuatorLibraryImport | [formulations/findActuatorFormulations/](formulations/findActuatorFormulations/) |
| [CalculateFormulationsTest] | testUnknownActuator | [formulations/findActuatorFormulations/](formulations/findActuatorFormulations/) |
| [CalculateTopologyTest] | testSerialChainTwoLink | [calculateTopology/](calculateTopology/) |
| [CalculateTopologyTest] | testSerialChainThreeLink | [calculateTopology/](calculateTopology/) |
| [CalculateTopologyTest] | testTreeTopology | [calculateTopology/](calculateTopology/) |
| [CalculateTopologyTest] | testClosedChain | [calculateTopology/](calculateTopology/) |
| [EqnCompMainTest] | testEqnCompMainSKO | [eqnCompMain/](eqnCompMain/) |
| [EqnCompMainTest] | testEqnCompMainNullModel | [eqnCompMain/](eqnCompMain/) |
| [EqnCompUtilsTest] | testToFloatExpWithFloatExp | [eqnCompUtils/numericConversion/](eqnCompUtils/numericConversion/) |
| [EqnCompUtilsTest] | testToFloatExpWithIntegerExp | [eqnCompUtils/numericConversion/](eqnCompUtils/numericConversion/) |
| [EqnCompUtilsTest] | testGetNumericValueWithFloatExp | [eqnCompUtils/numericConversion/](eqnCompUtils/numericConversion/) |
| [EqnCompUtilsTest] | testGetNumericValueWithIntegerExp | [eqnCompUtils/numericConversion/](eqnCompUtils/numericConversion/) |
| [EqnCompUtilsTest] | testHelperFunctionErrorHandling | [eqnCompUtils/numericConversion/](eqnCompUtils/numericConversion/) |
| [EqnCompUtilsTest] | testSpecificClassCastExceptionScenario | [eqnCompUtils/numericConversion/](eqnCompUtils/numericConversion/) |
| [EqnCompUtilsTest] | testToFloatExpWithFloats | [eqnCompUtils/numericConversion/](eqnCompUtils/numericConversion/) |
| [EqnCompUtilsTest] | testToFloatExpWithIntegers | [eqnCompUtils/numericConversion/](eqnCompUtils/numericConversion/) |
| [EqnCompUtilsTest] | testGetNumericValueMixed | [eqnCompUtils/numericConversion/](eqnCompUtils/numericConversion/) |
| [GeneratorServicesTest] | testInitialization | [generatorServices/](generatorServices/) |
| [GeneratorServicesTest] | testServicesBuiltInTest | [generatorServices/](generatorServices/) |
| [GeneratorServicesTest] | testHeadlessCompatibility | [generatorServices/](generatorServices/) |
| [GeneratorServicesTest] | testCreateEquation | [generatorServices/](generatorServices/) |
| [GeneratorServicesTest] | testCreateConstraint | [generatorServices/](generatorServices/) |
| [GeneratorServicesTest] | testCreateRelation | [generatorServices/](generatorServices/) |
| [GeneratorServicesTest] | testCreateFlexiRelation | [generatorServices/](generatorServices/) |
| [GeneratorServicesTest] | testCreateConstant | [generatorServices/](generatorServices/) |
| [GeneratorServicesTest] | testReadVariable | [generatorServices/](generatorServices/) |
| [GeneratorServicesTest] | testInitializeVariable | [generatorServices/](generatorServices/) |
| [GeneratorServicesTest] | testReadPMExpression | [generatorServices/](generatorServices/) |
| [LocaliseRefsTest] | testConvertRefJoints | [localiseRefs/convertReferenceJointsToLocal/](localiseRefs/convertReferenceJointsToLocal/) |
| [LocaliseRefsTest] | testConvertSingleRefJoint | [localiseRefs/convertReferenceJointsToLocal/](localiseRefs/convertReferenceJointsToLocal/) |
| [LocaliseRefsTest] | testConvertMixedJoints | [localiseRefs/convertReferenceJointsToLocal/](localiseRefs/convertReferenceJointsToLocal/) |
| [LocaliseRefsTest] | testCreateLocalJoint | [localiseRefs/convertReferenceJointsToLocal/](localiseRefs/convertReferenceJointsToLocal/) |
| [LocaliseRefsTest] | testConvertReferenceJointsToLocalWithNoReferenceJoints | [localiseRefs/convertReferenceJointsToLocal/](localiseRefs/convertReferenceJointsToLocal/) |
| [LocaliseRefsTest] | testCreateLocalJointPreservesNestedActuators | [localiseRefs/convertReferenceJointsToLocal/](localiseRefs/convertReferenceJointsToLocal/) |
| [LocaliseRefsTest] | testCreateLocalJointPreservesNestedSensors | [localiseRefs/convertReferenceJointsToLocal/](localiseRefs/convertReferenceJointsToLocal/) |
| [LocaliseRefsTest] | testConvertRefLinks | [localiseRefs/convertReferenceLinksToLocal/](localiseRefs/convertReferenceLinksToLocal/) |
| [LocaliseRefsTest] | testConvertRefSensors | [localiseRefs/convertReferenceSensorsToLocal/](localiseRefs/convertReferenceSensorsToLocal/) |
| [LocaliseRefsTest] | testConvertRefSensorsJointScope | [localiseRefs/convertReferenceSensorsToLocal/](localiseRefs/convertReferenceSensorsToLocal/) |
| [LocaliseRefsTest] | testConvertRefActuators | [localiseRefs/convertReferenceActuatorsToLocal/](localiseRefs/convertReferenceActuatorsToLocal/) |
| [LocaliseRefsTest] | testConvertRefActuatorsLinkScope | [localiseRefs/convertReferenceActuatorsToLocal/](localiseRefs/convertReferenceActuatorsToLocal/) |
| [LocaliseRefsTest] | testConvertRefBodies | [localiseRefs/convertReferenceBodiesToLocal/](localiseRefs/convertReferenceBodiesToLocal/) |
| [PhysModTextualTest] | testSKORevoluteXImport | [physmodTextual/](physmodTextual/) |
| [PhysModTextualTest] | testSolutionBlockScoping | [physmodTextual/](physmodTextual/) |
| [PhysModTextualTest] | testSolutionQualifiedNamesDoNotCollideWithModelVars | [physmodTextual/](physmodTextual/) |
| [PhysModTextualTest] | testJointEquationAccess | [physmodTextual/](physmodTextual/) |
| [PhysModTextualTest] | testAnnotationTemplateDuplicates | [physmodTextual/](physmodTextual/) |
| [ValidateTest] | testValidPModel | [eqnCompValidator/](eqnCompValidator/) |
| [ValidateTest] | testValidFeatherstoneModel | [eqnCompValidator/](eqnCompValidator/) |
| [ValidateTest] | testMissingPose | [eqnCompValidator/](eqnCompValidator/) |
| [ValidateTest] | testMissingInertia | [eqnCompValidator/](eqnCompValidator/) |
| [ValidateTest] | testEmptyPModel | [eqnCompValidator/](eqnCompValidator/) |
| [ValidateTest] | testMixedValidity | [eqnCompValidator/](eqnCompValidator/) |
| [ValidateTest] | testNonSKO | [eqnCompValidator/](eqnCompValidator/) |

<!-- Unit test source files -->
[AssignNumberingTest]: ../../../../../physmod-eqnComp/circus.robocalc.robosim.physmod.generator.eqnComp.tests/src/circus/robocalc/robosim/physmod/generator/eqnComp/tests/unitTests/assignNumbering/AssignNumberingTest.java
[CalculateEquationsTest]: ../../../../../physmod-eqnComp/circus.robocalc.robosim.physmod.generator.eqnComp.tests/src/circus/robocalc/robosim/physmod/generator/eqnComp/tests/unitTests/calculateEquations/CalculateEquationsTest.java
[CalculateFormulationsTest]: ../../../../../physmod-eqnComp/circus.robocalc.robosim.physmod.generator.eqnComp.tests/src/circus/robocalc/robosim/physmod/generator/eqnComp/tests/unitTests/calculateFormulations/CalculateFormulationsTest.java
[CalculateTopologyTest]: ../../../../../physmod-eqnComp/circus.robocalc.robosim.physmod.generator.eqnComp.tests/src/circus/robocalc/robosim/physmod/generator/eqnComp/tests/unitTests/calculateTopology/CalculateTopologyTest.java
[EqnCompMainTest]: ../../../../../physmod-eqnComp/circus.robocalc.robosim.physmod.generator.eqnComp.tests/src/circus/robocalc/robosim/physmod/generator/eqnComp/tests/unitTests/eqnCompMain/EqnCompMainTest.java
[EqnCompUtilsTest]: ../../../../../physmod-eqnComp/circus.robocalc.robosim.physmod.generator.eqnComp.tests/src/circus/robocalc/robosim/physmod/generator/eqnComp/tests/unitTests/eqnCompUtils/EqnCompUtilsTest.java
[GeneratorServicesTest]: ../../../../../physmod-eqnComp/circus.robocalc.robosim.physmod.generator.eqnComp.tests/src/circus/robocalc/robosim/physmod/generator/eqnComp/tests/unitTests/generatorServices/GeneratorServicesTest.java
[LocaliseRefsTest]: ../../../../../physmod-eqnComp/circus.robocalc.robosim.physmod.generator.eqnComp.tests/src/circus/robocalc/robosim/physmod/generator/eqnComp/tests/unitTests/localiseRefs/LocaliseRefsTest.java
[PhysModTextualTest]: ../../../../../physmod-eqnComp/circus.robocalc.robosim.physmod.generator.eqnComp.tests/src/circus/robocalc/robosim/physmod/generator/eqnComp/tests/unitTests/physmodTextual/PhysModTextualTest.java
[ValidateTest]: ../../../../../physmod-eqnComp/circus.robocalc.robosim.physmod.generator.eqnComp.tests/src/circus/robocalc/robosim/physmod/generator/eqnComp/tests/unitTests/validate/ValidateTest.java
