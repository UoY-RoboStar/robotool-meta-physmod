# PhysMod Test Data

This project contains test data (inputs and expected outputs) used by generator and pipeline tests in physmod-meta.

## Structure

```
testdata/
├── unit/                      # Unit-test data by generator stage
│   ├── T3/ ...                 # eqnComp unit data
│   ├── T4/ ...                 # guidedChoice unit data
│   └── T5/ ...                 # sourceCodeGen unit data
├── integration/
│   ├── T3/ ...                 # eqnComp integration data
│   ├── T4/ ...                 # guidedChoice integration data
│   ├── T5/ ...                 # sourceCodeGen integration data
│   └── pipeline/ ...           # End-to-end pipeline data (T3->T4->T5)
```

## Coverage Criteria (C1-C5)

| Criterion | Description | Test data evidence |
| --- | --- | --- |
| C1 Unit coverage | every algorithm has at least one test covering normal, boundary, and error cases | `testdata/unit/T3/`, `testdata/unit/T4/`, `testdata/unit/T5/` |
| C2 Integration coverage | end-to-end pipeline tests validate generated artifacts | `testdata/integration/T3/`, `testdata/integration/T4/`, `testdata/integration/T5/`, `testdata/integration/pipeline/` |
| C3 Formulation coverage | SKO, Featherstone, and CGA formulations are exercised | `testdata/integration/T3/RobotExamples/`, `testdata/integration/T5/Acrobot/`, `testdata/integration/pipeline/RobotExamples/` |
| C4 Topology coverage | serial, tree, and closed-chain topologies are exercised | `testdata/integration/T3/RobotExamples/`, `testdata/integration/T3/ClosedChain/`, `testdata/integration/T5/ClosedChain/` |
| C5 P-model coverage | PhysMod metamodel elements are exercised | `testdata/integration/T3/metamodelCoverage/` |

## Formulation Coverage Summary

| Formulation | Techniques | Robot examples |
| --- | --- | --- |
| SKO | T3, T4, T5, Pipeline | SimpleArm, Acrobot, AcrobotControlled, MobileRobot, ClosedChain |
| Featherstone | T3, T5, Pipeline | Acrobot |
| CGA | T3, T5, Pipeline | Acrobot |

## Topology Coverage Summary

| Topology | Integration scenarios | Unit data |
| --- | --- | --- |
| Serial chain | SimpleArm, Acrobot | assignNumbering, calculateTopology |
| Tree (branching) | MobileRobot | assignNumbering, calculateTopology |
| Closed chain | ClosedChain | assignNumbering, calculateTopology |

## Test Suite Summary

| Technique | Suite | Unit tests | Integration tests | Total | Test data |
| --- | --- | --- | --- | --- | --- |
| T3 | eqnComp | 117 | 9 | 126 | `testdata/unit/T3/`, `testdata/integration/T3/` |
| T4 | guidedChoice | 101 | 31 | 132 | `testdata/unit/T4/`, `testdata/integration/T4/` |
| T5 | sourceCodeGen | 12 | 26 | 38 | `testdata/unit/T5/`, `testdata/integration/T5/` |
| Pipeline | T3->T4->T5 | - | 13 | 13 | `testdata/integration/pipeline/` |

## Detailed Test Data Tables

| Technique | Unit data table | Integration data table |
| --- | --- | --- |
| T3 eqnComp | [T3 unit data](testdata/unit/T3/README.md) | [T3 integration data](testdata/integration/T3/README.md) |
| T4 guidedChoice | [T4 unit data](testdata/unit/T4/README.md) | [T4 integration data](testdata/integration/T4/README.md) |
| T5 sourceCodeGen | [T5 unit data](testdata/unit/T5/README.md) | [T5 integration data](testdata/integration/T5/README.md) |
| Pipeline | - | [Pipeline data](testdata/integration/pipeline/README.md) |


## How To Run Tests

The T3 eqnComp and T4 guidedChoice test runners are in a private repository and cannot be run from this project alone. The T5 sourceCodeGen, pipeline, and metamodel coverage tests can be run from the repo root:

```bash
# T5 sourceCodeGen tests
mvn -pl physmod-sourceCodeGen/circus.robocalc.robosim.physmod.generator.sourceCodeGen.tests -am test

# End-to-end pipeline tests (T3 -> T4 -> T5)
mvn -pl IntegrationTests/circus.robocalc.robosim.physmod.generator.pipeline.tests -am test

# PhysMod metamodel coverage tests (C5)
mvn -pl physmod-eqnComp/circus.robocalc.robosim.physmod.generator.eqnComp.tests -am -Dtest=MetamodelCoverageGeneratorTest,MetamodelCoverageSKOGeneratorTest test
```

## Test Data Conventions

Each test scenario uses the following directory structure:

- `input/` — test inputs (p-models, mappings, solution blocks)
- `expected/` — expected test outputs
- `temp/` — generated during test runs

When adding a new test, create a directory under the appropriate technique and level (e.g. `testdata/unit/T3/<group>/` or `testdata/integration/T4/<scenario>/`) containing at least an `input/` subdirectory with the test inputs and an `expected/` subdirectory with the expected outputs. The test harness will compare generated output against the contents of `expected/`. Update the corresponding README and method_index.md to document the new test.
