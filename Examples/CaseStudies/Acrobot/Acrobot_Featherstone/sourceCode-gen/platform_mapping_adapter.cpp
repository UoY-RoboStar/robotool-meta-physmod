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
        // Sensor outputs - copied from sensor_output
        p_mapping.Acrobot.BaseLink.ShoulderEncoder.AngleOut = sensor_output.Acrobot.BaseLink.ShoulderEncoder.AngleOut;
        p_mapping.Acrobot.BaseLink.ShoulderEncoder.VelocityOut = sensor_output.Acrobot.BaseLink.ShoulderEncoder.VelocityOut;
        p_mapping.Acrobot.Link1.ElbowEncoder.AngleOut = sensor_output.Acrobot.Link1.ElbowEncoder.AngleOut;
        p_mapping.Acrobot.Link1.ElbowEncoder.VelocityOut = sensor_output.Acrobot.Link1.ElbowEncoder.VelocityOut;
    }
};

PlatformMappingImpl platform_mapping_instance;
} // namespace

IPlatformMapping* get_platform_mapping() {
    return &platform_mapping_instance;
}
