// MobileRobot orchestrator (manual integration-test harness).
// Runs CacheConsM controller against the physics engine.

#include "orchestrator.h"
#include "interfaces.hpp"
#include "platform1_state.hpp"
#include "platform_mapping.h"
#include "world_mapping.h"
#include "dmodel_interface.h"

extern "C" {
#include "defs_fmi.h"
}

#include <chrono>
#include <condition_variable>
#include <cstdlib>
#include <deque>
#include <fstream>
#include <iomanip>
#include <mutex>
#include <thread>
#include <atomic>

namespace {
void sleep_seconds(double seconds) {
    if (seconds <= 0.0) {
        return;
    }
    std::this_thread::sleep_for(std::chrono::duration<double>(seconds));
}

struct DModelInputEvent {
    int type;
    double value;
};

std::mutex dmodel_input_mutex;
std::condition_variable dmodel_input_cv;
std::deque<DModelInputEvent> dmodel_input_queue;
bool dmodel_terminate = false;

double current_lv = 0.0;
double current_av = 0.0;
std::atomic<bool> move_emitted{false};

std::ofstream outputs_log;
bool outputs_log_ready = false;
constexpr double kControlPeriod = 0.2;
constexpr double kLogPeriod = 0.2;
constexpr double kTimeEps = 1e-9;
constexpr size_t kObstacleCount = 4;
std::ofstream clearance_log;
bool clearance_log_ready = false;

void init_outputs_log() {
    outputs_log.open("outputs.csv");
    if (!outputs_log.is_open()) {
        outputs_log_ready = false;
        return;
    }
    outputs_log << "time,{mapping}.mapping.closestDistance,{mapping}.mapping.closest_distance,"
                   "{mapping}.mapping.closestAngle,{mapping}.mapping.closest_angle,"
                   "{dmodel}.dmodel.move,{dmodel}.dmodel.lv,{dmodel}.dmodel.av"
                << std::endl;
    outputs_log << std::boolalpha;
    outputs_log_ready = true;
}

void init_clearance_log() {
    clearance_log.open("collision_clearance.csv");
    if (!clearance_log.is_open()) {
        clearance_log_ready = false;
        return;
    }
    clearance_log << "time,box1,box2,cylinder1,cylinder2,wall_min" << std::endl;
    clearance_log_ready = true;
}

void log_outputs(double time,
                 bool closest_distance_evt,
                 double closest_distance,
                 bool closest_angle_evt,
                 double closest_angle,
                 bool move_evt,
                 double lv,
                 double av) {
    if (!outputs_log_ready) {
        return;
    }
    outputs_log << std::fixed << std::setprecision(6)
                << time << ","
                << closest_distance_evt << "," << closest_distance << ","
                << closest_angle_evt << "," << closest_angle << ","
                << move_evt << "," << lv << "," << av
                << std::endl;
}

void log_clearances(double time, const double* distances, size_t count, double wall_clearance) {
    if (!clearance_log_ready || !distances) {
        return;
    }
    clearance_log << std::fixed << std::setprecision(6)
                  << time;
    for (size_t i = 0; i < count; ++i) {
        clearance_log << "," << distances[i];
    }
    clearance_log << "," << wall_clearance << std::endl;
}

void publish_dmodel_inputs(double distance, double angle) {
    std::lock_guard<std::mutex> lock(dmodel_input_mutex);
    dmodel_input_queue.clear();
    dmodel_input_queue.push_back({INPUT_CLOSEST_DISTANCE, distance});
    dmodel_input_queue.push_back({INPUT_CLOSEST_ANGLE, angle});
    dmodel_input_queue.push_back({INPUT_DONE, 0.0});
    dmodel_input_cv.notify_all();
}

bool registerRead_impl(int* type, void* data, size_t size) {
    if (!type) {
        return false;
    }

    std::unique_lock<std::mutex> lock(dmodel_input_mutex);
    dmodel_input_cv.wait(lock, [] {
        return dmodel_terminate || !dmodel_input_queue.empty();
    });

    if (dmodel_input_queue.empty()) {
        *type = INPUT_TERMINATE;
        return false;
    }

    const DModelInputEvent evt = dmodel_input_queue.front();
    dmodel_input_queue.pop_front();
    *type = evt.type;

    if (data && size >= sizeof(EventData)) {
        EventData* event = static_cast<EventData*>(data);
        event->occurred = true;
        event->value = evt.value;
    }

    return true;
}

void registerWrite_impl(const OperationData* op) {
    if (!op) {
        return;
    }

    if (op->type == OUTPUT_MOVE) {
        move_emitted.store(true, std::memory_order_relaxed);
        current_av = op->params[0];
        current_lv = op->params[1];
        apply_move_command(&p_mapping, current_lv, current_av);
    }
}

void tock_impl(int /*type*/) {}
} // namespace

class DModelIOAdapter : public IDModelIO {
public:
    bool registerRead(int* type, void* data, size_t size) override {
        return registerRead_impl(type, data, size);
    }

