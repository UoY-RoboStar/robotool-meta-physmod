/*
 * Main action (BaseModule) - implementation overview
 * --------------------------------------------------
 *   Init;
 *   mu X . SendToDModel;
 *          (ReceiveFromDModel interrupted by Wait(cycle));
 *          ResetTimer;
 *          Evolve interrupted by (timer >= cycle);
 *          X
 *
 * In this file the orchestration is realised as follows.
 *   - Init:  physics runtime setup, logging, and priming of the first input-channel message.
 *   - SendToDModel:  the latest sensor message is published to the input channel so the d-model can
 *                    consume both detect_object and detect_goal events for the current cycle.
 *   - ReceiveFromDModel:  registerWrite enqueues torque requests which are handled by a dedicated
 *                          output-processing thread that updates the platform mapping.
 *   - Wait(cycle):  the physics loop honours the discrete control period using Wait and emits
 *                   tock INPUT_DONE once the scaled timer reaches the configured cycle duration.
 *   - ResetTimer:  after each discrete cycle the timer is reset to 0 before the next evolution step.
 *   - Evolve:  physics_update advances the continuous dynamics, updates mapping variables, and
 *              prepares the data published in the next SendToDModel.
 */

#pragma region includes
#define _POSIX_C_SOURCE 200112L
#define _DEFAULT_SOURCE

#include <iostream>
#include <memory>
#include <cstdio>
#include <cstdbool>
#include <cstdlib>
#include <unistd.h>
#include <pthread.h>
#include <ctime>
#include <csignal>
#include <cstring>
#include <cmath>
#include <string>
#include <atomic>

#include "orchestrator.h"
#include "dmodel_interface.h"
#include "interfaces.hpp"
#include "platform1_state.hpp"
#include "platform_mapping.h"
#include "world_mapping.h"
#include "utils.h"

// Generated RoboSim controller
extern "C" int acrobot_generated_main(int argc, char* argv[]);
// Manual implementation (for comparison)
// extern "C" int acrobot_main(int argc, char* argv[]);
#pragma endregion includes

#pragma region shared_state
// Input register for the D-Model: buffered per-cycle inputs delivered via registerRead
typedef struct {
    pthread_mutex_t mutex;
    bool terminate;
} engine_input_t;

typedef struct {
    pthread_mutex_t mutex;
    pthread_cond_t data_ready;
    pthread_cond_t data_consumed;
    bool data_available;
    bool terminate;
    
    int operation_type;
    double parameter;
    double timestamp;
} engine_output_t;

typedef struct {
    int cycle;                    // Number of tock events per control cycle (paper: cycle)
    double t_scale;               // Seconds per tock (paper: tscale)
    double platform_dt;           // Platform (physics) integration timestep
    double world_dt;              // World sampling timestep (sensor updates)
    int max_steps;                // Safety bound on platform iterations
} simulation_config_t;

static const simulation_config_t SIM_CONFIG = {
    .cycle = 1,                   // d-model cycle
    .t_scale = 0.005,             // 200 Hz d-model: cycle * tScale = 0.005 s per cycle
    .platform_dt = 0.005,         // Platform update every 5 ms (200 Hz)
    .world_dt = 0.005,            // World update in sync with platform step
    .max_steps = 2000,            // 10s @ 200Hz (match Drake example)
};

static inline double sim_cycle_duration_seconds(void) {
    return static_cast<double>(SIM_CONFIG.cycle) * SIM_CONFIG.t_scale;
}


// Derive d-model cycle seconds from t_scale (seconds per tock)
static inline double dmodel_cycle_seconds() { return SIM_CONFIG.t_scale; }

static engine_input_t engine_input = {
    .mutex = PTHREAD_MUTEX_INITIALIZER,
    .terminate = false
};

static engine_output_t engine_output = {
    .mutex = PTHREAD_MUTEX_INITIALIZER,
    .data_ready = PTHREAD_COND_INITIALIZER,
    .data_consumed = PTHREAD_COND_INITIALIZER,
    .data_available = false,
    .terminate = false
};

