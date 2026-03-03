#include <math.h>
#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>
#include "platform_mapping.h"
#include "dmodel_interface.h"

static double clamp(double v, double lo, double hi) { return v < lo ? lo : (v > hi ? hi : v); }

int acrobot_main(int argc, char* argv[]) {
    (void)argc; (void)argv;

    // Default Drake Acrobot parameters
    const double m1 = 1.0, m2 = 1.0;
    const double l1 = 1.0, l2 = 2.0;
    const double lc1 = 0.5, lc2 = 1.0;
    const double Ic1 = 0.083, Ic2 = 0.33;

    const double Ke_gain = 2.0;  // energy shaping
    const double Kp = 10.0;      // partial feedback linearization
    const double Kd = 2.0;       // damping on elbow

    printf("[Acrobot Controller] Starting d-model control loop\n");
    fflush(stdout);

    // Controller loop: synchronize with orchestrator via registerRead (SimpleArm pattern)
    int cycle_count = 0;
    for (;;) {
        int input_type;
        EventData input_value;
        if (!registerRead(&input_type, &input_value, sizeof(input_value))) {
            break; // orchestrator terminating
        }
        if (input_type == INPUT_TERMINATE) {
            break;
        }
        if (input_type != INPUT_DONE) {
            continue; // ignore non-done events (none for Acrobot)
        }
        // Compute gravity magnitude from world sensor
        double gx = p_mapping.World.gravity_world[0];
        double gy = p_mapping.World.gravity_world[1];
        double gz = p_mapping.World.gravity_world[2];
        double g = sqrt(gx*gx + gy*gy + gz*gz);
        if (!(g > 0.0)) g = 9.81;

        // Read joint states from mapping (updated by orchestrator each cycle)
        const double q1 = p_mapping.Acrobot.upper_link.shoulder.angle;
        const double q2 = p_mapping.Acrobot.upper_link.elbow.angle;
        const double dq1 = p_mapping.Acrobot.upper_link.shoulder.velocity;
        const double dq2 = p_mapping.Acrobot.upper_link.elbow.velocity;

        // Dynamics terms from mapping
        const double a2 = p_mapping.Acrobot.dynamics.M_inv[0][1];
        const double a3 = p_mapping.Acrobot.dynamics.M_inv[1][1];
        const double C0 = p_mapping.Acrobot.dynamics.bias[0];
        const double C1 = p_mapping.Acrobot.dynamics.bias[1];

        // Energies (compute locally)
        const double c2 = cos(q2);
        const double q12 = q1 + q2;
        const double c12 = cos(q12);

        // Kinetic Energy
        const double h11 = Ic1 + Ic2 + m1*lc1*lc1 + m2*(l1*l1 + lc2*lc2 + 2*l1*lc2*c2);
        const double h22 = Ic2 + m2*lc2*lc2;
        const double h12 = Ic2 + m2*(lc2*lc2 + l1*lc2*c2);
        const double KE = 0.5*h11*dq1*dq1 + 0.5*h22*dq2*dq2 + h12*dq1*dq2;

        // Potential Energy (zero at downward configuration)
        const double PE = -g * (m1*lc1*cos(q1) + m2*(l1*cos(q1) + lc2*c12));
        const double E = KE + PE;
        const double E_desired = (m1*lc1 + m2*(l1 + lc2)) * g;
        const double E_tilde = E - E_desired;

        // Energy shaping component
        const double u_e = -Ke_gain * E_tilde * dq2;

        // Partial feedback linearization on elbow
        const double y = -Kp * q2 - Kd * dq2;
        const double u_p = (a2 * C0 + y) / (a3 != 0.0 ? a3 : 1e-6) + C1;

        double u = u_e + u_p;
        // Kickstart: inject small torque for first 50 cycles if system is exactly at rest
        if (cycle_count < 50 && fabs(dq2) < 1e-6 && fabs(q2) < 1e-6) {
            u = 0.5;
        }
        u = clamp(u, -20.0, 20.0);

        // Debug output every 200 cycles (~1 second)
        if (cycle_count % 200 == 0) {
            printf("[Acrobot Controller] Cycle %d: q=[%.3f, %.3f], dq=[%.3f, %.3f], u=%.3f, E_tilde=%.3f\n",
                   cycle_count, q1, q2, dq1, dq2, u, E_tilde);
            fflush(stdout);
        }

        // Send torque command to orchestrator via registerWrite
        registerWrite(&(OperationData){OUTPUT_TORQUE, 1, {u}, (double)cycle_count * 0.005});

        cycle_count++;
        if (cycle_count % 200 == 0) {
            printf("[Acrobot Controller] Cycle %d: q=[%.3f, %.3f], u=%.3f, E_tilde=%.3f\n", 
                   cycle_count, q1, q2, u, E_tilde);
        }
    }

    printf("[Acrobot Controller] Exiting after %d cycles\n", cycle_count);
    return 0;
}
