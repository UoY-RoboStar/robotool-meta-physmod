#ifndef PLATFORM_MAPPING_H
#define PLATFORM_MAPPING_H

#ifdef __cplusplus
extern "C" {
#endif

// Mapping for AcrobotControlled: platform sensors, actuators, and world properties.
// Structure matches the p-model naming (link.sensor / link.joint.actuator).
//
// Sensor sources:
//   - Platform sensors (joint encoders): copied from platform_state in computeSensorReadings()
//   - World properties (gravity): from world_mapping.cpp via computeSensorReadings()
//
// NOTE: Dynamics (M_inv, bias) are computed internally by the controller,
// not provided by the platform. If needed, they would be defined as sensors
// in the p-model and mapped to d-model events.
//
typedef struct mapping_state_t {
    const char* operation_name;  // Current operation name (for d-model integration)
    double k;                    // Cycle index from D-model
    
    // World properties (populated by world_mapping.cpp, NOT platform sensors)
    struct {
        double gravity_world[3];  // Gravity vector in world frame (x,y,z)
    } World;
    
    // Platform sensors and actuators (populated by updateFromSensors())
    struct {
        struct {
            struct {
                // JointEncoder outputs for ShoulderJoint (q1)
                double AngleOut;
                double VelocityOut;
            } ShoulderEncoder;
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
// Contains both world-dependent and platform-internal sensor readings.
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
