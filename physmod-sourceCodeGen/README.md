# PhysMod Source Code Generation (sourceCodeGen)

Source Code Generation (sourceCodeGen) is Technique 5 in the RoboSim simulation framework. It transforms the resolved solutions from guidedChoice into executable platform engine code through a two-phase process.

```
 ┌─────────────┐
 │  p-model+   │
 │ (solutions) │
 └──────┬──────┘
        │
        │  Technique 5
        │  sourceCodeGen
        ▼
 ┌─────────────┐
 │  Platform   │
 │   Engine    │
 │    Code     │
 └─────────────┘
```

In the first phase, each slnRef entry (solution reference) is resolved by querying the solution library for its corresponding solution template. The generator uses the library templates to return concrete algorithmic implementations in slnDF format (solution description format), which are then combined into a unified slnDF specification removing duplicate shared state variables, procedures, and functions. The resulting slnDF specification contains `state` blocks defining simulation variables with their types and initial values, `computation` blocks specifying the step-by-step evaluation sequence, and `functions` and `procedures` blocks implementing the computational algorithms. This phase instantiates abstract solution method references with concrete implementations that are ready for platform-specific code generation.

In the second phase, the unified slnDF specification is translated into platform-specific source code. A code generator for the target platform translates slnDF constructs to their target language equivalents: state variables become language-specific variable declarations, computation blocks become executable statements, and mathematical operations become library calls appropriate to the target platform (such as Eigen for C++, NumPy for Python).

The resulting platform engine source code provides the computational implementation derived from the p-model. However, to form a complete executable simulation, this generated code must be integrated with an orchestrator component. The orchestrator provides stubs for simulation timing, event scheduling, and communication between source-code generated from RoboSim models. In the current workflow, these stubs are filled in manually by the developer.

The intermediate slnDF representation provides an explicit, inspectable specification of the computational implementation that facilitates verification of semantic preservation. This description is simulator and programming language independent. It is the gateway to facilitate extensibility of the framework. Providing support for additional programming languages requires only the creation of alternative translations (second step of this technique), without any impact on the rest of the approach.

```
 Phase 1: SolutionRef → slnDF     — resolve references via solution library templates,
                                     combine into unified specification
 Phase 2: slnDF → Source Code     — translate slnDF to target language equivalents
```

## Where sourceCodeGen fits in the simulation framework

```
 ┌─────────┐   ┌──────────────────┐   ┌───────────┐
 │ d-model │   │ Platform Mapping │   │  p-model  │
 └────┬────┘   └────────┬─────────┘   └─────┬─────┘
      │                 │                    │
      │ T1              │ T2                 │ T3 eqnComp
      │ d-modelGen      │ mappingGen         │
      ▼                 ▼                    ▼
 ┌─────────┐   ┌──────────────────┐   ┌───────────┐  ┌─────────┐
 │ d-model │   │ Platform Mapping │   │ p-model+  │──│ Library │
 │  Code   │   │      Code        │   └─────┬─────┘  └────┬────┘
 └────┬────┘   └────────┬─────────┘         │             │
      │                 │                    │ T4 guidedChoice
      │                 │                    ▼
      │                 │              ┌───────────┐
      │                 │              │ p-model+  │
      │                 │              │(solutions)│
      │                 │              └─────┬─────┘
      │                 │                    │ T5 sourceCodeGen
      │                 │                    ▼
      │                 │              ┌───────────┐
      │                 │              │ Platform  │
      │                 │              │  Engine   │
      │                 │              │   Code    │
      ▼                 ▼              └─────┬─────┘
 ┌───────────────────────────────────────────┴──────┐
 │                  Orchestrator                     │
 └───────────────────────────────────────────────────┘
```

## Target languages

The generator supports multiple output formats: C++ (the primary target, producing executable physics engines), LaTeX (mathematical documentation), and Isabelle/UTP (formal verification theories).

For C++, several generation modes are available. Standalone mode produces a pure physics engine without external interfaces. Standalone with visualisation adds 3D visualisation support via MeshcatCpp. Integrated mode generates physics with a controller interface for full simulation with a discrete model. Integrated with mapping further adds auto-generated platform mappings.

## Project structure

- `circus.robocalc.robosim.physmod.generator.sourceCodeGen/` — the Eclipse plugin containing the generator source (Xtend/Java)
- `circus.robocalc.robosim.physmod.generator.sourceCodeGen.tests/` — unit and integration tests
- `circus.robocalc.robosim.physmod.generator.sourceCodeGen.feature/` — Eclipse feature definition
- `circus.robocalc.robosim.physmod.generator.sourceCodeGen.target/` — target platform definition
- `circus.robocalc.robosim.physmod.generator.sourceCodeGen.update/` — P2 update site

## Building

Prerequisites: Java 11+, Maven 3.6+.

```bash
mvn clean install
```

## Running tests

```bash
mvn clean install
cd circus.robocalc.robosim.physmod.generator.sourceCodeGen.tests
mvn test
```

To run a specific test:

```bash
mvn test -Dtest=TestSKO_T5Standalone
```
