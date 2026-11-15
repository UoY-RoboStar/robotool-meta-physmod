#ifndef INTERFACE
#define INTERFACE

#include <stdbool.h>
#include <stdio.h>

#include "defs.h"
#include "defs_fmi.h"
#include "dmodel_interface.h"

// Adapter layer for CacheConsM: map engine events/operations onto controller inputs/outputs.

static inline void update_fmi_data(ModelData* comp) {
    (void)comp;
}

static inline M_CacheConsM_input_Enum read_input(void) {
    int type = INPUT_DONE;
    EventData event = {false, 0.0};
    const bool ok = registerRead(&type, &event, sizeof(event));
    if (!ok) {
        return create_M_CacheConsM_input__terminate_();
    }

    switch (type) {
    case INPUT_CLOSEST_DISTANCE:
        return create_M_CacheConsM_input_closestDistance((float)event.value);
    case INPUT_CLOSEST_ANGLE:
        return create_M_CacheConsM_input_closestAngle((float)event.value);
    case INPUT_TERMINATE:
        return create_M_CacheConsM_input__terminate_();
    case INPUT_DONE:
    default:
        return create_M_CacheConsM_input__done_();
    }
}

static inline void write_output(M_CacheConsM_output_Enum output) {
    if (output.type == M_CacheConsM_output__move) {
        const OperationData op = {OUTPUT_MOVE, 2, {(double)output.data._move.v1, (double)output.data._move.v2}, 0.0};
        registerWrite(&op);
        return;
    }

    if (output.type == M_CacheConsM_output__done_) {
        const OperationData op = {OUTPUT_DONE, 0, {0.0}, 0.0};
        registerWrite(&op);
    }
}

#endif
