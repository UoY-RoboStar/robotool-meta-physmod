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
static std::vector<Eigen::VectorXd>& motor_k = state.motor_k;
static std::vector<Eigen::VectorXd>& motor_joint = state.motor_joint;
static Eigen::VectorXd& theta = state.theta;
static std::vector<Eigen::VectorXd>& motor_T = state.motor_T;
static std::vector<Eigen::VectorXd>& H = state.H;
static Eigen::VectorXd& l = state.l;
static Eigen::VectorXd& lc = state.lc;
static int& n = state.n;
static Eigen::MatrixXd& B_1 = state.B_1;
static Eigen::MatrixXd& B_2 = state.B_2;
static Eigen::MatrixXd& B_3 = state.B_3;
static Eigen::VectorXd& motor_T_3 = state.motor_T_3;
static Eigen::VectorXd& motor_T_2 = state.motor_T_2;
static Eigen::VectorXd& motor_T_1 = state.motor_T_1;
static Eigen::VectorXd& H_2 = state.H_2;
static Eigen::VectorXd& H_1 = state.H_1;
static int& N = state.N;
static Eigen::MatrixXd& M_mass = state.M_mass;
static Eigen::VectorXd& m = state.m;
static Eigen::VectorXd& Ic = state.Ic;
static std::vector<Eigen::MatrixXd>& M_spatial = state.M_spatial;
static Eigen::MatrixXd& M_3 = state.M_3;
static Eigen::MatrixXd& M_2 = state.M_2;
static Eigen::MatrixXd& M_1 = state.M_1;
static Eigen::VectorXd& bias = state.bias;
static Eigen::VectorXd& theta_dot = state.theta_dot;
static Eigen::VectorXd& b = state.b;
static double& gravity = state.gravity;
static Eigen::VectorXd& theta_dotdot = state.theta_dotdot;
static Eigen::VectorXd& tau = state.tau;
static Eigen::VectorXd& d_theta_dot = state.d_theta_dot;
static double& dt = state.dt;
static Eigen::VectorXd& d_theta = state.d_theta;

// Additional state variables
static double t = 0.0;
// Note: dt is already available from state.dt

// Geom struct declarations for visualization
// Geometry datatypes
struct Geom { const char* geomType; int valCount; double geomVal[3]; const char* meshUri; int meshScaleCount; double meshScale[3]; };
static const Geom L1_geom = { "cylinder", 2, {0.05, 1.0, 0.0}, "", 1, {1.0, 1.0, 1.0} };  // gripper
static const Geom L2_geom = { "cylinder", 2, {0.05, 2.0, 0.0}, "", 1, {1.0, 1.0, 1.0} };  // intermediate
static const Geom L3_geom = { "sphere", 1, {0.08, 0.0, 0.0}, "", 1, {1.0, 1.0, 1.0} };  // base

// Visualization runtime state (metadata extracted from Geom records in Solution DSL)
struct VisualLinkSpec {
    const char* name;
    int shape;       // 0=box, 1=cylinder, 2=sphere, 3=mesh
    double dims[3];  // Shape dimensions (interpretation depends on shape)
};

