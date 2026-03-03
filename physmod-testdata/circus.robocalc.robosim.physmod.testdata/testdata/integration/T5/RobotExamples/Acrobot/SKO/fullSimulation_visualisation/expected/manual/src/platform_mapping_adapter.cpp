#include "interfaces.hpp"
#include "platform_mapping.h"  // extern "C" mapping_state_t, sensor_data_t

extern mapping_state_t w_mapping;
extern "C" mapping_state_t p_mapping;

namespace {
class PlatformMappingImpl final : public IPlatformMapping {
public:
    void initialise() override {}
    mapping_state_t& mapping() override { return p_mapping; }
    void updateFromSensors(const sensor_data_t& sensor_output) override {
        // Copy world gravity (world frame) into platform mapping for controller use
        p_mapping.World.gravity_world[0] = sensor_output.World.gravity_world[0];
        p_mapping.World.gravity_world[1] = sensor_output.World.gravity_world[1];
        p_mapping.World.gravity_world[2] = sensor_output.World.gravity_world[2];
    }
};

PlatformMappingImpl g_platform_mapping;
} // namespace

IPlatformMapping* get_platform_mapping() { return &g_platform_mapping; }


