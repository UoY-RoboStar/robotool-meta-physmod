// Platform1 State - Generated from Solution DSL
// This header defines the consolidated state structure for the platform physics engine

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
    // State variables from Solution DSL
    std::vector<Eigen::MatrixXd> B_k;
    std::vector<Eigen::MatrixXd> X_J;
    std::vector<Eigen::MatrixXd> X_T;
    int n = 0;
    Eigen::VectorXd theta;
    Eigen::MatrixXd B_1;
    Eigen::MatrixXd B_2;
    Eigen::MatrixXd B_3;
    Eigen::MatrixXd B_4;
    Eigen::MatrixXd X_J_1;
    Eigen::MatrixXd X_J_2;
    Eigen::MatrixXd X_J_3;
    Eigen::MatrixXd X_T_1;
    Eigen::MatrixXd X_T_2;
    Eigen::MatrixXd X_T_3;
    Eigen::MatrixXd X_T_4;
    Eigen::MatrixXd phi;
    Eigen::VectorXd C;
    Eigen::MatrixXd M_1;
    Eigen::MatrixXd M_2;
    Eigen::MatrixXd M_3;
    Eigen::MatrixXd M_4;
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
    std::vector<Eigen::MatrixXd> T_offset;
    Eigen::MatrixXd T_geom_1;
    Eigen::MatrixXd T_offset_1;
    Eigen::MatrixXd T_geom_2;
    Eigen::MatrixXd T_offset_2;
    Eigen::MatrixXd T_geom_3;
    Eigen::MatrixXd T_offset_3;
    Eigen::MatrixXd T_geom_4;
    Eigen::MatrixXd T_offset_4;
    std::vector<Eigen::MatrixXd> X_J_k;
    Eigen::MatrixXd H_1;
    Eigen::MatrixXd H_2;
    Eigen::MatrixXd H_3;
    Eigen::MatrixXd M_mass;
    Eigen::MatrixXd M_inv;
    Eigen::VectorXd tau_d;
    Eigen::MatrixXd damping;
    double dt = 0.0;
    Eigen::MatrixXd G_c;
    Eigen::VectorXd Uprime;
    Eigen::MatrixXd Q_c;
    Eigen::MatrixXd B_sel;
    Eigen::VectorXd tau;
    Eigen::VectorXd lambda_c;
    Eigen::VectorXd g_pos;

};

}  // namespace platform1

#endif  // PLATFORM1_STATE_HPP
