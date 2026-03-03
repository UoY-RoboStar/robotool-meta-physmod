// Platform1 Physics Engine - Generated from Solution DSL
// Generation Mode: FULL_SIMULATION_VISUALISATION
// Structure: Includes → State → Procedures → Functions → Computation → API

/* TODO/STUB */

#pragma region includes
#include <iostream>
#include <Eigen/Dense>
#include <vector>
#include <memory>
#include <thread>
#include <chrono>
#include <cmath>
#include <fstream>
#include <iomanip>
#include <cstring>
#include "platform1_state.hpp"

// FULL_SIMULATION_VISUALISATION MODE: Full orchestrator integration with visualisation
#include "interfaces.hpp"
#include "platform_mapping.h"
#include "world_mapping.h"
#include "utils.h"
// Visualization support (generated when solution name indicates visualization)
#include "visualization_client.h"
#pragma endregion includes

// ═══════════════════════════════════════════════════════════════════════════
// STATE (SolutionDSL: state { ... })
// ═══════════════════════════════════════════════════════════════════════════
#pragma region state

// Platform state (consolidated physics state)
static platform1::State state;

// Reference bindings for backward compatibility with existing code
static std::vector<Eigen::MatrixXd>& B_k = state.B_k;
static std::vector<Eigen::MatrixXd>& X_J = state.X_J;
static std::vector<Eigen::MatrixXd>& X_T = state.X_T;
static int& n = state.n;
static Eigen::VectorXd& theta = state.theta;
static Eigen::MatrixXd& B_1 = state.B_1;
static Eigen::MatrixXd& B_2 = state.B_2;
static Eigen::MatrixXd& B_3 = state.B_3;
static Eigen::MatrixXd& X_J_1 = state.X_J_1;
static Eigen::MatrixXd& X_J_2 = state.X_J_2;
static Eigen::MatrixXd& X_T_1 = state.X_T_1;
static Eigen::MatrixXd& X_T_2 = state.X_T_2;
static Eigen::MatrixXd& X_T_3 = state.X_T_3;
static Eigen::MatrixXd& phi = state.phi;
static Eigen::VectorXd& C = state.C;
static Eigen::MatrixXd& M_1 = state.M_1;
static Eigen::MatrixXd& M_2 = state.M_2;
static Eigen::MatrixXd& M_3 = state.M_3;
static Eigen::MatrixXd& H = state.H;
static Eigen::VectorXd& d_theta = state.d_theta;
static Eigen::VectorXd& dd_theta = state.dd_theta;
static Eigen::VectorXd& alpha = state.alpha;
static Eigen::VectorXd& V = state.V;
static Eigen::VectorXd& a = state.a;
static Eigen::VectorXd& b = state.b;
static Eigen::VectorXd& f = state.f;
static Eigen::MatrixXd& M = state.M;
static double& N = state.N;
static Eigen::MatrixXd& M_mass = state.M_mass;
static Eigen::MatrixXd& M_inv = state.M_inv;
static Eigen::VectorXd& tau = state.tau;
static Eigen::VectorXd& tau_d = state.tau_d;
static double& dt = state.dt;

// Additional state variables
static double t = 0.0;
// Note: dt is already available from state.dt

// Geom struct declarations for visualization
// Geometry datatypes
struct Geom { const char* geomType; int valCount; double geomVal[3]; const char* meshUri; int meshScaleCount; double meshScale[3]; };
static const Geom L1_geom = { "box", 3, {1.0, 1.0, 0.5}, "", 1, {1.0, 1.0, 1.0} };  // gripper
static const Geom L2_geom = { "cylinder", 2, {0.25, 4.0, 0.0}, "", 1, {1.0, 1.0, 1.0} };  // intermediate
static const Geom L3_geom = { "box", 3, {0.5, 0.5, 0.5}, "", 1, {1.0, 1.0, 1.0} };  // base

// Visualization runtime state (metadata extracted from Geom records in Solution DSL)
struct VisualLinkSpec {
    const char* name;
    int shape;       // 0=box, 1=cylinder, 2=sphere, 3=mesh
    double dims[3];  // Shape dimensions (interpretation depends on shape)
};

static bool visualization_enabled = true;
static std::unique_ptr<VisualizationClient> viz_client = nullptr;
static const VisualLinkSpec ROBOT_VISUAL_LINKS[] = {
    {"robot/link_1", 0, {1.0, 1.0, 0.5}},
    {"robot/link_2", 1, {0.25, 4.0, 0.0}},
    {"robot/link_3", 0, {0.5, 0.5, 0.5}}
};

// Logging state
static std::ofstream transform_log_file;
static bool transform_logging_enabled = false;
static std::ofstream torque_log_file;
static bool torque_logging_enabled = false;
// Logging variables declared in utils.cpp - use extern to access the shared globals
extern std::ofstream high_freq_log_file;
extern bool high_freq_logging_enabled;
extern int log_counter;
extern const double HIGH_FREQ_LOG_PERIOD;
extern std::ofstream velocity_log_file;
extern bool velocity_logging_enabled;

