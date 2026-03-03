#ifndef WORLD_MAPPING_H
#define WORLD_MAPPING_H

#include <math.h>
#include <stddef.h>

#include "platform_mapping.h"

#define WORLD_HAS_ROBOT_POSE 1

// World engine functions (implemented in world_engine.cpp)
void world_initialize(void);
void world_step(double dt, double linear_vel, double angular_vel);
void world_get_closest_obstacle(double* distance, double* angle);
void world_get_obstacle_clearances(double* distances, size_t count);
double world_get_wall_clearance(void);
void world_get_robot_pose(double* x, double* y, double* yaw);
void world_get_robot_velocity(double* linear_vel, double* angular_vel);
double world_get_time(void);

// World mapping state (defined in platform1_engine.cpp)
extern mapping_state_t w_mapping;

#endif // WORLD_MAPPING_H
