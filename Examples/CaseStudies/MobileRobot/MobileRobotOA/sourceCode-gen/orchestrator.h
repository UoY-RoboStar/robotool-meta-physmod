#ifndef ORCHESTRATOR_H
#define ORCHESTRATOR_H

#include <pthread.h>

typedef struct {
    pthread_t input_thread_id;
    pthread_t output_thread_id;
} engine_threads_t;

engine_threads_t start_engine_runtime();
void shutdown_engine(engine_threads_t engine_threads);
void Wait(double cycleDurationSeconds);

#endif // ORCHESTRATOR_H
