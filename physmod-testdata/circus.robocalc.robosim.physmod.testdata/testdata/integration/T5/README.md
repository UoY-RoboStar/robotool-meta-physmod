# T5 sourceCodeGen integration test data

[Back to Test Data Overview](../../../README.md)

This document summarizes integration-level test data for sourceCodeGen (T5). Each integration test runs the full sourceCodeGen algorithm (Algorithm 3 in the thesis), which comprises two steps: S1 translateSlnRefToSln (assembling solution references into a unified slnDF) and S2 translateSlnDFToTarget (translating the slnDF into executable code in a target language). Each scenario contains input/ (slnRef files), expected/ (generated output for comparison), and where applicable manual/ (reference implementations and fixtures) subdirectories.

## Method Index

See [method_index.md](method_index.md) for the test method to data directory mapping.

## Table T5-I1: Integration scenarios

Target key: C++ = C++ source code, LaTeX = LaTeX equations, Isabelle = Isabelle theory file.

| Scenario | Formulation | Target | Profile | Substeps covered | Path |
| --- | --- | --- | --- | --- | --- |
| SKO fullSimulation | SKO | C++ | fullSimulation | S1, S2 | [SKO/fullSimulation/](SKO/fullSimulation/) |
| SKO fullSimulation visualisation | SKO | C++ | fullSimulation_visualisation | S1, S2 | [SKO/fullSimulation_visualisation/](SKO/fullSimulation_visualisation/) |
| SKO standalone | SKO | C++ | standalone | S1, S2 | [SKO/standalone/](SKO/standalone/) |
| SKO standalone visualisation | SKO | C++ | standalone_visualisation | S1, S2 | [SKO/standalone_visualisation/](SKO/standalone_visualisation/) |
| SKO latex | SKO | LaTeX | latex | S1, S2 | [SKO/latex/](SKO/latex/) |
| SKO Isabelle equations | SKO | Isabelle | integrated | S1, S2 | [SKO/integrated/](SKO/integrated/) |
| SKO Isabelle proof | SKO | Isabelle | proof | S1, S2 | [SKO_proof/](SKO_proof/) |
| Acrobot SKO latex | SKO | LaTeX | latex | S1, S2 | [RobotExamples/Acrobot/SKO/](RobotExamples/Acrobot/SKO/) |
| Acrobot SKO standalone visualisation | SKO | C++ | standalone_visualisation | S1, S2 | [Acrobot/SKO/standalone_visualisation/](Acrobot/SKO/standalone_visualisation/) |
| Acrobot SKO fullSimulation visualisation | SKO | C++ | fullSimulation_visualisation | S1, S2 | [RobotExamples/Acrobot/SKO/fullSimulation_visualisation/](RobotExamples/Acrobot/SKO/fullSimulation_visualisation/) |
| Acrobot CGA standalone visualisation | CGA | C++ | standalone_visualisation | S1, S2 | [Acrobot/CGA/](Acrobot/CGA/) |
| AcrobotControlled SKO fullSimulation visualisation | SKO | C++ | fullSimulation_visualisation | S1, S2 | [AcrobotControlled/SKO/FullSimulation_Visualisation/](AcrobotControlled/SKO/FullSimulation_Visualisation/) |
| AcrobotControlled Isabelle proof | SKO | Isabelle | proof | S1, S2 | [AcrobotControlled/SKO/](AcrobotControlled/SKO/) |
| SimpleArm SKO standalone visualisation | SKO | C++ | standalone_visualisation | S1, S2 | [RobotExamples/SimpleArm/SKO/](RobotExamples/SimpleArm/SKO/) |
| ClosedChain SKO | SKO | C++ | constraint dynamics | S1, S2 | [ClosedChain/SKO/](ClosedChain/SKO/) |
| ClosedChain SKO standalone visualisation | SKO | C++ | standalone_visualisation | S1, S2 | [ClosedChain/SKO/standalone_visualisation/](ClosedChain/SKO/standalone_visualisation/) |

## Table T5-I2: SKO suite profiles

| Profile | Path | Description |
| --- | --- | --- |
| default | [SKO/default/](SKO/default/) | Default output profile (unit tests) |
| standalone | [SKO/standalone/](SKO/standalone/) | Standalone mode with trajectory logging |
| integrated | [SKO/integrated/](SKO/integrated/) | Integrated mode |
| latex | [SKO/latex/](SKO/latex/) | LaTeX equation generation |
| proof | [SKO/proof/](SKO/proof/) | Proof mode output |
| fullSimulation | [SKO/fullSimulation/](SKO/fullSimulation/) | Full simulation with orchestrator |
| fullSimulation_visualisation | [SKO/fullSimulation_visualisation/](SKO/fullSimulation_visualisation/) | Full simulation with visualisation |
| standalone_visualisation | [SKO/standalone_visualisation/](SKO/standalone_visualisation/) | Standalone with visualisation |

## Algorithm substep coverage

The table below summarises which integration scenarios exercise each substep of the sourceCodeGen algorithm. Both S1 and S2 are exercised by every integration scenario since the full pipeline always runs. The scenarios are differentiated by the formulation (which determines the slnRef structure), the target language (which determines the code generator used in S2), and the profile (which determines the output mode and what components are generated).

| Substep | Algorithm | Scenarios |
| --- | --- | --- |
| S1 | `translateSlnRefToSln` | All scenarios. Includes datatype aggregation, state variable deduplication, procedure and function signature deduplication, and computation sequence assembly. |
| S2 | `translateSlnDFToTarget` | All scenarios. C++ scenarios test header generation, Eigen type mapping, state declarations, function/procedure translation, and entry point generation. LaTeX scenarios test equation rendering. Isabelle scenarios test theory file generation with ISAVodes dataspace format. Acrobot CGA tests CGA-specific type mapping and Geom record handling. ClosedChain tests constraint Jacobian code generation. |
