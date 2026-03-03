# T4 guidedChoice unit test data

[Back to Test Data Overview](../../../README.md)

This document summarizes the unit-level test data used by the guidedChoice (T4) generator tests. Most T4 unit tests use inline test data constructed as Xtend multiline strings within the test source files themselves. Only a subset of tests reference external data files from this directory.

See [method_index.md](method_index.md) for the test method to data directory mapping.

## Coverage and traceability

| Step | Algorithm | Count | Test Method(s) |
| --- | --- | --- | --- |
| S1 | `initialiseSidecar`, `addNullDatatype` | 74 | [GuidedChoiceUtilsTest] (72), [HeadlessInitializationTest] (1), [SimpleHeadlessTest] (1) |
| S3 | `resolveSolutionFirstPass` | 98 | [GuidedChoiceUtilsTest] (72), [AlgebraicConstraintsTest] (11), [HeadlessPrintingServicesTest] (14), [SimpleArmSerialGuidedChoiceTests] (1) |
| S3a | `calculateInitialConditions` | subset of S3 | [HeadlessPrintingServicesTest], [GuidedChoiceUtilsTest] (constraint evaluation) |
| S3b | `processAlgebraicConstraints` | subset of S3 | [AlgebraicConstraintsTest], [GuidedChoiceUtilsTest] |

Total counts distinct tests; some tests exercise multiple steps, so row totals are not additive.

<!-- Unit test source files -->
[AlgebraicConstraintsTest]: ../../../../../physmod-guidedChoice/circus.robocalc.robosim.physmod.generator.guidedChoice.tests/src/circus/robocalc/robosim/physmod/generator/guidedChoice/tests/AlgebraicConstraintsTest.java
[HeadlessPrintingServicesTest]: ../../../../../physmod-guidedChoice/circus.robocalc.robosim.physmod.generator.guidedChoice.tests/src/circus/robocalc/robosim/physmod/generator/guidedChoice/tests/HeadlessPrintingServicesTest.java
[GuidedChoiceUtilsTest]: ../../../../../physmod-guidedChoice/circus.robocalc.robosim.physmod.generator.guidedChoice.tests/src/circus/robocalc/robosim/physmod/generator/guidedChoice/tests/GuidedChoiceUtilsTest.xtend
[SimpleArmSerialGuidedChoiceTests]: ../../../../../physmod-guidedChoice/circus.robocalc.robosim.physmod.generator.guidedChoice.tests/src/circus/robocalc/robosim/physmod/generator/guidedChoice/tests/SimpleArmSerialGuidedChoiceTests.xtend
[HeadlessInitializationTest]: ../../../../../physmod-guidedChoice/circus.robocalc.robosim.physmod.generator.guidedChoice.tests/src/circus/robocalc/robosim/physmod/generator/guidedChoice/tests/HeadlessInitializationTest.xtend
[SimpleHeadlessTest]: ../../../../../physmod-guidedChoice/circus.robocalc.robosim.physmod.generator.guidedChoice.tests/src/circus/robocalc/robosim/physmod/generator/guidedChoice/tests/SimpleHeadlessTest.xtend
[SimpleXJTest]: ../../../../../physmod-guidedChoice/circus.robocalc.robosim.physmod.generator.guidedChoice.tests/src/circus/robocalc/robosim/physmod/generator/guidedChoice/tests/SimpleXJTest.xtend
