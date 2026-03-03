// Platform1 State - AcrobotCGA Reference Implementation
// Conformal Geometric Algebra (CGA) formulation using Motor representation
// Motor basis: (scalar, e12, e13, e23, e1i, e2i, e3i, e123i)

#ifndef PLATFORM1_STATE_HPP
#define PLATFORM1_STATE_HPP

#include <Eigen/Dense>
#include <vector>

namespace platform1 {

// Motor struct: 8-component CGA versor for rigid transformations
// Basis: (scalar, e12, e13, e23, e1i, e2i, e3i, e123i)
// For Y-axis rotation: Motor = cos(theta/2) - sin(theta/2)*e13
// For Z-axis translation: Motor = 1 - (d/2)*e3i
struct Motor {
    Eigen::Matrix<double, 8, 1> data;

    Motor() { data.setZero(); data(0) = 1.0; }  // Identity motor
    Motor(const Eigen::Matrix<double, 8, 1>& d) : data(d) {}

    double& operator[](int i) { return data(i); }
    const double& operator[](int i) const { return data(i); }

    // Scalar part (grade 0)
    double scalar() const { return data(0); }
    // Bivector parts (grade 2)
    double e12() const { return data(1); }
    double e13() const { return data(2); }
    double e23() const { return data(3); }
    // Translation parts (grade 2 with infinity)
    double e1i() const { return data(4); }
    double e2i() const { return data(5); }
    double e3i() const { return data(6); }
    // Pseudoscalar part (grade 4)
    double e123i() const { return data(7); }
};

// Twist struct: 6-component spatial velocity
// Basis: (omega_x, omega_y, omega_z, v_x, v_y, v_z)
struct Twist {
    Eigen::Matrix<double, 6, 1> data;

    Twist() { data.setZero(); }
    Twist(const Eigen::Matrix<double, 6, 1>& d) : data(d) {}

    Eigen::Vector3d omega() const { return data.head<3>(); }
    Eigen::Vector3d v() const { return data.tail<3>(); }
};

// Wrench struct: 6-component spatial force
// Basis: (tau_x, tau_y, tau_z, f_x, f_y, f_z)
struct Wrench {
    Eigen::Matrix<double, 6, 1> data;

    Wrench() { data.setZero(); }
    Wrench(const Eigen::Matrix<double, 6, 1>& d) : data(d) {}

    Eigen::Vector3d tau() const { return data.head<3>(); }
    Eigen::Vector3d f() const { return data.tail<3>(); }
};

// State structure following SKO pattern
struct State {
    // System configuration
    int n = 3;  // Number of frames (base + 2 links)
    int N = 2;  // Number of joints

    // Frame transforms (4x4 homogeneous) - for compatibility with visualization
    std::vector<Eigen::MatrixXd> B_k;
    Eigen::MatrixXd B_1;
    Eigen::MatrixXd B_2;
    Eigen::MatrixXd B_3;

    // CGA Motor representation of frames
    std::vector<Motor> motor_k;
    Motor motor_1;  // Link 1 frame motor
    Motor motor_2;  // Link 2 frame motor
    Motor motor_3;  // Base frame motor (identity)

    // Joint motors (rotation about Y-axis)
    std::vector<Motor> motor_joint;
    Motor motor_joint_1;
    Motor motor_joint_2;

    // Tree transforms (as Motors)
    std::vector<Motor> motor_T;
    Motor motor_T_1;
    Motor motor_T_2;
    Motor motor_T_3;

    // Joint state
    Eigen::VectorXd theta;      // Joint angles
    Eigen::VectorXd d_theta;    // Joint velocities
    Eigen::VectorXd dd_theta;   // Joint accelerations

    // Spatial transforms (6x6) for dynamics
    Eigen::MatrixXd phi;        // Composite spatial transform matrix

    // Dynamics matrices and vectors
    Eigen::VectorXd C;          // Bias forces (Coriolis + gravity)
    Eigen::MatrixXd M_mass;     // Mass matrix
    Eigen::MatrixXd M_inv;      // Inverse mass matrix

    // Spatial inertias (6x6 for each link)
    Eigen::MatrixXd M_1;
    Eigen::MatrixXd M_2;
    Eigen::MatrixXd M_3;
    Eigen::MatrixXd M;          // Composite spatial inertia

    // Joint axes
    Eigen::MatrixXd H;
    Eigen::VectorXd H_1;
    Eigen::VectorXd H_2;

    // Newton-Euler intermediate vectors
    Eigen::VectorXd alpha;      // Spatial acceleration
    Eigen::VectorXd V;          // Spatial velocity
    Eigen::VectorXd a;          // Cross product terms
    Eigen::VectorXd b;          // Bias terms
    Eigen::VectorXd f;          // Spatial forces

    // Control and damping
    Eigen::VectorXd tau;        // Applied torques
    Eigen::VectorXd tau_d;      // Damping torques
    Eigen::MatrixXd damping;    // Damping matrix

    // Time stepping
    double dt = 0.01;

    // Visualization transforms
    std::vector<Eigen::MatrixXd> T_geom;
    std::vector<Eigen::MatrixXd> T_offset;
    Eigen::MatrixXd T_geom_1;
    Eigen::MatrixXd T_geom_2;
    Eigen::MatrixXd T_geom_3;
    Eigen::MatrixXd T_offset_1;
    Eigen::MatrixXd T_offset_2;
    Eigen::MatrixXd T_offset_3;

    // Physical parameters
    Eigen::VectorXd m;          // Link masses
    Eigen::VectorXd l;          // Link lengths
    Eigen::VectorXd lc;         // Center of mass distances
    Eigen::VectorXd Ic;         // Moments of inertia about CoM
    Eigen::VectorXd b_damp;     // Joint damping coefficients
    double gravity = 9.81;
};

}  // namespace platform1

#endif  // PLATFORM1_STATE_HPP