// Platform and world mapping globals
//
// Design rationale for global state:
// 1. C bridge requirement: d-model (C code) needs stable ABI to access platform mapping
// 2. extern "C" prevents name mangling, ensuring PickPlace.c can link against p_mapping
// 3. Alternative considered: heap allocation with C API getters/setters
//    - Rejected: adds indirection, increases coupling, complicates generated d-model code
// 4. Current approach: global state with clear ownership
//    - p_mapping: Written by d-model (via registerWrite), read by platform engine
//    - w_mapping: Written by world mapping (sensor computation), read by platform mapping
// 5. Thread safety: orchestrator.cpp manages all mutations via mutexes on cycle boundaries
// 6. This pattern matches RoboSim semantics: platform and world are separate processes
//    communicating via shared "channels" (here realized as global structs)
extern "C" {
mapping_state_t p_mapping = {};  // Platform mapping (d-model ↔ platform engine)
}
mapping_state_t w_mapping = {};  // World mapping (world engine → platform sensors)

#pragma endregion state

// ═══════════════════════════════════════════════════════════════════════════
// FUNCTION FORWARD DECLARATIONS
// ═══════════════════════════════════════════════════════════════════════════
Eigen::MatrixXd Identity(int n);
Eigen::MatrixXd lx(Eigen::VectorXd x, Eigen::VectorXd y);
Eigen::MatrixXd skewSymmetric(Eigen::VectorXd v);
Eigen::MatrixXd transpose(Eigen::MatrixXd m);
Eigen::MatrixXd SKO_cross_force(Eigen::VectorXd v);
Eigen::VectorXd SKOv(Eigen::VectorXd systemVector, int x);
Eigen::VectorXd l(Eigen::VectorXd Pose1, Eigen::VectorXd Pose2);
Eigen::VectorXd getFramePosition(int frame, std::vector<Eigen::MatrixXd> B_k);
Eigen::MatrixXd SKO_cross(Eigen::VectorXd v);
Eigen::MatrixXd LDLT(Eigen::MatrixXd matIn);
Eigen::MatrixXd zeroMat(int rows, int cols);
Eigen::VectorXd zeroVec(int size);
Eigen::MatrixXd CalcPhi(int i, int j, std::vector<Eigen::MatrixXd> B_k);
Eigen::MatrixXd Identity(int n, int m);
Eigen::MatrixXd SKOm(Eigen::MatrixXd systemMatrix, int x, int y);

void initVisualization();
void updateRobotVisualization();

// ═══════════════════════════════════════════════════════════════════════════
// PROCEDURES (SolutionDSL: procedures { ... })
// ═══════════════════════════════════════════════════════════════════════════
#pragma region procedures

void SKOm_set(Eigen::MatrixXd &modifier, int x, int y, Eigen::MatrixXd input) {
    modifier.block((6 * x), (6 * y), 6, 6) = input;
}


void CalcPhiStar_proc(int i, int j, std::vector<Eigen::MatrixXd> B_k, Eigen::MatrixXd &result) {
    Eigen::MatrixXd R_i = B_k[(i - 1)].block(0, 0, 3, 3);
        Eigen::MatrixXd R_j = B_k[(j - 1)].block(0, 0, 3, 3);
        Eigen::MatrixXd R_ij = (R_i.transpose() * R_j);
        Eigen::VectorXd p_i; // TODO: Dimension not provided for vector p_i
    p_i=B_k[(i - 1)].block(0, 3, 3, 1);
        Eigen::VectorXd p_j; // TODO: Dimension not provided for vector p_j
    p_j=B_k[(j - 1)].block(0, 3, 3, 1);
        Eigen::VectorXd p_ij_i; // TODO: Dimension not provided for vector p_ij_i
    p_ij_i=(R_i.transpose() * (p_j - p_i));
        Eigen::MatrixXd skew_p = skewSymmetric(p_ij_i);
        Eigen::MatrixXd neg_R_skew = (-R_ij * skew_p);
        for (int row = 0; row < 3; row++) {
        for (int col = 0; col < 3; col++) {
            result(row, col) = R_ij(row, col);
        }
    }
        for (int row = 0; row < 3; row++) {
        for (int col = 3; col < 6; col++) {
            result(row, col) = 0.0;
        }
    }
        for (int row = 3; row < 6; row++) {
        for (int col = 0; col < 3; col++) {
            result(row, col) = neg_R_skew((row - 3), col);
        }
    }
        for (int row = 3; row < 6; row++) {
        for (int col = 3; col < 6; col++) {
            result(row, col) = R_ij((row - 3), (col - 3));
        }
    }
}


