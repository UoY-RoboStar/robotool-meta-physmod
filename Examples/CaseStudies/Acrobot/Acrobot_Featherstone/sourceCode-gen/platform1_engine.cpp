// Platform1 Physics Engine - Generated from Solution DSL
// Generation Mode: FULL_SIMULATION_VISUALISATION
// Structure: Includes → State → Procedures → Functions → Computation → API

/* TODO/STUB */

#pragma region includes
#include <iostream>
#include <Eigen/Dense>
#include <Eigen/Geometry>
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
static int& N = state.N;
static double& gravity = state.gravity;
static Eigen::VectorXd& dd_q = state.dd_q;
static Eigen::VectorXd& q = state.q;
static Eigen::VectorXd& d_q = state.d_q;
static Eigen::VectorXd& tau = state.tau;
static Eigen::MatrixXd& damping = state.damping;
static std::vector<Eigen::MatrixXd>& XT = state.XT;
static std::vector<Eigen::MatrixXd>& I = state.I;
static std::vector<int>& jtype = state.jtype;
static int& n = state.n;
static double& dt = state.dt;
static std::vector<Eigen::MatrixXd>& T_geom = state.T_geom;
static platform1::Geom& geom_01 = state.geom_01;
static platform1::Geom& geom_11 = state.geom_11;
static platform1::Geom& geom_21 = state.geom_21;
static Eigen::MatrixXd& B_1 = state.B_1;
static Eigen::MatrixXd& B_2 = state.B_2;
static Eigen::MatrixXd& B_3 = state.B_3;
static std::vector<Eigen::MatrixXd>& B_k = state.B_k;
static Eigen::MatrixXd& T_geom_1 = state.T_geom_1;
static Eigen::MatrixXd& T_geom_2 = state.T_geom_2;
static Eigen::MatrixXd& T_geom_3 = state.T_geom_3;
static Eigen::MatrixXd& T_offset_1 = state.T_offset_1;
static Eigen::MatrixXd& T_offset_2 = state.T_offset_2;
static Eigen::MatrixXd& T_offset_3 = state.T_offset_3;
static std::vector<Eigen::MatrixXd>& T_offset = state.T_offset;
static double& sensor_outputs = state.sensor_outputs;
static Eigen::VectorXd& theta = state.theta;
static Eigen::VectorXd& d_theta = state.d_theta;

// Additional state variables
static double t = 0.0;
// Note: dt is already available from state.dt

// Geom struct declarations for visualization
// Geometry datatypes
struct Geom { const char* geomType; int valCount; double geomVal[3]; const char* meshUri; int meshScaleCount; double meshScale[3]; };
static const Geom L1_geom = { "", 1, {0.0, 0.0, 0.0}, "", 1, {1.0, 1.0, 1.0} };  // gripper
static const Geom L2_geom = { "", 1, {0.0, 0.0, 0.0}, "", 1, {1.0, 1.0, 1.0} };  // intermediate
static const Geom L3_geom = { "", 1, {0.0, 0.0, 0.0}, "", 1, {1.0, 1.0, 1.0} };  // base

// Visualization runtime state (metadata extracted from Geom records in Solution DSL)
struct VisualLinkSpec {
    const char* name;
    int shape;       // 0=box, 1=cylinder, 2=sphere, 3=mesh
    double dims[3];  // Shape dimensions (interpretation depends on shape)
};

