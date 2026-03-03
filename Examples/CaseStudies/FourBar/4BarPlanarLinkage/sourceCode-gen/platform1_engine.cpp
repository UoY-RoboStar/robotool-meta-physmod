// Platform1 Physics Engine - Generated from Solution DSL
// Generation Mode: STANDALONE_VISUALISATION
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
#include <cstdlib>
#include "platform1_state.hpp"

// STANDALONE_VISUALISATION MODE: Minimal orchestrator with visualisation
// No mapping or interfaces needed - standalone physics with viz only
#include "world_mapping.h"
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
static Eigen::MatrixXd& B_4 = state.B_4;
static Eigen::MatrixXd& X_J_1 = state.X_J_1;
static Eigen::MatrixXd& X_J_2 = state.X_J_2;
static Eigen::MatrixXd& X_J_3 = state.X_J_3;
static Eigen::MatrixXd& X_T_1 = state.X_T_1;
static Eigen::MatrixXd& X_T_2 = state.X_T_2;
static Eigen::MatrixXd& X_T_3 = state.X_T_3;
static Eigen::MatrixXd& X_T_4 = state.X_T_4;
static Eigen::MatrixXd& phi = state.phi;
static Eigen::VectorXd& C = state.C;
static Eigen::MatrixXd& M_1 = state.M_1;
static Eigen::MatrixXd& M_2 = state.M_2;
static Eigen::MatrixXd& M_3 = state.M_3;
static Eigen::MatrixXd& M_4 = state.M_4;
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
static std::vector<Eigen::MatrixXd>& T_offset = state.T_offset;
static Eigen::MatrixXd& T_geom_1 = state.T_geom_1;
static Eigen::MatrixXd& T_offset_1 = state.T_offset_1;
static Eigen::MatrixXd& T_geom_2 = state.T_geom_2;
static Eigen::MatrixXd& T_offset_2 = state.T_offset_2;
static Eigen::MatrixXd& T_geom_3 = state.T_geom_3;
static Eigen::MatrixXd& T_offset_3 = state.T_offset_3;
static Eigen::MatrixXd& T_geom_4 = state.T_geom_4;
static Eigen::MatrixXd& T_offset_4 = state.T_offset_4;
static std::vector<Eigen::MatrixXd>& X_J_k = state.X_J_k;
static Eigen::MatrixXd& H_1 = state.H_1;
static Eigen::MatrixXd& H_2 = state.H_2;
static Eigen::MatrixXd& H_3 = state.H_3;
static Eigen::MatrixXd& M_mass = state.M_mass;
static Eigen::MatrixXd& M_inv = state.M_inv;
static Eigen::VectorXd& tau_d = state.tau_d;
static Eigen::MatrixXd& damping = state.damping;
static double& dt = state.dt;
static Eigen::MatrixXd& G_c = state.G_c;
static Eigen::VectorXd& Uprime = state.Uprime;
static Eigen::MatrixXd& Q_c = state.Q_c;
static Eigen::MatrixXd& B_sel = state.B_sel;
static Eigen::VectorXd& tau = state.tau;
static Eigen::VectorXd& lambda_c = state.lambda_c;
static Eigen::VectorXd& g_pos = state.g_pos;

// Additional state variables
static double t = 0.0;
static Eigen::Vector3d g;  // Gravity vector in world coordinates (synchronized from w_mapping)
// Note: dt is already available from state.dt

// Geom struct declarations for visualization
// Geometry datatypes
struct Geom { const char* geomType; int valCount; double geomVal[3]; };
static const Geom L1_geom = { "box", 3, {4.0, 0.1, 0.2} };  // gripper
static const Geom L2_geom = { "box", 3, {4.0, 0.1, 0.2} };  // intermediate
static const Geom L3_geom = { "box", 3, {4.0, 0.1, 0.2} };  // intermediate
static const Geom L4_geom = { "box", 3, {2.0, 0.1, 0.2} };  // base

// Visualization runtime state (metadata extracted from Geom records in Solution DSL)
struct VisualLinkSpec {
    const char* name;
    int shape;       // 0=box, 1=cylinder, 2=sphere, 3=mesh
    double dims[3];  // Shape dimensions (interpretation depends on shape)
};