void SKOv_set(Eigen::VectorXd &modifier, int x, Eigen::VectorXd input) {
    modifier.segment((6 * x), 6) = input;
}


void CalcPhi_proc(int i, int j, std::vector<Eigen::MatrixXd> B_k, Eigen::MatrixXd &result) {
    Eigen::MatrixXd R_i = B_k[(i - 1)].block(0, 0, 3, 3);
        Eigen::MatrixXd R_j = B_k[(j - 1)].block(0, 0, 3, 3);
        Eigen::MatrixXd R_ij = (R_i.transpose() * R_j);
        Eigen::VectorXd p_i; // TODO: Dimension not provided for vector p_i
    p_i=B_k[(i - 1)].block(0, 3, 3, 1);
        Eigen::VectorXd p_j; // TODO: Dimension not provided for vector p_j
    p_j=B_k[(j - 1)].block(0, 3, 3, 1);
        Eigen::VectorXd p_ij_i; // TODO: Dimension not provided for vector p_ij_i
    p_ij_i=(R_i.transpose() * (p_j - p_i));
        Eigen::MatrixXd skew_p = skewSymmetric(p_ij_i);
        for (int row = 0; row < 3; row++) {
        for (int col = 0; col < 3; col++) {
            result(row, col) = R_ij(row, col);
        }
    }
        for (int row = 0; row < 3; row++) {
        for (int col = 3; col < 6; col++) {
            result(row, col) = (skew_p * R_ij)(row, (col - 3));
        }
    }
        for (int row = 3; row < 6; row++) {
        for (int col = 0; col < 3; col++) {
            result(row, col) = 0.0;
        }
    }
        for (int row = 3; row < 6; row++) {
        for (int col = 3; col < 6; col++) {
            result(row, col) = R_ij((row - 3), (col - 3));
        }
    }
}



#pragma endregion procedures

// ═══════════════════════════════════════════════════════════════════════════
// FUNCTIONS (SolutionDSL: functions { ... })
// ═══════════════════════════════════════════════════════════════════════════
#pragma region functions

Eigen::MatrixXd Identity(int n) {
	    return Eigen::MatrixXd::Identity(n, n);
}


Eigen::MatrixXd lx(Eigen::VectorXd x, Eigen::VectorXd y) {
    Eigen::MatrixXd result = Eigen::MatrixXd::Zero(3, 3);
    result(0,0) = 0;
    result(0,1) = -l(x, y)(2);
    result(0,2) = l(x, y)(1);
    result(1,0) = l(x, y)(2);
    result(1,1) = 0;
    result(1,2) = -l(x, y)(0);
    result(2,0) = -l(x, y)(1);
    result(2,1) = l(x, y)(0);
    result(2,2) = 0;
    return result;
}


Eigen::MatrixXd skewSymmetric(Eigen::VectorXd v) {
    Eigen::MatrixXd result = Eigen::MatrixXd::Zero(3, 3);
    result(0,0) = 0;
    result(0,1) = -v(2);
    result(0,2) = v(1);
    result(1,0) = v(2);
    result(1,1) = 0;
    result(1,2) = -v(0);
    result(2,0) = -v(1);
    result(2,1) = v(0);
    result(2,2) = 0;
    return result;
}


Eigen::MatrixXd transpose(const Eigen::MatrixXd& m) {
    return m.transpose();
}


Eigen::MatrixXd SKO_cross_force(Eigen::VectorXd v) {
    Eigen::MatrixXd result = Eigen::MatrixXd::Zero(6, 6);
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
        result(i,j) = skewSymmetric(v.segment(0, 3))(i,j);
    }
    }
    for (int i = 0; i < 3; i++) {
        for (int j = 3; j < 6; j++) {
        result(i,j) = skewSymmetric(v.segment(3, 3))(i,(j - 3));
    }
    }
    for (int i = 3; i < 6; i++) {
        for (int j = 0; j < 3; j++) {
        result(i,j) = 0;
    }
    }
    for (int i = 3; i < 6; i++) {
        for (int j = 3; j < 6; j++) {
        result(i,j) = skewSymmetric(v.segment(0, 3))((i - 3),(j - 3));
    }
    }
    return result;
}


Eigen::VectorXd SKOv(Eigen::VectorXd systemVector, int x) {
    Eigen::VectorXd result = Eigen::VectorXd::Zero(6);
    result = systemVector.segment((6 * x), 6);
    return result;
}


Eigen::VectorXd l(Eigen::VectorXd Pose1, Eigen::VectorXd Pose2) {
    Eigen::VectorXd result = Eigen::VectorXd::Zero(3);
    return result;
}


Eigen::VectorXd getFramePosition(int frame, std::vector<Eigen::MatrixXd> B_k) {
    Eigen::VectorXd result = Eigen::VectorXd::Zero(3);
    result = B_k[(frame - 1)].block(0, 3, 3, 1);
    return result;
}


