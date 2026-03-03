// Platform1 State - Generated from Solution DSL
// This header defines the consolidated state structure for the platform physics engine

#ifndef PLATFORM1_STATE_HPP
#define PLATFORM1_STATE_HPP

#include <Eigen/Dense>
#include <vector>
#include "interfaces.hpp"

namespace platform1 {

// Custom datatypes from Solution DSL
struct Geom {
    std::string geomType;
    Eigen::VectorXd geomVal;
    std::string meshUri;
    Eigen::VectorXd meshScale;
};


struct State : public IEntityState {
    // State variables from Solution DSL
    std::vector<Eigen::MatrixXd> B_k;
    std::vector<Eigen::MatrixXd> X_J;
    std::vector<Eigen::MatrixXd> X_T;
    int n = 0;
    Eigen::VectorXd theta;
    Eigen::MatrixXd B_1;
    Eigen::MatrixXd B_2;
    Eigen::MatrixXd B_3;
    Eigen::MatrixXd X_J_1;
    Eigen::MatrixXd X_J_2;
    Eigen::MatrixXd X_T_1;
    Eigen::MatrixXd X_T_2;
    Eigen::MatrixXd X_T_3;
    Eigen::MatrixXd phi;
    Eigen::VectorXd C;
    Eigen::MatrixXd M_1;
    Eigen::MatrixXd M_2;
    Eigen::MatrixXd M_3;
    Eigen::MatrixXd H;
    Eigen::VectorXd d_theta;
    Eigen::VectorXd dd_theta;
    Eigen::VectorXd alpha;
    Eigen::VectorXd V;
    Eigen::VectorXd a;
    Eigen::VectorXd b;
    Eigen::VectorXd f;
    Eigen::MatrixXd M;
    double N = 0.0;
    Eigen::MatrixXd M_mass;
    Eigen::MatrixXd M_inv;
    Eigen::VectorXd tau_d;
    Eigen::MatrixXd damping;
    double dt = 0.0;
    Eigen::VectorXd tau;

    // IEntityState interface implementation
    Eigen::Vector3d position;
    Eigen::Vector3d velocity;
    Eigen::Vector3d orientation;  // Euler angles or quaternion representation

    State() : position(Eigen::Vector3d::Zero()),
             velocity(Eigen::Vector3d::Zero()),
             orientation(Eigen::Vector3d::Zero()) {}
};

}  // namespace platform1

#endif  // PLATFORM1_STATE_HPP
