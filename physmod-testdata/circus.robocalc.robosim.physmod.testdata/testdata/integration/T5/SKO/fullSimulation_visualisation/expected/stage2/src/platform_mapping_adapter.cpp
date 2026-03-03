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
        // Copy sensor readings from world mapping to platform mapping (controller's view)
        p_mapping.SimpleArm.BaseLink.ObjectBeamSensor.measurement = 
            sensor_output.SimpleArm.BaseLink.ObjectBeamSensor.measurement;
        p_mapping.SimpleArm.BaseLink.GoalBeamSensor.measurement = 
            sensor_output.SimpleArm.BaseLink.GoalBeamSensor.measurement;
    }
};

PlatformMappingImpl platform_mapping_instance;
} // namespace

IPlatformMapping* get_platform_mapping() {
    return &platform_mapping_instance;
}


