#ifndef WORLD_MAPPING_H
#define WORLD_MAPPING_H

#ifdef __cplusplus
extern "C" {
#endif

// World mapping state structure
// Contains world-level parameters that are synchronized with the platform
typedef struct {
    double g[3];  // Gravity vector in world coordinates [x, y, z]
} world_mapping_t;

// World mapping instance (defined in platform engine)
extern world_mapping_t w_mapping;

#ifdef __cplusplus
}
#endif

#endif // WORLD_MAPPING_H