static bool visualization_enabled = true;
static std::unique_ptr<VisualizationClient> viz_client = nullptr;
static const VisualLinkSpec ROBOT_VISUAL_LINKS[] = {
    {"robot/link_1", 0, {4.0, 0.1, 0.2}},
    {"robot/link_2", 0, {4.0, 0.1, 0.2}},
    {"robot/link_3", 0, {4.0, 0.1, 0.2}},
    {"robot/link_4", 0, {2.0, 0.1, 0.2}}
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
static bool closed_chain_diag_enabled = false;
static bool closed_chain_diag_ran = false;

// STANDALONE_VISUALISATION MODE: World mapping for gravity synchronization
world_mapping_t w_mapping = {
    .g = {0.0, 0.0, -9.81}  // Default gravity in world coordinates
};

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

void initClosedChainDiagnostics();
void runClosedChainDiagnostics();
void initVisualization();
void updateRobotVisualization();

// ═══════════════════════════════════════════════════════════════════════════
// PROCEDURES (SolutionDSL: procedures { ... })
// ═══════════════════════════════════════════════════════════════════════════
#pragma region procedures

void T_from_X(Eigen::MatrixXd X, Eigen::MatrixXd &result) {
    Eigen::MatrixXd R = Eigen::MatrixXd::Zero(3, 3);
        Eigen::MatrixXd BL = Eigen::MatrixXd::Zero(3, 3);
        Eigen::MatrixXd S = Eigen::MatrixXd::Zero(3, 3);
        Eigen::VectorXd p = Eigen::VectorXd::Zero(3);
        for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
            R(i,j) = X(i,j);
        }
    }
        for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
            BL(i,j) = X((i + 3),j);
        }
    }
        for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
            S(i,j) = 0;
            for (int k = 0; k < 3; k++) {
                S(i,j) = (S(i,j) - (BL(i,k) * R(j,k)));
            }
        }
    }
        p(0) = S(2,1);
        p(1) = S(0,2);
        p(2) = S(1,0);
        for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
            result(i,j) = R(i,j);
        }
    }
        for (int i = 0; i < 3; i++) {
        result(i,3) = p(i);
    }
        result(3,0) = 0;
        result(3,1) = 0;
        result(3,2) = 0;
        result(3,3) = 1;
}


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
        n = 4;
        theta.resize(3);
        theta << -1.8234765819369751, -1.8234765819369751, 1.8234765819369751;
        B_1.resize(4, 4);
        B_1 << 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1;
        B_2.resize(4, 4);
        B_2 << 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1;
        B_3.resize(4, 4);
        B_3 << 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1;
        B_4.resize(4, 4);
        B_4 << 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1;
        X_J_1.resize(6, 6);
        X_J_1 << 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0;
        X_J_2.resize(6, 6);
        X_J_2 << 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0;
        X_J_3.resize(6, 6);
        X_J_3 << 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0;
        X_T_1.resize(6, 6);
        X_T_1 << 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 4, 0, 1, 0, 0, -4, 0, 0, 0, 1;
        X_T_2.resize(6, 6);
        X_T_2 << 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 4, 0, 1, 0, 0, -4, 0, 0, 0, 1;
        X_T_3.resize(6, 6);
        X_T_3 << 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1;
        X_T_4.resize(6, 6);
        X_T_4 << 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1;
        phi = Eigen::MatrixXd::Zero(24, 24);
        C = Eigen::VectorXd::Zero(3);
        M_1 = Eigen::MatrixXd::Zero(6, 6);
        M_2 = Eigen::MatrixXd::Zero(6, 6);
        M_3 = Eigen::MatrixXd::Zero(6, 6);
        M_4 = Eigen::MatrixXd::Zero(6, 6);
        H.resize(3, 24);
        H << 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
        d_theta.resize(3);
        d_theta << 1.5, -1.5, 3.0;
        dd_theta = Eigen::VectorXd::Zero(3);
        alpha = Eigen::VectorXd::Zero(24);
        V = Eigen::VectorXd::Zero(24);
        a = Eigen::VectorXd::Zero(24);
        b = Eigen::VectorXd::Zero(24);
        f = Eigen::VectorXd::Zero(24);
        M = Eigen::MatrixXd::Zero(24, 24);
        N = 3;
        T_geom_1 = Eigen::MatrixXd::Zero(4, 4);
        T_offset_1.resize(4, 4);
        T_offset_1 << 1, 0, 0, 2, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1;
        T_geom_2 = Eigen::MatrixXd::Zero(4, 4);
        T_offset_2.resize(4, 4);
        T_offset_2 << 1, 0, 0, 2, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1;
        T_geom_3 = Eigen::MatrixXd::Zero(4, 4);
        T_offset_3.resize(4, 4);
        T_offset_3 << 1, 0, 0, 2, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1;
        T_geom_4 = Eigen::MatrixXd::Zero(4, 4);
        T_offset_4.resize(4, 4);
        T_offset_4 << 1, 0, 0, -1, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1;
        H_1.resize(1, 6);
        H_1 << 0, 1, 0, 0, 0, 0;
        H_2.resize(1, 6);
        H_2 << 0, 1, 0, 0, 0, 0;
        H_3.resize(1, 6);
        H_3 << 0, 1, 0, 0, 0, 0;
        M_mass = Eigen::MatrixXd::Zero(3, 3);
        M_inv = Eigen::MatrixXd::Zero(3, 3);
        tau_d = Eigen::VectorXd::Zero(3);
        damping = Eigen::MatrixXd::Zero(3, 3);
        dt = 0.01;
        G_c = Eigen::MatrixXd::Zero(6, 3);
        Uprime = Eigen::VectorXd::Zero(6);
        Q_c.resize(6, 12);
        Q_c << 1, 0, 0, 0, 0, 0, -1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, -1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, -1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, -1, 0, 0, 0, 0, 4, 0, 1, 0, 0, 0, 0, 0, -1, 0, 0, -4, 0, 0, 0, 1, 0, 0, 0, 0, 0, -1;
        B_sel.resize(12, 24);
        B_sel << 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1;
        tau = Eigen::VectorXd::Zero(3);
        g_pos = Eigen::VectorXd::Zero(3);
        B_k = std::vector<typename std::remove_reference<decltype(B_1)>::type>({ B_1, B_2, B_3, B_4 });
        X_J = std::vector<typename std::remove_reference<decltype(X_J_1)>::type>({ X_J_1, X_J_2, X_J_3 });
        X_T = std::vector<typename std::remove_reference<decltype(X_T_1)>::type>({ X_T_1, X_T_2, X_T_3, X_T_4 });
        T_offset = std::vector<typename std::remove_reference<decltype(T_offset_1)>::type>({ T_offset_1, T_offset_2, T_offset_3, T_offset_4 });
        X_J_k = std::vector<typename std::remove_reference<decltype(X_J_1)>::type>({ X_J_1, X_J_2, X_J_3 });
    initClosedChainDiagnostics();

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
        X_J[0] << std::cos(theta(0)), 0, std::sin(theta(0)), 0, 0, 0, 0, 1, 0, 0, 0, 0, -std::sin(theta(0)), 0, std::cos(theta(0)), 0, 0, 0, 0, 0, 0, std::cos(theta(0)), 0, std::sin(theta(0)), 0, 0, 0, 0, 1, 0, 0, 0, 0, -std::sin(theta(0)), 0, std::cos(theta(0));
        X_J[1] << std::cos(theta(1)), 0, std::sin(theta(1)), 0, 0, 0, 0, 1, 0, 0, 0, 0, -std::sin(theta(1)), 0, std::cos(theta(1)), 0, 0, 0, 0, 0, 0, std::cos(theta(1)), 0, std::sin(theta(1)), 0, 0, 0, 0, 1, 0, 0, 0, 0, -std::sin(theta(1)), 0, std::cos(theta(1));
        X_J[2] << std::cos(theta(2)), 0, std::sin(theta(2)), 0, 0, 0, 0, 1, 0, 0, 0, 0, -std::sin(theta(2)), 0, std::cos(theta(2)), 0, 0, 0, 0, 0, 0, std::cos(theta(2)), 0, std::sin(theta(2)), 0, 0, 0, 0, 1, 0, 0, 0, 0, -std::sin(theta(2)), 0, std::cos(theta(2));
        Eigen::MatrixXd T_XT = Eigen::MatrixXd::Zero(4, 4);
        Eigen::MatrixXd T_XJ = Eigen::MatrixXd::Zero(4, 4);
        for (int k = (n - 2); k > -1; k += -1) {
            T_from_X(X_T[k], T_XT);
            T_from_X(X_J[k], T_XJ);
            B_k[k] = ((B_k[(k + 1)] * T_XT) * T_XJ);
        }
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
        Eigen::MatrixXd temp_3_0 = Eigen::MatrixXd::Zero(6, 6);
        {
            CalcPhi_proc(4, 1, B_k, temp_3_0);
        }
        SKOm_set(phi, 3, 0, temp_3_0);
        Eigen::MatrixXd temp_3_1 = Eigen::MatrixXd::Zero(6, 6);
        {
            CalcPhi_proc(4, 2, B_k, temp_3_1);
        }
        SKOm_set(phi, 3, 1, temp_3_1);
        Eigen::MatrixXd temp_3_2 = Eigen::MatrixXd::Zero(6, 6);
        {
            CalcPhi_proc(4, 3, B_k, temp_3_2);
        }
        SKOm_set(phi, 3, 2, temp_3_2);
        SKOm_set(phi, 3, 3, Eigen::MatrixXd::Identity(6, 6));
    }
        {
        Eigen::VectorXd a_grav = Eigen::VectorXd::Zero(6);
        a_grav<<0.0, 0.0, 0.0, 0.0, 0.0, 9.81;
        Eigen::VectorXd d_theta_loc; // TODO: Dimension not provided for vector d_theta_loc
        d_theta_loc=Eigen::VectorXd::Zero(n);
        for (int i = 0; i < (n - 1); i++) {
            d_theta_loc(i) = d_theta(i);
        }
        d_theta_loc((n - 1)) = 0.0;
        for (int k = (n - 2); k > -1; k += -1) {
            Eigen::VectorXd vJ; // TODO: Dimension not provided for vector vJ
        vJ=(H.block(k, (6 * k), 1, 6).transpose() * d_theta_loc.segment(k, 1));
            if (k == (n - 2)) {
                Eigen::MatrixXd X_m = CalcPhi(n, (k + 1), B_k).transpose();
                SKOv_set(V, k, vJ);
                SKOv_set(a, k, (SKO_cross(SKOv(V, k)) * vJ));
                SKOv_set(alpha, k, ((X_m * a_grav) + SKOv(a, k)));
            } else {
                Eigen::MatrixXd X_m = CalcPhi((k + 2), (k + 1), B_k).transpose();
                SKOv_set(V, k, ((X_m * SKOv(V, (k + 1))) + vJ));
                SKOv_set(a, k, (SKO_cross(SKOv(V, k)) * vJ));
                SKOv_set(alpha, k, ((X_m * SKOv(alpha, (k + 1))) + SKOv(a, k)));
            }
        }
        for (int k = 0; k < (n - 1); k++) {
            SKOv_set(b, k, ((SKOm(M, k, k) * SKOv(alpha, k)) + ((SKO_cross_force(SKOv(V, k)) * SKOm(M, k, k)) * SKOv(V, k))));
            if (k == 0) {
                SKOv_set(f, k, SKOv(b, k));
            } else {
                Eigen::MatrixXd Xf = CalcPhi((k + 1), k, B_k);
                SKOv_set(f, k, ((Xf * SKOv(f, (k - 1))) + SKOv(b, k)));
            }
        }
        for (int k = 0; k < (n - 1); k++) {
            C(k) = (H.block(k, (6 * k), 1, 6) * SKOv(f, k))(0, 0);
        }
    }
        {
        T_geom_1 = (B_1 * T_offset_1);
        T_geom_2 = (B_2 * T_offset_2);
        T_geom_3 = (B_3 * T_offset_3);
        T_geom_4 = (B_4 * T_offset_4);
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
        tau_d = (damping * d_theta);
    }
        {
        G_c = (((Q_c * B_sel) * phi.transpose()) * H.transpose());
        Uprime = (((-Q_c * B_sel) * phi.transpose()) * a);
    }
        {
        Eigen::VectorXd dd_theta_0; // TODO: Dimension not provided for vector dd_theta_0
        dd_theta_0=(M_inv * ((tau - C) - tau_d));
        Eigen::MatrixXd S = ((G_c * M_inv) * G_c.transpose());
        Eigen::MatrixXd S_inv = S.ldlt().solve(Eigen::MatrixXd::Identity(S.rows(),S.cols()));
        Eigen::VectorXd rhs; // TODO: Dimension not provided for vector rhs
        rhs=(Uprime - (G_c * dd_theta_0));
        lambda_c = (S_inv * rhs);
        dd_theta = (dd_theta_0 + ((M_inv * G_c.transpose()) * lambda_c));
    }
        {
        d_theta = (d_theta + (dt * dd_theta));
    }
        {
        theta = (theta + (dt * d_theta));
    }
        {
    
    }
        {
        // Recompute forward kinematics for projection using updated theta
        X_J[0] << std::cos(theta(0)), 0, std::sin(theta(0)), 0, 0, 0, 0, 1, 0, 0, 0, 0, -std::sin(theta(0)), 0, std::cos(theta(0)), 0, 0, 0, 0, 0, 0, std::cos(theta(0)), 0, std::sin(theta(0)), 0, 0, 0, 0, 1, 0, 0, 0, 0, -std::sin(theta(0)), 0, std::cos(theta(0));
        X_J[1] << std::cos(theta(1)), 0, std::sin(theta(1)), 0, 0, 0, 0, 1, 0, 0, 0, 0, -std::sin(theta(1)), 0, std::cos(theta(1)), 0, 0, 0, 0, 0, 0, std::cos(theta(1)), 0, std::sin(theta(1)), 0, 0, 0, 0, 1, 0, 0, 0, 0, -std::sin(theta(1)), 0, std::cos(theta(1));
        X_J[2] << std::cos(theta(2)), 0, std::sin(theta(2)), 0, 0, 0, 0, 1, 0, 0, 0, 0, -std::sin(theta(2)), 0, std::cos(theta(2)), 0, 0, 0, 0, 0, 0, std::cos(theta(2)), 0, std::sin(theta(2)), 0, 0, 0, 0, 1, 0, 0, 0, 0, -std::sin(theta(2)), 0, std::cos(theta(2));
        Eigen::MatrixXd T_XT_proj = Eigen::MatrixXd::Zero(4, 4);
        Eigen::MatrixXd T_XJ_proj = Eigen::MatrixXd::Zero(4, 4);
        Eigen::MatrixXd R_XT_proj = Eigen::MatrixXd::Zero(3, 3);
        Eigen::MatrixXd BL_XT_proj = Eigen::MatrixXd::Zero(3, 3);
        Eigen::MatrixXd S_XT_proj = Eigen::MatrixXd::Zero(3, 3);
        Eigen::VectorXd p_XT_proj = Eigen::VectorXd::Zero(3);
        Eigen::MatrixXd R_XJ_proj = Eigen::MatrixXd::Zero(3, 3);
        Eigen::MatrixXd BL_XJ_proj = Eigen::MatrixXd::Zero(3, 3);
        Eigen::MatrixXd S_XJ_proj = Eigen::MatrixXd::Zero(3, 3);
        Eigen::VectorXd p_XJ_proj = Eigen::VectorXd::Zero(3);
        for (int k = (n - 2); k >= 0; k += -1) {
            for (int i = 0; i < 3; i++) {
                for (int j = 0; j < 3; j++) {
                    R_XT_proj(i,j) = X_T[k](i,j);
                    BL_XT_proj(i,j) = X_T[k]((i + 3),j);
                }
            }
            for (int i = 0; i < 3; i++) {
                for (int j = 0; j < 3; j++) {
                    S_XT_proj(i,j) = 0;
                    for (int m = 0; m < 3; m++) {
                        S_XT_proj(i,j) = (S_XT_proj(i,j) + (BL_XT_proj(i,m) * R_XT_proj(j,m)));
                    }
                }
            }
            p_XT_proj(0) = S_XT_proj(2,1);
            p_XT_proj(1) = S_XT_proj(0,2);
            p_XT_proj(2) = S_XT_proj(1,0);
            for (int i = 0; i < 3; i++) {
                for (int j = 0; j < 3; j++) {
                    T_XT_proj(i,j) = R_XT_proj(i,j);
                }
            }
            for (int i = 0; i < 3; i++) {
                T_XT_proj(i,3) = p_XT_proj(i);
            }
            T_XT_proj(3,0) = 0;
            T_XT_proj(3,1) = 0;
            T_XT_proj(3,2) = 0;
            T_XT_proj(3,3) = 1;

            for (int i = 0; i < 3; i++) {
                for (int j = 0; j < 3; j++) {
                    R_XJ_proj(i,j) = X_J[k](i,j);
                    BL_XJ_proj(i,j) = X_J[k]((i + 3),j);
                }
            }
            for (int i = 0; i < 3; i++) {
                for (int j = 0; j < 3; j++) {
                    S_XJ_proj(i,j) = 0;
                    for (int m = 0; m < 3; m++) {
                        S_XJ_proj(i,j) = (S_XJ_proj(i,j) + (BL_XJ_proj(i,m) * R_XJ_proj(j,m)));
                    }
                }
            }
            p_XJ_proj(0) = S_XJ_proj(2,1);
            p_XJ_proj(1) = S_XJ_proj(0,2);
            p_XJ_proj(2) = S_XJ_proj(1,0);
            for (int i = 0; i < 3; i++) {
                for (int j = 0; j < 3; j++) {
                    T_XJ_proj(i,j) = R_XJ_proj(i,j);
                }
            }
            for (int i = 0; i < 3; i++) {
                T_XJ_proj(i,3) = p_XJ_proj(i);
            }
            T_XJ_proj(3,0) = 0;
            T_XJ_proj(3,1) = 0;
            T_XJ_proj(3,2) = 0;
            T_XJ_proj(3,3) = 1;

            B_k[k] = ((B_k[(k + 1)] * T_XT_proj) * T_XJ_proj);
        }
        // Recompute phi and G_c for updated configuration
        SKOm_set(phi, 0, 0, Eigen::MatrixXd::Identity(6, 6));
        Eigen::MatrixXd proj_1_0 = Eigen::MatrixXd::Zero(6, 6);
        { CalcPhi_proc(2, 1, B_k, proj_1_0); }
        SKOm_set(phi, 1, 0, proj_1_0);
        SKOm_set(phi, 1, 1, Eigen::MatrixXd::Identity(6, 6));
        Eigen::MatrixXd proj_2_0 = Eigen::MatrixXd::Zero(6, 6);
        { CalcPhi_proc(3, 1, B_k, proj_2_0); }
        SKOm_set(phi, 2, 0, proj_2_0);
        Eigen::MatrixXd proj_2_1 = Eigen::MatrixXd::Zero(6, 6);
        { CalcPhi_proc(3, 2, B_k, proj_2_1); }
        SKOm_set(phi, 2, 1, proj_2_1);
        SKOm_set(phi, 2, 2, Eigen::MatrixXd::Identity(6, 6));
        Eigen::MatrixXd proj_3_0 = Eigen::MatrixXd::Zero(6, 6);
        { CalcPhi_proc(4, 1, B_k, proj_3_0); }
        SKOm_set(phi, 3, 0, proj_3_0);
        Eigen::MatrixXd proj_3_1 = Eigen::MatrixXd::Zero(6, 6);
        { CalcPhi_proc(4, 2, B_k, proj_3_1); }
        SKOm_set(phi, 3, 1, proj_3_1);
        Eigen::MatrixXd proj_3_2 = Eigen::MatrixXd::Zero(6, 6);
        { CalcPhi_proc(4, 3, B_k, proj_3_2); }
        SKOm_set(phi, 3, 2, proj_3_2);
        SKOm_set(phi, 3, 3, Eigen::MatrixXd::Identity(6, 6));
        G_c = (((Q_c * B_sel) * phi.transpose()) * H.transpose());
        g_pos = (B_k[0].block(0, 3, 3, 1) + (B_k[0].block(0, 0, 3, 3) * Eigen::Vector3d(4.0, 0.0, 0.0)) - B_k[3].block(0, 3, 3, 1));
        Eigen::MatrixXd G_pos = Eigen::MatrixXd::Zero(3, 3);
        for (int loop = 0; loop < 1; loop++) {
            for (int row = 0; row < 3; row++) {
                for (int col = 0; col < 3; col++) {
                    G_pos(((3 * loop) + row),col) = G_c((((6 * loop) + 3) + row),col);
                }
            }
        }
        Eigen::MatrixXd S = (G_pos * G_pos.transpose());
        Eigen::MatrixXd S_inv = S.ldlt().solve(Eigen::MatrixXd::Identity(S.rows(),S.cols()));
        Eigen::VectorXd delta; // TODO: Dimension not provided for vector delta
        delta=(-S_inv * g_pos);
        theta = (theta + (G_pos.transpose() * delta));
        Eigen::VectorXd vres; // TODO: Dimension not provided for vector vres
        vres=(G_pos * d_theta);
        Eigen::VectorXd vcorr; // TODO: Dimension not provided for vector vcorr
        vcorr=(S_inv * vres);
        d_theta = (d_theta - (G_pos.transpose() * vcorr));
        Eigen::MatrixXd T_up = Eigen::MatrixXd::Zero(4, 4);
        Eigen::MatrixXd R_up = Eigen::MatrixXd::Zero(3, 3);
        Eigen::MatrixXd BL_up = Eigen::MatrixXd::Zero(3, 3);
        Eigen::MatrixXd S_up = Eigen::MatrixXd::Zero(3, 3);
        Eigen::VectorXd p_up = Eigen::VectorXd::Zero(3);
        Eigen::MatrixXd X_T_k = Eigen::MatrixXd::Zero(6, 6);
        Eigen::MatrixXd X_J_local = Eigen::MatrixXd::Zero(6, 6);
        Eigen::MatrixXd X_up = Eigen::MatrixXd::Zero(6, 6);
        for (int k = (n - 2); k > -1; k += -1) {
            X_T_k = X_T[k];
            X_J_local = X_J[k];
            X_up = (X_T_k * X_J_local);
            for (int i = 0; i < 3; i++) {
                for (int j = 0; j < 3; j++) {
                    R_up(i,j) = X_up(i,j);
                    BL_up(i,j) = X_up((i + 3),j);
                }
            }
            for (int i = 0; i < 3; i++) {
                for (int j = 0; j < 3; j++) {
                    S_up(i,j) = 0;
                    for (int m = 0; m < 3; m++) {
                        S_up(i,j) = (S_up(i,j) - (BL_up(i,m) * R_up(j,m)));
                    }
                }
            }
            p_up(0) = S_up(2,1);
            p_up(1) = S_up(0,2);
            p_up(2) = S_up(1,0);
            for (int i = 0; i < 3; i++) {
                for (int j = 0; j < 3; j++) {
                    T_up(i,j) = R_up(i,j);
                }
            }
            for (int i = 0; i < 3; i++) {
                T_up(i,3) = p_up(i);
            }
            T_up(3,0) = 0;
            T_up(3,1) = 0;
            T_up(3,2) = 0;
            T_up(3,3) = 1;
            B_k[k] = (B_k[(k + 1)] * T_up);
        }
        B_1 = B_k[0];
        B_2 = B_k[1];
        B_3 = B_k[2];
        B_4 = B_k[3];
    }
        
        // Update time for next iteration
        t += dt;
    if (visualization_enabled) {
        updateRobotVisualization();
    }
}

