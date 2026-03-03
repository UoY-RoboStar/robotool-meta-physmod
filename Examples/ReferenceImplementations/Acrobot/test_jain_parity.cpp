#include <iostream>
#include <iomanip>
#include <cmath>
#include <array>

// Reference implementation
namespace ref {
    extern "C" {
        void platform1_initialise(void);
        void platform1_compute_dynamics_at_state(double theta0, double theta1,
                                                 double dtheta0, double dtheta1,
                                                 double* bias_out,
                                                 double* mass_out,
                                                 double* coriolis_out,
                                                 double* gravity_out);
    }
}

// Jain implementation - we'll compile it separately
namespace jain {
    extern "C" {
        void platform1_initialise(void);
        void platform1_compute_dynamics_at_state(double theta0, double theta1,
                                                 double dtheta0, double dtheta1,
                                                 double* bias_out,
                                                 double* mass_out,
                                                 double* coriolis_out,
                                                 double* gravity_out);
    }
}

bool compare_values(double a, double b, double tol, const char* name) {
    double err = std::abs(a - b);
    if (err > tol) {
        std::cout << "  MISMATCH " << name << ": ref=" << a << " jain=" << b << " err=" << err << std::endl;
        return false;
    }
    return true;
}

int main() {
    std::cout << "=== Testing Jain implementation against reference ===" << std::endl;
    
    // Initialize both
    ref::platform1_initialise();
    jain::platform1_initialise();
    
    // Test at several configurations
    std::array<std::array<double, 4>, 5> test_configs = {{
        {1.0, 1.0, 0.0, 0.0},      // Initial config (Drake default)
        {0.0, 0.0, 0.0, 0.0},      // Zero config
        {0.5, -0.3, 0.2, -0.1},    // Random config 1
        {1.5, 0.8, -0.5, 0.3},     // Random config 2
        {-0.7, 1.2, 0.4, -0.6}     // Random config 3
    }};
    
    const double tolerance = 1e-9;
    int passed = 0;
    int total = 0;
    
    for (size_t i = 0; i < test_configs.size(); ++i) {
        double theta0 = test_configs[i][0];
        double theta1 = test_configs[i][1];
        double dtheta0 = test_configs[i][2];
        double dtheta1 = test_configs[i][3];
        
        std::cout << "\nTest " << (i+1) << ": theta=[" << theta0 << ", " << theta1 
                  << "], dtheta=[" << dtheta0 << ", " << dtheta1 << "]" << std::endl;
        
        double ref_bias[2], ref_mass[4], ref_coriolis[2], ref_gravity[2];
        double jain_bias[2], jain_mass[4], jain_coriolis[2], jain_gravity[2];
        
        ref::platform1_compute_dynamics_at_state(theta0, theta1, dtheta0, dtheta1,
                                                  ref_bias, ref_mass, ref_coriolis, ref_gravity);
        jain::platform1_compute_dynamics_at_state(theta0, theta1, dtheta0, dtheta1,
                                                   jain_bias, jain_mass, jain_coriolis, jain_gravity);
        
        bool test_passed = true;
        
        // Compare mass matrix
        test_passed &= compare_values(ref_mass[0], jain_mass[0], tolerance, "M(0,0)");
        test_passed &= compare_values(ref_mass[1], jain_mass[1], tolerance, "M(0,1)");
        test_passed &= compare_values(ref_mass[2], jain_mass[2], tolerance, "M(1,0)");
        test_passed &= compare_values(ref_mass[3], jain_mass[3], tolerance, "M(1,1)");
        
        // Compare bias
        test_passed &= compare_values(ref_bias[0], jain_bias[0], tolerance, "bias[0]");
        test_passed &= compare_values(ref_bias[1], jain_bias[1], tolerance, "bias[1]");
        
        // Compare gravity
        test_passed &= compare_values(ref_gravity[0], jain_gravity[0], tolerance, "gravity[0]");
        test_passed &= compare_values(ref_gravity[1], jain_gravity[1], tolerance, "gravity[1]");
        
        // Compare coriolis
        test_passed &= compare_values(ref_coriolis[0], jain_coriolis[0], tolerance, "coriolis[0]");
        test_passed &= compare_values(ref_coriolis[1], jain_coriolis[1], tolerance, "coriolis[1]");
        
        if (test_passed) {
            std::cout << "  ✓ PASSED" << std::endl;
            passed++;
        } else {
            std::cout << "  ✗ FAILED" << std::endl;
        }
        total++;
    }
    
    std::cout << "\n=== Results: " << passed << "/" << total << " tests passed ===" << std::endl;
    
    return (passed == total) ? 0 : 1;
}


