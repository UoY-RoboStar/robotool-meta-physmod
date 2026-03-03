#ifndef PLATFORM_MAPPING_H
#define PLATFORM_MAPPING_H

#include <stdbool.h>
#include <math.h>
#include <string.h>

#ifdef __cplusplus
extern "C" {
#endif

extern const char* determineOperation(void);
// Paper-aligned time scaling (cycles per second)
// Provided by the orchestrator; used to convert cycles -> seconds
double get_tScale(void);

typedef struct mapping_state_t {
    const char* operation_name;
    double k;          // Cycle index from D-model
    struct { double gravity_world[3]; } World;
    struct {
        struct {
            struct { struct { double AngleOut; double VelocityOut; } ShoulderEncoder; } BaseLink;
            struct { struct { double AngleOut; double VelocityOut; } ElbowEncoder; } Link1;
        };
    } __synthetic0;
    struct {
        struct {
            struct {
                struct { double TorqueIn; } WristJointMotor;
            } WristJoint;
        } IntermediateLink;
        struct {
            struct {
                struct { double TorqueIn; } ElbowJointMotor;
            } ElbowJoint;
            struct { double AngleOut; double VelocityOut; } ShoulderEncoder;
            struct { double measurement; } ObjectBeamSensor;
            struct { double measurement; } GoalBeamSensor;
        } BaseLink;
        struct { struct { double AngleOut; double VelocityOut; } ElbowEncoder; } Link1;
    } SimpleArm;
} mapping_state_t;

extern mapping_state_t p_mapping;

typedef struct sensor_data_t {
    struct { double gravity_world[3]; } World;
    struct {
        struct {
            struct { struct { double AngleOut; double VelocityOut; } ShoulderEncoder; } BaseLink;
            struct { struct { double AngleOut; double VelocityOut; } ElbowEncoder; } Link1;
        };
    } __synthetic0;
    struct {
        struct {
            struct { double AngleOut; double VelocityOut; } ShoulderEncoder;
            struct { double measurement; } ObjectBeamSensor;
            struct { double measurement; } GoalBeamSensor;
        } BaseLink;
        struct { struct { double AngleOut; double VelocityOut; } ElbowEncoder; } Link1;
    } SimpleArm;
    double time;
} sensor_data_t;

typedef sensor_data_t sensor_outputs_t;

typedef struct {
    double object_detection_lower;
    double object_detection_upper;
    double goal_detection_lower;
    double goal_detection_upper;
} mapping_config_t;

#ifdef __has_include
#  if __has_include("platform_mapping.generated.h")
#    include "platform_mapping.generated.h"
#  endif
#endif

static const mapping_config_t DEFAULT_MAPPING_CONFIG = {
    .object_detection_lower = 4.749,
    .object_detection_upper = 4.75111,
    .goal_detection_lower = 4.749,
    .goal_detection_upper = 4.75111,
};


static inline bool Event1(double distance, const mapping_config_t* config) {
    return (distance < config->object_detection_upper &&
            distance > config->object_detection_lower);
}

static inline bool Event2(double distance, const mapping_config_t* config) {
    return (distance < config->goal_detection_upper &&
            distance > config->goal_detection_lower);
}

static inline double ind(double t, double lower, double upper) {
    return (t >= lower && t <= upper) ? 1.0 : 0.0;
}

static inline double PrePick(double k_seconds) {
    const double k = k_seconds;
    return 14.40105 * (
        -ind(k, 0.0, 1.0) * -33.0 * pow(k, 9) * (18694.0 * pow(k, 2) - 13439.0 * k - 5255.0) / 1250.0
        -ind(k, 1.0, 2.0) * 33.0 * pow(2.0 - k, 9) * (18694.0 * pow(2.0 - k, 2) - 13439.0 * (2.0 - k) - 5255.0) / 1250.0
    );
}

static inline double PrePlace(double k_seconds) {
    const double k = k_seconds;
    return -14.40105 * (
        -ind(k, 0.0, 1.0) * -33.0 * pow(k, 9) * (18694.0 * pow(k, 2) - 13439.0 * k - 5255.0) / 1250.0
        -ind(k, 1.0, 2.0) * 33.0 * pow(2.0 - k, 9) * (18694.0 * pow(2.0 - k, 2) - 13439.0 * (2.0 - k) - 5255.0) / 1250.0
        -ind(k, 2.0, 3.0) * -33.0 * pow(k - 2.0, 9) * (18694.0 * pow(k - 2.0, 2) - 13439.0 * (k - 2.0) - 5255.0) / 1250.0
        -ind(k, 3.0, 4.0) * 33.0 * pow(4.0 - k, 9) * (18694.0 * pow(4.0 - k, 2) - 13439.0 * (4.0 - k) - 5255.0) / 1250.0
    );
}

static inline double Return(double k_seconds) {
    return PrePick(k_seconds);
}

static inline double ContinuousOperation(double object_distance, double goal_distance, double absolute_time) {
    (void)object_distance;
    (void)goal_distance;
    (void)absolute_time;
    const char* current_op = p_mapping.operation_name ? p_mapping.operation_name : "Invalid";
    const double k_seconds = (p_mapping.k < 0.0) ? 0.0 : p_mapping.k;
    if (strcmp(current_op, "PrePick") == 0) {
        return PrePick(k_seconds);
    } else if (strcmp(current_op, "PrePlace") == 0) {
        return PrePlace(k_seconds);
    } else if (strcmp(current_op, "Return") == 0) {
        return Return(k_seconds);
    }
    return 0.0;
}

static inline void update_mapping_from_operations(void) {
    const double torque = ContinuousOperation(
        p_mapping.SimpleArm.BaseLink.ObjectBeamSensor.measurement,
        p_mapping.SimpleArm.BaseLink.GoalBeamSensor.measurement,
        0.0);
    p_mapping.SimpleArm.BaseLink.ElbowJoint.ElbowJointMotor.TorqueIn = torque;
}

#ifdef __cplusplus
}

