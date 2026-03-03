#ifndef ORCHESTRATOR_H
#define ORCHESTRATOR_H

#include <pthread.h>

/* TODO/STUB */

typedef struct {
    pthread_t input_thread_id;
    pthread_t output_thread_id;
} engine_threads_t;

/* TODO/STUB */
engine_threads_t start_engine_runtime();

/* TODO/STUB */
void shutdown_engine(engine_threads_t engine_threads);

/* TODO/STUB */
void Wait(double cycleDurationSeconds);

#endif // ORCHESTRATOR_H
