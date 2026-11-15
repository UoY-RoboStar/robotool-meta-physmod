// platform_mapping_adapter.cpp - Copies sensor values into the platform mapping
//
// This adapter populates p_mapping from sensor_output produced by world_mapping.
// sensor_output includes world-dependent sensors and platform-internal sensors
// derived from platform_state in computeSensorReadings().

#include "interfaces.hpp"
#include "platform_mapping.h"

extern mapping_state_t w_mapping;
extern "C" mapping_state_t p_mapping;

namespace {
class PlatformMappingImpl final : public IPlatformMapping {
public:
    void initialise() override {}

    mapping_state_t& mapping() override {
        return p_mapping;
    }

    void updateFromSensors(const sensor_data_t& sensor_output) override {
        // Copy world sensors from sensor_data_t (computed by world_mapping.cpp)
        p_mapping.World.gravity_world[0] = sensor_output.World.gravity_world[0];
        p_mapping.World.gravity_world[1] = sensor_output.World.gravity_world[1];
        p_mapping.World.gravity_world[2] = sensor_output.World.gravity_world[2];

        // Copy platform sensors from sensor_data_t (derived from platform_state)
        p_mapping.AcrobotControlled.BaseLink.ShoulderEncoder.AngleOut =
            sensor_output.AcrobotControlled.BaseLink.ShoulderEncoder.AngleOut;
        p_mapping.AcrobotControlled.BaseLink.ShoulderEncoder.VelocityOut =
            sensor_output.AcrobotControlled.BaseLink.ShoulderEncoder.VelocityOut;
        p_mapping.AcrobotControlled.Link1.ElbowEncoder.AngleOut =
            sensor_output.AcrobotControlled.Link1.ElbowEncoder.AngleOut;
        p_mapping.AcrobotControlled.Link1.ElbowEncoder.VelocityOut =
            sensor_output.AcrobotControlled.Link1.ElbowEncoder.VelocityOut;

        // NOTE: Dynamics (M_inv, bias) are computed internally by the controller,
        // not provided by the platform. If a controller needed dynamics from the
        // platform, they would be defined as sensors in the p-model and mapped
        // to d-model events via mapping.pm.
    }
};

PlatformMappingImpl platform_mapping_instance;
} // namespace

IPlatformMapping* get_platform_mapping() {
    return &platform_mapping_instance;
}