static bool visualization_enabled = true;
static std::unique_ptr<VisualizationClient> viz_client = nullptr;
static const VisualLinkSpec ROBOT_VISUAL_LINKS[] = {
    {"robot/link_1", 1, {0.05, 1.0, 0.0}},
    {"robot/link_2", 1, {0.05, 2.0, 0.0}},
    {"robot/link_3", 2, {0.08, 0.0, 0.0}}
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
Eigen::VectorXd translatorZ(double d);
Eigen::MatrixXd transpose(Eigen::MatrixXd m);
Eigen::MatrixXd identity(int n);
Eigen::VectorXd rotorX(double q);
Eigen::VectorXd motorReverse(Eigen::VectorXd m);
Eigen::MatrixXd zeroMat(int n, int m);
Eigen::MatrixXd skewSymmetric(Eigen::VectorXd p);
Eigen::MatrixXd spatialCrossMotion(Eigen::VectorXd v);
Eigen::MatrixXd LDLT(Eigen::MatrixXd M);
Eigen::VectorXd motorProduct(Eigen::VectorXd m1, Eigen::VectorXd m2);
Eigen::MatrixXd motorToMatrix(Eigen::VectorXd m);
Eigen::MatrixXd spatialCrossForce(Eigen::VectorXd v);
Eigen::VectorXd motorIdentity();

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


Eigen::VectorXd translatorZ(double d) {
    Eigen::VectorXd result = Eigen::VectorXd::Zero(8);
    return result;
}


Eigen::MatrixXd transpose(const Eigen::MatrixXd& m) {
    return m.transpose();
}


Eigen::MatrixXd identity(int n) {
    Eigen::MatrixXd result = Eigen::MatrixXd::Zero(4, 4);
    return result;
}


Eigen::VectorXd rotorX(double q) {
    Eigen::VectorXd result = Eigen::VectorXd::Zero(8);
    return result;
}


Eigen::VectorXd motorReverse(Eigen::VectorXd m) {
    Eigen::VectorXd result = Eigen::VectorXd::Zero(8);
    return result;
}


Eigen::MatrixXd zeroMat(int n, int m) {
    return Eigen::MatrixXd::Zero(n, m);
}


Eigen::MatrixXd skewSymmetric(Eigen::VectorXd p) {
    Eigen::MatrixXd result = Eigen::MatrixXd::Zero(3, 3);
    return result;
}


Eigen::MatrixXd spatialCrossMotion(Eigen::VectorXd v) {
    Eigen::MatrixXd result = Eigen::MatrixXd::Zero(6, 6);
    return result;
}


Eigen::MatrixXd LDLT(const Eigen::MatrixXd& M) {
    return M.ldlt().solve(Eigen::MatrixXd::Identity(M.rows(), M.cols()));
}


Eigen::VectorXd motorProduct(Eigen::VectorXd m1, Eigen::VectorXd m2) {
    Eigen::VectorXd result = Eigen::VectorXd::Zero(8);
    return result;
}


Eigen::MatrixXd motorToMatrix(Eigen::VectorXd m) {
    Eigen::MatrixXd result = Eigen::MatrixXd::Zero(4, 4);
    return result;
}


Eigen::MatrixXd spatialCrossForce(Eigen::VectorXd v) {
    Eigen::MatrixXd result = Eigen::MatrixXd::Zero(6, 6);
    return result;
}


Eigen::VectorXd motorIdentity() {
    Eigen::VectorXd result = Eigen::VectorXd::Zero(8);
    return result;
}



#pragma endregion functions

// ═══════════════════════════════════════════════════════════════════════════
// INITIALIZATION (SolutionDSL: state { ... } with initial values)
// ═══════════════════════════════════════════════════════════════════════════
#pragma region initialization

void initGlobals() {
        theta.resize(2);
        theta << 1.0, 1.0;
        l.resize(2);
        l << 1.0, 2.0;
        lc.resize(2);
        lc << 0.5, 1.0;
        n = 3;
        B_1.resize(4, 4);
        B_1 << 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0;
        B_2.resize(4, 4);
        B_2 << 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0;
        B_3 = Eigen::MatrixXd::Identity(4, 4);
        motor_T_3 = Eigen::VectorXd::Zero(8);
        motor_T_2 = Eigen::VectorXd::Zero(8);
        motor_T_1 = Eigen::VectorXd::Zero(8);
        H_2 = Eigen::VectorXd::Zero(6);
        H_1 = Eigen::VectorXd::Zero(6);
        N = 2;
        M_mass.resize(2, 2);
        M_mass << unknown_fun(2, 2);
        m.resize(2);
        m << 1.0, 1.0;
        Ic.resize(2);
        Ic << 0.083, 0.33;
        M_3 = Eigen::MatrixXd::Zero(6, 6);
        M_2 = Eigen::MatrixXd::Zero(6, 6);
        M_1 = Eigen::MatrixXd::Zero(6, 6);
        bias.resize(2);
        bias << unknown_fun(2);
        theta_dot.resize(2);
        theta_dot << 0.0, 0.0;
        b.resize(2);
        b << 0.1, 0.1;
        gravity = 9.81;
        theta_dotdot.resize(2);
        theta_dotdot << unknown_fun(2);
        tau.resize(2);
        tau << 0.0, 0.0;
        d_theta_dot.resize(2);
        d_theta_dot << 0.0, 0.0;
        dt = 0.01;
        d_theta.resize(2);
        d_theta << 0.0, 0.0;
        B_k = std::vector<typename std::remove_reference<decltype(B_3)>::type>({ B_3, B_2, B_1 });
        motor_k = std::vector<typename std::remove_reference<decltype(motorIdentity())>::type>({ motorIdentity(), motorIdentity(), motorIdentity() });
        motor_joint = std::vector<typename std::remove_reference<decltype(motorIdentity())>::type>({ motorIdentity(), motorIdentity() });
        motor_T = std::vector<typename std::remove_reference<decltype(motor_T_3)>::type>({ motor_T_3, motor_T_2, motor_T_1 });
        H = std::vector<typename std::remove_reference<decltype(H_2)>::type>({ H_2, H_1 });
        M_spatial = std::vector<typename std::remove_reference<decltype(M_3)>::type>({ M_3, M_2, M_1 });

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
        motor_k[N] = motorIdentity();
        B_k[N] = Eigen::MatrixXd::Identity(4, 4);
        for (int k = (N - 1); k > -1; k += -1) {
            motor_joint[k] = rotorX(theta(k));
            motor_k[k] = motorProduct(motorProduct(motor_k[(k + 1)], motor_T[k]), motor_joint[k]);
            B_k[k] = motorToMatrix(motor_k[k]);
        }
    }
        {
        std::vector<Eigen::MatrixXd> Xup = std::vector<Eigen::MatrixXd>({ Eigen::MatrixXd::Zero(6, 6), Eigen::MatrixXd::Zero(6, 6) });
        std::vector<Eigen::VectorXd> S = std::vector<Eigen::VectorXd>({ Eigen::VectorXd::Zero(6), Eigen::VectorXd::Zero(6) });
        std::vector<Eigen::MatrixXd> I = std::vector<Eigen::MatrixXd>({ Eigen::MatrixXd::Zero(6, 6), Eigen::MatrixXd::Zero(6, 6) });
        for (int i = 0; i < N; i++) {
            Eigen::MatrixXd R_p = B_k[(i + 1)].block(0, 0, 3, 3);
            Eigen::VectorXd p_p; // TODO: Dimension not provided for vector p_p
        p_p=B_k[(i + 1)].block(0, 3, 3, 1);
            Eigen::MatrixXd R_c = B_k[i].block(0, 0, 3, 3);
            Eigen::VectorXd p_c; // TODO: Dimension not provided for vector p_c
        p_c=B_k[i].block(0, 3, 3, 1);
            Eigen::MatrixXd R_pc = (R_p.transpose() * R_c);
            Eigen::VectorXd p_pc; // TODO: Dimension not provided for vector p_pc
        p_pc=(R_p.transpose() * (p_c - p_p));
            Eigen::MatrixXd E = R_pc.transpose();
            Eigen::MatrixXd X = Eigen::MatrixXd::Zero(6, 6);
            X.block(0, 0, 3, 3) = E;
            X.block(3, 3, 3, 3) = E;
            X.block(3, 0, 3, 3) = (-E * skewSymmetric(p_pc));
            Xup[i] = X;
            S[i] = H[i];
            I[i] = M_spatial[i];
        }
        std::vector<Eigen::MatrixXd> I_comp = I;
        for (int i = 0; i < N; i++) {
            if (i < (N - 1)) {
                I_comp[(i + 1)] = (I_comp[(i + 1)] + ((Xup[i].transpose() * I_comp[i]) * Xup[i]));
            }
        }
        M_mass = Eigen::MatrixXd::Zero(N, N);
        for (int i = 0; i < N; i++) {
            Eigen::VectorXd F; // TODO: Dimension not provided for vector F
        F=(I_comp[i] * S[i]);
            M_mass(i,i) = (S[i].transpose() * F);
            Eigen::VectorXd Ftmp; // TODO: Dimension not provided for vector Ftmp
        Ftmp=F;
            for (int j = (i + 1); j < N; j++) {
                Ftmp = (Xup[(j - 1)].transpose() * Ftmp);
                M_mass(i,j) = (S[j].transpose() * Ftmp);
                M_mass(j,i) = M_mass(i,j);
            }
        }
    }
        {
        std::vector<Eigen::MatrixXd> Xup = std::vector<Eigen::MatrixXd>({ Eigen::MatrixXd::Zero(6, 6), Eigen::MatrixXd::Zero(6, 6) });
        std::vector<Eigen::VectorXd> S = std::vector<Eigen::VectorXd>({ Eigen::VectorXd::Zero(6), Eigen::VectorXd::Zero(6) });
        std::vector<Eigen::MatrixXd> I = std::vector<Eigen::MatrixXd>({ Eigen::MatrixXd::Zero(6, 6), Eigen::MatrixXd::Zero(6, 6) });
        for (int i = 0; i < N; i++) {
            Eigen::MatrixXd R_p = B_k[(i + 1)].block(0, 0, 3, 3);
            Eigen::VectorXd p_p; // TODO: Dimension not provided for vector p_p
        p_p=B_k[(i + 1)].block(0, 3, 3, 1);
            Eigen::MatrixXd R_c = B_k[i].block(0, 0, 3, 3);
            Eigen::VectorXd p_c; // TODO: Dimension not provided for vector p_c
        p_c=B_k[i].block(0, 3, 3, 1);
            Eigen::MatrixXd R_pc = (R_p.transpose() * R_c);
            Eigen::VectorXd p_pc; // TODO: Dimension not provided for vector p_pc
        p_pc=(R_p.transpose() * (p_c - p_p));
            Eigen::MatrixXd E = R_pc.transpose();
            Eigen::MatrixXd X = Eigen::MatrixXd::Zero(6, 6);
            X.block(0, 0, 3, 3) = E;
            X.block(3, 3, 3, 3) = E;
            X.block(3, 0, 3, 3) = (-E * skewSymmetric(p_pc));
            Xup[i] = X;
            S[i] = H[i];
            I[i] = M_spatial[i];
        }
        std::vector<Eigen::VectorXd> v = std::vector<Eigen::VectorXd>({ Eigen::VectorXd::Zero(6), Eigen::VectorXd::Zero(6) });
        std::vector<Eigen::VectorXd> a = std::vector<Eigen::VectorXd>({ Eigen::VectorXd::Zero(6), Eigen::VectorXd::Zero(6) });
        std::vector<Eigen::VectorXd> f = std::vector<Eigen::VectorXd>({ Eigen::VectorXd::Zero(6), Eigen::VectorXd::Zero(6) });
        Eigen::VectorXd a_base; // TODO: Dimension not provided for vector a_base
        a_base=Eigen::VectorXd::Zero(6);
        a_base(5) = gravity;
        for (int i = (N - 1); i > -1; i += -1) {
            Eigen::VectorXd vJ; // TODO: Dimension not provided for vector vJ
        vJ=(S[i] * theta_dot(i));
            if (i == (N - 1)) {
                v[i] = vJ;
                a[i] = ((Xup[i] * a_base) + (spatialCrossMotion(v[i]) * vJ));
            } else {
                v[i] = ((Xup[i] * v[(i + 1)]) + vJ);
                a[i] = ((Xup[i] * a[(i + 1)]) + (spatialCrossMotion(v[i]) * vJ));
            }
            f[i] = ((I[i] * a[i]) + (spatialCrossForce(v[i]) * (I[i] * v[i])));
        }
        for (int i = 0; i < N; i++) {
            bias(i) = (S[i].transpose() * f[i]);
            if (i < (N - 1)) {
                f[(i + 1)] = (f[(i + 1)] + (Xup[i].transpose() * f[i]));
            }
        }
    }
        {
        Eigen::VectorXd rhs; // TODO: Dimension not provided for vector rhs
        rhs=(tau - bias);
        Eigen::MatrixXd M_inv = M_mass.ldlt().solve(Eigen::MatrixXd::Identity(M_mass.rows(),M_mass.cols()));
        theta_dotdot = (M_inv * rhs);
    }
        {
        theta_dot = (theta_dot + (dt * d_theta_dot));
    }
        {
        theta = (theta + (dt * d_theta));
    }
        {
    
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