static double previousPhysicsTime = 0.0;
static bool operationActive = false;

static inline double cycles_to_seconds(double k_cycles) {
    return k_cycles * SIM_CONFIG.t_scale;
}
static pthread_mutex_t inputChannelMutex = PTHREAD_MUTEX_INITIALIZER;
static pthread_cond_t  inputChannelCv    = PTHREAD_COND_INITIALIZER;
static IPlatformEngine* platform_engine = nullptr;

// Sensor event queue for Acrobot - delivers combined sensor values via registerReadSensorUpdate
// Uses single combined event to avoid codegen issues with multiple input events per cycle
typedef struct {
    bool ready;           // Buffer has been populated for this cycle
    bool sensorPending;   // Combined sensor event pending
    bool doneReady;       // INPUT_DONE ready to deliver
    
    // Combined sensor values read from p_mapping (robot sensors only)
    AcrobotSensorState sensors;
} input_register_t;

static input_register_t inputRegister = {};

static const char* const INVALID_OPERATION = "Invalid Input";
#pragma endregion shared_state

// -----------------------------------------------------------------------------
// Main-action helpers (internal linkage)
// -----------------------------------------------------------------------------

// World mapping is executed inside the physics engine step (platform1_engine.cpp)

#pragma region dmodel_inputs_support
/**
 * D-model inputs: publish sensor readings at the start of a discrete control cycle.
 *
 * Reads all sensor values from p_mapping and queues them for delivery via registerRead().
 * The controller receives a combined INPUT_SENSOR_UPDATE event, followed by INPUT_DONE.
 */
static void dmodel_publish_input_message(void) {
    pthread_mutex_lock(&inputChannelMutex);
    if (inputRegister.ready) {
        // Already published for this cycle; do not overwrite mid-cycle
        pthread_mutex_unlock(&inputChannelMutex);
        return;
    }
    
    // Read sensor values from p_mapping into combined struct (robot sensors only)
    inputRegister.sensors.shoulderAngle = p_mapping.AcrobotControlled.BaseLink.ShoulderEncoder.AngleOut;
    inputRegister.sensors.shoulderVelocity = p_mapping.AcrobotControlled.BaseLink.ShoulderEncoder.VelocityOut;
    inputRegister.sensors.elbowAngle = p_mapping.AcrobotControlled.Link1.ElbowEncoder.AngleOut;
    inputRegister.sensors.elbowVelocity = p_mapping.AcrobotControlled.Link1.ElbowEncoder.VelocityOut;
    
    // Mark combined sensor event as pending
    inputRegister.sensorPending = true;
    inputRegister.doneReady = false;
    inputRegister.ready = true;
    
    pthread_cond_broadcast(&inputChannelCv);
    pthread_mutex_unlock(&inputChannelMutex);
}
#pragma endregion dmodel_inputs_support

#pragma region platform_mapping
/**
 * Maps an operation type code to its human-readable name.
 * @param operation_type One of OUTPUT_CONTROL_IN, OUTPUT_DONE.
 * @return Null-terminated string name for logging and mapping.
 */
static const char* to_operation_name(int operation_type) {
    switch (operation_type) {
        case OUTPUT_CONTROL_IN: return "ControlIn";
        case OUTPUT_DONE:       return "Done";
        default:                return "Unknown";
    }
}

static void process_operation_event(int operation_type, double parameter, double log_time) {
    const char* operation_name = to_operation_name(operation_type);

    if (strcmp(operation_name, "Unknown") == 0) {
        return;
    }

    std::cout << "[Engine] Received operation: " << operation_name
              << " param=" << parameter << " at time " << log_time << std::endl;

    if (strcmp(operation_name, "ControlIn") == 0) {
        // Acrobot controller command: ControlIn is the scalar input u.
        // The platform computes joint torques as tau = B_ctrl * u during physics_update().
        p_mapping.AcrobotControlled.Link1.ElbowJoint.ElbowMotor.ControlIn = parameter;
        std::cout << "[Engine] Updated ControlIn (u) = " << parameter << std::endl;
    } else if (strcmp(operation_name, "Done") == 0) {
        std::cout << "[Engine] Done handshake received" << std::endl;
        // Done is just a cycle boundary marker, not an operation change
    }
}

