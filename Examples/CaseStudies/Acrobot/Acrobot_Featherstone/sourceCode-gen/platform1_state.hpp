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
    int N = 0;
    double gravity = 0.0;
    Eigen::VectorXd dd_q;
    Eigen::VectorXd q;
    Eigen::VectorXd d_q;
    Eigen::VectorXd tau;
    Eigen::MatrixXd damping;
    std::vector<Eigen::MatrixXd> XT;
    std::vector<Eigen::MatrixXd> I;
    std::vector<int> jtype;
    int n = 0;
    double dt = 0.0;
    std::vector<Eigen::MatrixXd> T_geom;
    Geom geom_01;
    Geom geom_11;
    Geom geom_21;
    Eigen::MatrixXd B_1;
    Eigen::MatrixXd B_2;
    Eigen::MatrixXd B_3;
    std::vector<Eigen::MatrixXd> B_k;
    Eigen::MatrixXd T_geom_1;
    Eigen::MatrixXd T_geom_2;
    Eigen::MatrixXd T_geom_3;
    Eigen::MatrixXd T_offset_1;
    Eigen::MatrixXd T_offset_2;
    Eigen::MatrixXd T_offset_3;
    std::vector<Eigen::MatrixXd> T_offset;
    double sensor_outputs = 0.0;
    Eigen::VectorXd theta;
    double p_mapping_Acrobot_BaseLink_ShoulderEncoder_AngleOut = 0.0;
    Eigen::VectorXd d_theta;
    double p_mapping_Acrobot_BaseLink_ShoulderEncoder_VelocityOut = 0.0;
    double p_mapping_Acrobot_Link1_ElbowEncoder_AngleOut = 0.0;
    double p_mapping_Acrobot_Link1_ElbowEncoder_VelocityOut = 0.0;

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