Eigen::MatrixXd SKO_cross(Eigen::VectorXd v) {
    Eigen::MatrixXd result = Eigen::MatrixXd::Zero(6, 6);
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
        result(i,j) = skewSymmetric(v.segment(0, 3))(i,j);
    }
    }
    for (int i = 0; i < 3; i++) {
        for (int j = 3; j < 6; j++) {
        result(i,j) = 0;
    }
    }
    for (int i = 3; i < 6; i++) {
        for (int j = 0; j < 3; j++) {
        result(i,j) = skewSymmetric(v.segment(3, 3))((i - 3),j);
    }
    }
    for (int i = 3; i < 6; i++) {
        for (int j = 3; j < 6; j++) {
        result(i,j) = skewSymmetric(v.segment(0, 3))((i - 3),(j - 3));
    }
    }
    return result;
}


Eigen::MatrixXd LDLT(const Eigen::MatrixXd& matIn) {
    return matIn.ldlt().solve(Eigen::MatrixXd::Identity(matIn.rows(), matIn.cols()));
}


Eigen::MatrixXd zeroMat(int rows, int cols) {
    return Eigen::MatrixXd::Zero(rows, cols);
}


Eigen::VectorXd zeroVec(int size) {
	    return Eigen::VectorXd::Zero(size);
	}


Eigen::MatrixXd CalcPhi(int i, int j, std::vector<Eigen::MatrixXd> B_k) {
    // Force transform φ(i,j) from frame j to frame i
    Eigen::Matrix3d R_i = B_k[i - 1].block<3,3>(0, 0);
    Eigen::Matrix3d R_j = B_k[j - 1].block<3,3>(0, 0);
    Eigen::Matrix3d R_ij = R_i.transpose() * R_j;
    Eigen::Vector3d p_i = B_k[i - 1].block<3,1>(0, 3);
    Eigen::Vector3d p_j = B_k[j - 1].block<3,1>(0, 3);
    Eigen::Vector3d p_ij_i = R_i.transpose() * (p_j - p_i);
    // skew(p) matrix
    Eigen::Matrix3d skew_p;
    skew_p << 0, -p_ij_i(2), p_ij_i(1),
              p_ij_i(2), 0, -p_ij_i(0),
              -p_ij_i(1), p_ij_i(0), 0;
    Eigen::MatrixXd X = Eigen::MatrixXd::Zero(6, 6);
    X.block<3,3>(0,0) = R_ij;
    X.block<3,3>(0,3) = skew_p * R_ij;
    X.block<3,3>(3,3) = R_ij;
    return X;
}


Eigen::MatrixXd Identity(int n, int m) {
    return Eigen::MatrixXd::Identity(n, m);
}


Eigen::MatrixXd SKOm(Eigen::MatrixXd systemMatrix, int x, int y) {
    Eigen::MatrixXd result = Eigen::MatrixXd::Zero(6, 6);
    result = systemMatrix.block((6 * x), (6 * y), 6, 6);
    return result;
}



#pragma endregion functions

// ═══════════════════════════════════════════════════════════════════════════
// INITIALIZATION (SolutionDSL: state { ... } with initial values)
// ═══════════════════════════════════════════════════════════════════════════
#pragma region initialization