#pragma endregion platform_mapping

#pragma region logging_helpers
static void enable_logging_streams(void) {
    enable_torque_logging("generated_torques.csv");
    enable_high_freq_logging("generated_torques_1ms.csv");
    enable_mapping_debug_logging("mapping_debug.csv");
    enable_velocity_logging("pmh_velocity_log_our_implementation.csv");
    enable_transform_logging("transform_log.csv");
}

static void disable_logging_streams(void) {
    disable_torque_logging();
    disable_high_freq_logging();
    disable_velocity_logging();
    disable_transform_logging();
    disable_mapping_debug_logging();
}
#pragma endregion logging_helpers

#pragma region runtime_init
/**
 * Init (paper): Initializes physics runtime and logging, prepares the first
 * input-channel message.
 */
static void initialise_runtime_state(void) {
    std::cout << "[Engine] Priming physics runtime state" << std::endl;

    // Use abstract interfaces
    IWorldEngine* world_engine = get_world_engine();
    IPlatformWorldMapping* platform_world_mapping = get_platform_world_mapping();
    IPlatformMapping* platform_mapping = get_platform_mapping();
    platform_engine = get_platform_engine();

    IPlatformEngine* platform_engine_local = platform_engine;

    if (world_engine) {
        world_engine->initialise();
    }
    if (platform_world_mapping) {
        platform_world_mapping->initialise();
    }
    platform_engine_local->initialise();
    if (platform_mapping) {
        platform_mapping->initialise();
    }

    enable_logging_streams();

    // Mapping initialisation is handled by platform/world engines and mapping classes

    // Sync timer baseline with the engine clock defined by platform1_initialise()
    previousPhysicsTime = (platform_engine_local != nullptr) ? platform_engine_local->getTime() : 0.0;
}

#pragma endregion runtime_init

// Non-bridge helpers used by both the C bridge and the adapter
static void tock_impl(int type) {
    pthread_mutex_lock(&inputChannelMutex);
    if (type == INPUT_DONE) {
        inputRegister.doneReady = true;
        pthread_cond_broadcast(&inputChannelCv);
    } else if (type == INPUT_TERMINATE) {
        engine_input.terminate = true;
        pthread_cond_broadcast(&inputChannelCv);
    }
    pthread_mutex_unlock(&inputChannelMutex);
}
#pragma region register_utils
/**
 * Deliver the combined sensor event to the controller.
 * Uses single combined event to avoid codegen issues with multiple input events per cycle.
 * Note: Only robot sensors (from platform mapping) are inputs, not world properties.
 */
static inline bool deliver_buffered_event_locked(int* type, void* data, size_t size) {
    // Deliver combined sensor event
    if (inputRegister.sensorPending) {
        *type = INPUT_SENSOR_UPDATE;
        if (data != nullptr && size >= sizeof(AcrobotSensorState)) {
            *static_cast<AcrobotSensorState*>(data) = inputRegister.sensors;
        }
        inputRegister.sensorPending = false;
        inputRegister.doneReady = true;
        return true;
    }
    if (inputRegister.doneReady) {
        *type = INPUT_DONE;
        inputRegister.doneReady = false;
        inputRegister.ready = false;  // Cycle complete, need new publish
        return true;
    }
    return false;
}

/**
 * Populate input buffer is now handled by dmodel_publish_input_message().
 * This function is kept for backward compatibility but is effectively a no-op.
 */
static inline void populate_input_buffer_locked(void) {
    // Sensor values are populated by dmodel_publish_input_message()
    // This is called when we need to signal new data is available
}
#pragma endregion register_utils

// Forward declaration for world mapping evolve
static void EvolveWorldMapping();

