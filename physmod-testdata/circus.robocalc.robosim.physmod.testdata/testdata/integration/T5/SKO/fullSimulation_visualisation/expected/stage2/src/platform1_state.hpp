#ifndef PLATFORM1_STATE_HPP
#define PLATFORM1_STATE_HPP

#include <vector>
#include <Eigen/Dense>
#include "interfaces.hpp"  // For IPlatformState

namespace platform1 {

/**
 * Platform1-specific state structure.
 * Inherits from IPlatformState to allow polymorphic access via abstract interface.
 */
struct State : IPlatformState {
    // Kinematics and dynamics state (mirrors globals in platform1_engine.cpp)
    Eigen::Matrix4d T_21;
    Eigen::Matrix4d T_32;
    Eigen::Matrix4d T_p3;
    Eigen::MatrixXd B_1;  // 4x4
    Eigen::MatrixXd B_2;  // 4x4
    Eigen::MatrixXd B_3;  // 4x4
    std::vector<Eigen::MatrixXd> Bk; // sequence of frames
    
    // Featherstone transforms
    std::vector<Eigen::MatrixXd> X_J; // Joint transforms (6x6 spatial motion transforms) - updated from theta
    std::vector<Eigen::MatrixXd> X_T; // Fixed link transforms (4x4 homogeneous transforms) - constant

    Eigen::VectorXd tau;
    Eigen::MatrixXd phi;
    Eigen::VectorXd C;
    Eigen::MatrixXd M_1;  // 6x6
    Eigen::MatrixXd M_2;  // 6x6
    Eigen::MatrixXd M_3;  // 6x6
    int n = 0;
    Eigen::VectorXd theta;
    Eigen::MatrixXd H;
    Eigen::VectorXd d_theta;
    Eigen::VectorXd dd_theta;
    Eigen::VectorXd alpha;
    Eigen::VectorXd V;
    Eigen::VectorXd a;
    Eigen::VectorXd b;
    Eigen::VectorXd f;
    Eigen::MatrixXd M;
    Eigen::MatrixXd M_mass;
    Eigen::MatrixXd M_inv;
    double N = 0.0;
    double h = 0.0;
    double regularization = 0.0;
    double time_seconds = 0.0;
};

} // namespace platform1

#endif // PLATFORM1_STATE_HPP





