#ifndef INTERFACES_HPP
#define INTERFACES_HPP

#include <cstddef>
#include <vector>
#include <string>

#include "dmodel_data.h"

// Forward declarations
struct mapping_state_t;
struct sensor_data_t;
};

// Accessors for concrete instances (defined in respective .cpp files)
IPlatformEngine* get_platform_engine();
IWorldEngine* get_world_engine();
IPlatformWorldMapping* get_platform_world_mapping();  // Renamed from IWorldMapping
IPlatformMapping* get_platform_mapping();

// Active D-Model adapter setter used by the C bridge
void set_active_dmodel_io(IDModelIO* io);

#endif // INTERFACES_HPP