// Core implementations (non-bridge)
static bool registerRead_impl(int* type, void* data, size_t size) {
    if (type == nullptr) {
        return false;
    }

    pthread_mutex_lock(&inputChannelMutex);
    for (;;) {
        if (engine_input.terminate) {
            *type = INPUT_TERMINATE;
            pthread_mutex_unlock(&inputChannelMutex);
            return false;
        }
        if (inputRegister.ready && deliver_buffered_event_locked(type, data, size)) {
            pthread_mutex_unlock(&inputChannelMutex);
            return true;
        }
        pthread_cond_wait(&inputChannelCv, &inputChannelMutex);
    }
}

static void SendToDModel_impl(void) {
    if (engine_input.terminate) {
        return;
    }

    pthread_mutex_lock(&inputChannelMutex);

    if (engine_input.terminate || inputRegister.ready) {
        pthread_mutex_unlock(&inputChannelMutex);
        return;
    }

    populate_input_buffer_locked();

    pthread_cond_broadcast(&inputChannelCv);
    pthread_mutex_unlock(&inputChannelMutex);
}

static void registerWrite_impl(const OperationData* op) {
    if (op == nullptr) return;
    pthread_mutex_lock(&engine_output.mutex);
    while (engine_output.data_available && !engine_output.terminate) {
        pthread_cond_wait(&engine_output.data_consumed, &engine_output.mutex);
    }

    if (!engine_output.terminate) {
        engine_output.operation_type = op->type;
        engine_output.parameter = op->params[0];
        engine_output.timestamp = op->time;
        engine_output.data_available = true;
        pthread_cond_signal(&engine_output.data_ready);

        std::cout << "[DModel->Engine] Queued operation: "
                  << to_operation_name(op->type)
                  << ", k=" << op->params[0] << std::endl;
    }
    pthread_mutex_unlock(&engine_output.mutex);
}

// Note: C ABI for d-model is provided in dmodel_interface.cpp; we only keep impls here.

/**
 * ReceiveFromDModel (paper): receives one pending operation from the d-model
 */
bool ReceiveFromDModel(int* operation_type, double* parameter, double* timestamp) {
    pthread_mutex_lock(&engine_output.mutex);
    while (!engine_output.data_available && !engine_output.terminate) {
        pthread_cond_wait(&engine_output.data_ready, &engine_output.mutex);
    }

    if (engine_output.terminate) {
        pthread_mutex_unlock(&engine_output.mutex);
        return false;
    }
    
    *operation_type = engine_output.operation_type;
    if (parameter != nullptr) {
        *parameter = engine_output.parameter;
    }
    if (timestamp != nullptr) {
        *timestamp = engine_output.timestamp;
    }

    engine_output.data_available = false;
    pthread_cond_signal(&engine_output.data_consumed);
    pthread_mutex_unlock(&engine_output.mutex);
    return true;
}

/**
 * Evolve (paper): Advances continuous dynamics by one physics step.
 *
 * Mapping.pm semantics: derivative(k) = 1 while operation is active.
 * k is seeded at cycle boundaries and integrated continuously between them.
 * 
 * @param timer In/out timer C (cycles)
 * @return true if timer >= SIM_CONFIG.cycle, otherwise false.
 */