void initGlobals() {
        n = 3;
        theta = Eigen::VectorXd::Zero(2);
        B_1.resize(4, 4);
        B_1 << 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 4.5, 0, 0, 0, 1;
        B_2.resize(4, 4);
        B_2 << 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.5, 0, 0, 0, 1;
        B_3.resize(4, 4);
        B_3 << 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0, 0, 0, 0, 1;
        X_J_1 = Eigen::MatrixXd::Zero(6, 6);
        X_J_2 = Eigen::MatrixXd::Zero(6, 6);
        X_T_1.resize(6, 6);
        X_T_1 << 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, -4, 0.0, 1, 0, 0, 4, 0, 0.0, 0, 1, 0, 0.0, 0.0, 0, 0, 0, 1;
        X_T_2.resize(6, 6);
        X_T_2 << 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, -0.5, 0.0, 1, 0, 0, 0.5, 0, 0.0, 0, 1, 0, 0.0, 0.0, 0, 0, 0, 1;
        X_T_3.resize(6, 6);
        X_T_3 << 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1;
        phi = Eigen::MatrixXd::Zero(18, 18);
        C = Eigen::VectorXd::Zero(2);
        M_1 = Eigen::MatrixXd::Zero(6, 6);
        M_2 = Eigen::MatrixXd::Zero(6, 6);
        M_3 = Eigen::MatrixXd::Zero(6, 6);
        H.resize(2, 18);
        H << 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
        d_theta = Eigen::VectorXd::Zero(2);
        dd_theta = Eigen::VectorXd::Zero(2);
        alpha = Eigen::VectorXd::Zero(18);
        V = Eigen::VectorXd::Zero(18);
        a = Eigen::VectorXd::Zero(18);
        b = Eigen::VectorXd::Zero(18);
        f = Eigen::VectorXd::Zero(18);
        M.resize(18, 18);
        M << 0.05205, 0.0, 0.0, 0.0, 0.125, 0.0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.0, 0.05205, 0.0, -0.125, 0.0, 0.0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.0, 0.0, 0.0208, 0.0, 0.0, 0.0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.0, -0.125, 0.0, 0.5, 0.0, 0.0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.125, 0.0, 0.0, 0.0, 0.5, 0.0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5.349, 0.0, 0.0, 0.0, 2, 0.0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.0, 5.349, 0.0, -2.0, 0.0, 0.0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.0, 0.0, 0.0313, 0.0, 0.0, 0.0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.0, -2.0, 0.0, 1, 0.0, 0.0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0.0, 0.0, 0.0, 1, 0.0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.0, 0.0, 0.0, 0.0, 0.0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 16.667, 0.0, 0.0, 0.0, 25, 0.0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.0, 22.917, 0.0, -25.0, 0.0, 0.0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.0, 0.0, 10.417, 0.0, 0.0, 0.0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.0, -25.0, 0.0, 100, 0.0, 0.0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 25, 0.0, 0.0, 0.0, 100, 0.0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.0, 0.0, 0.0, 0.0, 0.0, 100;
        N = 2;
        M_mass = Eigen::MatrixXd::Zero(2, 2);
        M_inv = Eigen::MatrixXd::Zero(2, 2);
        tau = Eigen::VectorXd::Zero(2);
        tau_d = Eigen::VectorXd::Zero(2);
        dt = 0.01;
        B_k = std::vector<typename std::remove_reference<decltype(B_1)>::type>({ B_1, B_2, B_3 });
        X_J = std::vector<typename std::remove_reference<decltype(X_J_1)>::type>({ X_J_1, X_J_2 });
        X_T = std::vector<typename std::remove_reference<decltype(X_T_1)>::type>({ X_T_1, X_T_2, X_T_3 });

    std::cout << "Physics globals initialized" << std::endl;
    visualization_enabled = true;
}

#pragma endregion initialization

// ═══════════════════════════════════════════════════════════════════════════
// COMPUTATION (SolutionDSL: computation { ... })
// ═══════════════════════════════════════════════════════════════════════════
#pragma region computation