    void registerWrite(const OperationData* op) override {
        registerWrite_impl(op);
    }

    void tock(int type) override {
        tock_impl(type);
    }
};

engine_threads_t start_engine_runtime() {
    engine_threads_t threads{};
    return threads;
}

void shutdown_engine(engine_threads_t /*engine_threads*/) {}

void Wait(double cycleDurationSeconds) {
    sleep_seconds(cycleDurationSeconds);
}

int main(int argc, char* argv[]) {
    int max_steps = 12000;
    if (argc > 1) {
        const int parsed = std::atoi(argv[1]);
        if (parsed > 0) {
            max_steps = parsed;
        }
    }
    double sleep_scale = 1.0;
    if (argc > 2) {
        const double parsed_scale = std::atof(argv[2]);
        if (parsed_scale >= 0.0) {
            sleep_scale = parsed_scale;
        }
    }
    std::srand(0);

    IWorldEngine* world_engine = get_world_engine();
    IPlatformWorldMapping* platform_world_mapping = get_platform_world_mapping();
    IPlatformMapping* platform_mapping = get_platform_mapping();
    IPlatformEngine* platform_engine = get_platform_engine();

    world_engine->initialise();
    platform_world_mapping->initialise();
    platform_engine->initialise();
    if (platform_mapping) {
        platform_mapping->initialise();
    }

    init_outputs_log();
    init_clearance_log();

    DModelIOAdapter dmodel_io;
    set_active_dmodel_io(&dmodel_io);

    ModelData controller_state{};
    init(&controller_state);

    const auto& platform_state =
        static_cast<const platform1::State&>(platform_engine->getPlatform().getState());
    const double dt = platform_state.dt > 0.0 ? platform_state.dt : 0.01;

    double lv = 0.0;
    double av = 0.0;
    apply_move_command(&p_mapping, lv, av);
    double next_control_time = kControlPeriod;
    double next_log_time = kLogPeriod;

    {
        sensor_data_t sensors{};
        platform_world_mapping->computeSensorReadings(
            world_engine->state(),
            platform_engine->getPlatform().getState(),
            sensors);
        if (platform_mapping) {
            platform_mapping->updateFromSensors(sensors);
        }
        log_outputs(
            world_get_time(),
            true,
            sensors.Turtlebot3.Burger.BaseLink.TBLidar.scan.range_min,
            true,
            sensors.Turtlebot3.Burger.BaseLink.TBLidar.scan.angle_min,
            false,
            lv,
            av);

        double obstacle_distances[kObstacleCount] = {};
        world_get_obstacle_clearances(obstacle_distances, kObstacleCount);
        const double wall_clearance = world_get_wall_clearance();
        log_clearances(world_get_time(), obstacle_distances, kObstacleCount, wall_clearance);
    }

    for (int step = 0; step < max_steps; ++step) {
        world_step(dt, lv, av);

        const double now = world_get_time();
        double obstacle_distances[kObstacleCount] = {};
        world_get_obstacle_clearances(obstacle_distances, kObstacleCount);
        const double wall_clearance = world_get_wall_clearance();
        log_clearances(now, obstacle_distances, kObstacleCount, wall_clearance);
        sensor_data_t sensors{};
        bool ran_control = false;

        if (now + kTimeEps >= next_control_time) {
            platform_world_mapping->computeSensorReadings(
                world_engine->state(),
                platform_engine->getPlatform().getState(),
                sensors);

            if (platform_mapping) {
                platform_mapping->updateFromSensors(sensors);
            }

            publish_dmodel_inputs(
                sensors.Turtlebot3.Burger.BaseLink.TBLidar.scan.range_min,
                sensors.Turtlebot3.Burger.BaseLink.TBLidar.scan.angle_min);

            move_emitted.store(false, std::memory_order_relaxed);
            tick(&controller_state);

            lv = current_lv;
            av = current_av;
            ran_control = true;
            next_control_time += kControlPeriod;
        }

        if (now + kTimeEps >= next_log_time) {
            if (!ran_control) {
                platform_world_mapping->computeSensorReadings(
                    world_engine->state(),
                    platform_engine->getPlatform().getState(),
                    sensors);

                if (platform_mapping) {
                    platform_mapping->updateFromSensors(sensors);
                }
            }

            log_outputs(
                now,
                true,
                sensors.Turtlebot3.Burger.BaseLink.TBLidar.scan.range_min,
                true,
                sensors.Turtlebot3.Burger.BaseLink.TBLidar.scan.angle_min,
                move_emitted.load(std::memory_order_relaxed),
                lv,
                av);
            next_log_time += kLogPeriod;
        }

        platform_engine->update();
        world_engine->update();
        Wait(dt * sleep_scale);
    }

    if (outputs_log.is_open()) {
        outputs_log.close();
    }
    if (clearance_log.is_open()) {
        clearance_log.close();
    }

    return 0;
}
