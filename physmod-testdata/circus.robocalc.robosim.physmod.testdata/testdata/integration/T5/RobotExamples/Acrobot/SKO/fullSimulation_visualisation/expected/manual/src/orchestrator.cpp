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

extern "C" int acrobot_main(int argc, char* argv[]);
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
    .max_steps = 6000,           
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
// Flag to signal cycle boundary for buffered operation application
static bool cycle_boundary_flag = false;
static pthread_mutex_t cycle_boundary_mutex = PTHREAD_MUTEX_INITIALIZER;
static pthread_mutex_t inputChannelMutex = PTHREAD_MUTEX_INITIALIZER;
static pthread_cond_t  inputChannelCv    = PTHREAD_COND_INITIALIZER;
static IPlatformEngine* platform_engine = nullptr;

typedef struct {
    bool ready;
    bool doneReady;
    struct {
        bool event1;
        bool event2;
    } fields;
    struct {
        bool event1Pending;
        bool event2Pending;
    } pending;
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
 * D-model inputs: publish a sensor message at the start of a discrete control cycle.
 *
 * Computes Event1 and Event2 from platform mapping sensor registers and stores
 * their boolean values in the channel buffer for the duration of the current cycle.
 * registerRead will deliver detectObject, detectGoal, then Done exactly once per
 * cycle using this buffered message.
 */
 static void dmodel_publish_input_message(void) {
    pthread_mutex_lock(&inputChannelMutex);
    if (inputRegister.ready) {
        // Already published for this cycle; do not overwrite mid-cycle
        pthread_mutex_unlock(&inputChannelMutex);
        return;
    }
    // No world sensors in Acrobot example; publish a no-op input message
    inputRegister.fields.event1 = false;
    inputRegister.fields.event2 = false;
    inputRegister.pending.event1Pending = false;
    inputRegister.pending.event2Pending = false;
    inputRegister.doneReady = false;
    inputRegister.ready = true;
    pthread_cond_broadcast(&inputChannelCv);
    pthread_mutex_unlock(&inputChannelMutex);
}
#pragma endregion dmodel_inputs_support

#pragma region platform_mapping
/**
 * Maps an operation type code to its human-readable name.
 * @param operation_type One of OUTPUT_PRE_PICK, OUTPUT_PRE_PLACE, OUTPUT_RETURN, OUTPUT_DONE.
 * @return Null-terminated string name for logging and mapping.
 */
static const char* to_operation_name(int operation_type) {
    switch (operation_type) {
        case OUTPUT_PRE_PICK:  return "PrePick";
        case OUTPUT_PRE_PLACE: return "PrePlace";
        case OUTPUT_RETURN:    return "Return";
        case OUTPUT_DONE:      return "Done";
        default:               return "Unknown";
    }
}

/**
 * Platform: starts a new operation by seeding k from the d-model.
 *
 * Mapping.pm semantics: derivative(k) = 1, so k is seeded here and then 
 * integrated continuously in Evolve() until the next cycle boundary.
 */
static void platform_start_operation(const char* operation_name, double parameter_cycles) {
    p_mapping.operation_name = operation_name;
    p_mapping.k = std::max(0.0, cycles_to_seconds(parameter_cycles));
    operationActive = true;
    std::cout << "[Engine] Starting operation " << operation_name
              << " with k=" << p_mapping.k << " s (from " << parameter_cycles << " cycles)" << std::endl;
}

static void process_operation_event(int operation_type, double parameter, double log_time) {
    const char* operation_name = to_operation_name(operation_type);

    if (strcmp(operation_name, "Unknown") == 0) {
        return;
    }

    std::cout << "[Engine] Received operation: " << operation_name
              << " param=" << parameter << " at time " << log_time << std::endl;

    if (strcmp(operation_name, "PrePick") == 0 ||
        strcmp(operation_name, "PrePlace") == 0 ||
        strcmp(operation_name, "Return") == 0) {
        // Controller guarantees operations are only sent on state entry
        // Seed k from controller parameter and mark active (Mapping.pm semantics)
        // Then Evolve() integrates dk/dt=1 continuously
        platform_start_operation(operation_name, parameter);

        // For Acrobot, treat parameter as desired torque command
        p_mapping.Acrobot.upper_link.elbow.elbow_actuator.TorqueIn = parameter;
        std::cout << "[Engine] Updated TorqueIn = "
                  << p_mapping.Acrobot.upper_link.elbow.elbow_actuator.TorqueIn
                  << " Nm" << std::endl;
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
static inline bool deliver_buffered_event_locked(int* type, void* data, size_t size) {
    if (size < sizeof(EventData)) return false;
    EventData* event = static_cast<EventData*>(data);

    if (inputRegister.pending.event1Pending) {
        *type = INPUT_DETECT_OBJECT;
        event->occurred = inputRegister.fields.event1;
        event->value = 0.0;
        inputRegister.pending.event1Pending = false;
        return true;
    }
    if (inputRegister.pending.event2Pending) {
        *type = INPUT_DETECT_GOAL;
        event->occurred = inputRegister.fields.event2;
        event->value = 0.0;
        inputRegister.pending.event2Pending = false;
        return true;
    }
    if (inputRegister.doneReady) {
        *type = INPUT_DONE;
        event->occurred = false;
        event->value = 0.0;
        inputRegister.doneReady = false;
        inputRegister.ready = false;
        return true;
    }
    return false;
}

static inline void populate_input_buffer_locked(void) {
    // No sensor inputs for Acrobot example; keep channel idle
    inputRegister.fields.event1 = false;
    inputRegister.fields.event2 = false;
    inputRegister.pending.event1Pending = false;
    inputRegister.pending.event2Pending = false;
    inputRegister.doneReady = false;
    inputRegister.ready = true;
}
#pragma endregion register_utils

// Forward declaration for world mapping evolve
static void EvolveWorldMapping();

// Core implementations (non-bridge)
static bool registerRead_impl(int* type, void* data, size_t size) {
    if (type == nullptr || data == nullptr) {
        return false;
    }

    pthread_mutex_lock(&inputChannelMutex);
    for (;;) {
        if (engine_input.terminate) {
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
    if (!op) return;

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

    return timer >= (static_cast<double>(SIM_CONFIG.cycle) * SIM_CONFIG.t_scale);
}

static void EvolveWorldMapping() {
    IPlatformWorldMapping* platform_world_mapping = get_platform_world_mapping();
    IPlatformMapping* platform_mapping = get_platform_mapping();
    IWorldEngine* world_engine = get_world_engine();
    
    if (!platform_world_mapping || !platform_mapping || !platform_engine || !world_engine) {
        return;
    }
    
    // Compute sensor readings from world state and platform state
    sensor_outputs_t sensors{};
    platform_world_mapping->computeSensorReadings(
        world_engine->state(),
        platform_engine->getPlatform().getState(),
        sensors);
    
    // Mirror sensors to platform mapping (controller's view)
    platform_mapping->updateFromSensors(sensors);

    // Also mirror platform joint state and dynamics into mapping for controller
    const platform1::State& st = static_cast<const platform1::State&>(platform_engine->getPlatform().getState());
    if (st.theta.size() >= 1) p_mapping.Acrobot.upper_link.shoulder.angle = st.theta(0);
    if (st.d_theta.size() >= 1) p_mapping.Acrobot.upper_link.shoulder.velocity = st.d_theta(0);
    if (st.theta.size() >= 2) p_mapping.Acrobot.upper_link.elbow.angle = st.theta(1);
    if (st.d_theta.size() >= 2) p_mapping.Acrobot.upper_link.elbow.velocity = st.d_theta(1);

    if (st.M_inv.rows() >= 2 && st.M_inv.cols() >= 2) {
        p_mapping.Acrobot.dynamics.M_inv[0][0] = st.M_inv(0,0);
        p_mapping.Acrobot.dynamics.M_inv[0][1] = st.M_inv(0,1);
        p_mapping.Acrobot.dynamics.M_inv[1][0] = st.M_inv(1,0);
        p_mapping.Acrobot.dynamics.M_inv[1][1] = st.M_inv(1,1);
    }
    if (st.C.size() >= 2) {
        p_mapping.Acrobot.dynamics.bias[0] = st.C(0);
        p_mapping.Acrobot.dynamics.bias[1] = st.C(1);
    }
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
    // Publish initial input-channel message for the first control cycle
    std::cout << "[Engine] Publishing initial input message" << std::endl;
    dmodel_publish_input_message();
    std::cout << "[Engine] Entering main Evolve loop" << std::endl;

    while (!engine_input.terminate) {
        if (step_counter % 100 == 0) {
            std::cout << "[Engine] Evolve step " << step_counter << ", timer=" << timer << ", k=" << p_mapping.k << std::endl;
        }

        const bool cycle_completed = Evolve(timer);

        if (cycle_completed) {
            // Paper-aligned boundary sequence:
            // 1. Update world sensors and mirror to platform mapping
            EvolveWorldMapping();
            
            // 2. Signal boundary to output thread (apply buffered operation)
            pthread_mutex_lock(&cycle_boundary_mutex);
            cycle_boundary_flag = true;
            pthread_mutex_unlock(&cycle_boundary_mutex);
            
            // 3. Advance d-model with INPUT_DONE
            tock(INPUT_DONE);
            
            // 4. Reset timer for next cycle
            resetTimer(timer);
            
            // 5. Publish next input snapshot
            dmodel_publish_input_message();
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
        
        // Check if cycle boundary was signaled by engine_thread
        pthread_mutex_lock(&cycle_boundary_mutex);
        const bool at_boundary = cycle_boundary_flag;
        if (at_boundary) {
            cycle_boundary_flag = false;
            pthread_mutex_unlock(&cycle_boundary_mutex);
            
            // Apply buffered operation at cycle boundary (paper-aligned)
            if (have_buffered_operation) {
                process_operation_event(buffered_operation, buffered_parameter, 0.0);
                buffered_operation = OUTPUT_DONE;
                buffered_parameter = 0.0;
                have_buffered_operation = false;
            }
        } else {
            pthread_mutex_unlock(&cycle_boundary_mutex);
        }
        
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
    
    status = pthread_create(&threads.output_thread_id, nullptr, output_processing_thread, nullptr);
    if (status != 0) {
        std::cerr << "Error creating engine output thread: " << strerror(status) << std::endl;
        std::exit(EXIT_FAILURE);
    }
    
    std::cout << "[Engine] Physics engine runtime online with input and output threads" << std::endl;
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
    pthread_join(engine_threads.output_thread_id, nullptr);

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
    int pickplace_exit_code = acrobot_main(argc, argv);
 
    shutdown_engine(engine_threads);

    std::cout << "[Orchestrator] Orchestration complete" << std::endl;
    return pickplace_exit_code;
}