static bool visualization_enabled = true;
static std::unique_ptr<VisualizationClient> viz_client = nullptr;
static const VisualLinkSpec ROBOT_VISUAL_LINKS[] = {
    {"robot/link_1", 0, {0.0, 0.0, 0.0}},
    {"robot/link_2", 0, {0.0, 0.0, 0.0}},
    {"robot/link_3", 0, {0.0, 0.0, 0.0}}
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
Eigen::VectorXd zeroVec(int n);
Eigen::MatrixXd zeroMat(int n, int m);
Eigen::MatrixXd skewSymmetric(Eigen::VectorXd p);
std::vector<Eigen::MatrixXd> zeroMatSeq(int length, int n, int m);
Eigen::MatrixXd identity(int n);
Eigen::MatrixXd transpose(Eigen::MatrixXd m);
std::vector<Eigen::VectorXd> zeroVecSeq(int length, int n);

void initVisualization();
void updateRobotVisualization();

// ═══════════════════════════════════════════════════════════════════════════
// PROCEDURES (SolutionDSL: procedures { ... })
// ═══════════════════════════════════════════════════════════════════════════
#pragma region procedures


#pragma endregion procedures

// ═══════════════════════════════════════════════════════════════════════════
// FUNCTIONS (SolutionDSL: functions { ... })
// ═══════════════════════════════════════════════════════════════════════════
#pragma region functions

Eigen::VectorXd zeroVec(int n) {
	    return Eigen::VectorXd::Zero(n);
	}


Eigen::MatrixXd zeroMat(int n, int m) {
    return Eigen::MatrixXd::Zero(n, m);
}


Eigen::MatrixXd skewSymmetric(Eigen::VectorXd p) {
    Eigen::MatrixXd result = Eigen::MatrixXd::Zero(3, 3);
    result(0,0) = 0;
    result(0,1) = -p(2);
    result(0,2) = p(1);
    result(1,0) = p(2);
    result(1,1) = 0;
    result(1,2) = -p(0);
    result(2,0) = -p(1);
    result(2,1) = p(0);
    result(2,2) = 0;
    return result;
}


std::vector<Eigen::MatrixXd> zeroMatSeq(int length, int n, int m) {
    std::vector<Eigen::MatrixXd> result;
    result.reserve(length);
    for (int i = 0; i < length; ++i) {
        result.push_back(Eigen::MatrixXd::Zero(n, m));
    }
    return result;
}


Eigen::MatrixXd identity(int n) {
    Eigen::MatrixXd result = Eigen::MatrixXd();
    return result;
}


Eigen::MatrixXd transpose(const Eigen::MatrixXd& m) {
    return m.transpose();
}


std::vector<Eigen::VectorXd> zeroVecSeq(int length, int n) {
    std::vector<Eigen::VectorXd> result;
    result.reserve(length);
    for (int i = 0; i < length; ++i) {
        result.push_back(Eigen::VectorXd::Zero(n));
    }
    return result;
}



#pragma endregion functions

// ═══════════════════════════════════════════════════════════════════════════
// INITIALIZATION (SolutionDSL: state { ... } with initial values)
// ═══════════════════════════════════════════════════════════════════════════
#pragma region initialization

void initGlobals() {
        N = 2;
        gravity = 9.81;
        dd_q = Eigen::VectorXd::Zero(2);
        q = Eigen::VectorXd::Zero(2);
        d_q = Eigen::VectorXd::Zero(2);
        tau = Eigen::VectorXd::Zero(2);
        damping = Eigen::MatrixXd::Zero(2, 2);
        XT = std::vector<Eigen::MatrixXd>({ ([](){ Eigen::MatrixXd tmp(6, 6); tmp << 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0; return tmp; }()), ([](){ Eigen::MatrixXd tmp(6, 6); tmp << 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0; return tmp; }()) });
        I = std::vector<Eigen::MatrixXd>({ ([](){ Eigen::MatrixXd tmp(6, 6); tmp << 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0; return tmp; }()), ([](){ Eigen::MatrixXd tmp(6, 6); tmp << 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0; return tmp; }()) });
        n = 3;
        dt = 0.01;
        B_1.resize(4, 4);
        B_1 << 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.15, 0.0, 0.0, 1.0, 0.0, 0, 0, 0, 1;
        B_2.resize(4, 4);
        B_2 << 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0, 0, 0, 1;
        B_3.resize(4, 4);
        B_3 << 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0, 0, 0, 1;
        T_geom_1.resize(4, 4);
        T_geom_1 << 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, -0.4, 0, 0, 0, 1;
        T_geom_2.resize(4, 4);
        T_geom_2 << 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, -2.15, 0, 0, 0, 1;
        T_geom_3.resize(4, 4);
        T_geom_3 << 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, -0.1, 0, 0, 0, 1;
        T_offset_1.resize(4, 4);
        T_offset_1 << 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, -1.05, 0, 0, 0, 1;
        T_offset_2.resize(4, 4);
        T_offset_2 << 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, -0.55, 0, 0, 0, 1;
        T_offset_3.resize(4, 4);
        T_offset_3 << 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, -0.1, 0, 0, 0, 1;
        sensor_outputs = 0.0;
        theta = Eigen::VectorXd::Zero(2);
        d_theta = Eigen::VectorXd::Zero(2);
        jtype = std::vector<typename std::remove_reference<decltype(1)>::type>({ 1, 1 });
        T_geom = std::vector<typename std::remove_reference<decltype(T_geom_1)>::type>({ T_geom_1, T_geom_2, T_geom_3 });
        B_k = std::vector<typename std::remove_reference<decltype(B_1)>::type>({ B_1, B_2, B_3 });
        T_offset = std::vector<typename std::remove_reference<decltype(T_offset_1)>::type>({ T_offset_1, T_offset_2, T_offset_3 });

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
        Eigen::VectorXd tau_eff; // TODO: Dimension not provided for vector tau_eff
        tau_eff=(tau - (damping * d_q));
        std::vector<Eigen::MatrixXd> Xup = zeroMatSeq(N, 6, 6);
        std::vector<Eigen::VectorXd> S = zeroVecSeq(N, 6);
        std::vector<Eigen::VectorXd> v = zeroVecSeq(N, 6);
        std::vector<Eigen::VectorXd> c = zeroVecSeq(N, 6);
        std::vector<Eigen::MatrixXd> IA = zeroMatSeq(N, 6, 6);
        std::vector<Eigen::VectorXd> pA = zeroVecSeq(N, 6);
        std::vector<Eigen::VectorXd> U = zeroVecSeq(N, 6);
        Eigen::VectorXd d; // TODO: Dimension not provided for vector d
        d=Eigen::VectorXd::Zero(N);
        Eigen::VectorXd u; // TODO: Dimension not provided for vector u
        u=Eigen::VectorXd::Zero(N);
        std::vector<Eigen::VectorXd> a = zeroVecSeq(N, 6);
        Eigen::VectorXd qdd; // TODO: Dimension not provided for vector qdd
        qdd=Eigen::VectorXd::Zero(N);
        Eigen::VectorXd v_base; // TODO: Dimension not provided for vector v_base
        v_base=Eigen::VectorXd::Zero(6);
        Eigen::VectorXd a_base; // TODO: Dimension not provided for vector a_base
        a_base=Eigen::VectorXd::Zero(6);
        a_base(5) = gravity;
        for (int i = 0; i < N; i++) {
            int jt = jtype[i];
            double axisSign = 1.0;
            if (jt < 0) {
                axisSign = -1.0;
            }
            int jtAbs = jt;
            if (jt < 0) {
                jtAbs = -jt;
            }
            double qi = q(i);
            double qdi = d_q(i);
            double qEff = (axisSign * qi);
            Eigen::VectorXd Si; // TODO: Dimension not provided for vector Si
        Si=Eigen::VectorXd::Zero(6);
            Eigen::MatrixXd XJ = Eigen::MatrixXd::Identity(6, 6);
            if (jtAbs == 1) {
                Si << axisSign, 0, 0, 0, 0, 0;
                double cR = std::cos(qEff);
                double sR = std::sin(qEff);
                XJ << 1, 0, 0, 0, 0, 0, 0, cR, sR, 0, 0, 0, 0, -sR, cR, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, cR, sR, 0, 0, 0, 0, -sR, cR;
            }
            if (jtAbs == 2) {
                Si << 0, axisSign, 0, 0, 0, 0;
                double cR = std::cos(qEff);
                double sR = std::sin(qEff);
                XJ << cR, 0, -sR, 0, 0, 0, 0, 1, 0, 0, 0, 0, sR, 0, cR, 0, 0, 0, 0, 0, 0, cR, 0, -sR, 0, 0, 0, 0, 1, 0, 0, 0, 0, sR, 0, cR;
            }
            if (jtAbs == 3) {
                Si << 0, 0, axisSign, 0, 0, 0;
                double cR = std::cos(qEff);
                double sR = std::sin(qEff);
                XJ << cR, sR, 0, 0, 0, 0, -sR, cR, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, cR, sR, 0, 0, 0, 0, -sR, cR, 0, 0, 0, 0, 0, 0, 1;
            }
            if (jtAbs == 4) {
                Si << 0, 0, 0, axisSign, 0, 0;
                double dP = qEff;
                XJ << 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, dP, 0, 1, 0, 0, -dP, 0, 0, 0, 1;
            }
            if (jtAbs == 5) {
                Si << 0, 0, 0, 0, axisSign, 0;
                double dP = qEff;
                XJ << 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, -dP, 1, 0, 0, 0, 0, 0, 0, 1, 0, dP, 0, 0, 0, 0, 1;
            }
            if (jtAbs == 6) {
                Si << 0, 0, 0, 0, 0, axisSign;
                double dP = qEff;
                XJ << 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, dP, 0, 1, 0, 0, -dP, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1;
            }
            S[i] = Si;
            Xup[i] = (XJ * XT[i]);
            Eigen::VectorXd vJ; // TODO: Dimension not provided for vector vJ
        vJ=(Si * qdi);
            if (i == 0) {
                v[i] = ((Xup[i] * v_base) + vJ);
            } else {
                v[i] = ((Xup[i] * v[(i - 1)]) + vJ);
            }
            Eigen::VectorXd w; // TODO: Dimension not provided for vector w
        w=v[i].segment(0, 3);
            Eigen::VectorXd vl; // TODO: Dimension not provided for vector vl
        vl=v[i].segment(3, 3);
            Eigen::MatrixXd wx = skewSymmetric(w);
            Eigen::MatrixXd vx = skewSymmetric(vl);
            Eigen::MatrixXd crm_v = Eigen::MatrixXd::Zero(6, 6);
            crm_v.block(0, 0, 3, 3) = wx;
            crm_v.block(3, 0, 3, 3) = vx;
            crm_v.block(3, 3, 3, 3) = wx;
            c[i] = (crm_v * vJ);
            IA[i] = I[i];
            Eigen::MatrixXd crf_v = Eigen::MatrixXd::Zero(6, 6);
            crf_v.block(0, 0, 3, 3) = wx;
            crf_v.block(0, 3, 3, 3) = vx;
            crf_v.block(3, 3, 3, 3) = wx;
            Eigen::VectorXd Iv; // TODO: Dimension not provided for vector Iv
        Iv=(I[i] * v[i]);
            pA[i] = (crf_v * Iv);
        }
        for (int i = (N - 1); i > -1; i += -1) {
            U[i] = (IA[i] * S[i]);
            d(i) = (S[i].transpose() * U[i]);
            u(i) = (tau_eff(i) - (S[i].transpose() * pA[i]));
            if (i > 0) {
                Eigen::MatrixXd Ia = (IA[i] - ((U[i] * U[i].transpose()) / d(i)));
                IA[(i - 1)] = (IA[(i - 1)] + ((Xup[i].transpose() * Ia) * Xup[i]));
                Eigen::VectorXd pa; // TODO: Dimension not provided for vector pa
        pa=((pA[i] + (Ia * c[i])) + (U[i] * (u(i) / d(i))));
                pA[(i - 1)] = (pA[(i - 1)] + (Xup[i].transpose() * pa));
            }
        }
        for (int i = 0; i < N; i++) {
            if (i == 0) {
                a[i] = ((Xup[i] * a_base) + c[i]);
            } else {
                a[i] = ((Xup[i] * a[(i - 1)]) + c[i]);
            }
            qdd(i) = ((u(i) - (U[i].transpose() * a[i])) / d(i));
            a[i] = (a[i] + (S[i] * qdd(i)));
        }
        dd_q = qdd;
    }
        {
        d_q = (d_q + (dt * dd_q));
    }
        {
        q = (q + (dt * d_q));
    }
        {
        // skip;
    }
        {
        p_mapping.Acrobot.BaseLink.ShoulderEncoder.AngleOut = theta(0);
        p_mapping.Acrobot.BaseLink.ShoulderEncoder.VelocityOut = d_theta(0);
        p_mapping.Acrobot.Link1.ElbowEncoder.AngleOut = theta(1);
        p_mapping.Acrobot.Link1.ElbowEncoder.VelocityOut = d_theta(1);
    }
        
        // Update time for next iteration
        t += dt;
    
        // Log velocity data for trajectory comparison
        log_velocity(t, theta, d_theta, tau, Eigen::MatrixXd());
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
    // T_offset exists in state as sequence
    T_offset_vec = state.T_offset;

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
