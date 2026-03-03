STANDALONE Test Manual Files
=============================

This folder contains code snippets used by TestSKO_T5Standalone to modify
generated platform_engine.cpp for standalone execution with trajectory logging.

Files:
- trajectory_logging_globals.cpp: Global variables for trajectory logging (add after includes)
- physics_update_wrapper.cpp: Wrapper around physics_update that adds trajectory logging

The test uses these snippets to:
1. Add trajectory logging infrastructure
2. Set default actuator values (tau = 0)
3. Log joint positions, velocities, torques, and mass matrix values to CSV
