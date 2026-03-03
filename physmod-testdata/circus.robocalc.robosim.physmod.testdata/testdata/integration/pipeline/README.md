# Pipeline integration test data

[Back to Test Data Overview](../../../README.md)

This document summarises integration-level test data for the end-to-end pipeline tests. Each pipeline test exercises the full T3→T4→T5 chain on a single input model, running eqnComp, guidedChoice, and sourceCodeGen in sequence. Most scenarios also compile the generated code and run a simulation, comparing the resulting trajectory against a reference CSV. The tests complement the per-generator integration tests (T3, T4, T5) by verifying that generator outputs compose correctly across stages.

## Method Index

See [method_index.md](method_index.md) for the test method to data directory mapping.

## Table P-I1: Pipeline scenarios

Feature key: TV = trajectory validation, LR = library references, PM = platform mapping, Vis = visualisation, IP = Isabelle proof generation, BM = benchmarking.

| Scenario | Robot | Formulation | Topology | Features | Path |
| --- | --- | --- | --- | --- | --- |
| SKO baseline | SimpleArm | SKO | Serial | TV | [SKO/](SKO/) |
| SKO LibRefs | SimpleArm | SKO | Serial | LR, TV | [SKO/](SKO/) |
| Acrobot SKO | Acrobot | SKO | Serial | TV | [RobotExamples/acrobot/](RobotExamples/acrobot/) |
| Acrobot Featherstone | Acrobot | Featherstone | Serial | TV | [RobotExamples/acrobot/](RobotExamples/acrobot/) |
| Acrobot CGA | Acrobot | CGA | Serial | TV | [RobotExamples/acrobot/](RobotExamples/acrobot/) |
| AcrobotControlled | Acrobot | SKO | Serial | TV | [AcrobotControlled/](AcrobotControlled/) |
| AcrobotControlled mapping | Acrobot | SKO | Serial | PM, TV | [AcrobotControlled/Mapping/](AcrobotControlled/Mapping/) |
| SKOVis | SimpleArm | SKO | Serial | Vis | [visualisation/SKOVis/](visualisation/SKOVis/) |
| ClosedChain FourBar | Four-Bar | SKO | Closed | TV | [ClosedChain/FourBar/](ClosedChain/FourBar/) |
| MobileRobot mapping | Turtlebot | SKO | Tree | PM, Vis | [MobileRobot/Mapping/](MobileRobot/Mapping/) |
| MobileRobot Isabelle proof | Turtlebot | SKO | Tree | IP | [MobileRobot/IsabelleProof/](MobileRobot/IsabelleProof/) |
| AcrobotSerial20 benchmarking | Acrobot (20-link) | SKO | Serial | BM | `Examples/Benchmarking/` (external) |

The AcrobotSerial20 benchmarking test uses data from `Examples/Benchmarking/` outside the testdata directory. All other tests read exclusively from their listed pipeline directory.
