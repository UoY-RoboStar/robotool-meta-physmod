# T5 sourceCodeGen unit test data

[Back to Test Data Overview](../../../README.md)

This document summarizes the unit-level test data used by the sourceCodeGen (T5) generator tests. The unit tests exercise the SolutionDSL-to-C++ translation covering datatypes, functions, procedures, statements, and expression forms.

See the [T5 integration method_index](../../integration/T5/method_index.md) for the test method to data directory mapping, which covers both unit and integration tests.

## Coverage and traceability

| Step | Algorithm | Count | Test Method(s) |
| --- | --- | --- | --- |
| S2 | `slnDFToTargetTranslation` | 12 | [testSimpleFunctionGeneration][SolutionToCppGeneratorTest], [testCustomStructs][SolutionToCppGeneratorTest], [testFunctionLoopsAndConditionals][SolutionToCppGeneratorTest], [testFunctionMatrixOperations][SolutionToCppGeneratorTest], [testProcedureParameterModes][SolutionToCppGeneratorTest], [testProcedureSubmatrixOperations][SolutionToCppGeneratorTest], [testForLoops][SolutionToCppGeneratorTest], [testIfThenElse][SolutionToCppGeneratorTest], [testAssignments][SolutionToCppGeneratorTest], [testArithmeticExpressions][SolutionToCppGeneratorTest], [testDataStructureExpressions][SolutionToCppGeneratorTest], [testAllGeneratedCodeCompiles][SolutionToCppGeneratorTest] |

Total counts distinct tests; some tests exercise multiple steps, so row totals are not additive.

## Table T5-U3: Unit test cases

| Test case | Step | Input | Expected | Description |
| --- | --- | --- | --- | --- |
| simple_function | S2 | `input/simple_function.sln` | `expected/simple_function_DEFAULT_OUTPUTsolution.cpp` | Basic function definition and call |
| custom_struct | S2 | `input/datatypes/custom_struct.sln` | `expected/datatypes/custom_struct_DEFAULT_OUTPUTsolution.cpp` | Struct definitions with field access |
| enums | S2 | `input/datatypes/enums.sln` | `expected/datatypes/enums_DEFAULT_OUTPUTsolution.cpp` | Enum type definitions |
| loops_and_conditionals | S2 | `input/functions/loops_and_conditionals.sln` | `expected/functions/loops_and_conditionals_DEFAULT_OUTPUTsolution.cpp` | Functions with for loops and if-then-else |
| matrix_operations | S2 | `input/functions/matrix_operations.sln` | `expected/functions/matrix_operations_DEFAULT_OUTPUTsolution.cpp` | Vector/matrix element and subrange access |
| parameter_modes | S2 | `input/procedures/parameter_modes.sln` | `expected/procedures/parameter_modes_DEFAULT_OUTPUTsolution.cpp` | val, res, val-res parameter modes |
| submatrix_operations | S2 | `input/procedures/submatrix_operations.sln` | `expected/procedures/submatrix_operations_DEFAULT_OUTPUTsolution.cpp` | Submatrix and subvector assignment |
| assignments | S2 | `input/statements/assignments.sln` | `expected/statements/assignments_DEFAULT_OUTPUTsolution.cpp` | Variable, element, and block assignment |
| for_loops | S2 | `input/statements/for_loops.sln` | `expected/statements/for_loops_DEFAULT_OUTPUTsolution.cpp` | Range-based and element-based for loops |
| if_then_else | S2 | `input/statements/if_then_else.sln` | `expected/statements/if_then_else_DEFAULT_OUTPUTsolution.cpp` | Conditional statements with nesting |
| arithmetic | S2 | `input/expressions/arithmetic.sln` | `expected/expressions/arithmetic_DEFAULT_OUTPUTsolution.cpp` | Arithmetic and comparison operators |
| data_structures | S2 | `input/expressions/data_structures.sln` | `expected/expressions/data_structures_DEFAULT_OUTPUTsolution.cpp` | Vectors, matrices, sequences with indexing |

<!-- Unit test source files -->
[SolutionToCppGeneratorTest]: ../../../../../physmod-sourceCodeGen/circus.robocalc.robosim.physmod.generator.sourceCodeGen.tests/src/circus/robocalc/robosim/physmod/generator/sourceCodeGen/tests/SolutionToCppGeneratorTest.java
