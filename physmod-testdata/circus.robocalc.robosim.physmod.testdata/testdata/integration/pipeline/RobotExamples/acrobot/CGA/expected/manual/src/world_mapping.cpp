#include "interfaces.hpp"
#include "platform1_state.hpp"  // For platform1::State
#include "world_mapping.h"

namespace {
class PlatformWorldMappingImpl final : public IPlatformWorldMapping {
public:
    void initialise() override {}

    void computeSensorReadings(
        const IWorldState& world_state,
        const IPlatformState& platform_state,
        sensor_data_t& out) override {

        // Cast to concrete platform type to access B_k matrices (physics-computed FK)
        const auto& state = static_cast<const platform1::State&>(platform_state);

        // Use physics-computed B_k matrices for accurate gripper position
        double object_sensor = 0.0;
        double goal_sensor = 0.0;
        scenario_update_sensors(state.B_k, &object_sensor, &goal_sensor);

        w_mapping.SimpleArm.BaseLink.ObjectBeamSensor.measurement = object_sensor;
        w_mapping.SimpleArm.BaseLink.GoalBeamSensor.measurement = goal_sensor;

        out.SimpleArm.BaseLink.ObjectBeamSensor.measurement = object_sensor;
        out.SimpleArm.BaseLink.GoalBeamSensor.measurement = goal_sensor;
        out.time = 0.0; // Orchestrator will set if needed
    }
    
    void computeWorldInputs(
        const IPlatformState& platform_state,
        IWorldState& world_state) override {
        
        // In this simple example, world positions are set directly by scenario_update_sensors
        // For a more complex example, this would compute gripper position from FK
        // and update world entity positions based on platform actuator outputs
    }
};

PlatformWorldMappingImpl platform_world_mapping_instance;
} // namespace

IPlatformWorldMapping* get_platform_world_mapping() {
    return &platform_world_mapping_instance;
}
