// Platform1 State - Generated from Solution DSL
// This header defines the consolidated state structure for the platform physics engine

#ifndef PLATFORM1_STATE_HPP
#define PLATFORM1_STATE_HPP

#include <Eigen/Dense>
#include <vector>
#include "interfaces.hpp"

namespace platform1 {

// Custom datatypes from Solution DSL

struct State : public IEntityState {
    // State variables from Solution DSL
    Eigen::VectorXd tau;
    double p_mapping_SimpleArm_IntermediateLink_WristJoint_WristActuator_TorqueIn = 0.0;
    double p_mapping_SimpleArm_BaseLink_ElbowJoint_ElbowActuator_TorqueIn = 0.0;
    Eigen::MatrixXd phi;
    Eigen::MatrixXd B_1;
    Eigen::MatrixXd B_2;
    Eigen::MatrixXd B_3;
    std::vector<Eigen::MatrixXd> B_k;
    int n = 0;
    Eigen::VectorXd C;
    Eigen::MatrixXd M_1;
    Eigen::MatrixXd M_2;
    Eigen::MatrixXd M_3;
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
    Eigen::VectorXd tau_d;
    double dt = 0.0;
    std::vector<Eigen::MatrixXd> X_J;
    std::vector<Eigen::MatrixXd> X_T;
    Eigen::MatrixXd X_J_1;
    Eigen::MatrixXd X_J_2;
    Eigen::MatrixXd X_T_1;
    Eigen::MatrixXd X_T_2;
    Eigen::MatrixXd X_T_3;
    double SimpleArmSerial_BaseLink_BaseSensor_SignalIn = 0.0;

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
