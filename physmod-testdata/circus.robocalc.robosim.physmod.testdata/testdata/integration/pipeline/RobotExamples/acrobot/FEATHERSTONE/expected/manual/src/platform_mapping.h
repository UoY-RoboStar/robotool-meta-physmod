#ifndef PLATFORM_MAPPING_H
#define PLATFORM_MAPPING_H

#ifdef __cplusplus
extern "C" {
#endif

// Mapping for Acrobot (Featherstone): joint encoders and world gravity.
typedef struct mapping_state_t {
    const char* operation_name;  // Current operation name (for d-model integration)
    double k;                     // Cycle index from D-model
    struct {
        double gravity_world[3];  // Gravity vector in world frame (x,y,z)
    } World;
    struct {
        struct {
            struct { double AngleOut; double VelocityOut; } ShoulderEncoder;
        } BaseLink;
        struct {
            struct { double AngleOut; double VelocityOut; } ElbowEncoder;
        } Link1;
    } Acrobot;
} mapping_state_t;

extern mapping_state_t p_mapping;

// Minimal sensor ABI: platform sensors + world gravity.
typedef struct sensor_data_t {
    struct {
        struct {
            struct { double AngleOut; double VelocityOut; } ShoulderEncoder;
        } BaseLink;
        struct {
            struct { double AngleOut; double VelocityOut; } ElbowEncoder;
        } Link1;
    } Acrobot;
    struct {
        double gravity_world[3];
    } World;
    double time;
} sensor_data_t;

typedef sensor_data_t sensor_outputs_t;

static inline void update_mapping_from_operations(void) {
    // No mapping operations for Acrobot Featherstone.
}

#ifdef __cplusplus
}
#endif

#endif // PLATFORM_MAPPING_H