#pragma endregion computation

// ═══════════════════════════════════════════════════════════════════════════
// CLOSED-CHAIN DIAGNOSTICS
// ═══════════════════════════════════════════════════════════════════════════
#pragma region diagnostics

void initClosedChainDiagnostics() {
    const char* env = std::getenv("PHYSICS_CLOSED_CHAIN_DIAGNOSTICS");
    closed_chain_diag_enabled = (env != nullptr && std::strcmp(env, "1") == 0);
}

void runClosedChainDiagnostics() {
    if (!closed_chain_diag_enabled || closed_chain_diag_ran) {
        return;
    }
    closed_chain_diag_ran = true;

    const double eps = 1e-6;
    const auto state_backup = state;
    const double dt_backup = dt;
    const double t_backup = t;
    const bool viz_backup = visualization_enabled;
    visualization_enabled = false;
    dt = 0.0;

    // First pass: compute g_pos at initial theta and apply projection
    physics_update();
    const Eigen::VectorXd g_pre = g_pos;
    const auto projected_state = state;

    // Second pass: recompute g_pos for projected theta
    state = projected_state;
    dt = 0.0;
    physics_update();
    const Eigen::VectorXd g_post = g_pos;

    if (G_c.rows() % 6 != 0) {
        std::cout << "[Diagnostics] Skipping G_pos extraction: G_c rows not divisible by 6 (rows="
                  << G_c.rows() << ")" << std::endl;
        state = state_backup;
        dt = dt_backup;
        t = t_backup;
        visualization_enabled = viz_backup;
        return;
    }

    const int n_loop = static_cast<int>(G_c.rows() / 6);
    const int pos_dim = 3 * n_loop;
    Eigen::MatrixXd G_pos = Eigen::MatrixXd::Zero(pos_dim, G_c.cols());
    for (int loop = 0; loop < n_loop; ++loop) {
        for (int row = 0; row < 3; ++row) {
            for (int col = 0; col < G_c.cols(); ++col) {
                G_pos((3 * loop + row), col) = G_c((6 * loop + 3 + row), col);
            }
        }
    }

    if (g_post.size() == pos_dim) {
        const double g_pre_norm = g_pre.norm();
        const double g_pre_max = g_pre.cwiseAbs().maxCoeff();
        const double g_post_norm = g_post.norm();
        const double g_post_max = g_post.cwiseAbs().maxCoeff();
        std::cout << "[Diagnostics] g_pos pre-projection: norm=" << g_pre_norm
                  << ", max_abs=" << g_pre_max << std::endl;
        std::cout << "[Diagnostics] g_pos post-projection: norm=" << g_post_norm
                  << ", max_abs=" << g_post_max << std::endl;
    } else {
        std::cout << "[Diagnostics] g_pos size mismatch: expected " << pos_dim
                  << ", got " << g_post.size() << std::endl;
    }

    const char* dump_env = std::getenv("PHYSICS_CLOSED_CHAIN_DIAGNOSTICS_DUMP");
    const bool dump_enabled = (dump_env != nullptr && std::strcmp(dump_env, "1") == 0);
    if (dump_enabled) {
        auto dump_vec = [](const Eigen::VectorXd& v, const char* name) {
            std::cout << "[Diagnostics] " << name << " (" << v.size() << "):";
            for (int i = 0; i < v.size(); ++i) {
                std::cout << (i == 0 ? " " : ", ") << v(i);
            }
            std::cout << std::endl;
        };
        auto dump_mat = [](const Eigen::MatrixXd& m, const char* name, int max_rows, int max_cols) {
            const int rows = (m.rows() < max_rows) ? m.rows() : max_rows;
            const int cols = (m.cols() < max_cols) ? m.cols() : max_cols;
            std::cout << "[Diagnostics] " << name << " (" << m.rows() << "x" << m.cols() << "):" << std::endl;
            for (int r = 0; r < rows; ++r) {
                std::cout << "  ";
                for (int c = 0; c < cols; ++c) {
                    std::cout << m(r, c);
                    if (c + 1 < cols) std::cout << ", ";
                }
                if (cols < m.cols()) std::cout << ", ...";
                std::cout << std::endl;
            }
            if (rows < m.rows()) {
                std::cout << "  ..." << std::endl;
            }
        };
        dump_vec(g_pre, "g_pos_pre");
        dump_vec(g_post, "g_pos_post");
        dump_mat(G_c, "G_c", 12, 12);
        dump_mat(G_pos, "G_pos", 12, 12);
    }

    // Numeric Jacobian check around projected theta
    const auto base_state = state;
    Eigen::MatrixXd J_num = Eigen::MatrixXd::Zero(pos_dim, theta.size());
    for (int i = 0; i < theta.size(); ++i) {
        state = base_state;
        dt = 0.0;
        visualization_enabled = false;
        theta(i) += eps;
        physics_update();
        const Eigen::VectorXd g_plus = g_pos;

        state = base_state;
        dt = 0.0;
        visualization_enabled = false;
        theta(i) -= eps;
        physics_update();
        const Eigen::VectorXd g_minus = g_pos;

        if (g_plus.size() == pos_dim && g_minus.size() == pos_dim) {
            J_num.col(i) = (g_plus - g_minus) / (2.0 * eps);
        }
    }

    if (J_num.rows() == G_pos.rows() && J_num.cols() == G_pos.cols()) {
        const Eigen::MatrixXd diff = J_num - G_pos;
        const double max_abs = diff.cwiseAbs().maxCoeff();
        const double rmse = std::sqrt(diff.array().square().sum() /
                                      static_cast<double>(diff.rows() * diff.cols()));
        std::cout << "[Diagnostics] G_pos vs finite-diff: rmse=" << rmse
                  << ", max_abs=" << max_abs << std::endl;
    } else {
        std::cout << "[Diagnostics] Jacobian size mismatch: G_pos="
                  << G_pos.rows() << "x" << G_pos.cols()
                  << ", J_num=" << J_num.rows() << "x" << J_num.cols()
                  << std::endl;
    }

    state = state_backup;
    dt = dt_backup;
    t = t_backup;
    visualization_enabled = viz_backup;
}

