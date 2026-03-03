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
};


struct State : public IEntityState {
    // State variables from Solution DSL
    Eigen::VectorXd u;
    double p_mapping_AcrobotControlled_Link1_ElbowJoint_ElbowMotor_ControlIn = 0.0;
    Eigen::VectorXd tau;
    Eigen::MatrixXd B_ctrl;
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
    double N = 0.0;
    Eigen::MatrixXd M_mass;
    std::vector<Eigen::MatrixXd> T_geom;
    Eigen::MatrixXd T_geom_1;
    Eigen::MatrixXd T_offset_1;
    Eigen::MatrixXd T_geom_2;
    Eigen::MatrixXd T_offset_2;
    Eigen::MatrixXd T_geom_3;
    Eigen::MatrixXd T_offset_3;
    Eigen::MatrixXd M_inv;
    Eigen::VectorXd tau_d;
    Eigen::MatrixXd damping;
    std::vector<Eigen::MatrixXd> T_offset;
    std::vector<Eigen::MatrixXd> X_J_k;
    Eigen::MatrixXd H_1;
    Eigen::MatrixXd H_2;
    Eigen::MatrixXd X_J_1;
    Eigen::MatrixXd X_J_2;
    double dt = 0.0;
    std::vector<Eigen::MatrixXd> X_J;
    std::vector<Eigen::MatrixXd> X_T;
    Eigen::MatrixXd X_T_1;
    Eigen::MatrixXd X_T_2;
    Eigen::MatrixXd X_T_3;
    double ShoulderEncoderAngle = 0.0;
    double BaseLink_ShoulderEncoder_AngleOut = 0.0;
    double ShoulderEncoderVelocity = 0.0;
    double BaseLink_ShoulderEncoder_VelocityOut = 0.0;
    double ElbowEncoderAngle = 0.0;
    double Link1_ElbowEncoder_AngleOut = 0.0;
    double ElbowEncoderVelocity = 0.0;
    double Link1_ElbowEncoder_VelocityOut = 0.0;

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
