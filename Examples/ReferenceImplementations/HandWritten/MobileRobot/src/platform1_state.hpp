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
    Eigen::VectorXd u;
    double p_mapping_Turtlebot3_Burger_BaseLink_LeftWheelJoint_LeftMotor_ControlIn = 0.0;
    double p_mapping_Turtlebot3_Burger_BaseLink_RightWheelJoint_RightMotor_ControlIn = 0.0;
    Eigen::VectorXd tau;
    Eigen::MatrixXd B_ctrl;
    double n = 0.0;
    Eigen::MatrixXd phi;
    Eigen::MatrixXd B_1;
    Eigen::MatrixXd B_2;
    Eigen::MatrixXd B_3;
    std::vector<Eigen::MatrixXd> B_k;
    double inputEvent_2 = 0.0;
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
    double N = 0.0;
    Eigen::MatrixXd H_1;
    Eigen::MatrixXd H_2;
    std::vector<Eigen::MatrixXd> X_J;
    std::vector<Eigen::MatrixXd> X_T;
    Eigen::MatrixXd X_J_1;
    Eigen::MatrixXd X_J_2;
    Eigen::MatrixXd X_T_1;
    Eigen::MatrixXd X_T_2;
    Eigen::MatrixXd X_T_3;
    double inputEvent_3 = 0.0;
    Eigen::MatrixXd M_mass;
    Eigen::MatrixXd M;
    std::vector<Eigen::MatrixXd> T_geom;
    Eigen::MatrixXd T_geom_1;
    Eigen::MatrixXd T_offset_1;
    Eigen::MatrixXd T_geom_2;
    Eigen::MatrixXd T_offset_2;
    Eigen::MatrixXd T_geom_3;
    Eigen::MatrixXd T_offset_3;
    Eigen::MatrixXd M_inv;
    std::vector<Eigen::MatrixXd> T_offset;
    std::vector<Eigen::MatrixXd> X_J_k;
    Eigen::VectorXd tau_d;
    Eigen::MatrixXd damping;
    double dt = 0.0;
    double sensor_outputs = 0.0;

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