void physics_update() {
        {
        X_J[0] << std::cos(theta(0)), -std::sin(theta(0)), 0, 0, 0, 0, std::sin(theta(0)), std::cos(theta(0)), 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, std::cos(theta(0)), -std::sin(theta(0)), 0, 0, 0, 0, std::sin(theta(0)), std::cos(theta(0)), 0, 0, 0, 0, 0, 0, 1;
        X_J[1] << 1, 0, 0, 0, 0, 0, 0, std::cos(theta(1)), -std::sin(theta(1)), 0, 0, 0, 0, std::sin(theta(1)), std::cos(theta(1)), 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, std::cos(theta(1)), -std::sin(theta(1)), 0, 0, 0, 0, std::sin(theta(1)), std::cos(theta(1));
        Eigen::MatrixXd T_XT = Eigen::MatrixXd::Zero(4, 4);
        Eigen::MatrixXd T_XJ = Eigen::MatrixXd::Zero(4, 4);
        Eigen::MatrixXd R_XT = Eigen::MatrixXd::Zero(3, 3);
        Eigen::MatrixXd BL_XT = Eigen::MatrixXd::Zero(3, 3);
        Eigen::MatrixXd S_XT = Eigen::MatrixXd::Zero(3, 3);
        Eigen::VectorXd p_XT = Eigen::VectorXd::Zero(3);
        Eigen::MatrixXd R_XJ = Eigen::MatrixXd::Zero(3, 3);
        Eigen::MatrixXd BL_XJ = Eigen::MatrixXd::Zero(3, 3);
        Eigen::MatrixXd S_XJ = Eigen::MatrixXd::Zero(3, 3);
        Eigen::VectorXd p_XJ = Eigen::VectorXd::Zero(3);
        Eigen::MatrixXd X_T_k = Eigen::MatrixXd::Zero(6, 6);
        Eigen::MatrixXd X_J_local = Eigen::MatrixXd::Zero(6, 6);
        for (int k = (n - 2); k >= 0; k += -1) {
            X_T_k = X_T[k];
            for (int i = 0; i < 3; i++) {
                for (int j = 0; j < 3; j++) {
                    R_XT(i,j) = X_T_k(i,j);
                    BL_XT(i,j) = X_T_k((i + 3),j);
                }
            }
            for (int i = 0; i < 3; i++) {
                for (int j = 0; j < 3; j++) {
                    S_XT(i,j) = 0;
                    for (int m = 0; m < 3; m++) {
                        S_XT(i,j) = (S_XT(i,j) + (BL_XT(i,m) * R_XT(j,m)));
                    }
                }
            }
            p_XT(0) = S_XT(2,1);
            p_XT(1) = S_XT(0,2);
            p_XT(2) = S_XT(1,0);
            for (int i = 0; i < 3; i++) {
                for (int j = 0; j < 3; j++) {
                    T_XT(i,j) = R_XT(i,j);
                }
            }
            for (int i = 0; i < 3; i++) {
                T_XT(i,3) = p_XT(i);
            }
            T_XT(3,0) = 0;
            T_XT(3,1) = 0;
            T_XT(3,2) = 0;
            T_XT(3,3) = 1;
            X_J_local = X_J[k];
            for (int i = 0; i < 3; i++) {
                for (int j = 0; j < 3; j++) {
                    R_XJ(i,j) = X_J_local(i,j);
                    BL_XJ(i,j) = X_J_local((i + 3),j);
                }
            }
            for (int i = 0; i < 3; i++) {
                for (int j = 0; j < 3; j++) {
                    S_XJ(i,j) = 0;
                    for (int m = 0; m < 3; m++) {
                        S_XJ(i,j) = (S_XJ(i,j) + (BL_XJ(i,m) * R_XJ(j,m)));
                    }
                }
            }
            p_XJ(0) = S_XJ(2,1);
            p_XJ(1) = S_XJ(0,2);
            p_XJ(2) = S_XJ(1,0);
            for (int i = 0; i < 3; i++) {
                for (int j = 0; j < 3; j++) {
                    T_XJ(i,j) = R_XJ(i,j);
                }
            }
            for (int i = 0; i < 3; i++) {
                T_XJ(i,3) = p_XJ(i);
            }
            T_XJ(3,0) = 0;
            T_XJ(3,1) = 0;
            T_XJ(3,2) = 0;
            T_XJ(3,3) = 1;
            B_k[k] = ((B_k[(k + 1)] * T_XT) * T_XJ);
        }
        B_1 = B_k[0];
        B_2 = B_k[1];
        B_3 = B_k[2];
    }
        {
        SKOm_set(phi, 0, 0, Eigen::MatrixXd::Identity(6, 6));
        Eigen::MatrixXd temp_1_0 = Eigen::MatrixXd::Zero(6, 6);
        {
            CalcPhi_proc(2, 1, B_k, temp_1_0);
        }
        SKOm_set(phi, 1, 0, temp_1_0);
        SKOm_set(phi, 1, 1, Eigen::MatrixXd::Identity(6, 6));
        Eigen::MatrixXd temp_2_0 = Eigen::MatrixXd::Zero(6, 6);
        {
            CalcPhi_proc(3, 1, B_k, temp_2_0);
        }
        SKOm_set(phi, 2, 0, temp_2_0);
        Eigen::MatrixXd temp_2_1 = Eigen::MatrixXd::Zero(6, 6);
        {
            CalcPhi_proc(3, 2, B_k, temp_2_1);
        }
        SKOm_set(phi, 2, 1, temp_2_1);
        SKOm_set(phi, 2, 2, Eigen::MatrixXd::Identity(6, 6));
    }
        {
        for (int k = 0; k < (n - 1); k++) {
            Eigen::VectorXd vJ; // TODO: Dimension not provided for vector vJ
        vJ=(H.block(k, (6 * k), 1, 6).transpose() * d_theta.segment(k, 1));
            if (k == 0) {
                SKOv_set(V, k, vJ);
                SKOv_set(a, k, (SKO_cross(SKOv(V, k)) * vJ));
                SKOv_set(alpha, k, SKOv(a, k));
            } else {
                Eigen::MatrixXd X_m = CalcPhi(k, (k + 1), B_k).transpose();
                SKOv_set(V, k, ((X_m * SKOv(V, (k - 1))) + vJ));
                SKOv_set(a, k, (SKO_cross(SKOv(V, k)) * vJ));
                SKOv_set(alpha, k, ((X_m * SKOv(alpha, (k - 1))) + SKOv(a, k)));
            }
        }
        for (int k = (n - 2); k >= 0; k += -1) {
            SKOv_set(b, k, ((SKOm(M, k, k) * SKOv(alpha, k)) + ((SKO_cross_force(SKOv(V, k)) * SKOm(M, k, k)) * SKOv(V, k))));
            if (k == (n - 2)) {
                SKOv_set(f, k, SKOv(b, k));
            } else {
                Eigen::MatrixXd Xf = CalcPhi((k + 1), (k + 2), B_k);
                SKOv_set(f, k, ((Xf * SKOv(f, (k + 1))) + SKOv(b, k)));
            }
        }
        for (int k = 0; k < (n - 1); k++) {
            C(k) = (H.block(k, (6 * k), 1, 6) * SKOv(f, k))(0, 0);
        }
    }
        {
        Eigen::MatrixXd R = Eigen::MatrixXd::Zero((6 * n), (6 * n));
        Eigen::VectorXd X; // TODO: Dimension not provided for vector X
        X=Eigen::VectorXd::Zero((6 * n));
        for (int k = 0; k < (n - 1); k++) {
            if (k == 0) {
                SKOm_set(R, k, k, SKOm(M, k, k));
            } else {
                Eigen::MatrixXd Xf = CalcPhi((k + 1), k, B_k);
                SKOm_set(R, k, k, (((Xf * SKOm(R, (k - 1), (k - 1))) * Xf.transpose()) + SKOm(M, k, k)));
            }
        }
        for (int k = 0; k < (n - 1); k++) {
            SKOv_set(X, k, (SKOm(R, k, k) * H.block(k, (6 * k), 1, 6).transpose()));
            M_mass(k, k) = (H.block(k, (6 * k), 1, 6) * SKOv(X, k))(0, 0);
            for (int j = (k + 1); j < (n - 1); j++) {
                Eigen::MatrixXd phi_f = CalcPhi((j + 1), j, B_k);
                SKOv_set(X, j, (phi_f * SKOv(X, (j - 1))));
                M_mass(j, k) = (H.block(j, (6 * j), 1, 6) * SKOv(X, j))(0, 0);
                M_mass(k, j) = M_mass(j, k);
            }
        }
    }
        {
        M_inv = M_mass.ldlt().solve(Eigen::MatrixXd::Identity(M_mass.rows(),M_mass.cols()));
    }
        {
        dd_theta = (M_inv * ((tau - C) - tau_d));
    }
        {
        d_theta = (d_theta + (dt * dd_theta));
    }
        {
        theta = (theta + (dt * d_theta));
    }
        {
        // skip;
    }
        
        // Update time for next iteration
        t += dt;
    
        // Log velocity data for trajectory comparison
        log_velocity(t, theta, d_theta, tau, M_mass);
    if (visualization_enabled) {
        updateRobotVisualization();
    }
}

