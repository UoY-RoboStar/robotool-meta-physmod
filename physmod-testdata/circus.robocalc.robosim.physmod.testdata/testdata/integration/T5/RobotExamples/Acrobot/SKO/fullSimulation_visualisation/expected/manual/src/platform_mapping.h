#ifndef PLATFORM_MAPPING_H
#define PLATFORM_MAPPING_H

#ifdef __cplusplus
extern "C" {
#endif

// Mapping for Acrobot: joint states, dynamics sensors, world gravity, and torque command
typedef struct mapping_state_t {
    const char* operation_name;  // Current operation name (for d-model integration)
    double k;                     // Cycle index from D-model
    struct {
        double gravity_world[3];  // Gravity vector in world frame (x,y,z)
    } World;
    struct {
        struct {
            struct {
                // Shoulder joint state (base_link -> upper_link)
                double angle;      // radians
                double velocity;   // rad/s
            } shoulder;
            struct {
                // Elbow joint state (upper_link -> lower_link)
                double angle;      // radians
                double velocity;   // rad/s
                struct { double TorqueIn; } elbow_actuator;
            } elbow;
        } upper_link;
        struct {
            // Combined dynamics and energies for controller
            double M_inv[2][2];   // Inverse mass matrix
            double bias[2];       // C(q,qdot) qdot + G(q)
            double PE;            // Potential energy
            double KE;            // Kinetic energy
        } dynamics;
    } Acrobot;
} mapping_state_t;

extern mapping_state_t p_mapping;

// Minimal sensor ABI: world → platform adapter passes gravity via sensor_data_t
typedef struct sensor_data_t {
    struct {
        double gravity_world[3];
    } World;
    double time;
} sensor_data_t;

typedef sensor_data_t sensor_outputs_t;

#ifdef __cplusplus
}
#endif

#endif // PLATFORM_MAPPING_H
