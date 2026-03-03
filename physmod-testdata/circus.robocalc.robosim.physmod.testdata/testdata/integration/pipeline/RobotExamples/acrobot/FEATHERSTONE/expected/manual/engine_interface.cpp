#include <array>
#include <cmath>
#include <cstddef>
#include <iostream>

#include "dmodel_interface.h"
#include "interfaces.hpp"
#include "platform_mapping.h"
#include "platform1_state.hpp"
#include "utils.h"
#include "world_mapping.h"

namespace {

class HeadlessDModelIO final : public IDModelIO {
public:
    bool registerRead(int* type, void* data, size_t size) override;
    void registerWrite(const OperationData* op) override;
    void tock(int type) override;
};

bool HeadlessDModelIO::registerRead(int* type, void* data, size_t size) {
    (void)type;
    (void)data;
    (void)size;
    return false;
}

void HeadlessDModelIO::registerWrite(const OperationData* op) {
    (void)op;
}

void HeadlessDModelIO::tock(int type) {
    (void)type;
}

struct OperationScheduleEntry {
    const char* name;
    double duration_seconds;
};

struct SimulationConfig {
    double duration_seconds = 28.32;
    std::array<OperationScheduleEntry, 3> schedule{{
        {"PrePick", 6.0},
        {"PrePlace", 12.0},
        {"Return", 10.32}
    }};
};

std::string default_log_path() {
    return "../pmh_velocity_log_our_implementation.csv";
}

}  // namespace

int main() {
    auto* platform_engine = get_platform_engine();
    auto* world_engine = get_world_engine();
    auto* platform_mapping = get_platform_mapping();
    auto* mapping = get_platform_world_mapping();

    if (!platform_engine || !platform_mapping) {
        std::cerr << "[Harness] Missing platform engine or mapping implementation" << std::endl;
        return 1;
    }

    const bool has_world = (world_engine != nullptr) && (mapping != nullptr);

    HeadlessDModelIO io{};
    set_active_dmodel_io(&io);

    enable_velocity_logging(default_log_path().c_str());

    platform_engine->initialise();
    platform_mapping->initialise();

    if (has_world) {
        world_engine->initialise();
        mapping->initialise();
    }

    auto& platform_state = static_cast<platform1::State&>(platform_engine->getPlatform().getState());

    const double dt = (platform_state.dt > 1e-12) ? platform_state.dt : 0.005;
    const SimulationConfig config{};
    const int total_steps = static_cast<int>(std::ceil(config.duration_seconds / dt));

    sensor_data_t sensors{};
    std::size_t schedule_index = 0;
    double operation_elapsed = 0.0;

    for (int step = 0; step < total_steps; ++step) {
        const auto& current = config.schedule[schedule_index];
        p_mapping.operation_name = current.name;
        p_mapping.k = operation_elapsed;

        if (has_world) {
            mapping->computeWorldInputs(platform_state, world_engine->state());
            world_engine->update();
            mapping->computeSensorReadings(world_engine->state(), platform_state, sensors);
        } else {
            sensors.time = platform_engine->getTime();
        }

        platform_mapping->updateFromSensors(sensors);

        update_mapping_from_operations();

        platform_engine->update();


        operation_elapsed += dt;
        if (operation_elapsed >= current.duration_seconds) {
            operation_elapsed = 0.0;
            schedule_index = (schedule_index + 1) % config.schedule.size();
        }
    }

    disable_velocity_logging();
    set_active_dmodel_io(nullptr);
    return 0;
}
