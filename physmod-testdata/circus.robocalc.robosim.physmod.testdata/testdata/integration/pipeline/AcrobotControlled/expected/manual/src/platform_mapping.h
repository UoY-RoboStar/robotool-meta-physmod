#ifndef PLATFORM_MAPPING_H
#define PLATFORM_MAPPING_H

#ifdef __cplusplus
extern "C" {
#endif

// Mapping for AcrobotControlled: world gravity, link-level sensor outputs, and actuator command.
// Structure matches the p-model naming (link.sensor / link.joint.actuator).
typedef struct mapping_state_t {
    const char* operation_name;  // Current operation name (for d-model integration)
    double k;                    // Cycle index from D-model
    struct {
        double gravity_world[3];  // Gravity vector in world frame (x,y,z)
    } World;
    struct {
        struct {
            struct {
                // JointEncoder outputs for ShoulderJoint (q1)
                double AngleOut;
                double VelocityOut;
            } ShoulderEncoder;
            struct {
                // Dynamics outputs exposed as a sensor (computed on-platform).
                // Ordered in Drake coordinates: [q1=shoulder, q2=elbow].
                double M_inv[2][2];  // Inverse mass matrix
                double bias[2];      // C(q,qdot)qdot + G(q) (no damping)
            } DynamicsSensor;
        } BaseLink;
        struct {
            struct {
                struct {
                    // ControlledMotor input for ElbowJoint (u)
                    double ControlIn;
                } ElbowMotor;
            } ElbowJoint;
            struct {
                // JointEncoder outputs for ElbowJoint (q2)
                double AngleOut;
                double VelocityOut;
            } ElbowEncoder;
        } Link1;
        struct {
            // Link2 has no sensors/actuators in this example.
            double _unused;
        } Link2;
    } AcrobotControlled;
} mapping_state_t;

extern mapping_state_t p_mapping;

// Sensor ABI: world/platform mapping passes sensor outputs via sensor_data_t.
typedef struct sensor_data_t {
    struct {
        double gravity_world[3];
    } World;
    struct {
        struct {
            struct {
                double AngleOut;
                double VelocityOut;
            } ShoulderEncoder;
            struct {
                double M_inv[2][2];
                double bias[2];
            } DynamicsSensor;
        } BaseLink;
        struct {
            struct {
                double AngleOut;
                double VelocityOut;
            } ElbowEncoder;
        } Link1;
    } AcrobotControlled;
    double time;
} sensor_data_t;

typedef sensor_data_t sensor_outputs_t;

#ifdef __cplusplus
}
#endif

#endif // PLATFORM_MAPPING_H
