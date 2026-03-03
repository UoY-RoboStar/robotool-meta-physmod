# T4 guidedChoice unit test method index

[Back to T4 unit README](README.md)

Each method listed here maps to the data directory it uses. Most T4 unit tests use inline test data constructed within the test source files; only a subset reference external data files. Data directories contain the input/ subfolders used by the tests.

| Test class | Test method | Data directory |
| --- | --- | --- |
| [AlgebraicConstraintsTest] | testStage3_Algebraic_XJ_Resolution_UsesThetaIndex | Inline |
| [AlgebraicConstraintsTest] | testStage3_Algebraic_XJ_SequenceAggregate_Resolution | Inline |
| [AlgebraicConstraintsTest] | testStage3_ProcessAlgebraicConstraints_XJ_Aggregate | [guidedChoice/algebraicConstraints/](guidedChoice/algebraicConstraints/) |
| [AlgebraicConstraintsTest] | testResolveExpressionPlusAlgebraic | Inline |
| [AlgebraicConstraintsTest] | testAlgebraicConstraintDetection | Inline |
| [AlgebraicConstraintsTest] | testEvaluateVariableAlgebraic_XJ_SinCos | Inline |
| [AlgebraicConstraintsTest] | testStage1_PropagateSystemCorrespondence_FiltersByInputs | Inline |
| [AlgebraicConstraintsTest] | testStage1_PropagateSystemCorrespondence_IndexKinds | Inline |
| [AlgebraicConstraintsTest] | testStage1_PropagateSystemCorrespondence_JointAndFlexiScopes | Inline |
| [AlgebraicConstraintsTest] | testStage3_SubstitutesUsingPrepropagatedMapping | Inline |
| [AlgebraicConstraintsTest] | testAlgebraicPrefersTrigOverICZero_XJ | Inline |
| [HeadlessPrintingServicesTest] | testBasicExpressionPrinting | Inline |
| [HeadlessPrintingServicesTest] | testBinaryExpressionPrinting | Inline |
| [HeadlessPrintingServicesTest] | testVarAndRefPrinting | Inline |
| [HeadlessPrintingServicesTest] | testSeqAndMatrixPrinting | Inline |
| [HeadlessPrintingServicesTest] | testSequenceExpressionDebug | Inline |
| [HeadlessPrintingServicesTest] | testIBConditionPrinting | Inline |
| [HeadlessPrintingServicesTest] | testSubMatrixPrinting | Inline |
| [HeadlessPrintingServicesTest] | testHeadlessInstantiation | Inline |
| [HeadlessPrintingServicesTest] | testDerivativeExpressionCreation | Inline |
| [HeadlessPrintingServicesTest] | testConstraintVariablePrinting | Inline |
| [HeadlessPrintingServicesTest] | testSubMatrixConstraintPrinting | Inline |
| [HeadlessPrintingServicesTest] | testConstraintParsingAndPrinting | Inline |
| [HeadlessPrintingServicesTest] | testEqualsExpressionDebug | Inline |
| [HeadlessPrintingServicesTest] | testRecordTypeSerializationAsDatatype | Inline |
| [GuidedChoiceUtilsTest] | testStage2_SystemCorrespondence_thetaIndexing | Inline |
| [GuidedChoiceUtilsTest] | testJointToLinkToPModelPropagation | Inline |
| [GuidedChoiceUtilsTest] | testStage3_Algebraic_XJ_Resolution_UsesThetaIndex | Inline |
| [GuidedChoiceUtilsTest] | testStage3_Algebraic_XJ_SequenceAggregate_Resolution | Inline |
| [GuidedChoiceUtilsTest] | testStage3_ProcessAlgebraicConstraints_XJ_Aggregate | [guidedChoice/algebraicConstraints/](guidedChoice/algebraicConstraints/) |
| [GuidedChoiceUtilsTest] | testGetRootFromEquationSimple | Inline |
| [GuidedChoiceUtilsTest] | testGetRootFromSubmatrix | Inline |
| [GuidedChoiceUtilsTest] | testEvaluateVariableConstantOnDeviceConstraint | Inline |
| [GuidedChoiceUtilsTest] | testEvaluateVariableConstantOnDeviceEquation | Inline |
| [GuidedChoiceUtilsTest] | testEvaluateVariableConstantOnLink | Inline |
| [GuidedChoiceUtilsTest] | testEvaluateVariableConstantOnLinkRelationOnly | Inline |
| [GuidedChoiceUtilsTest] | testEvaluateVariableConstantOnLinkAdditionalConstraint | Inline |
| [GuidedChoiceUtilsTest] | testEvaluateVariableConstantOnLinkAdditionalEquation | Inline |
| [GuidedChoiceUtilsTest] | testEvaluateVariableConstantOnLinkTwoEquations | Inline |
| [GuidedChoiceUtilsTest] | testEvaluateVariableConstantNotOnLink | Inline |
| [GuidedChoiceUtilsTest] | testEvaluateVariableThroughActuator | Inline |
| [GuidedChoiceUtilsTest] | testEvaluateVariableInOutMixedChain | Inline |
| [GuidedChoiceUtilsTest] | testEvaluateVariable_N_SKO | Inline |
| [GuidedChoiceUtilsTest] | testEvaluateVariable_tau_SKO | Inline |
| [GuidedChoiceUtilsTest] | testEvaluateVariable_V_SKO | Inline |
| [GuidedChoiceUtilsTest] | testEvaluateVariable_f_SKO | Inline |
| [GuidedChoiceUtilsTest] | testEvaluateVariable_phi_SKO | Inline |
| [GuidedChoiceUtilsTest] | testPropagateDependentVarsNoDependencies | Inline |
| [GuidedChoiceUtilsTest] | testCountLiteralsNullExpression | Inline |
| [GuidedChoiceUtilsTest] | testCountLiteralsSingleInteger | Inline |
| [GuidedChoiceUtilsTest] | testCountLiteralsSingleFloat | Inline |
| [GuidedChoiceUtilsTest] | testCountLiteralsSingleString | Inline |
| [GuidedChoiceUtilsTest] | testCountLiteralsSingleBoolean | Inline |
| [GuidedChoiceUtilsTest] | testCountLiteralsBinaryMinus | Inline |
| [GuidedChoiceUtilsTest] | testCountLiteralsBinaryMult | Inline |
| [GuidedChoiceUtilsTest] | testCountLiteralsBinaryDiv | Inline |
| [GuidedChoiceUtilsTest] | testCountLiteralsNot | Inline |
| [GuidedChoiceUtilsTest] | testCountLiteralsNested | Inline |
| [GuidedChoiceUtilsTest] | testCountLiteralsRefExp | Inline |
| [GuidedChoiceUtilsTest] | testCountLiteralsSubmatrixExp | Inline |
| [GuidedChoiceUtilsTest] | testCountLiteralsIBCondition | Inline |
| [GuidedChoiceUtilsTest] | testInitialiseSidecar | Inline |
| [GuidedChoiceUtilsTest] | testInitialiseSidecarSubExpressions | Inline |
| [GuidedChoiceUtilsTest] | testEvaluateVariableWRTConstraintsUpdatesSidecar | Inline |
| [GuidedChoiceUtilsTest] | testEvaluateVariableWRTConstraintsUpdatesSidecarOnMixedRHS | Inline |
| [GuidedChoiceUtilsTest] | testEvaluateVariableWRTConstraintsSubmatrix | Inline |
| [GuidedChoiceUtilsTest] | testEvaluateVariableWRTConstraintsEquationOnly | Inline |
| [GuidedChoiceUtilsTest] | testEvaluateVariableWRTConstraintsMixedEqThenConstraint | Inline |
| [GuidedChoiceUtilsTest] | testEvaluateVariableWRTConstraintsMixedConstraintThenEq | Inline |
| [GuidedChoiceUtilsTest] | testEvaluateVariableWRTConstraintsLongChainResolvesF | Inline |
| [GuidedChoiceUtilsTest] | testEvaluateVariableWRTConstraintsConstantNotOnLink | Inline |
| [GuidedChoiceUtilsTest] | testEvaluateVariableWRTConstraintsCycleThrows | Inline |
| [GuidedChoiceUtilsTest] | testResolveExpressionRefExpKnownConstant | Inline |
| [GuidedChoiceUtilsTest] | testResolveExpressionPlusPartialConstant | Inline |
| [GuidedChoiceUtilsTest] | testResolveExpressionPlusAllConstants | Inline |
| [GuidedChoiceUtilsTest] | testResolveExpressionPlusAlgebraic | Inline |
| [GuidedChoiceUtilsTest] | testGetVarNamesEquationDependencies | Inline |
| [GuidedChoiceUtilsTest] | testGetVarNamesNoDependencies | Inline |
| [GuidedChoiceUtilsTest] | testGetVarNamesFromIBConditionRHS | Inline |
| [GuidedChoiceUtilsTest] | testTryDirectRelation_LeftSide | Inline |
| [GuidedChoiceUtilsTest] | testTryDirectRelation_RightSide | Inline |
| [GuidedChoiceUtilsTest] | testTryDirectRelation_NoRelation | Inline |
| [GuidedChoiceUtilsTest] | testAddLocalToPModelWithNullTypeDefaultsToNull | Inline |
| [GuidedChoiceUtilsTest] | testAlgebraicConstraintDetection | Inline |
| [GuidedChoiceUtilsTest] | testEvaluateVariableWithMixedConstraints | Inline |
| [GuidedChoiceUtilsTest] | testConstraintFormatRecognition | Inline |
| [GuidedChoiceUtilsTest] | testEvaluateXJ1_ThroughRelation | Inline |
| [GuidedChoiceUtilsTest] | testEvaluateVariableAlgebraic_XJ_SinCos | Inline |
| [GuidedChoiceUtilsTest] | testConstraintTypeClassification | Inline |
| [GuidedChoiceUtilsTest] | testVariableTypeInConstraints | Inline |
| [GuidedChoiceUtilsTest] | testBuildSubstitutionMap_SingleVariable | Inline |
| [GuidedChoiceUtilsTest] | testBuildSubstitutionMap_MultipleVariables | Inline |
| [GuidedChoiceUtilsTest] | testBuildSubstitutionMap_MissingCorrespondence | Inline |
| [GuidedChoiceUtilsTest] | testBuildSubstitutionMap_JointToPModel | Inline |
| [GuidedChoiceUtilsTest] | testFindCorrespondenceInRelation_LeftPattern | Inline |
| [GuidedChoiceUtilsTest] | testFindCorrespondenceInRelation_RightPattern | Inline |
| [GuidedChoiceUtilsTest] | testFindCorrespondenceInRelation_NoMatch | Inline |
| [SimpleArmSerialGuidedChoiceTests] | evaluateVariableTest | Inline |
| [SimpleXJTest] | testEvaluateXJFromJoint | Inline |
| [HeadlessInitializationTest] | testHeadlessInitialization | Inline |
| [SimpleHeadlessTest] | testBasicPrinting | Inline |