#pragma endregion diagnostics

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


    // Get T_offset from state (similar to B_k pattern)
    std::vector<Eigen::MatrixXd> T_offset_vec;
    // T_offset exists in state as sequence
    T_offset_vec = state.T_offset;

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


        const Geom geoms[] = { L1_geom, L2_geom, L3_geom, L4_geom };
        const int count = static_cast<int>(std::min<std::size_t>(state.B_k.size(), 4));

        for (int k = 0; k < count; ++k) {
            const Geom& g = geoms[k];
            const int shape = shape_from(g);
            double dims[3] = {0.0, 0.0, 0.0};
            const int m = std::min(g.valCount, 3);
            for (int i = 0; i < m; ++i) dims[i] = g.geomVal[i];
            const char* name = ROBOT_VISUAL_LINKS[k].name;
            viz_client->createObject(name, shape, dims, grey);
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
// API (STANDALONE_VISUALISATION Mode)
// ═══════════════════════════════════════════════════════════════════════════
#pragma region api

// STANDALONE/STANDALONE_VISUALISATION MODE: Simple C API for running physics without orchestrator
extern "C" {
    void platform1_initialise(void) {
        initGlobals();
        initVisualization();
        std::cout << "Platform1 physics engine initialized (STANDALONE)" << std::endl;
    }

    void platform1_step(void) {
        runClosedChainDiagnostics();
        physics_update();
    }

    double platform1_get_time(void) {
        return t;
    }
}

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
