#include "interfaces.hpp"
#include "platform1_state.hpp"  // For platform1::State
#include "world_mapping.h"

namespace {
class PlatformWorldMappingImpl final : public IPlatformWorldMapping {
public:
    void initialise() override {}

    void computeSensorReadings(
        const IWorldState& /*world_state*/,
        const IPlatformState& /*platform_state*/,
        sensor_data_t& out) override {
        // Provide gravity as a world sensor (world-frame 3D vector)
        // For this example, use constant Earth gravity in -Z
        out.World.gravity_world[0] = 0.0;
        out.World.gravity_world[1] = 0.0;
        out.World.gravity_world[2] = -9.81;

        // Mirror into world mapping snapshot (optional; allows debugging)
        w_mapping.World.gravity_world[0] = out.World.gravity_world[0];
        w_mapping.World.gravity_world[1] = out.World.gravity_world[1];
        w_mapping.World.gravity_world[2] = out.World.gravity_world[2];

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
