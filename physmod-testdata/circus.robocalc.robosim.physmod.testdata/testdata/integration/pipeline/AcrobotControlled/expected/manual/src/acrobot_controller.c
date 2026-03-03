/**
 * Acrobot Spong Controller
 *
 * Implements the Spong swing-up controller as described in:
 *   Spong, Mark W. "Swing up control of the acrobot." Robotics and Automation,
 *   1994. Proceedings., 1994 IEEE International Conference on. IEEE, 1994.
 *
 * This implementation matches Drake's acrobot example controller.
 *
 * Swing-up control law: u = u_p + u_e
 *   u_e: Energy shaping controller to pump energy into the system
 *   u_p: Partial feedback linearization to stabilize q2
 *
 * When near upright, switches to LQR balancing controller.
 */
#include <math.h>
#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include "platform_mapping.h"
#include "dmodel_interface.h"

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

static double clamp(double v, double lo, double hi) { return v < lo ? lo : (v > hi ? hi : v); }

// Wrap angle to [low, high) - matches Drake's wrap_to
static double wrap_to(double value, double low, double high) {
    double range = high - low;
    double wrapped = fmod(value - low, range);
    if (wrapped < 0.0) wrapped += range;
    return wrapped + low;
}

// #region agent log
static long long agent_now_ms(void) {
    struct timespec ts;
    clock_gettime(CLOCK_REALTIME, &ts);
    return (long long)ts.tv_sec * 1000LL + (long long)(ts.tv_nsec / 1000000LL);
}

static void agent_log(const char* runId,
                      const char* hypothesisId,
                      const char* location,
                      const char* message,
                      const char* data_json) {
    FILE* f = fopen("/home/arjunbadyal/MathHub/ABadyal/source/Thesis/.cursor/debug.log", "a");
    if (!f) return;
    long long ts = agent_now_ms();
    fprintf(
        f,
        "{\"sessionId\":\"debug-session\",\"runId\":\"%s\",\"hypothesisId\":\"%s\","
        "\"location\":\"%s\",\"message\":\"%s\",\"data\":%s,\"timestamp\":%lld}\n",
        runId, hypothesisId, location, message, data_json, ts
    );
    fclose(f);
}
// #endregion

