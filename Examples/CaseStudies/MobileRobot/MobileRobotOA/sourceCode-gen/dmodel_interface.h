#ifndef DMODEL_INTERFACE_H
#define DMODEL_INTERFACE_H

#include "dmodel_data.h"

// ========================================================================
// D-Model Interface: C ABI for discrete controller communication
// ========================================================================

// Input event types (engine -> d-model)
enum {
    INPUT_CLOSEST_DISTANCE,  // EventData.value = distance
    INPUT_CLOSEST_ANGLE,     // EventData.value = angle (radians)
    INPUT_DONE,              // End of input batch for this cycle
    INPUT_TERMINATE          // Shutdown signal
};

// Output operation types (d-model -> engine)
enum {
    OUTPUT_MOVE,             // OperationData.params[0]=av, params[1]=lv
    OUTPUT_DONE              // Command acknowledgement
};

#ifdef __cplusplus
extern "C" {
#endif

bool registerRead(int* type, void* data, size_t size);
void tock(int type);
void registerWrite(const OperationData* op);

#ifdef __cplusplus
}
#endif

#endif // DMODEL_INTERFACE_H
