#include <cmath>
#include <iostream>
#include <string>

#include "interfaces.hpp"
#include "platform1_state.hpp"
#include "platform_mapping.h"
#include "utils.h"

static std::string default_log_path() {
    return std::string("../pmh_velocity_log_our_implementation.csv");
}

int main() {
    IPlatformEngine* platform_engine = get_platform_engine();
    if (!platform_engine) {
        std::cerr << "[Harness] Missing platform engine" << std::endl;
        return 1;
    }

    platform_engine->initialise();

    // Access generated state
    auto& state = static_cast<platform1::State&>(platform_engine->getPlatform().getState());
    const double dt = (state.dt > 1e-12) ? state.dt : 0.005;

    // Simple PD controller around elbow joint (index 1)
    const double kp = 30.0;   // proportional gain
    const double kd = 5.0;    // derivative gain

    // Total simulation time
    const double sim_duration = 20.0; // seconds
    const int total_steps = static_cast<int>(std::ceil(sim_duration / dt));

    enable_velocity_logging(default_log_path().c_str());

    double t = 0.0;
    for (int step = 0; step < total_steps; ++step) {
        // Defensive: ensure vectors are correctly sized
        if (state.theta.size() < 2) {
            std::cerr << "[Harness] Unexpected state.theta size: " << state.theta.size() << std::endl;
            break;
        }
        if (state.d_theta.size() < 2) {
            std::cerr << "[Harness] Unexpected state.d_theta size: " << state.d_theta.size() << std::endl;
            break;
        }

        const double theta_elbow = state.theta(1);
        const double dtheta_elbow = state.d_theta(1);

        // PD torque (target = 0.0)
        const double tau = -kp * theta_elbow - kd * dtheta_elbow;

        // Map controller output to platform mapping (Acrobot elbow actuator)
        p_mapping.Acrobot.upper_link.elbow.elbow_actuator.TorqueIn = tau;

        // Advance physics one step
        platform_engine->update();

        t += dt;
    return 0;
}


