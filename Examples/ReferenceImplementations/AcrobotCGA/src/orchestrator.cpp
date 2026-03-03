// Orchestrator for Acrobot Standalone (CGA implementation)
// Conformal Geometric Algebra formulation using Motor representation
// Follows ReferenceImplementations architecture pattern (standalone mode)

#include <iostream>
#include <thread>
#include <chrono>
#include <memory>
#include "interfaces.hpp"

int main() {
    std::cout << "Starting Acrobot simulation (CGA implementation)..." << std::endl;

    // Create and initialize platform engine using interface
    auto platform_engine = createPlatformEngine();
    platform_engine->initialise();

    const double sim_duration = 30.0;  // Match reference implementation duration
    const double dt = platform_engine->getDt();
    const int max_steps = static_cast<int>(sim_duration / dt);

    std::cout << "Running " << max_steps << " steps (dt=" << dt << "s, total=" << sim_duration << "s)..." << std::endl;
    std::cout << "Running at real-time speed (sleeping " << (dt * 1000) << "ms between steps)..." << std::endl;

    auto start_time = std::chrono::steady_clock::now();

    for (int step = 0; step < max_steps; ++step) {
        auto step_start = std::chrono::steady_clock::now();

        // Update physics via interface
        platform_engine->update();

        if (step % 500 == 0) {
            double t = platform_engine->getTime();
            auto elapsed = std::chrono::duration_cast<std::chrono::seconds>(
                std::chrono::steady_clock::now() - start_time).count();
            std::cout << "Step " << step << " / " << max_steps
                      << " (sim_t=" << t << "s, real_t=" << elapsed << "s)" << std::endl;
        }

        // Real-time pacing: sleep to match dt
        auto step_end = std::chrono::steady_clock::now();
        auto step_duration = std::chrono::duration_cast<std::chrono::microseconds>(
            step_end - step_start).count();
        auto target_duration_us = static_cast<long>(dt * 1e6);
        auto sleep_time_us = target_duration_us - step_duration;

        if (sleep_time_us > 0) {
            std::this_thread::sleep_for(std::chrono::microseconds(sleep_time_us));
        }
    }

    std::cout << "Simulation complete. Check trajectory.csv and poses_ours.csv" << std::endl;

    return 0;
}
