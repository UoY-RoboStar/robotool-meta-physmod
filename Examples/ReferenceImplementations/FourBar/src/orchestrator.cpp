/*
 * Minimal Orchestrator - STANDALONE_VISUALISATION Mode
 * ----------------------------------------------------------
 * Four-Bar Linkage Reference Implementation
 *
 * This orchestrator provides minimal infrastructure:
 *   - Timing loop (sim_time, dt, max_time)
 *   - Platform engine calls (initialise, step)
 *   - Visualization integration
 */

#include <iostream>
#include <fstream>
#include <unistd.h>
#include "platform1_state.hpp"

// Platform engine API declarations
extern "C" {
    void platform1_initialise(void);
    void platform1_step(void);
    double platform1_get_time(void);
}

// Visualization forward declaration
void updateRobotVisualization();

int main() {
    std::cout << "==============================================\n";
    std::cout << "  Four-Bar Linkage Reference Implementation\n";
    std::cout << "  (STANDALONE_VISUALISATION Mode)\n";
    std::cout << "==============================================\n\n";

    std::cout << "Based on Drake's four_bar example:\n";
    std::cout << "  - 3 moving links (Crank A, Coupler B, Rocker C)\n";
    std::cout << "  - Lagrange multiplier enforcement for loop closure\n";
    std::cout << "  - Passive simulation (no applied torques)\n\n";

    // Initialize platform physics engine
    platform1_initialise();

    std::cout << "\nVisualization support enabled\n";
    std::cout << "Make sure visualization_server is running on localhost:9999\n\n";

    // Simulation parameters
    double sim_time = 0.0;
    double dt = 0.001;      // 1ms timestep (matches physics engine)
    double max_time = 2.0;  // 2 second simulation

    std::cout << "Starting simulation...\n";
    std::cout << "Duration: " << max_time << "s, Timestep: " << dt << "s\n\n";

    // Main timing loop
    while (sim_time < max_time) {
        // Step the physics engine
        platform1_step();

        // Advance simulation time
        sim_time += dt;

        // Sleep to run in real-time
        const useconds_t sleep_us = static_cast<useconds_t>(dt * 1e6);
        usleep(sleep_us);

        // Progress indicator every 0.1 seconds
        if (static_cast<int>(sim_time * 10) % 1 == 0 &&
            (sim_time - dt) * 10 < static_cast<int>(sim_time * 10)) {
            std::cout << "Simulation time: " << sim_time << "s\r" << std::flush;
        }
    }

    std::cout << "\n\nSimulation complete!\n";
    std::cout << "Final time: " << sim_time << "s\n";
    std::cout << "Trajectory logged to: trajectory_fourbar.csv\n";

    return 0;
}
