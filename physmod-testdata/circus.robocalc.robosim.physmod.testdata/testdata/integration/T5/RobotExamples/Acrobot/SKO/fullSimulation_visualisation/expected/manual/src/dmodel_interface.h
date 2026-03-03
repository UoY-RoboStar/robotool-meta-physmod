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


// Input event types (engine → d-model)
enum {
    INPUT_DETECT_OBJECT,
    INPUT_DETECT_GOAL,
    INPUT_DONE,
    INPUT_TICK,  // Generic tick for continuous control loops
    INPUT_TERMINATE
};

// Output operation types (d-model → engine)
enum {
    OUTPUT_PRE_PICK,
    OUTPUT_PRE_PLACE,
    OUTPUT_RETURN,
    OUTPUT_TORQUE,  // For Acrobot torque commands
    OUTPUT_DONE
};

// D-model C ABI functions
#ifdef __cplusplus
extern "C" {
#endif

/**
 * Read sensor input from the engine (non-blocking).
 * @param type Output parameter for input type (INPUT_*)
 * @param data Output buffer for event payload (EventData* for scalar, struct* for structured)
 * @param size Size of the data buffer in bytes
 * @return true if data was available, false otherwise
 */
bool registerRead(int* type, void* data, size_t size);

/**
 * Signal completion of discrete cycle processing.
 * @param type The input type that was processed
 */
void tock(int type);

/**
 * Write operation command to the engine.
 * @param op The operation data containing type, parameter, and time
 */
void registerWrite(const OperationData* op);

#ifdef __cplusplus
}
#endif

#endif // DMODEL_INTERFACE_H