#pragma endregion computation

// ═══════════════════════════════════════════════════════════════════════════
// VISUALIZATION SUPPORT
// ═══════════════════════════════════════════════════════════════════════════
#pragma region visualization

void updateRobotVisualization() {
    if (!viz_client || !viz_client->isConnected()) {
        return;
    }
    const std::size_t linkCount = sizeof(ROBOT_VISUAL_LINKS) / sizeof(ROBOT_VISUAL_LINKS[0]);

    // Construct Bk vector from individual B matrices
    // Check if Bk exists in state, otherwise construct from B_1, B_2, B_3
    std::vector<Eigen::MatrixXd> Bk_vec;
    // B_k exists in state
    Bk_vec = state.B_k;

    // Log transforms to CSV when logging is enabled
    log_transforms(t, Bk_vec);

    // Get T_offset from state (similar to B_k pattern)
    std::vector<Eigen::MatrixXd> T_offset_vec;
    // No T_offset provided by the solution: default to identity offsets so T_geom == B_k.
    // This keeps visualisation working for formulations that only provide body frames.
    T_offset_vec.reserve(linkCount);
    for (std::size_t i = 0; i < linkCount; ++i) {
        T_offset_vec.push_back(Eigen::MatrixXd::Identity(4, 4));
    }

    // Optional world transform for mobile robots (e.g., arena navigation).
    // If WORLD_HAS_ROBOT_POSE is not defined, this remains identity.
    Eigen::Matrix4d world_transform = Eigen::Matrix4d::Identity();
    #ifdef WORLD_HAS_ROBOT_POSE
    double world_x = 0.0;
    double world_y = 0.0;
    double world_yaw = 0.0;
    world_get_robot_pose(&world_x, &world_y, &world_yaw);
    const double c = std::cos(world_yaw);
    const double s = std::sin(world_yaw);
    world_transform(0, 0) = c;
    world_transform(0, 1) = -s;
    world_transform(1, 0) = s;
    world_transform(1, 1) = c;
    world_transform(0, 3) = world_x;
    world_transform(1, 3) = world_y;
    #endif

    // Compute T_geom dynamically: T_geom_k = B_k * T_offset_k
    // This is the body-center frame for visualization (formulation-agnostic)
    // Note: We use Bk_vec elements (not B_i) because ForwardKinematics updates B_k[i] not B_i
    std::vector<Eigen::MatrixXd> T_geom_vec;
    T_geom_vec.reserve(Bk_vec.size());
    for (std::size_t i = 0; i < Bk_vec.size() && i < T_offset_vec.size(); ++i) {
        T_geom_vec.push_back(Bk_vec[i] * T_offset_vec[i]);
    }

    std::size_t limit = T_geom_vec.size();
    if (limit > linkCount) {
        limit = linkCount;
    }

    for (std::size_t idx = 0; idx < limit; ++idx) {
        const Eigen::MatrixXd& frame = T_geom_vec[idx];
        if (frame.rows() == 4 && frame.cols() == 4) {
            Eigen::Matrix4d transform = frame;

            // T_geom is already at body center, only apply shape-specific rotations
            const VisualLinkSpec& linkSpec = ROBOT_VISUAL_LINKS[idx];
            const int shape = linkSpec.shape;

            if (shape == 1) {
                // Cylinder: rotate 90° about X to align Y-axis cylinder with Z-axis
                Eigen::Matrix4d rotation = Eigen::Matrix4d::Identity();
                rotation(1, 1) = std::cos(M_PI / 2.0);
                rotation(1, 2) = -std::sin(M_PI / 2.0);
                rotation(2, 1) = std::sin(M_PI / 2.0);
                rotation(2, 2) = std::cos(M_PI / 2.0);
                transform = transform * rotation;
            }
            // Box and Sphere: no rotation needed

            transform = world_transform * transform;

            viz_client->sendTransform(ROBOT_VISUAL_LINKS[idx].name, transform, false);
        }
    }
}