// ============================================================================
// C++ Operation and Event Implementations (Generated from Mapping.pm)
// Include interfaces.hpp before including this file to get IOperation/IEvent definitions
// ============================================================================

#include <cmath>
#include <vector>
#include <string>
#include <cstring>

// Note: ind() helper is defined in the C section above and shared with C++ code

/**
 * PrePick operation (generated from Mapping.pm lines 3-12)
 * 
 * Maps phase time k to elbow joint torque following the polynomial:
 *   TorqueIn = -ind(k,0,1) * k^10 * (34683 + 80634*k - 102817*k^2)/2500
 *            + ind(k,1,2) * k^10 * (34683 + 80634*k - 102817*k^2)/2500
 * 
 * Integrated variables: k (dk/dt = 1)
 */
class PrePickOperation : public IOperation {
public:
    const char* getName() const override { 
        return "PrePick"; 
    }
    
    std::vector<std::pair<std::string, double>> getIntegratedVariables() const override {
        return {{"k", 1.0}};  // From: equation derivative(k) == 1
    }
    
    void computeOutputs(mapping_state_t& mapping) const override {
        // Read integrated variable k from mapping
        const double k = mapping.k;
        
        // Direct typed access - no string lookup, compiler-optimized
        const double k2 = k * k;
        const double k10 = std::pow(k, 10);
        const double poly = (34683.0 + 80634.0 * k - 102817.0 * k2) / 2500.0;
        
        mapping.SimpleArm.BaseLink.ElbowJoint.ElbowJointMotor.TorqueIn = 
            -ind(k, 0, 1) * k10 * poly
            + ind(k, 1, 2) * k10 * poly;
    }
};

/**
 * PrePlace operation (generated from Mapping.pm lines 14-24)
 * 
 * Maps phase time k to elbow joint torque with three phases:
 *   [0,1]: positive ramp up
 *   [1,2]: constant pi/4
 *   [2,3]: negative ramp down
 * 
 * Integrated variables: k (dk/dt = 1)
 */
