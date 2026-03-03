// Platform1 State - Four-Bar Linkage Reference Implementation
// This header defines the consolidated state structure for the platform physics engine
// Closed-chain dynamics are enforced via Lagrange multipliers in the engine

#ifndef PLATFORM1_STATE_HPP
#define PLATFORM1_STATE_HPP

#include <Eigen/Dense>
#include <vector>

namespace platform1 {

// Custom datatypes from Solution DSL
struct Geom {
    std::string geomType;
    Eigen::VectorXd geomVal;
};

struct State {
    // Number of links (3 moving links in the four-bar: A, B, C)
    int n = 0;

    // Link transforms (4x4 homogeneous transforms from world frame)
    Eigen::MatrixXd B_1;  // Transform to link A frame (crank)
    Eigen::MatrixXd B_2;  // Transform to link B frame (coupler)
    Eigen::MatrixXd B_3;  // Transform to link C frame (rocker)
    std::vector<Eigen::MatrixXd> B_k;

    // Joint transforms (6x6 spatial transforms)
    Eigen::MatrixXd X_J_1;
    Eigen::MatrixXd X_J_2;
    Eigen::MatrixXd X_J_3;
    std::vector<Eigen::MatrixXd> X_J;

    // Tree transforms (6x6 spatial transforms for tree structure)
    Eigen::MatrixXd X_T_1;
    Eigen::MatrixXd X_T_2;
    Eigen::MatrixXd X_T_3;
    std::vector<Eigen::MatrixXd> X_T;

    // Joint angles and velocities
    // theta(0) = qA (crank angle)
    // theta(1) = qB (relative coupler angle)
    // theta(2) = qC (rocker angle)
    Eigen::VectorXd theta;
    Eigen::VectorXd d_theta;
    Eigen::VectorXd dd_theta;

    // Force transforms (phi matrix for SKO formulation)
    Eigen::MatrixXd phi;

    // Bias forces (Coriolis + gravity)
    Eigen::VectorXd C;

    // Spatial inertia matrices for each link
    Eigen::MatrixXd M_1;
    Eigen::MatrixXd M_2;
    Eigen::MatrixXd M_3;

    // Joint selection matrices
    Eigen::MatrixXd H;
    Eigen::MatrixXd H_1;
    Eigen::MatrixXd H_2;
    Eigen::MatrixXd H_3;

    // RNEA intermediate variables
    Eigen::VectorXd alpha;  // Accelerations
    Eigen::VectorXd V;      // Velocities
    Eigen::VectorXd a;      // Joint accelerations
    Eigen::VectorXd b;      // Bias accelerations
    Eigen::VectorXd f;      // Forces

    // System inertia matrix (SKO formulation)
    Eigen::MatrixXd M;

    // Joint-space mass matrix and inverse
    Eigen::MatrixXd M_mass;
    Eigen::MatrixXd M_inv;

    // Number of DOF (1 for kinematically-constrained four-bar)
    double N = 0.0;

    // Damping
    Eigen::VectorXd tau_d;
    Eigen::MatrixXd damping;

    // Applied torques
    Eigen::VectorXd tau;

    // Timestep
    double dt = 0.0;

    // Visualization transforms
    Eigen::MatrixXd T_geom_1;
    Eigen::MatrixXd T_geom_2;
    Eigen::MatrixXd T_geom_3;
    std::vector<Eigen::MatrixXd> T_geom;

    // Visualization offsets (from joint frame to geometric center)
    Eigen::MatrixXd T_offset_1;
    Eigen::MatrixXd T_offset_2;
    Eigen::MatrixXd T_offset_3;
    std::vector<Eigen::MatrixXd> T_offset;

    // Physical parameters (Drake four_bar model)
    double link_length = 4.0;    // Length of each link (m)
    double link_mass = 20.0;     // Mass of each link (kg)
    double ground_length = 2.0;  // Distance between world pivots (m)
    double link_inertia_yy = 0.0;  // Moment of inertia about joint axis (kg·m²)

    // Geometry specifications for visualization
    Geom L_A_geom;
    Geom L_B_geom;
    Geom L_C_geom;
};

}  // namespace platform1

#endif  // PLATFORM1_STATE_HPP
