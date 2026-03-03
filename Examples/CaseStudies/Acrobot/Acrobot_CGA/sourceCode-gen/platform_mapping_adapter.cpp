#include "interfaces.hpp"
#include "platform_mapping.h"  // Has proper extern "C" guards internally

extern mapping_state_t w_mapping;
extern "C" mapping_state_t p_mapping;

namespace {
class PlatformMappingImpl final : public IPlatformMapping {
public:
    void initialise() override {
        // No world snapshot mirroring; mapping is updated from sensors explicitly
    }

    mapping_state_t& mapping() override {
        return p_mapping;
    }

    void updateFromSensors(const sensor_data_t& sensor_output) override {
        // Copy world-level sensor outputs into mapping.
        // sensor_data_t includes both world-dependent and platform-internal sensors.
        p_mapping.World.gravity_world[0] = sensor_output.World.gravity_world[0];
        p_mapping.World.gravity_world[1] = sensor_output.World.gravity_world[1];
        p_mapping.World.gravity_world[2] = sensor_output.World.gravity_world[2];

        // Sensor outputs - copied from sensor_output
        // Encoder sensor outputs - copied from sensor_output (fallback)
        p_mapping.SimpleArm.BaseLink.ShoulderEncoder.AngleOut =
            sensor_output.SimpleArm.BaseLink.ShoulderEncoder.AngleOut;
        p_mapping.SimpleArm.BaseLink.ShoulderEncoder.VelocityOut =
            sensor_output.SimpleArm.BaseLink.ShoulderEncoder.VelocityOut;
        p_mapping.SimpleArm.Link1.ElbowEncoder.AngleOut =
            sensor_output.SimpleArm.Link1.ElbowEncoder.AngleOut;
        p_mapping.SimpleArm.Link1.ElbowEncoder.VelocityOut =
            sensor_output.SimpleArm.Link1.ElbowEncoder.VelocityOut;
    }
};

PlatformMappingImpl platform_mapping_instance;
} // namespace

IPlatformMapping* get_platform_mapping() {
    return &platform_mapping_instance;
}
