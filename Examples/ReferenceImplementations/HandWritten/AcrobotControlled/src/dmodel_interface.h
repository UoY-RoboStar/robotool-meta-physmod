#ifndef DMODEL_INTERFACE_H
#include "dmodel_data.h"
#define DMODEL_INTERFACE_H


// ============================================================================
// D-Model Interface: C ABI for discrete controller communication
// ============================================================================
//
// This header defines the boundary between the continuous physics engine
// (orchestrator) and the discrete controller (d-model C code).
//
// The d-model calls these functions to:
//   - Read sensor inputs (registerRead)
//   - Write operation commands (registerWrite)
//
// Implementation: dmodel_interface.cpp
// ============================================================================


// Combined sensor state (matches AcrobotSensorState datatype in .rst)
typedef struct {
    double shoulderAngle;
    double shoulderVelocity;
    double elbowAngle;
    double elbowVelocity;
} AcrobotSensorState;

// Input event types (engine → d-model) - sensor readings from platform mapping
// Uses a single combined event to avoid codegen issues with multiple events per cycle
enum {
    INPUT_SENSOR_UPDATE,       // Combined sensor event (AcrobotSensorState)
    INPUT_DONE,                // All sensors delivered for this cycle
    INPUT_TERMINATE            // Shutdown signal
};

// Output operation types (d-model → engine) - control commands
enum {
    OUTPUT_CONTROL_IN,  // ControlIn (u) - scalar torque command
    OUTPUT_DONE         // Command acknowledgement
};

// D-model C ABI functions
#ifdef __cplusplus
extern "C" {
#endif

/**
 * Read input from the engine (blocking until data available).
 * @param type Output parameter for input type (INPUT_*)
 * @param data Output buffer for event data (type-dependent)
 *             - INPUT_SENSOR_UPDATE: AcrobotSensorState*
 *             - INPUT_DONE/TERMINATE: ignored (can be NULL)
 * @param size Size of the data buffer
 * @return true if data was available, false if terminated
 */
bool registerRead(int* type, void* data, size_t size);

/**
 * Signal completion of discrete cycle processing.
 * @param type The input type that was processed
 */
void tock(int type);

/**
 * Write operation command to the engine.
 * @param op Pointer to OperationData containing operation type and parameters
 */
void registerWrite(const OperationData* op);

#ifdef __cplusplus
}
#endif

#endif // DMODEL_INTERFACE_H