static bool Evolve(double& timer) {
    // Update world->platform mapping sensors for this step before physics
    EvolveWorldMapping();

    Wait(SIM_CONFIG.platform_dt);
    
    // Update platform physics using interface
    if (platform_engine != nullptr) {
        platform_engine->update();
    }

    double now = (platform_engine != nullptr) ? platform_engine->getTime()
                                              : (previousPhysicsTime + SIM_CONFIG.platform_dt);
    double dt = now - previousPhysicsTime;
    if (dt <= 0.0) {
        dt = SIM_CONFIG.platform_dt;
    }
    // Clamp dt to the configured platform step to avoid floating point drift
    // causing missed cycle boundaries (e.g., dt = 0.004999999999... < 0.005).
    if (std::fabs(dt - SIM_CONFIG.platform_dt) < 1e-12) {
        dt = SIM_CONFIG.platform_dt;
    }
    previousPhysicsTime = now;

    // Mapping.pm: derivative(k) = 1 → integrate k continuously while operation is active
    if (operationActive) {
        const char* op = p_mapping.operation_name;
        if (op && (strcmp(op, "PrePick") == 0 || 
                   strcmp(op, "PrePlace") == 0 || 
                   strcmp(op, "Return") == 0)) {
            p_mapping.k += dt;
            // No additional mapping updates required per-cycle for Acrobot
        }
    }

    // Paper semantics: dtimer/dt = 1, cycle completes when timer >= cycle * tScale
    timer += dt;

    const double cycle_seconds = sim_cycle_duration_seconds();
    return (timer + 1e-12) >= cycle_seconds;
}

static void EvolveWorldMapping() {
    IPlatformWorldMapping* platform_world_mapping = get_platform_world_mapping();
    IWorldEngine* world_engine = get_world_engine();
    
    if (!platform_world_mapping || !platform_engine || !world_engine) {
        return;
    }
    
    // Compute sensor readings from world + platform state
    sensor_outputs_t sensors{};
    platform_world_mapping->computeSensorReadings(
        world_engine->state(),
        platform_engine->getPlatform().getState(),
        sensors);

    // Copy sensors into platform mapping
    get_platform_mapping()->updateFromSensors(sensors);
}
#pragma endregion main_semantics

#pragma region scheduling
/**
 * Wait (paper): blocks for the supplied duration in seconds.
 *
 * When invoked with `cycle × tscale` this mirrors the paper's Wait(cycle)
 * operator; we also reuse it for finer-grained platform steps.
 */
void Wait(double cycleDurationSeconds) {
    const useconds_t sleep_us = static_cast<useconds_t>(cycleDurationSeconds * 1e6);
    usleep(sleep_us);
}
#pragma endregion scheduling

#pragma region cycle_management
/**
 * ResetTimer (paper): Resets the timer C to 0 at the end of a cycle.
 */
static inline void resetTimer(double& timer) {
    timer = 0.0;
}
#pragma endregion cycle_management

/**
 * BaseModule (paper): Engine input thread orchestrating the main action.
 *
 * Sequence: Init (performed by start_engine_runtime before thread launch) → [Evolve;
 * emit tock when cycle completes; ResetTimer; publish next input message] →
 * repeat, until termination or max steps.
 */
