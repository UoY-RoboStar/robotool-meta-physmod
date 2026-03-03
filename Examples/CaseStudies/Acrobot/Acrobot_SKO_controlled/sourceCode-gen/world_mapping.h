#ifndef WORLD_MAPPING_H
#define WORLD_MAPPING_H

#include <Eigen/Dense>
#include <vector>

#include "platform_mapping.h"  // mapping_state_t and p_mapping/w_mapping

// Minimal world model functions for Acrobot.
// Implemented in world_engine.cpp.
void world_initialize(void);

// World mapping snapshot (optional; defined in platform1_engine.cpp)
extern mapping_state_t w_mapping;

// Compatibility stub: some generic templates reference this, but Acrobot does not
// use pick-and-place object/goal sensors.
static inline void scenario_update_sensors(const std::vector<Eigen::MatrixXd>&,
                                          double* /*object_sensor*/,
                                          double* /*goal_sensor*/) {
    // No-op.
}

#endif // WORLD_MAPPING_H
