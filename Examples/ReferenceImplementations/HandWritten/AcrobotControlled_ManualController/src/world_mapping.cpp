// world_mapping.cpp - Computes sensor readings from world and platform state
//
// This implements IPlatformWorldMapping::computeSensorReadings for sensors
// that require world state (e.g., gravity, object positions, distances).
// Platform sensors (joint encoders) are copied from platform_state here.

#include "interfaces.hpp"
#include "platform1_state.hpp"
#include "world_mapping.h"

namespace {
class PlatformWorldMappingImpl final : public IPlatformWorldMapping {
public:
    void initialise() override {}

    void computeSensorReadings(
        const IWorldState& /*world_state*/,
        const IPlatformState& platform_state,
        sensor_data_t& out) override {
        // World sensor: gravity vector (world-frame 3D vector)
        // This is the ONLY world-dependent sensor for the Acrobot.
        out.World.gravity_world[0] = 0.0;
        out.World.gravity_world[1] = 0.0;
        out.World.gravity_world[2] = -9.81;

        const platform1::State& state = static_cast<const platform1::State&>(platform_state);

        out.AcrobotControlled.BaseLink.ShoulderEncoder.AngleOut =
            state.BaseLink_ShoulderEncoder_AngleOut;
        out.AcrobotControlled.BaseLink.ShoulderEncoder.VelocityOut =
            state.BaseLink_ShoulderEncoder_VelocityOut;
        out.AcrobotControlled.Link1.ElbowEncoder.AngleOut =
            state.Link1_ElbowEncoder_AngleOut;
        out.AcrobotControlled.Link1.ElbowEncoder.VelocityOut =
            state.Link1_ElbowEncoder_VelocityOut;

        // Mirror into world mapping snapshot (optional; allows debugging)
        w_mapping.World.gravity_world[0] = out.World.gravity_world[0];
        w_mapping.World.gravity_world[1] = out.World.gravity_world[1];
        w_mapping.World.gravity_world[2] = out.World.gravity_world[2];

        // NOTE: Platform sensors (joint encoders, dynamics sensor) are NOT set here.
        // They are copied directly from platform state by platform_mapping_adapter.cpp.
        out.time = 0.0; // Orchestrator will set if needed
    }
    
    void computeWorldInputs(
        const IPlatformState& platform_state,
        IWorldState& /*world_state*/) override {
        // For the Acrobot, no world inputs are computed from platform state.
        // A more complex example (e.g., pick-and-place) would compute gripper
        // position from FK and update world entity positions.
    }
};

PlatformWorldMappingImpl platform_world_mapping_instance;
} // namespace

IPlatformWorldMapping* get_platform_world_mapping() {
    return &platform_world_mapping_instance;
}