void* engine_thread(void* arg) {
    (void)arg;
    std::cout << "[Engine] Input thread starting" << std::endl;
    double timer = 0.0;
    int step_counter = 0;

    // FIX: Get torque BEFORE physics, not after (eliminates 1-cycle delay)
    // Initial cycle setup: publish sensors, get first torque
    std::cout << "[Engine] Publishing initial input message" << std::endl;
    EvolveWorldMapping();  // Update sensors first
    dmodel_publish_input_message();
    tock(INPUT_DONE);  // Signal d-model to compute

    // Wait for initial torque
    {
        int operation_type = OUTPUT_DONE;
        double parameter = 0.0;
        pthread_mutex_lock(&engine_output.mutex);
        while (!engine_output.data_available && !engine_output.terminate && !engine_input.terminate) {
            pthread_cond_wait(&engine_output.data_ready, &engine_output.mutex);
        }
        if (engine_output.data_available) {
            operation_type = engine_output.operation_type;
            parameter = engine_output.parameter;
            engine_output.data_available = false;
            pthread_cond_signal(&engine_output.data_consumed);
        }
        pthread_mutex_unlock(&engine_output.mutex);
        if (operation_type != OUTPUT_DONE) {
            process_operation_event(operation_type, parameter, platform_engine ? platform_engine->getTime() : 0.0);
        }
    }

    std::cout << "[Engine] Entering main Evolve loop" << std::endl;

    while (!engine_input.terminate) {
        if (step_counter % 100 == 0) {
            std::cout << "[Engine] Evolve step " << step_counter << ", timer=" << timer << ", k=" << p_mapping.k << std::endl;
        }

        // Physics evolves with CURRENT torque (already applied)
        const bool cycle_completed = Evolve(timer);

        if (cycle_completed) {
            // Cycle boundary: get NEW torque for next cycle BEFORE physics runs
            // 1. Update world sensors
            EvolveWorldMapping();

            // 2. Reset timer for next cycle
            resetTimer(timer);

            // 3. Publish new sensor snapshot
            dmodel_publish_input_message();

            // 4. Signal d-model to compute
            tock(INPUT_DONE);

            // 5. Wait for controller output and apply BEFORE next Evolve
            int operation_type = OUTPUT_DONE;
            double parameter = 0.0;
            pthread_mutex_lock(&engine_output.mutex);
            while (!engine_output.data_available && !engine_output.terminate && !engine_input.terminate) {
                pthread_cond_wait(&engine_output.data_ready, &engine_output.mutex);
            }
            if (engine_output.data_available) {
                operation_type = engine_output.operation_type;
                parameter = engine_output.parameter;
                engine_output.data_available = false;
                pthread_cond_signal(&engine_output.data_consumed);
            }
            pthread_mutex_unlock(&engine_output.mutex);

            if (operation_type != OUTPUT_DONE) {
                process_operation_event(operation_type, parameter, platform_engine ? platform_engine->getTime() : 0.0);
            }
        }

        if (++step_counter >= SIM_CONFIG.max_steps) {
            std::cout << "[Engine] Simulation complete, sending terminate" << std::endl;
            tock(INPUT_TERMINATE);
            break;
        }
    }

    std::cout << "[Engine] Physics engine thread exiting" << std::endl;
    return nullptr;
}

/**
 * ReceiveFromDModel handler: output thread buffering controller outputs.
 *
 * Paper semantics: Buffer outputs received during a cycle, apply at boundary.
 * This ensures discrete effects align with the control tick and keeps
 * currentCycle and k in lockstep.
 */
void* output_processing_thread(void* arg) {
    (void)arg;
    std::cout << "[Engine] Starting output processing thread" << std::endl;
    
    // Paper-aligned: buffer last non-Done output within cycle, apply at boundary
    int buffered_operation = OUTPUT_DONE;
    double buffered_parameter = 0.0;
    bool have_buffered_operation = false;
    
    while (!engine_output.terminate) {
        int operation_type = OUTPUT_DONE;
        double parameter = 0.0;
        double timestamp = 0.0;
        
        // Non-blocking check for d-model outputs
        pthread_mutex_lock(&engine_output.mutex);
        if (engine_output.data_available && !engine_output.terminate) {
            operation_type = engine_output.operation_type;
            parameter = engine_output.parameter;
            timestamp = engine_output.timestamp;
            engine_output.data_available = false;
            pthread_cond_signal(&engine_output.data_consumed);
            
            // Buffer this output (keep most recent within the cycle)
            if (operation_type != OUTPUT_DONE) {
                buffered_operation = operation_type;
                buffered_parameter = parameter;
                have_buffered_operation = true;
            }
        }
        pthread_mutex_unlock(&engine_output.mutex);
        
        // In lockstep mode, outputs are applied directly by engine_thread after tock(INPUT_DONE).
        // Keep the thread alive for compatibility, but do not mutate mapping state here.
        
        // Small sleep to avoid busy-wait
        usleep(100);
    }
    
    std::cout << "[Engine] Output processing thread exiting" << std::endl;
    return nullptr;
}

#pragma region signal_handling
/**
 * Handles SIGINT/SIGTERM for clean shutdown and process termination.
 *
 * Wakes all blocked threads, restores default handlers, and re-raises the
 * signal to terminate the process.
 */
