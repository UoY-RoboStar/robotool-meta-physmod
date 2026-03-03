#ifndef DMODEL_DATA_H
#define DMODEL_DATA_H

#include <stdbool.h>
#include <stddef.h>

/**
 * Payload for scalar event delivery via registerRead.
 *
 * Encoding:
 *   - Predicate-only events: occurred = predicate value, value = 0.0
 *   - Value-carrying events: occurred = true, value = parameter
 *   - Structured events use dedicated payload structs (e.g., AcrobotSensorState)
 *
 * D-models must read 'occurred' for predicate events; 'value' is only meaningful
 * when occurred == true for value-carrying events.
 */
typedef struct {
    bool occurred;   // Whether the event occurred (or predicate result)
    double value;    // Optional associated value (e.g., sensor reading)
} EventData;

/**
 * Payload for operation commands via registerWrite.
 *
 * D-models write operation commands to the engine using this struct.
 * The engine reads the operation type and parameters to update platform mapping.
 */
#ifndef DMODEL_MAX_OP_PARAMS
#define DMODEL_MAX_OP_PARAMS 4
#endif

typedef struct {
    int type;                  // OUTPUT_* operation type
    size_t param_count;        // Number of parameters in params[]
    double params[DMODEL_MAX_OP_PARAMS]; // Operation parameters (ordered)
    double time;               // Timestamp (if needed)
} OperationData;

#endif // DMODEL_DATA_H
