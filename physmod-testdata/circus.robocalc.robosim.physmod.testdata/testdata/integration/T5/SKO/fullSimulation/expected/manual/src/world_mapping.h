#ifndef WORLD_MAPPING_H
#define WORLD_MAPPING_H

#include <math.h>
#include <Eigen/Dense>
#include <vector>
#include "platform_mapping.h"  // for mapping_state_t and p_mapping/w_mapping globals

// World model functions (from world_engine.cpp) - C++ only
void world_initialize(void);
void world_update_gripper_position(const std::vector<Eigen::MatrixXd>& Bk);
double world_get_distance_to_object(void);
double world_get_distance_to_goal(void);
void world_set_object_position(double x, double y, double z);
void world_set_goal_position(double x, double y, double z);
void world_get_gripper_position(double* x, double* y, double* z);
void world_get_object_position(double* x, double* y, double* z);
void world_get_goal_position(double* x, double* y, double* z);
void world_print_state(void);

// World mapping state (separate from platform mapping); defined in platform1_engine.cpp
extern mapping_state_t w_mapping;

/**
 * Update sensor readings based on current world state (Drake-style ObjectSensor)
 * Drake's ObjectSensor.cc logic: returns |object_y| when gripper_z <= 100
 * Uses physics-computed Bk matrices to get accurate gripper position
 */
static inline void scenario_update_sensors(const std::vector<Eigen::MatrixXd>& Bk,
                                          double* object_sensor,
                                          double* goal_sensor) {
    // Update gripper position from physics-computed Bk matrices
    world_update_gripper_position(Bk);
    
    // Get gripper position (center of gripper)
    double gripper_x, gripper_y, gripper_z;
    world_get_gripper_position(&gripper_x, &gripper_y, &gripper_z);
    
    // Get object and goal positions
    double object_x, object_y, object_z;
    double goal_x, goal_y, goal_z;
    world_get_object_position(&object_x, &object_y, &object_z);
    world_get_goal_position(&goal_x, &goal_y, &goal_z);
    
    // Beam sensor: reports gripper Y position (sensor mounted on gripper)
    // Detection occurs when gripper reaches object/goal position (y ∈ [4.749, 4.75111])
    // Object at y=4.751, Goal at y=-4.751 (absolute values both ~4.751)
    // Gripper starts at y=4.0 and must move to these positions
    if (object_sensor) {
        *object_sensor = fabs(gripper_y);
    }

    if (goal_sensor) {
        *goal_sensor = fabs(gripper_y);
    }
}

#endif // WORLD_MAPPING_H
