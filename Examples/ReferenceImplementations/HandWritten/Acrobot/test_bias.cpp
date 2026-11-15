#include <algorithm>
#include <array>
#include <cmath>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <sstream>
#include <string>

extern "C" {
    void platform1_initialise(void);
    void platform1_compute_dynamics_at_state(double theta0, double theta1,
                                             double dtheta0, double dtheta1,
                                             double* bias_out,
                                             double* mass_out,
                                             double* coriolis_out,
                                             double* gravity_out);
}

int main() {
    platform1_initialise();

    std::ifstream file("../../../../drake_examples/acrobot/trajectory_drake.csv");
    if (!file.is_open()) {
        std::cerr << "Failed to open drake_examples/acrobot/trajectory_drake.csv" << std::endl;
        return 1;
    }

    std::string line;
    std::getline(file, line);  // header

    double max_bias_err = 0.0;
    double max_mass_err = 0.0;
    double sum_bias_err = 0.0;
    double sum_mass_err = 0.0;
    size_t sample_count = 0;
    double worst_time = 0.0;
    double worst_bias_expected[2] = {0.0, 0.0};
    double worst_bias_calc[2] = {0.0, 0.0};
    double worst_theta[2] = {0.0, 0.0};
    double worst_dtheta[2] = {0.0, 0.0};
    double worst_coriolis[2] = {0.0, 0.0};
    double worst_gravity[2] = {0.0, 0.0};

    while (std::getline(file, line)) {
        if (line.empty()) continue;
        std::stringstream ss(line);
        std::string field;
        std::array<double, 13> fields{};
        int idx = 0;
        while (std::getline(ss, field, ',') && idx < static_cast<int>(fields.size())) {
            fields[idx++] = std::stod(field);
        }
        if (idx < 12) continue;

        double theta0 = fields[1];
        double theta1 = fields[2];
        double dtheta0 = fields[3];
        double dtheta1 = fields[4];
        double M00 = fields[7];
        double M01 = fields[8];
        double M10 = fields[9];
        double M11 = fields[10];
        double bias0 = fields[11];
        double bias1 = fields[12];

        double bias_out[2];
        double mass_out[4];
        double coriolis_out[2];
        double gravity_out[2];
        platform1_compute_dynamics_at_state(theta0, theta1, dtheta0, dtheta1,
                                            bias_out, mass_out, coriolis_out, gravity_out);

        double bias_err0 = std::abs(bias_out[0] - bias0);
        double bias_err1 = std::abs(bias_out[1] - bias1);
        double mass_err00 = std::abs(mass_out[0] - M00);
        double mass_err01 = std::abs(mass_out[1] - M01);
        double mass_err10 = std::abs(mass_out[2] - M10);
        double mass_err11 = std::abs(mass_out[3] - M11);

        if (bias_err0 > max_bias_err) {
            max_bias_err = bias_err0;
            worst_time = fields[0];
            worst_bias_expected[0] = bias0;
            worst_bias_expected[1] = bias1;
            worst_bias_calc[0] = bias_out[0];
            worst_bias_calc[1] = bias_out[1];
            worst_theta[0] = theta0;
            worst_theta[1] = theta1;
            worst_dtheta[0] = dtheta0;
            worst_dtheta[1] = dtheta1;
            worst_coriolis[0] = coriolis_out[0];
            worst_coriolis[1] = coriolis_out[1];
            worst_gravity[0] = gravity_out[0];
            worst_gravity[1] = gravity_out[1];
        }
        if (bias_err1 > max_bias_err) {
            max_bias_err = bias_err1;
            worst_time = fields[0];
            worst_bias_expected[0] = bias0;
            worst_bias_expected[1] = bias1;
            worst_bias_calc[0] = bias_out[0];
            worst_bias_calc[1] = bias_out[1];
            worst_theta[0] = theta0;
            worst_theta[1] = theta1;
            worst_dtheta[0] = dtheta0;
            worst_dtheta[1] = dtheta1;
            worst_coriolis[0] = coriolis_out[0];
            worst_coriolis[1] = coriolis_out[1];
            worst_gravity[0] = gravity_out[0];
            worst_gravity[1] = gravity_out[1];
        }
        max_mass_err = std::max({max_mass_err, mass_err00, mass_err01, mass_err10, mass_err11});
        sum_bias_err += bias_err0 + bias_err1;
        sum_mass_err += mass_err00 + mass_err01 + mass_err10 + mass_err11;
        ++sample_count;
    }

    std::cout << std::fixed << std::setprecision(9);
    std::cout << "Samples compared: " << sample_count << std::endl;
    std::cout << "Max bias error: " << max_bias_err << std::endl;
    std::cout << "Max mass error: " << max_mass_err << std::endl;
    std::cout << "Mean bias error: " << (sum_bias_err / (sample_count * 2.0)) << std::endl;
    std::cout << "Mean mass error: " << (sum_mass_err / (sample_count * 4.0)) << std::endl;
    std::cout << "Worst bias sample at t=" << worst_time
              << " theta=[" << worst_theta[0] << ", " << worst_theta[1]
              << "] dtheta=[" << worst_dtheta[0] << ", " << worst_dtheta[1] << "]" << std::endl;
    std::cout << "  expected bias=[" << worst_bias_expected[0] << ", "
              << worst_bias_expected[1] << "]" << std::endl;
    std::cout << "  computed bias=[" << worst_bias_calc[0] << ", "
              << worst_bias_calc[1] << "]" << std::endl;
    std::cout << "  coriolis=[" << worst_coriolis[0] << ", " << worst_coriolis[1]
              << "] gravity=[" << worst_gravity[0] << ", " << worst_gravity[1]
              << "] damping=[" << (worst_bias_calc[0] - worst_coriolis[0] - worst_gravity[0])
              << ", " << (worst_bias_calc[1] - worst_coriolis[1] - worst_gravity[1]) << "]"
              << std::endl;

    const double tol = 1e-6;
    if (max_bias_err < tol && max_mass_err < tol) {
        std::cout << "✓ Dynamics match Drake to numerical precision." << std::endl;
        return 0;
    }

    std::cout << "✗ Dynamics differ from Drake beyond tolerance." << std::endl;
    return 1;
}