<!-- Unit test source files -->
[AlgebraicConstraintsTest]: ../../../../../physmod-guidedChoice/circus.robocalc.robosim.physmod.generator.guidedChoice.tests/src/circus/robocalc/robosim/physmod/generator/guidedChoice/tests/AlgebraicConstraintsTest.java
[HeadlessPrintingServicesTest]: ../../../../../physmod-guidedChoice/circus.robocalc.robosim.physmod.generator.guidedChoice.tests/src/circus/robocalc/robosim/physmod/generator/guidedChoice/tests/HeadlessPrintingServicesTest.java
[GuidedChoiceUtilsTest]: ../../../../../physmod-guidedChoice/circus.robocalc.robosim.physmod.generator.guidedChoice.tests/src/circus/robocalc/robosim/physmod/generator/guidedChoice/tests/GuidedChoiceUtilsTest.xtend
[SimpleArmSerialGuidedChoiceTests]: ../../../../../physmod-guidedChoice/circus.robocalc.robosim.physmod.generator.guidedChoice.tests/src/circus/robocalc/robosim/physmod/generator/guidedChoice/tests/SimpleArmSerialGuidedChoiceTests.xtend
[SimpleXJTest]: ../../../../../physmod-guidedChoice/circus.robocalc.robosim.physmod.generator.guidedChoice.tests/src/circus/robocalc/robosim/physmod/generator/guidedChoice/tests/SimpleXJTest.xtend
[HeadlessInitializationTest]: ../../../../../physmod-guidedChoice/circus.robocalc.robosim.physmod.generator.guidedChoice.tests/src/circus/robocalc/robosim/physmod/generator/guidedChoice/tests/HeadlessInitializationTest.xtend
[SimpleHeadlessTest]: ../../../../../physmod-guidedChoice/circus.robocalc.robosim.physmod.generator.guidedChoice.tests/src/circus/robocalc/robosim/physmod/generator/guidedChoice/tests/SimpleHeadlessTest.xtend
