#ifndef DMODEL_INTERFACE_H
#define DMODEL_INTERFACE_H

#include "dmodel_data.h"

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


// Input event types (engine → d-model) - sensor readings from platform mapping
// Each sensor value is delivered as a separate event via registerRead()
// Note: Only robot sensors (from platform mapping) are inputs, not world properties
enum {
    INPUT_SHOULDER_ANGLE,      // ShoulderEncoder.AngleOut (double)
    INPUT_SHOULDER_VELOCITY,   // ShoulderEncoder.VelocityOut (double)
    INPUT_ELBOW_ANGLE,         // ElbowEncoder.AngleOut (double)
    INPUT_ELBOW_VELOCITY,      // ElbowEncoder.VelocityOut (double)
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
 * Read sensor input from the engine (blocking until data available).
 * @param type Output parameter for input type (INPUT_*)
 * @param data Output buffer for event payload (EventData* for scalar, struct* for structured)
 * @param size Size of the data buffer in bytes
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
 * @param op Operation data (type, parameter, timestamp)
 */
void registerWrite(const OperationData* op);

#ifdef __cplusplus
}
#endif

#endif // DMODEL_INTERFACE_H
