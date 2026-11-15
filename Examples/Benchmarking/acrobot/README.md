# Acrobot benchmark

Runs the generated SKO engine and RBDL, RobCoGen, GAFRO, Drake, MuJoCo and Pinocchio on the same damped
Acrobot: a 5 s trajectory in 1 ms steps, and the time of one forward-dynamics call.

## Build

Give the build the location of each C++ engine you have; an engine without a location is skipped.

```
cmake -S . -B build \
    -DRBDL_DIR=<rbdl source folder, built in build/> \
    -DROBCOGEN_GEN_DIR=<folder of the C++ code RobCoGen generated> \
    -DIITRBD_DIR=<robcogen>/etc/cpp-iitrbd \
    -DGAFRO_DIR=<gafro source folder, built in build/> \
    -DGAFRO_DESCRIPTIONS_DIR=<gafro_robot_descriptions source folder, built in build/> \
    -DSKO_ENGINE_DIR=<folder with the generated platform1_engine.cpp and platform1_state.hpp>
cmake --build build
```

- **SKO engine:** in RoboTool, set the output to standalone C++ without visualisation under Solution
  Generation → Configure Solution Generation, then run Generate Solution on
  `testdata/integration/T5/Acrobot/SKO/standalone_visualisation/input/acrobot_gravity_only.slnRef`. The files
  are written to the project's `src-gen/`.
- **RobCoGen code:** from RobCoGen 0.5.2's `exe` folder, run
  `./robcogen.sh <this folder>/robcogen/acrobot.kindsl <this folder>/robcogen/acrobot.dtdsl` and choose `1`,
  `4`, then `28`. Build it in a folder that holds no older generated copy.

## Run

```
python3 run_all.py --build build \
    --python-drake <python with pydrake> --python-mujoco <python with mujoco> --python-pinocchio <python with pinocchio>
```

For every engine that runs, this writes `results/trajectory_<engine>.csv` and
`results/timing_<engine>.csv`. It then prints two tables:

- the largest difference in any angle or rate between each engine's trajectory and the first engine's
  (the SKO engine, if it was built);
- each engine's mean time for one forward-dynamics call, in microseconds.

To run one engine on its own, call its program in `build/` (C++) or its script (Python) with `trajectory` or
`timing` and an output file:

```
build/engine_rbdl trajectory rbdl.csv
build/engine_rbdl timing rbdl_timing.csv
python3 engine_pinocchio.py trajectory pinocchio.csv
```

## Results

A. S. Badyal, *Physics Engines for Verification of Robotic Systems*, PhD thesis, University of York, 2026,
Section 4.2.2.
