#include "interfaces.hpp"
#include "dmodel_data.h"

static IDModelIO* active_io = nullptr;

void set_active_dmodel_io(IDModelIO* io) {
    active_io = io;
}

extern "C" bool registerRead(int* type, void* data, size_t size) {
    return active_io ? active_io->registerRead(type, data, size) : false;
}

extern "C" void registerWrite(const OperationData* op) {
    if (active_io) active_io->registerWrite(op);
}

extern "C" void tock(int type) {
    if (active_io) active_io->tock(type);
}


