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
    std::vector<Eigen::VectorXd> motor_k;
    std::vector<Eigen::VectorXd> motor_joint;
    Eigen::VectorXd theta;
    std::vector<Eigen::VectorXd> motor_T;
    std::vector<Eigen::VectorXd> H;
    Eigen::VectorXd l;
    Eigen::VectorXd lc;
    int n = 0;
    Eigen::MatrixXd B_1;
    Eigen::MatrixXd B_2;
    Eigen::MatrixXd B_3;
    Eigen::VectorXd motor_T_3;
    Eigen::VectorXd motor_T_2;
    Eigen::VectorXd motor_T_1;
    Eigen::VectorXd H_2;
    Eigen::VectorXd H_1;
    int N = 0;
    Eigen::MatrixXd M_mass;
    Eigen::VectorXd m;
    Eigen::VectorXd Ic;
    std::vector<Eigen::MatrixXd> M_spatial;
    Eigen::MatrixXd M_3;
    Eigen::MatrixXd M_2;
    Eigen::MatrixXd M_1;
    Eigen::VectorXd bias;
    Eigen::VectorXd theta_dot;
    Eigen::VectorXd b;
    double gravity = 0.0;
    Eigen::VectorXd theta_dotdot;
    Eigen::VectorXd tau;
    Eigen::VectorXd d_theta_dot;
    double dt = 0.0;
    Eigen::VectorXd d_theta;

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
