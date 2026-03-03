#ifndef PLATFORM_MAPPING_H
#define PLATFORM_MAPPING_H

#include <math.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

// Mapping state for Turtlebot3_Burger (split into Turtlebot3::Burger by codegen).
typedef struct mapping_state_t {
    const char* operation_name;
    struct {
        double gravity_world[3];
    } World;
    struct {
        struct {
            struct {
                struct {
                    struct { double ControlIn; } LeftMotor;
                } LeftWheelJoint;
                struct {
                    struct { double ControlIn; } RightMotor;
                } RightWheelJoint;
                struct {
                    double trueDistance;
                    double measuredDistance;
                    double angle_min;
                    double closestDistance;
                    double closestAngle;
                    struct {
                        double range_min;
                        double angle_min;
                    } scan;
                } TBLidar;
                struct {
                    double angularRateLV;
                    double angularRateAV;
                    double currentLV;
                    double currentAV;
                } TBIMU;
            } BaseLink;
        } Burger;
    } Turtlebot3;
    double lv;
    double av;
} mapping_state_t;

extern mapping_state_t p_mapping;

typedef struct sensor_data_t {
    struct {
        double gravity_world[3];
    } World;
    struct {               // Turtlebot3
        struct {           // Burger
            struct {       // BaseLink
                struct {   // TBLidar
                    double trueDistance;
                    double measuredDistance;
                    double angle_min;
                    double closestDistance;
                    double closestAngle;
                    struct {
                        double range_min;
                        double angle_min;
                    } scan;
                } TBLidar;
                struct {   // TBIMU
                    double currentLV;
                    double currentAV;
                } TBIMU;
            } BaseLink;
        } Burger;
    } Turtlebot3;
    double time;
} sensor_data_t;

typedef sensor_data_t sensor_outputs_t;

static const double WHEEL_BASE = 0.160;
static const double WHEEL_RADIUS = 0.033;

static inline void apply_move_command(mapping_state_t* mapping, double lv, double av) {
    if (!mapping) {
        return;
    }
    mapping->lv = lv;
    mapping->av = av;
    mapping->Turtlebot3.Burger.BaseLink.LeftWheelJoint.LeftMotor.ControlIn =
        (lv - av * WHEEL_BASE / 2.0) / WHEEL_RADIUS;
    mapping->Turtlebot3.Burger.BaseLink.RightWheelJoint.RightMotor.ControlIn =
        (lv + av * WHEEL_BASE / 2.0) / WHEEL_RADIUS;
}

#ifdef __cplusplus
}
#endif

#endif // PLATFORM_MAPPING_H