void initVisualization() {
    visualization_enabled = true;
    if (viz_client) {
        return;  // Early return if already initialized
    }

    viz_client = std::make_unique<VisualizationClient>();

    if (viz_client->connect("127.0.0.1", 9999)) {
        std::cout << "[Robot] Connected to visualization server" << std::endl;

        // Create visualization objects from Geom structs (matching manual implementation pattern)
        const int grey[3] = {128, 128, 128};

        auto shape_from = [](const Geom& g) -> int {
            const char c = g.geomType[0];
            return (c == 'b' ? 0 : (c == 'c' ? 1 : (c == 's' ? 2 : 0)));
        };


        const Geom geoms[] = { L1_geom, L2_geom, L3_geom };
        const int count = static_cast<int>(std::min<std::size_t>(state.B_k.size(), 3));

        for (int k = 0; k < count; ++k) {
            const Geom& g = geoms[k];
            const char* name = ROBOT_VISUAL_LINKS[k].name;
            const bool hasMesh = g.meshUri != nullptr && g.meshUri[0] != '\0';
            if (hasMesh) {
                const double scale = (g.meshScaleCount > 0 ? g.meshScale[0] : 1.0);
                viz_client->createMesh(name, g.meshUri, scale, grey);
            } else {
                const int shape = shape_from(g);
                double dims[3] = {0.0, 0.0, 0.0};
                const int m = std::min(g.valCount, 3);
                for (int i = 0; i < m; ++i) dims[i] = g.geomVal[i];
                viz_client->createObject(name, shape, dims, grey);
            }
        }

        updateRobotVisualization();
    } else {
        std::cerr << "[Robot] Failed to connect to visualization server" << std::endl;
        viz_client.reset();
        visualization_enabled = false;
    }
}

#pragma endregion visualization

// ═══════════════════════════════════════════════════════════════════════════
// API (FULL_SIMULATION_VISUALISATION Mode)
// ═══════════════════════════════════════════════════════════════════════════
#pragma region api

// FULL_SIMULATION MODE: Full API with Platform and PlatformEngineImpl classes
class Platform1 : public Platform {
public:
    Platform1() : Platform("Platform1", 0) {}

    IEntityState& getState() override { return ::state; }
    const IEntityState& getState() const override { return ::state; }
};

class PlatformEngineImpl : public IPlatformEngine {
    Platform1 platform_entity;

public:
    PlatformEngineImpl() {}

    void initialise() override {
        initGlobals();
        world_initialize();
        initVisualization();
        std::cout << "Starting simulation with visualization" << std::endl;
        std::cout << "Open the visualization server link (check server console) to view the robot." << std::endl;
    }

    void update() override {
        physics_update();
        platform_entity.advanceTime(dt);
    }

    double getTime() const override { return t; }

    Platform& getPlatform() override { return platform_entity; }
    const Platform& getPlatform() const override { return platform_entity; }
};

static PlatformEngineImpl platform_engine_instance;
IPlatformEngine* get_platform_engine() { return &platform_engine_instance; }

#pragma endregion api

#pragma region logging

// All logging functions removed - now centralized in utils.cpp to avoid code duplication
// Use the following functions from utils.h:
//   - enable_torque_logging() / disable_torque_logging()
//   - enable_high_freq_logging() / disable_high_freq_logging()
//   - enable_velocity_logging() / disable_velocity_logging()
//   - enable_transform_logging() / disable_transform_logging()
//   - enable_mapping_debug_logging() / disable_mapping_debug_logging()

#pragma endregion logging

// Note: STANDALONE mode now generates a separate orchestrator.cpp with main()
// The physics engine file no longer contains a main() function
