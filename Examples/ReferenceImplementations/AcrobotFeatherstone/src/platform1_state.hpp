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
    std::string meshUri;
    Eigen::VectorXd meshScale;
};


struct State {
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
    double dt = 0.0;
    std::vector<Eigen::MatrixXd> T_geom;
    Eigen::MatrixXd B_1;
    Eigen::MatrixXd B_2;
    Eigen::MatrixXd B_3;
    std::vector<Eigen::MatrixXd> B_k;
    std::vector<Eigen::MatrixXd> T_offset;
    Eigen::MatrixXd T_geom_1;
    Eigen::MatrixXd T_geom_2;
    Eigen::MatrixXd T_geom_3;
    Eigen::MatrixXd T_offset_1;
    Eigen::MatrixXd T_offset_2;
    Eigen::MatrixXd T_offset_3;

};

}  // namespace platform1

#endif  // PLATFORM1_STATE_HPP
