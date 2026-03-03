// world_engine.cpp - Minimal world model for Acrobot
//
// This example does not include pick-and-place objects (no red/green blocks).
// The only world responsibility required by the Acrobot controller is providing
// a gravity vector (world frame) via the platform mapping.

#include <vector>
#include <Eigen/Dense>

#include "interfaces.hpp"
#include "platform_mapping.h"

// Platform mapping is defined in platform1_engine.cpp
extern "C" mapping_state_t p_mapping;

// World mapping snapshot is defined in platform1_engine.cpp
extern mapping_state_t w_mapping;

namespace {
struct DummyWorldState : public IWorldState {};

class MinimalWorldEngine final : public IWorldEngine {
public:
    void initialise() override {
        // Provide constant Earth gravity (world frame)
        p_mapping.World.gravity_world[0] = 0.0;
        p_mapping.World.gravity_world[1] = 0.0;
        p_mapping.World.gravity_world[2] = -9.81;

        // Mirror into world snapshot (optional)
        w_mapping.World.gravity_world[0] = p_mapping.World.gravity_world[0];
        w_mapping.World.gravity_world[1] = p_mapping.World.gravity_world[1];
        w_mapping.World.gravity_world[2] = p_mapping.World.gravity_world[2];
    }

    void update() override {}

    double getTime() const override { return 0.0; }

    const IWorldState& state() const override { return state_; }

    IWorldState& state() override { return state_; }

private:
    mutable DummyWorldState state_;
};

static MinimalWorldEngine g_world_engine;
} // namespace

IWorldEngine* get_world_engine() { return &g_world_engine; }

void world_initialize(void) {
    g_world_engine.initialise();
}

// Compatibility stubs retained for generic templates (unused by Acrobot)
void world_update_gripper_position(const std::vector<Eigen::MatrixXd>&) {}

double world_get_distance_to_object(void) { return 0.0; }

double world_get_distance_to_goal(void) { return 0.0; }

void world_set_object_position(double, double, double) {}

void world_set_goal_position(double, double, double) {}

void world_get_gripper_position(double* x, double* y, double* z) {
    if (x) *x = 0.0;
    if (y) *y = 0.0;
    if (z) *z = 0.0;
}

void world_get_object_position(double* x, double* y, double* z) {
    if (x) *x = 0.0;
    if (y) *y = 0.0;
    if (z) *z = 0.0;
}

void world_get_goal_position(double* x, double* y, double* z) {
    if (x) *x = 0.0;
    if (y) *y = 0.0;
    if (z) *z = 0.0;
}

void world_print_state(void) {}
