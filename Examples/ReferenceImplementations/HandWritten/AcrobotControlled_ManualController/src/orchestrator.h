#ifndef ORCHESTRATOR_H
#define ORCHESTRATOR_H

#include <pthread.h>

// ============================================================================
// Orchestrator Interface: Simulation lifecycle management
// ============================================================================
//
// This header defines the API for controlling the physics simulation runtime,
// including thread management and timing utilities.
//
// The orchestrator manages:
//   - Input thread: Publishes sensor data to d-model
//   - Output thread: Processes operation commands from d-model
//   - Physics evolution: Continuous dynamics between discrete cycles
//
// Implementation: orchestrator.cpp
// ============================================================================

/**
 * Thread handle structure for orchestrator lifecycle management.
 */
typedef struct {
    pthread_t input_thread_id;
    pthread_t output_thread_id;
} engine_threads_t;

/**
 * Start the physics engine runtime (spawns input/output threads).
 * Must be called before running the d-model main loop.
 * @return Thread handles for later shutdown
 */
engine_threads_t start_engine_runtime();

/**
 * Shutdown the physics engine runtime (joins threads, closes logs).
 * @param engine_threads Thread handles from start_engine_runtime()
 */
void shutdown_engine(engine_threads_t engine_threads);

/**
 * Block execution for specified duration (seconds).
 * Used internally by orchestrator for timing control.
 * @param cycleDurationSeconds Duration to wait in real-time seconds
 */
void Wait(double cycleDurationSeconds);

#endif // ORCHESTRATOR_H