int acrobot_main(int argc, char* argv[]) {
    (void)argc; (void)argv;

    // Drake Acrobot physical parameters
    // m1=1.0, l1=1.0, lc1=0.5, Ic1=0.083 (link 1)
    // m2=1.0, l2=2.0, lc2=1.0, Ic2=0.333 (link 2)
    const double m1 = 1.0, m2 = 1.0;
    const double l1 = 1.0, l2 = 2.0;
    const double lc1 = 0.5, lc2 = 1.0;
    const double Ic1 = 0.083, Ic2 = 0.333;

    // Drake default Spong controller gains
    const double k_e = 5.0;    // Energy shaping gain
    const double k_p = 50.0;   // Partial feedback linearization P gain
    const double k_d = 5.0;    // Partial feedback linearization D gain

    // LQR gains for balancing (computed from linearized dynamics at upright equilibrium)
    // Using Q = diag(10, 10, 1, 1), R = 1, matching Drake's LQR setup
    const double K[4] = {-278.44, -112.29, -119.72, -56.83};

    // Drake switching: (x-x0)' S (x-x0) < balancing_threshold
    const double balancing_threshold = 1000.0;
    const double S[4][4] = {
        {16620.60660545, 7470.18734010, 7240.12368147, 3571.58116271},
        { 7470.18734010, 3374.43640794, 3256.40272521, 1608.54161654},
        { 7240.12368147, 3256.40272521, 3154.73036214, 1556.50607291},
        { 3571.58116271, 1608.54161654, 1556.50607291,  768.33308414},
    };

    printf("[Acrobot Spong Controller] Starting swing-up + LQR control loop\n");
    printf("[Acrobot Spong Controller] Gains: k_e=%.1f, k_p=%.1f, k_d=%.1f, balancing_threshold=%.1f\n",
           k_e, k_p, k_d, balancing_threshold);
    fflush(stdout);

    // Controller loop
    int cycle_count = 0;
    bool balancing_mode = false;
    bool prev_balancing_mode = false;

    // Sensor values received via registerRead (robot sensors from platform mapping only)
    double shoulder_angle = 0.0;   // ShoulderEncoder.AngleOut (TIP joint = Drake's θ2)
    double shoulder_velocity = 0.0; // ShoulderEncoder.VelocityOut
    double elbow_angle = 0.0;      // ElbowEncoder.AngleOut (BASE joint = Drake's θ1)
    double elbow_velocity = 0.0;   // ElbowEncoder.VelocityOut
    
    // Gravity is a constant (world property, not a robot sensor input)
    const double g = 9.81;

    for (;;) {
        int input_type;
        EventData input_event;
        if (!registerRead(&input_type, &input_event, sizeof(input_event))) {
            break;
        }
        
        // Process sensor events (robot sensors only)
        switch (input_type) {
            case INPUT_SHOULDER_ANGLE:
                if (input_event.occurred) {
                    shoulder_angle = input_event.value;
                }
                continue;  // Wait for more sensors
            case INPUT_SHOULDER_VELOCITY:
                if (input_event.occurred) {
                    shoulder_velocity = input_event.value;
                }
                continue;
            case INPUT_ELBOW_ANGLE:
                if (input_event.occurred) {
                    elbow_angle = input_event.value;
                }
                continue;
            case INPUT_ELBOW_VELOCITY:
                if (input_event.occurred) {
                    elbow_velocity = input_event.value;
                }
                continue;
            case INPUT_TERMINATE:
                goto exit_loop;
            case INPUT_DONE:
                // All sensors received, compute control below
                break;
            default:
                continue;
        }

        // Map sensor readings to Drake's convention
        // IMPORTANT: Our kinematic chain is TIP-to-BASE, opposite of Drake's BASE-to-TIP
        // - Our ShoulderEncoder is actually the TIP joint (Drake's θ2)
        // - Our ElbowEncoder is actually the BASE joint (Drake's θ1)
        // So we SWAP the sensor readings to match Drake's convention:
        const double q1_raw = elbow_angle;      // BASE = Drake's q1 (shoulder)
        const double q2_raw = shoulder_angle;   // TIP = Drake's q2 (elbow)
        const double dq1 = elbow_velocity;      // BASE velocity
        const double dq2 = shoulder_velocity;   // TIP velocity

        // Wrap angles (Drake convention)
        // theta1 wrapped to [0, 2π], theta2 wrapped to [-π, π]
        double q1 = wrap_to(q1_raw, 0.0, 2.0 * M_PI);
        double q2 = wrap_to(q2_raw, -M_PI, M_PI);

        // State error from upright equilibrium x0 = [π, 0, 0, 0]
        double x_err[4] = {
            q1 - M_PI,
            q2,
            dq1,
            dq2
        };

        // Drake switching criterion: (x-x0)' S (x-x0) < balancing_threshold
        double cost = 0.0;
        for (int i = 0; i < 4; ++i) {
            for (int j = 0; j < 4; ++j) {
                cost += x_err[i] * S[i][j] * x_err[j];
            }
        }
        bool near_upright = (cost < balancing_threshold);

        double u;

        if (near_upright) {
            // LQR Balancing mode: u = K * (x0 - x) = -K * x_err
            balancing_mode = true;
            u = -(K[0] * x_err[0] + K[1] * x_err[1] + K[2] * x_err[2] + K[3] * x_err[3]);
        } else {
            // Spong Swing-up mode: u = u_p + u_e
            balancing_mode = false;

            // Compute mass matrix elements for energy calculation
            double cos_q2 = cos(q2);
            double M11 = Ic1 + Ic2 + m1*lc1*lc1 + m2*(l1*l1 + lc2*lc2 + 2.0*l1*lc2*cos_q2);
            double M12 = Ic2 + m2*(lc2*lc2 + l1*lc2*cos_q2);
            double M22 = Ic2 + m2*lc2*lc2;

            // Compute kinetic energy: KE = 0.5 * dq' * M * dq
            double KE = 0.5 * (M11*dq1*dq1 + 2.0*M12*dq1*dq2 + M22*dq2*dq2);

            // Compute potential energy: PE = -m1*g*lc1*cos(q1) - m2*g*(l1*cos(q1) + lc2*cos(q1+q2))
            double cos_q1 = cos(q1);
            double cos_q1_q2 = cos(q1 + q2);
            double PE = -m1*g*lc1*cos_q1 - m2*g*(l1*cos_q1 + lc2*cos_q1_q2);

            // Total energy
            double E = PE + KE;

            // Desired energy (potential energy at upright: q1=π, q2=0)
            double E_desired = (m1*lc1 + m2*(l1 + lc2)) * g;

            // Energy error
            double E_tilde = E - E_desired;

            // Energy shaping control: u_e = -k_e * E_tilde * dq2
            double u_e = -k_e * E_tilde * dq2;

            // Partial feedback linearization for q2 stabilization
            // We want: q2_ddot = y = -k_p * q2 - k_d * dq2
            // From acrobot dynamics: q̈ = M⁻¹ * (Bu - bias), where:
            //   M⁻¹ = [a1, a2; a2, a3],  B=[0;1],  bias=[C0;C1]
            // We have: q̈₂ = -C0*a2 + a3*(u - C1)
            // Equating to y gives: u_p = (a2*C0 + y)/a3 + C1.
            double y = -k_p * q2 - k_d * dq2;

            // Partial feedback linearization using analytic dynamics (matches Drake)
            double u_p = 0.0;  // Will be computed below as u_p_an

            // H3: Compare against analytic Acrobot dynamics (Drake controller computes this internally).
            // Standard bias terms (Coriolis + gravity) for Acrobot with q=[q1,q2], dq=[dq1,dq2]:
            double sin_q2 = sin(q2);
            double C1_an = -m2*l1*lc2*sin_q2*(2.0*dq1*dq2 + dq2*dq2)
                           + (m1*lc1 + m2*l1)*g*sin(q1)
                           + m2*lc2*g*sin(q1 + q2);
            double C2_an =  m2*l1*lc2*sin_q2*(dq1*dq1)
                           + m2*lc2*g*sin(q1 + q2);
            // Inverse mass matrix (2x2) from (M11,M12,M22)
            double det = M11*M22 - M12*M12;
            double a2_an = (det != 0.0) ? (-M12 / det) : 0.0;
            double a3_an = (det != 0.0) ? ( M11 / det) : 0.0;
            // u_p derived from qdd2 = -a2*C1 + a3*(u - C2), set to y:
            double u_p_an = (a2_an * C1_an + y) / (a3_an != 0.0 ? a3_an : 1e-6) + C2_an;

            // Use analytic partial feedback linearization (closer to Drake's AcrobotSpongController).
            // Keep u_p (sensor-based) for logging/diagnostics only.
            double u_p_used = u_p_an;

            // Combined swing-up control
            u = u_e + u_p_used;

            // Debug output every 200 cycles
            if (cycle_count % 200 == 0) {
                printf("[Spong] Cycle %d: E=%.2f, E_des=%.2f, E_tilde=%.2f, u_e=%.2f, u_p=%.2f\n",
                       cycle_count, E, E_desired, E_tilde, u_e, u_p_an);
                char buf[512];
                snprintf(buf, sizeof(buf),
                         "{\"cycle\":%d,\"q1_raw\":%.6f,\"q2_raw\":%.6f,\"q1\":%.6f,\"q2\":%.6f,"
                         "\"dq1\":%.6f,\"dq2\":%.6f,\"cost\":%.6f,\"near_upright\":%s,"
                         "\"u_e\":%.6f,\"u_p_an\":%.6f,"
                         "\"a2_an\":%.6f,\"a3_an\":%.6f,\"C1_an\":%.6f,\"C2_an\":%.6f}",
                         cycle_count, q1_raw, q2_raw, q1, q2, dq1, dq2, cost, near_upright ? "true" : "false",
                         u_e, u_p_an,
                         a2_an, a3_an, C1_an, C2_an);
                agent_log("pre-fix", "H3", "acrobot_controller.c:swing:u_p_terms", "Analytic dynamics terms", buf);
            }
        }

        // Saturation (Drake uses ±20)
        u = clamp(u, -20.0, 20.0);

        // Debug output every 200 cycles
        if (cycle_count % 200 == 0) {
            printf("[Spong] Cycle %d: q=[%.3f, %.3f], dq=[%.3f, %.3f], err=[%.3f, %.3f], mode=%s, u=%.3f\n",
                   cycle_count, q1, q2, dq1, dq2, x_err[0], x_err[1],
                   balancing_mode ? "LQR" : "SWING", u);
            fflush(stdout);
        }

        // H2/H5: log mode switch times (hybrid controller sensitivity).
        if (cycle_count == 0) {
            agent_log("pre-fix", "H5", "acrobot_controller.c:cycle0", "Controller first-cycle state",
                      "{\"note\":\"cycle0 logged via other entries\"}");
        }
        if (balancing_mode != prev_balancing_mode) {
            char buf2[256];
            snprintf(buf2, sizeof(buf2),
                     "{\"cycle\":%d,\"t_assumed\":%.6f,\"mode\":\"%s\",\"q1\":%.6f,\"q2\":%.6f,\"dq1\":%.6f,\"dq2\":%.6f,\"u_sat\":%.6f}",
                     cycle_count, (double)cycle_count * 0.005, balancing_mode ? "LQR" : "SWING", q1, q2, dq1, dq2, u);
            agent_log("pre-fix", "H5", "acrobot_controller.c:mode_switch", "Mode switch observed", buf2);
            prev_balancing_mode = balancing_mode;
        }

        registerWrite(&(OperationData){OUTPUT_CONTROL_IN, 1, {u}, (double)cycle_count * 0.005});
        cycle_count++;
    }

exit_loop:
    printf("[Acrobot Spong Controller] Exiting after %d cycles\n", cycle_count);
    return 0;
}
