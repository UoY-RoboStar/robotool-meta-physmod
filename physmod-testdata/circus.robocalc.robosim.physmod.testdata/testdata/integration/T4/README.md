# T4 guidedChoice integration test data

[Back to Test Data Overview](../../../README.md)

This document summarizes integration-level test data for guidedChoice (T4). Each integration test runs the full guidedChoice algorithm (Algorithm 2 in the thesis), which comprises five steps: S1 initialiseSidecar, S2 calculateFormulation, S3 resolveSolutionFirstPass, S4 reorderSolutions, and S5 resolveSolution. While every test exercises all five steps, each scenario covers particular substeps depending on the model features and solution types it contains.

## Method Index

See [method_index.md](method_index.md) for the test method to data directory mapping.

## Table T4-I1: Integration scenarios

Solution key: GP = GeneralisedPosition, FD = ForwardDynamics, NI = NumericalIntegration, PM = PlatformMapping, Vis = Visualisation, Proof = Proof.

| Scenario | Formulation | Topology | Solutions | Substeps covered | Path |
| --- | --- | --- | --- | --- | --- |
| SKO baseline | SKO | Serial | GP, FD, NI | S1, S2, S3, S3a, S4, S5 | [SKO/](SKO/) |
| SKO LibRefs | SKO | Serial | GP, FD | S1, S2, S3, S3a, S4, S5 | [SKO/](SKO/) |
| SKO proof | SKO | Serial | GP, FD, NI, Proof | S1, S2, S3, S3a, S4, S5 | [SKO_proof/](SKO_proof/) |
| Acrobot SKO (from T3) | SKO | Serial | GP, FD | S1, S2, S3, S3a, S4, S5 | T3 eqnComp temp output |
| Acrobot Featherstone (from T3) | Featherstone | Serial | GP, FD | S1, S2, S3, S3a, S4, S5 | [../T3/RobotExamples/acrobot/Featherstone/](../T3/RobotExamples/acrobot/Featherstone/) |
| Acrobot CGA (from T3) | CGA | Serial | GP, FD | S1, S2, S3, S3a, S4, S5 | T3 eqnComp temp output |
| AcrobotControlled proof | SKO | Serial | GP, FD, PM, Proof | S1, S2, S3, S3a, S3b, S4, S5 | [AcrobotControlled/SKO/FullSimulation_Visual_Proof/](AcrobotControlled/SKO/FullSimulation_Visual_Proof/) |
| AcrobotControlled mapping | SKO | Serial | GP, FD, PM | S1, S2, S3, S3a, S3b, S4, S5 | [AcrobotControlled/SKO/FullSimulation_Visualisation_Mapping/](AcrobotControlled/SKO/FullSimulation_Visualisation_Mapping/) |
| MappingPM | SKO | Serial | PM | S1, S2, S3, S3a, S3b, S4, S5 | [AcrobotControlled/SKO/FullSimulation_Visualisation_Mapping/](AcrobotControlled/SKO/FullSimulation_Visualisation_Mapping/) |
| Visualisation | Visual | Serial | Vis | S1, S2, S3, S3a, S4, S5 | [vis/](vis/) |
| Vis algebraic constraints | Visual | Serial | Vis | S1, S2, S3, S3a, S3b, S4, S5 | [vis/](vis/) |
| ClosedChain | SKO | Closed | GP, FD, Vis | S1, S2, S3, S3a, S4, S5 | [../T3/ClosedChain/SKO/](../T3/ClosedChain/SKO/) |

## Algorithm substep coverage

The table below summarises which integration scenarios exercise each substep of the guidedChoice algorithm. S1, S2, S4, and S5 are exercised by every scenario since the full pipeline always runs. S3a (initial conditions) is also exercised by every scenario. The substep that differentiates scenarios is S3b (algebraic constraints), which is only exercised by scenarios that contain time-invariant [t==t] constraints.

| Substep | Algorithm | Scenarios |
| --- | --- | --- |
| S1 | `initialiseSidecar`, `addNullDatatype` | All scenarios. |
| S2 | `calculateFormulation` | All scenarios. Acrobot Featherstone and Acrobot CGA test alternative formulation detection. |
| S3 | `resolveSolutionFirstPass` | All scenarios. |
| S3a | `calculateInitialConditions` | All scenarios. AcrobotControlled proof and mapping scenarios test dimension placeholder resolution (zeroMat). |
| S3b | `processAlgebraicConstraints` | AcrobotControlled proof, AcrobotControlled mapping, MappingPM, Vis algebraic constraints (all contain time-invariant [t==t] constraints). AcrobotControlled scenarios test system correspondence propagation for XJ substitution. |
| S4 | `reorderSolutions` | All scenarios. |
| S5 | `resolveSolution` | All scenarios. AcrobotControlled mapping tests iterative resolution across multiple rounds. ClosedChain tests constraint dynamics solution resolution. |
