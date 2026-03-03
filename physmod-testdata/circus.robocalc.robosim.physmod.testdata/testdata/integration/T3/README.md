# T3 eqnComp integration test data

[Back to Test Data Overview](../../../README.md)

This document summarizes integration-level test data for eqnComp (T3). Each integration test runs the full eqnComp algorithm (Algorithm 1 in the thesis), which comprises six steps: S1 calculateFormulations, S2 localiseRefs, S3 validate, S4 calculateTopology, S5 assignNumbering, and S6 calculateEquations. While every test exercises all six steps, each scenario covers particular substeps depending on the model features it contains.

## Method Index

See [method_index.md](method_index.md) for the test method to data directory mapping.

## Table T3-I1: Integration scenarios

Component key: LJ = local joint, RJ = reference joint, LS = local sensor, RS = reference sensor, LA = local actuator, RA = reference actuator, B = body.

| Scenario | Formulation | Topology | Components | Substeps covered | Path |
| --- | --- | --- | --- | --- | --- |
| SKO baseline | SKO | Serial | LJ, LS, LA, B | S1a, S1b, S1c, S3, S4, S5a, S5b, S5c, S6a, S6b, S6c | [SKO/](SKO/) |
| SimpleArm LibRefs | SKO | Serial | RJ, LS, LA, B | S1a, S1b, S1c, S2a, S2b, S3, S4, S5a, S5b, S5c, S6a, S6b, S6c | [RobotExamples/SimpleArm/SKO/](RobotExamples/SimpleArm/SKO/) |
| Acrobot SKO | SKO | Serial | RJ, RS, RA, B | S1a, S1b, S1c, S2a, S2b, S3, S4, S5a, S5b, S5c, S6a, S6b, S6c | [RobotExamples/acrobot/SKO/](RobotExamples/acrobot/SKO/) |
| Acrobot Featherstone | Featherstone | Serial | LJ, B | S1a, S3, S4, S5a, S5b, S5c, S6a | [RobotExamples/acrobot/Featherstone/](RobotExamples/acrobot/Featherstone/) |
| Acrobot CGA | CGA | Serial | LJ, B | S1a, S3, S4, S5a, S5b, S5c, S6a | [RobotExamples/acrobot/CGA/](RobotExamples/acrobot/CGA/) |
| Acrobot controlled | SKO | Serial | RJ, RS, RA, B | S1a, S1b, S1c, S2a, S2b, S3, S4, S5a, S5b, S5c, S6a, S6b, S6c | [RobotExamples/acrobot_controlled/SKO/](RobotExamples/acrobot_controlled/SKO/) |
| MobileRobot | SKO | Tree | RJ, LS, RA, B | S1a, S1b, S1c, S2a, S2b, S3, S4, S5a, S5b, S5c, S6a, S6b, S6c | [RobotExamples/MobileRobot/SKO/](RobotExamples/MobileRobot/SKO/) |
| ClosedChain | SKO | Closed | RJ, B | S1a, S2a, S2b, S3, S4, S5a, S5b, S5c, S6a | [ClosedChain/SKO/](ClosedChain/SKO/) |
| Metamodel coverage (Default) | Default | Serial | LJ, RJ, LS, RS, LA, RA, B | S1a, S1b, S1c, S2a, S2b, S3, S4, S5a, S5b, S5c, S6a, S6b, S6c | [metamodelCoverage/Default/](metamodelCoverage/Default/) |
| Metamodel coverage (SKO) | SKO | Serial | LJ, RJ, LS, RS, LA, RA, B | S1a, S1b, S1c, S2a, S2b, S3, S4, S5a, S5b, S5c, S6a, S6b, S6c | [metamodelCoverage/SKO/](metamodelCoverage/SKO/) |

## Algorithm substep coverage

The table below summarises which integration scenarios exercise each substep of the eqnComp algorithm. S3, S4, S5a, S5b, S5c, and S6a are exercised by every scenario since the full pipeline always runs. The substeps that differentiate scenarios are S1a/S1b/S1c (depending on which component types the model contains), S2a/S2b (depending on which reference components need localising), and S6b/S6c (depending on whether the model contains sensors or actuators).

| Substep | Algorithm | Scenarios |
| --- | --- | --- |
| S1a | `findDynFormulation` | All scenarios (every model has joints). Acrobot Featherstone and Acrobot CGA test alternative formulation detection. |
| S1b | `findSensorFormulations` | SKO baseline, SimpleArm LibRefs, Acrobot SKO, Acrobot controlled, MobileRobot, metamodel coverage (all contain sensors). |
| S1c | `findActuatorFormulations` | SKO baseline, SimpleArm LibRefs, Acrobot SKO, Acrobot controlled, MobileRobot, metamodel coverage (all contain actuators). |
| S2a | `convertRef*` | SimpleArm LibRefs, Acrobot SKO, Acrobot controlled, MobileRobot, ClosedChain, metamodel coverage (all contain reference components). SimpleArm LibRefs tests different joint axes (Revolute_x, Revolute_z). |
| S2b | `createLocal*` | Same as S2a. Acrobot controlled tests ControlledMotor with B_ctrl matrix resolution. |
| S3 | `validate` | All scenarios. |
| S4 | `calculateTopology` | All scenarios. MobileRobot tests tree topology. ClosedChain tests closed-chain topology with constraint loop. All others test serial topology. |
| S5a | `orderPmodel` | All scenarios. |
| S5b | `getBaseLink` | All scenarios. |
| S5c | `getChildLinks` | All scenarios. ClosedChain tests constraint numbering for closed kinematic loops. |
| S6a | `calculateEquations` (dynamics) | All scenarios. SKO baseline tests inline H matrix and XJ equations. Acrobot Featherstone tests S matrix (motion subspace) equations. Acrobot controlled tests B_ctrl control input equations. |
| S6b | `calculateEquations` (sensors) | SKO baseline, SimpleArm LibRefs, Acrobot SKO, Acrobot controlled, MobileRobot, metamodel coverage (all contain sensors). MobileRobot tests complex sensor equations (LaserScan) and mesh geometry preservation. |
| S6c | `calculateEquations` (actuators) | SKO baseline, SimpleArm LibRefs, Acrobot SKO, Acrobot controlled, MobileRobot, metamodel coverage (all contain actuators). |