static void signal_handler(int sig) {
    (void)sig;
    pthread_mutex_lock(&engine_input.mutex);
    engine_input.terminate = true;
    pthread_mutex_unlock(&engine_input.mutex);

    pthread_mutex_lock(&engine_output.mutex);
    engine_output.terminate = true;
    pthread_cond_broadcast(&engine_output.data_ready);
    pthread_cond_broadcast(&engine_output.data_consumed);
    pthread_mutex_unlock(&engine_output.mutex);

    // Wake any readers blocked on the input-channel wait
    pthread_mutex_lock(&inputChannelMutex);
    pthread_cond_broadcast(&inputChannelCv);
    pthread_mutex_unlock(&inputChannelMutex);

    // Restore default handling and re-raise to terminate the process on Ctrl+C
    signal(SIGINT, SIG_DFL);
    signal(SIGTERM, SIG_DFL);
    raise(sig);
}
#pragma endregion signal_handling

#pragma region public_api
/**
 * Initializes the engine orchestration runtime: primes platform/world state,
 * computes tScale, installs signal handlers, and starts the worker threads.
 * @return Thread identifiers for joining during shutdown.
 */
engine_threads_t start_engine_runtime() {
    engine_threads_t threads{};
    
    std::cout << "[Engine] Starting physics engine runtime" << std::endl;
    std::cout << "[Engine] Control cycle period = " << sim_cycle_duration_seconds() << " s" << std::endl;
    initialise_runtime_state();

    signal(SIGINT, signal_handler);
    signal(SIGTERM, signal_handler);
    
    int status = pthread_create(&threads.input_thread_id, nullptr, engine_thread, nullptr);
    if (status != 0) {
        std::cerr << "Error creating engine input thread: " << strerror(status) << std::endl;
        std::exit(EXIT_FAILURE);
    }
    
    // Output thread no longer applies operations; kept optional for compatibility.
    threads.output_thread_id = 0;

    std::cout << "[Engine] Physics engine runtime online with input thread" << std::endl;
    return threads;
}

/**
 * Shuts down the engine: signals termination, joins threads, and disables
 * logging sinks.
 */
void shutdown_engine(engine_threads_t engine_threads) {
    std::cout << "[Engine] Shutting down physics engine runtime" << std::endl;
    
    pthread_mutex_lock(&engine_input.mutex);
    engine_input.terminate = true;
    pthread_mutex_unlock(&engine_input.mutex);

    pthread_mutex_lock(&engine_output.mutex);
    engine_output.terminate = true;
    pthread_cond_broadcast(&engine_output.data_ready);
    pthread_cond_broadcast(&engine_output.data_consumed);
    pthread_mutex_unlock(&engine_output.mutex);

    pthread_join(engine_threads.input_thread_id, nullptr);
    if (engine_threads.output_thread_id) {
        pthread_join(engine_threads.output_thread_id, nullptr);
    }

    disable_logging_streams();
    
    std::cout << "[Engine] Physics engine shutdown complete" << std::endl;
}
#pragma endregion public_api

// (no extern "C" definitions here)

class DModelIOAdapter : public IDModelIO {
public:
    bool registerRead(int* type, void* data, size_t size) override { return registerRead_impl(type, data, size); }
    void registerWrite(const OperationData* op) override { registerWrite_impl(op); }
    void tock(int type) override { tock_impl(type); }
};

int main(int argc, char* argv[]) {
    std::cout << "[Orchestrator] Starting orchestration" << std::endl;
    // Launch physics engine runtime
    engine_threads_t engine_threads = start_engine_runtime();

    const double cycle_seconds = sim_cycle_duration_seconds();
    std::cout << "[Orchestrator] Control cycle duration = " << cycle_seconds << " s" << std::endl;

    // Install D-model IO adapter for C bridge and launch d-model runtime
    DModelIOAdapter io;
    set_active_dmodel_io(&io);
    int pickplace_exit_code = acrobot_generated_main(argc, argv);
 
    shutdown_engine(engine_threads);

    std::cout << "[Orchestrator] Orchestration complete" << std::endl;
    return pickplace_exit_code;
}