class PrePlaceOperation : public IOperation {
public:
    const char* getName() const override { 
        return "PrePlace"; 
    }
    
    std::vector<std::pair<std::string, double>> getIntegratedVariables() const override {
        return {{"k", 1.0}};
    }
    
    void computeOutputs(mapping_state_t& mapping) const override {
        const double k = mapping.k;
        const double k2 = k * k;
        const double k10 = std::pow(k, 10);
        const double poly = (34683.0 + 80634.0 * k - 102817.0 * k2) / 2500.0;
        
        mapping.SimpleArm.BaseLink.ElbowJoint.ElbowJointMotor.TorqueIn = 
            ind(k, 0, 1) * k10 * poly
            + ind(k, 1, 2) * (3.141592653589793 / 4.0)
            - ind(k, 2, 3) * k10 * poly;
    }
};

/**
 * Return operation (generated from Mapping.pm lines 26-35)
 * 
 * Maps phase time k to elbow joint torque for return trajectory:
 *   [0,1]: negative ramp
 *   [1,2]: positive ramp
 * 
 * Integrated variables: k (dk/dt = 1)
 */
class ReturnOperation : public IOperation {
public:
    const char* getName() const override { 
        return "Return"; 
    }
    
    std::vector<std::pair<std::string, double>> getIntegratedVariables() const override {
        return {{"k", 1.0}};
    }
    
    void computeOutputs(mapping_state_t& mapping) const override {
        const double k = mapping.k;
        const double k2 = k * k;
        const double k10 = std::pow(k, 10);
        const double poly = (34683.0 + 80634.0 * k - 102817.0 * k2) / 2500.0;
        
        mapping.SimpleArm.BaseLink.ElbowJoint.ElbowJointMotor.TorqueIn = 
            -ind(k, 0, 1) * k10 * poly
            + ind(k, 1, 2) * k10 * poly;
    }
};

/**
 * DetectObject event (generated from Mapping.pm lines 36-38)
 * 
 * Predicate: 4.749 < ObjectBeamSensor.measurement < 4.75111
 */
class DetectObjectEvent : public IEvent {
public:
    const char* getName() const override { 
        return "detectObject"; 
    }
    
    bool evaluate(const mapping_state_t& mapping) const override {
        const double sensor = mapping.SimpleArm.BaseLink.ObjectBeamSensor.measurement;
        return (sensor < 4.75111 && sensor > 4.749);
    }
};

/**
 * DetectGoal event (generated from Mapping.pm lines 40-43)
 * 
 * Predicate: 4.749 < GoalBeamSensor.measurement < 4.75111
 */
class DetectGoalEvent : public IEvent {
public:
    const char* getName() const override { 
        return "detectGoal"; 
    }
    
    bool evaluate(const mapping_state_t& mapping) const override {
        const double sensor = mapping.SimpleArm.BaseLink.GoalBeamSensor.measurement;
        return (sensor < 4.75111 && sensor > 4.749);
    }
};

// Operation and Event registries (singleton instances for orchestrator lookup)
namespace Operations {
    static PrePickOperation PrePick;
    static PrePlaceOperation PrePlace;
    static ReturnOperation Return;
    
    inline IOperation* get(const char* name) {
        if (strcmp(name, "PrePick") == 0) return &PrePick;
        if (strcmp(name, "PrePlace") == 0) return &PrePlace;
        if (strcmp(name, "Return") == 0) return &Return;
        return nullptr;
    }
}

namespace EventInstances {
    static DetectObjectEvent DetectObject;
    static DetectGoalEvent DetectGoal;

    inline IEvent* get(const char* name) {
        if (strcmp(name, "detectObject") == 0) return &DetectObject;
        if (strcmp(name, "detectGoal") == 0) return &DetectGoal;
        return nullptr;
    }
}

#endif // __cplusplus

#endif // PLATFORM_MAPPING_H
