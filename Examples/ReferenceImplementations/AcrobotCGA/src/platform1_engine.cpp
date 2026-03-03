// Platform1 Physics Engine - AcrobotCGA Reference Implementation (GAFRO-aligned ABA)
// Conformal Geometric Algebra (CGA) formulation using Motor representation
// Structure: Includes -> State -> Functions -> Initialization -> Computation -> Visualization -> API
//
// Notes:
// - This version removes the SKO phi-matrix pipeline entirely.
// - Forward dynamics uses a standard Articulated-Body Algorithm (ABA) style recursion,
//   which matches GAFRO's forward-dynamics approach (computeJointAccelerations via ABA).
// - We keep the "computation step" style and your motor-based FK style.

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
#include "interfaces.hpp"
#include "visualization_client.h"
#pragma endregion includes

// Trajectory logging globals
static std::ofstream traj_log;
static bool traj_initialized = false;

// ═══════════════════════════════════════════════════════════════════════════
// STATE (SolutionDSL: state { ... })
// ═══════════════════════════════════════════════════════════════════════════
#pragma region state

// Platform state (consolidated physics state)
static platform1::State state;

// Reference bindings (keep only what we actually use; SKO/phi globals removed)
static int& n = state.n;
static int& N = state.N;

static std::vector<Eigen::MatrixXd>& B_k = state.B_k;
static Eigen::MatrixXd& B_1 = state.B_1;
static Eigen::MatrixXd& B_2 = state.B_2;
static Eigen::MatrixXd& B_3 = state.B_3;

static std::vector<platform1::Motor>& motor_k = state.motor_k;
static platform1::Motor& motor_1 = state.motor_1;
static platform1::Motor& motor_2 = state.motor_2;
static platform1::Motor& motor_3 = state.motor_3;

static std::vector<platform1::Motor>& motor_joint = state.motor_joint;
static platform1::Motor& motor_joint_1 = state.motor_joint_1;
static platform1::Motor& motor_joint_2 = state.motor_joint_2;

static std::vector<platform1::Motor>& motor_T = state.motor_T;
static platform1::Motor& motor_T_1 = state.motor_T_1;
static platform1::Motor& motor_T_2 = state.motor_T_2;
static platform1::Motor& motor_T_3 = state.motor_T_3;

static Eigen::VectorXd& theta = state.theta;
static Eigen::VectorXd& d_theta = state.d_theta;
static Eigen::VectorXd& dd_theta = state.dd_theta;

static Eigen::VectorXd& C = state.C;              // bias torques (for logging/debug)
static Eigen::VectorXd& H_1 = state.H_1;          // joint axis for body 0 (link1)
static Eigen::VectorXd& H_2 = state.H_2;          // joint axis for body 1 (link2)

static Eigen::MatrixXd& M_1 = state.M_1;          // spatial inertia for body 0 (link1)
static Eigen::MatrixXd& M_2 = state.M_2;          // spatial inertia for body 1 (link2)
static Eigen::MatrixXd& M_3 = state.M_3;          // base (unused in dynamics recursion but kept in state)

static Eigen::VectorXd& tau = state.tau;
static Eigen::VectorXd& tau_d = state.tau_d;
static Eigen::MatrixXd& damping = state.damping;

static double& dt = state.dt;

static std::vector<Eigen::MatrixXd>& T_geom = state.T_geom;
static std::vector<Eigen::MatrixXd>& T_offset = state.T_offset;
static Eigen::MatrixXd& T_geom_1 = state.T_geom_1;
static Eigen::MatrixXd& T_geom_2 = state.T_geom_2;
static Eigen::MatrixXd& T_geom_3 = state.T_geom_3;
static Eigen::MatrixXd& T_offset_1 = state.T_offset_1;
static Eigen::MatrixXd& T_offset_2 = state.T_offset_2;
static Eigen::MatrixXd& T_offset_3 = state.T_offset_3;

static Eigen::VectorXd& m = state.m;
static Eigen::VectorXd& l = state.l;
static Eigen::VectorXd& lc = state.lc;
static Eigen::VectorXd& Ic = state.Ic;
static Eigen::VectorXd& b_damp = state.b_damp;
static double& gravity = state.gravity;

// Time state
static double t = 0.0;

// Visualization runtime state
struct VisualLinkSpec {
    const char* name;
    int shape;       // 0=box, 1=cylinder, 2=sphere
    double dims[3];
};

static bool visualization_enabled = true;
static std::unique_ptr<VisualizationClient> viz_client = nullptr;
static const VisualLinkSpec ROBOT_VISUAL_LINKS[] = {
    {"robot/link_1", 1, {0.05, 2.1, 0.0}},   // Gripper - cylinder
    {"robot/link_2", 1, {0.05, 1.1, 0.0}},   // Intermediate - cylinder
    {"robot/link_3", 0, {0.2, 0.2, 0.2}}     // Base - box
};

#pragma endregion state

// ═══════════════════════════════════════════════════════════════════════════
// FUNCTION FORWARD DECLARATIONS
// ═══════════════════════════════════════════════════════════════════════════
platform1::Motor motorIdentity();
platform1::Motor rotorY(double angle);
platform1::Motor translatorZ(double d);
platform1::Motor motorProduct(const platform1::Motor& m1, const platform1::Motor& m2);
platform1::Motor motorReverse(const platform1::Motor& m);
Eigen::Matrix4d motorToMatrix(const platform1::Motor& m);

// Spatial algebra helpers (renamed; no SKO pipeline)
Eigen::Matrix3d skewSymmetric(const Eigen::Vector3d& v);
Eigen::Matrix<double, 6, 6> spatialCrossMotion(const Eigen::Matrix<double, 6, 1>& v);
Eigen::Matrix<double, 6, 6> spatialCrossForce(const Eigen::Matrix<double, 6, 1>& v);

void initVisualization();
void updateRobotVisualization();

// ═══════════════════════════════════════════════════════════════════════════
// FUNCTIONS (SolutionDSL: functions { ... })
// ═══════════════════════════════════════════════════════════════════════════
#pragma region functions

// ---------------------------------------------------------------------------
// CGA Motor Operations
// ---------------------------------------------------------------------------

// Create identity Motor (no transformation)
platform1::Motor motorIdentity() {
    platform1::Motor m;
    m.data.setZero();
    m.data(0) = 1.0;  // scalar = 1
    return m;
}

// Create Rotor from angle about Y-axis (gafro convention)
// Rotor = cos(angle/2) + sin(angle/2) * bivector
// Note: e13 = e1 ^ e3 represents rotation in XZ plane (about Y axis)
platform1::Motor rotorY(double angle) {
    platform1::Motor m;
    m.data.setZero();
    m.data(0) = std::cos(angle / 2.0);    // scalar
    m.data(2) = std::sin(angle / 2.0);    // e13 component
    return m;
}

// Create Translator along Z-axis (used here for link offsets)
// Translator = 1 - (d/2) * e3i
platform1::Motor translatorZ(double d) {
    platform1::Motor m;
    m.data.setZero();
    m.data(0) = 1.0;           // scalar
    m.data(6) = -d / 2.0;      // e3i component (Z translation)
    return m;
}

// --- Dual-quaternion view of the 8D CGA motor (matches GAFRO motor↔dual-quaternion isomorphism) ---
// We keep the existing blade storage layout in Motor::data, but interpret it as:
//   real/rotor quaternion  q_r = (w, x, y, z) = (scalar, -e23, +e13, -e12)
//   dual quaternion       q_d = (w, x, y, z) = (e123i, -e1i, -e2i, -e3i)
static inline Eigen::Quaterniond motorRotorQuat(const platform1::Motor& m) {
    return Eigen::Quaterniond(m.data(0), -m.data(3),  m.data(2), -m.data(1));
}
static inline Eigen::Quaterniond motorDualQuat(const platform1::Motor& m) {
    return Eigen::Quaterniond(m.data(7), -m.data(4), -m.data(5), -m.data(6));
}
static inline void setMotorRotorFromQuat(platform1::Motor& m, const Eigen::Quaterniond& q) {
    m.data(0) = q.w();
    m.data(3) = -q.x();
    m.data(2) =  q.y();
    m.data(1) = -q.z();
}
static inline void setMotorDualFromQuat(platform1::Motor& m, const Eigen::Quaterniond& q) {
    m.data(7) = q.w();
    m.data(4) = -q.x();
    m.data(5) = -q.y();
    m.data(6) = -q.z();
}

// Motor geometric product: M1 * M2 (dual quaternion product)
platform1::Motor motorProduct(const platform1::Motor& m1, const platform1::Motor& m2) {
    platform1::Motor result;
    result.data.setZero();

    const Eigen::Quaterniond r1 = motorRotorQuat(m1);
    const Eigen::Quaterniond d1 = motorDualQuat(m1);
    const Eigen::Quaterniond r2 = motorRotorQuat(m2);
    const Eigen::Quaterniond d2 = motorDualQuat(m2);

    // Dual quaternion product:
    //   (r1 + eps d1) * (r2 + eps d2) = (r1 r2) + eps (r1 d2 + d1 r2)
    const Eigen::Quaterniond r = r1 * r2;

    Eigen::Quaterniond d;
    d.coeffs() = (r1 * d2).coeffs() + (d1 * r2).coeffs();

    setMotorRotorFromQuat(result, r);
    setMotorDualFromQuat(result, d);

    return result;
}

// Motor reverse (conjugation)
// Reverse negates bivector parts (grades 2)
platform1::Motor motorReverse(const platform1::Motor& m) {
    platform1::Motor result;
    result.data(0) = m.data(0);    // scalar unchanged
    result.data(1) = -m.data(1);   // e12 negated
    result.data(2) = -m.data(2);   // e13 negated
    result.data(3) = -m.data(3);   // e23 negated
    result.data(4) = -m.data(4);   // e1i negated
    result.data(5) = -m.data(5);   // e2i negated
    result.data(6) = -m.data(6);   // e3i negated
    result.data(7) = m.data(7);    // e123i unchanged (grade 4)
    return result;
}

// Extract 4x4 transformation matrix from Motor (dual-quaternion pose extraction)
Eigen::Matrix4d motorToMatrix(const platform1::Motor& m) {
    // Pose extraction:
    //   M = r + eps d, with d = 0.5 * t * r  (t as pure-vector quaternion)
    //   => t = 2 * (d * r*)_vec
    Eigen::Quaterniond r = motorRotorQuat(m);
    Eigen::Quaterniond d = motorDualQuat(m);

    // Normalize (scale both parts by the same factor)
    const double nr = r.norm();
    if (nr > 1e-12) {
        r.coeffs() /= nr;
        d.coeffs() /= nr;
    } else {
        r = Eigen::Quaterniond::Identity();
        d.coeffs().setZero();
    }

    Eigen::Matrix4d T = Eigen::Matrix4d::Identity();
    T.block<3,3>(0, 0) = r.toRotationMatrix();

    const Eigen::Quaterniond tQuat = d * r.conjugate();
    const Eigen::Vector3d t = 2.0 * Eigen::Vector3d(tQuat.x(), tQuat.y(), tQuat.z());
    T.block<3,1>(0, 3) = t;

    return T;
}

// ---------------------------------------------------------------------------
// Spatial algebra helpers (no SKO global-matrix pipeline)
// Convention: spatial motion v = [omega; v]  and spatial force f = [n; f]
// ---------------------------------------------------------------------------

Eigen::Matrix3d skewSymmetric(const Eigen::Vector3d& v) {
    Eigen::Matrix3d result;
    result << 0.0, -v(2),  v(1),
              v(2),  0.0, -v(0),
             -v(1),  v(0),  0.0;
    return result;
}

// Motion cross-product operator crm(v): crm(v) * w = v x w
Eigen::Matrix<double, 6, 6> spatialCrossMotion(const Eigen::Matrix<double, 6, 1>& v) {
    Eigen::Matrix<double, 6, 6> X = Eigen::Matrix<double, 6, 6>::Zero();
    const Eigen::Vector3d w = v.head<3>();
    const Eigen::Vector3d lin = v.tail<3>();
    const Eigen::Matrix3d wx = skewSymmetric(w);
    const Eigen::Matrix3d vx = skewSymmetric(lin);

    X.block<3,3>(0,0) = wx;
    X.block<3,3>(3,0) = vx;
    X.block<3,3>(3,3) = wx;
    return X;
}

// Force cross-product operator crf(v): crf(v) * f = v x* f
Eigen::Matrix<double, 6, 6> spatialCrossForce(const Eigen::Matrix<double, 6, 1>& v) {
    Eigen::Matrix<double, 6, 6> X = Eigen::Matrix<double, 6, 6>::Zero();
    const Eigen::Vector3d w = v.head<3>();
    const Eigen::Vector3d lin = v.tail<3>();
    const Eigen::Matrix3d wx = skewSymmetric(w);
    const Eigen::Matrix3d vx = skewSymmetric(lin);

    X.block<3,3>(0,0) = wx;
    X.block<3,3>(0,3) = vx;
    X.block<3,3>(3,3) = wx;
    return X;
}

#pragma endregion functions

// ═══════════════════════════════════════════════════════════════════════════
// INITIALIZATION (SolutionDSL: state { ... } with initial values)
// ═══════════════════════════════════════════════════════════════════════════
#pragma region initialization

void initGlobals() {
    // System configuration
    n = 3;  // 3 frames (link1, link2, base)
    N = 2;  // 2 joints

    // Physical parameters
    m.resize(2);
    m << 1.0, 1.0;  // link masses

    // Link lengths: link1 (distal) = 2.0, link2 (proximal) = 1.0
    l.resize(2);
    l << 2.0, 1.0;

    // Center of mass distances from joint
    lc.resize(2);
    lc << 1.0, 0.5;

    // Moments of inertia about CoM (reference values)
    Ic.resize(2);
    Ic << (1.0 / 3.0), (1.0 / 12.0);

    b_damp.resize(2);
    b_damp << 0.1, 0.1;

    gravity = 9.81;

    // Joint state
    theta.resize(2);
    theta << 1.0, 1.0;  // initial angles (rad)

    d_theta = Eigen::VectorXd::Zero(2);
    dd_theta = Eigen::VectorXd::Zero(2);

    // Control inputs
    tau = Eigen::VectorXd::Zero(2);
    tau_d = Eigen::VectorXd::Zero(2);

    damping.resize(2, 2);
    damping << 0.1, 0.0,
               0.0, 0.1;

    // Initialize frame matrices
    B_1.resize(4, 4);
    B_1 << 1.0, 0.0, 0.0, 0.0,
           0.0, 1.0, 0.0, 0.15,
           0.0, 0.0, 1.0, 0.0,
           0.0, 0.0, 0.0, 1.0;

    B_2 = Eigen::Matrix4d::Identity();
    B_3 = Eigen::Matrix4d::Identity();

    B_k = {B_1, B_2, B_3};

    // Initialize CGA motors
    motor_1 = motorIdentity();
    motor_2 = motorIdentity();
    motor_3 = motorIdentity();
    motor_k = {motor_1, motor_2, motor_3};

    motor_joint_1 = motorIdentity();
    motor_joint_2 = motorIdentity();
    motor_joint = {motor_joint_1, motor_joint_2};

    // Constant tree transforms as motors (match SKO X_T offsets)
    motor_T_1 = translatorZ(-l(1));  // link2 length from elbow to wrist
    motor_T_2 = translatorZ(-0.2);   // base half-height offset (2 * 0.1)
    motor_T_3 = translatorZ(-0.1);   // base offset
    motor_T = {motor_T_1, motor_T_2, motor_T_3};

    // Joint axes (rotation about Y in body frame)
    H_1.resize(6);
    H_1 << 0.0, 1.0, 0.0, 0.0, 0.0, 0.0;  // body 0 joint axis

    H_2.resize(6);
    H_2 << 0.0, 1.0, 0.0, 0.0, 0.0, 0.0;  // body 1 joint axis

    // Spatial inertia matrices (computed from mass, COM, and Icom)
    const auto spatialInertiaFromCom = [](double mass, const Eigen::Vector3d& com, const Eigen::Matrix3d& Ic) {
        Eigen::Matrix<double, 6, 6> I = Eigen::Matrix<double, 6, 6>::Zero();
        const Eigen::Matrix3d C = skewSymmetric(com);
        I.block<3,3>(0,0) = Ic + mass * C * C.transpose();
        I.block<3,3>(0,3) = mass * C;
        I.block<3,3>(3,0) = (mass * C).transpose();
        I.block<3,3>(3,3) = mass * Eigen::Matrix3d::Identity();
        return I;
    };

    const Eigen::Vector3d com_1(0.0, 0.0, -lc(0));
    const Eigen::Vector3d com_2(0.0, 0.0, -lc(1));

    Eigen::Matrix3d Ic_1 = Eigen::Matrix3d::Zero();
    Ic_1(0,0) = Ic(0);
    Ic_1(1,1) = Ic(0);
    Ic_1(2,2) = 0.001;

    Eigen::Matrix3d Ic_2 = Eigen::Matrix3d::Zero();
    Ic_2(0,0) = Ic(1);
    Ic_2(1,1) = Ic(1);
    Ic_2(2,2) = 0.001;

    M_1 = spatialInertiaFromCom(m(0), com_1, Ic_1);
    M_2 = spatialInertiaFromCom(m(1), com_2, Ic_2);

    M_3 = Eigen::MatrixXd::Zero(6, 6);  // base (fixed)

    // Bias torques (for logging)
    C = Eigen::VectorXd::Zero(2);

    // Time step
    dt = 0.01;

    // Visualization offsets (match reference geometry)
    T_offset_1.resize(4, 4);
    T_offset_1 << 1.0, 0.0, 0.0, 0.0,
                  0.0, 1.0, 0.0, 0.0,
                  0.0, 0.0, 1.0, -1.05,
                  0.0, 0.0, 0.0, 1.0;

    T_offset_2.resize(4, 4);
    T_offset_2 << 1.0, 0.0, 0.0, 0.0,
                  0.0, 1.0, 0.0, 0.0,
                  0.0, 0.0, 1.0, -0.55,
                  0.0, 0.0, 0.0, 1.0;

    T_offset_3.resize(4, 4);
    T_offset_3 << 1.0, 0.0, 0.0, 0.0,
                  0.0, 1.0, 0.0, 0.0,
                  0.0, 0.0, 1.0, -0.1,
                  0.0, 0.0, 0.0, 1.0;

    T_offset = {T_offset_1, T_offset_2, T_offset_3};

    // Geometry transforms (computed each step)
    T_geom_1 = B_1 * T_offset_1;
    T_geom_2 = B_2 * T_offset_2;
    T_geom_3 = B_3 * T_offset_3;
    T_geom = {T_geom_1, T_geom_2, T_geom_3};

    std::cout << "[AcrobotCGA] Physics globals initialized (ABA, no SKO)" << std::endl;
}

#pragma endregion initialization

// ═══════════════════════════════════════════════════════════════════════════
// COMPUTATION (SolutionDSL: computation { ... })
// ═══════════════════════════════════════════════════════════════════════════
#pragma region computation

void physics_update_impl() {
    // -----------------------------------------------------------------------
    // Step 1: CGA Forward Kinematics using Motors (GAFRO-style ordered product)
    // -----------------------------------------------------------------------
    // Joint order:
    //   - joint2 (proximal) attaches link2 to base
    //   - joint1 (distal) attaches link1 to link2
    motor_joint_1 = rotorY(theta(0));
    motor_joint_2 = rotorY(theta(1));
    motor_joint[0] = motor_joint_1;
    motor_joint[1] = motor_joint_2;

    // Frame 3 (base): fixed offset motor
    motor_k[2] = motor_T_3;

    // Frame 2 (link2 at base joint): M2(q2)
    motor_k[1] = motorProduct(motor_k[2], motor_joint_2);

    // Frame 1 (link1 at elbow joint): M1(q) = M2(q2) * T_link2 * M1(q1)
    motor_k[0] = motorProduct(motorProduct(motor_k[1], motor_T_1), motor_joint_1);

    // Convert motors to 4x4 matrices for dynamics and visualization
    B_3 = motorToMatrix(motor_k[2]);  // Base frame (world)
    B_2 = motorToMatrix(motor_k[1]);  // link2
    B_1 = motorToMatrix(motor_k[0]);  // link1

    // Update B_k vector
    B_k[0] = B_1;
    B_k[1] = B_2;
    B_k[2] = B_3;

    // -----------------------------------------------------------------------
    // Step 2: Build spatial motion transforms Xup from the current CGA motors
    // -----------------------------------------------------------------------
    // Convention:
    //   spatial motion v = [wx wy wz vx vy vz]^T
    // Xup[i] maps parent spatial motion -> child spatial motion (expressed in child frame).
    auto motionX_from_parent_child = [](const Eigen::Matrix4d& T_parent_from_child) {
        const Eigen::Matrix3d R_pc = T_parent_from_child.block<3,3>(0, 0);
        const Eigen::Vector3d p_pc = T_parent_from_child.block<3,1>(0, 3);  // child origin in parent
        const Eigen::Matrix3d E = R_pc.transpose();                           // child_from_parent

        Eigen::Matrix<double, 6, 6> X = Eigen::Matrix<double, 6, 6>::Zero();
        X.block<3,3>(0,0) = E;
        X.block<3,3>(3,3) = E;
        X.block<3,3>(3,0) = -E * skewSymmetric(p_pc);  // v_c = E(v_p - w_p x p_pc)
        return X;
    };

    // Body indexing used in this file:
    //   body 1 = link2 (proximal), parent = base
    //   body 0 = link1 (distal),   parent = body 1
    //
    // IMPORTANT: This indexing matches theta/d_theta ordering:
    //   theta(0) -> joint1 (body 0)
    //   theta(1) -> joint2 (body 1)
    const int NB = 2;
    const int parent[NB] = { 1, -1 };

    // Traversal orders (because parent[0] > 0 in this indexing)
    const int order_fwd[NB] = { 1, 0 };  // base -> link2 -> link1
    const int order_bwd[NB] = { 0, 1 };  // link1 -> link2 -> base

    // Relative homogeneous transforms (parent_from_child)
    const Eigen::Matrix4d T_base_from_link2  = Eigen::Matrix4d(B_2);                  // base == world
    const Eigen::Matrix4d T_link2_from_link1 = Eigen::Matrix4d(B_2.inverse() * B_1);  // link2_from_link1

    Eigen::Matrix<double, 6, 6> Xup[NB];
    Xup[1] = motionX_from_parent_child(T_base_from_link2);
    Xup[0] = motionX_from_parent_child(T_link2_from_link1);

    static bool frame_debug_written = false;
    if (!frame_debug_written) {
        std::ofstream bk_log("bk_t0.csv");
        if (bk_log.is_open()) {
            bk_log << std::fixed << std::setprecision(9);
            bk_log << "name";
            for (int r = 0; r < 4; ++r) {
                for (int c = 0; c < 4; ++c) {
                    bk_log << ",m" << r << c;
                }
            }
            bk_log << std::endl;

            auto writeMat4 = [&](const char* name, const Eigen::MatrixXd& M) {
                bk_log << name;
                for (int r = 0; r < 4; ++r) {
                    for (int c = 0; c < 4; ++c) {
                        bk_log << "," << M(r, c);
                    }
                }
                bk_log << std::endl;
            };

            writeMat4("B_1", B_1);
            writeMat4("B_2", B_2);
            writeMat4("B_3", B_3);
        }

        std::ofstream xup_log("xup_t0.csv");
        if (xup_log.is_open()) {
            xup_log << std::fixed << std::setprecision(9);
            xup_log << "name";
            for (int r = 0; r < 6; ++r) {
                for (int c = 0; c < 6; ++c) {
                    xup_log << ",m" << r << c;
                }
            }
            xup_log << std::endl;

            auto writeMat6 = [&](const char* name, const Eigen::Matrix<double, 6, 6>& M) {
                xup_log << name;
                for (int r = 0; r < 6; ++r) {
                    for (int c = 0; c < 6; ++c) {
                        xup_log << "," << M(r, c);
                    }
                }
                xup_log << std::endl;
            };

            writeMat6("Xup_0", Xup[0]);
            writeMat6("Xup_1", Xup[1]);
        }

        frame_debug_written = true;
    }

    // Joint motion subspaces (axes), expressed in each body frame
    Eigen::Matrix<double, 6, 1> S[NB];
    S[0] = H_1;  // body 0 axis
    S[1] = H_2;  // body 1 axis

    // Body spatial inertias
    Eigen::Matrix<double, 6, 6> I[NB];
    I[0] = M_1;
    I[1] = M_2;

    // Base acceleration (gravity)
    Eigen::Matrix<double, 6, 1> a_base = Eigen::Matrix<double, 6, 1>::Zero();
    a_base(5) = gravity;

    // -----------------------------------------------------------------------
    // Step 3: Joint damping torque and effective torque
    // -----------------------------------------------------------------------
    tau_d = damping * d_theta;
    const Eigen::Vector2d tau_eff = (tau - tau_d);

    // -----------------------------------------------------------------------
    // Step 4: ABA forward velocity pass (compute v, c) and initialize IA, pA
    // -----------------------------------------------------------------------
    Eigen::Matrix<double, 6, 1> v[NB];
    Eigen::Matrix<double, 6, 1> c[NB];
    Eigen::Matrix<double, 6, 6> IA[NB];
    Eigen::Matrix<double, 6, 1> pA[NB];

    for (int k = 0; k < NB; ++k) {
        const int i = order_fwd[k];

        const Eigen::Matrix<double, 6, 1> vJ = S[i] * d_theta(i);

        if (parent[i] == -1) {
            v[i] = vJ;  // base velocity is zero
        } else {
            v[i] = Xup[i] * v[parent[i]] + vJ;
        }

        // Bias acceleration term due to joint motion
        c[i] = spatialCrossMotion(v[i]) * vJ;

        IA[i] = I[i];
        pA[i] = spatialCrossForce(v[i]) * (I[i] * v[i]);  // no external forces
    }

    // -----------------------------------------------------------------------
    // Step 5: ABA backward pass (articulated inertia/force propagation)
    // -----------------------------------------------------------------------
    Eigen::Matrix<double, 6, 1> U[NB];
    double d[NB] = {0.0, 0.0};
    double u[NB] = {0.0, 0.0};

    for (int k = 0; k < NB; ++k) {
        const int i = order_bwd[k];

        U[i] = IA[i] * S[i];
        d[i] = (S[i].transpose() * U[i])(0);

        // Robustness: avoid division by (near) zero
        if (std::abs(d[i]) < 1e-12) {
            d[i] = (d[i] >= 0.0) ? 1e-12 : -1e-12;
        }

        u[i] = tau_eff(i) - (S[i].transpose() * pA[i])(0);

        if (parent[i] != -1) {
            const double inv_d = 1.0 / d[i];

            const Eigen::Matrix<double, 6, 6> Ia =
                IA[i] - (U[i] * inv_d) * U[i].transpose();

            const Eigen::Matrix<double, 6, 1> pa =
                pA[i] + Ia * c[i] + U[i] * (u[i] * inv_d);

            IA[parent[i]] += Xup[i].transpose() * Ia * Xup[i];
            pA[parent[i]] += Xup[i].transpose() * pa;
        }
    }

    // -----------------------------------------------------------------------
    // Step 6: ABA forward acceleration pass (compute dd_theta)
    // -----------------------------------------------------------------------
    Eigen::Matrix<double, 6, 1> a[NB];

    for (int k = 0; k < NB; ++k) {
        const int i = order_fwd[k];

        const Eigen::Matrix<double, 6, 1> a_parent =
            (parent[i] == -1) ? a_base : a[parent[i]];

        // a_i = Xup * a_parent + c_i + S_i * qdd_i  (solve qdd_i next)
        a[i] = Xup[i] * a_parent + c[i];

        const double qdd_i = (u[i] - (U[i].transpose() * a[i])(0)) / d[i];
        dd_theta(i) = qdd_i;

        a[i] += S[i] * qdd_i;
    }

    // -----------------------------------------------------------------------
    // Step 7: (Optional but useful) Bias torque vector C(q,qd) via RNEA with qdd=0
    // -----------------------------------------------------------------------
    // This is purely for logging/debug and matches the library split: ABA for forward dynamics,
    // RNEA for inverse dynamics (here used with qdd = 0).
    {
        Eigen::Matrix<double, 6, 1> a0_rnea[NB];
        Eigen::Matrix<double, 6, 1> f_rnea[NB];

        // Forward pass (use same v, c already computed; set qdd = 0)
        for (int k = 0; k < NB; ++k) {
            const int i = order_fwd[k];
            const Eigen::Matrix<double, 6, 1> a_parent =
                (parent[i] == -1) ? a_base : a0_rnea[parent[i]];

            a0_rnea[i] = Xup[i] * a_parent + c[i];

            f_rnea[i] = I[i] * a0_rnea[i] + spatialCrossForce(v[i]) * (I[i] * v[i]);
        }

        // Backward pass (accumulate forces, project to joints)
        Eigen::Vector2d C_local;
        C_local.setZero();

        for (int k = 0; k < NB; ++k) {
            const int i = order_bwd[k];

            C_local(i) = (S[i].transpose() * f_rnea[i])(0);

            if (parent[i] != -1) {
                f_rnea[parent[i]] += Xup[i].transpose() * f_rnea[i];
            }
        }

        C = C_local;
    }

    // -----------------------------------------------------------------------
    // Step 8: Semi-implicit Euler integration
    // -----------------------------------------------------------------------
    d_theta = d_theta + dt * dd_theta;
    theta = theta + dt * d_theta;

    // -----------------------------------------------------------------------
    // Step 9: Update visualization transforms and time
    // -----------------------------------------------------------------------
    T_geom[0] = B_k[0] * T_offset[0];
    T_geom[1] = B_k[1] * T_offset[1];
    T_geom[2] = B_k[2] * T_offset[2];

    t += dt;

    if (visualization_enabled) {
        updateRobotVisualization();
    }
}

void physics_update() {
    if (!traj_initialized) {
        traj_log.open("trajectory.csv");
        traj_log << "time,theta0,theta1,dtheta0,dtheta1,C0,C1" << std::endl;
        traj_initialized = true;
    }

    physics_update_impl();

    if (traj_initialized && traj_log.is_open()) {
        traj_log << std::fixed << std::setprecision(6) << t
                 << "," << theta(0) << "," << theta(1)
                 << "," << d_theta(0) << "," << d_theta(1)
                 << "," << C(0) << "," << C(1) << std::endl;
        if (static_cast<int>(t / dt) % 100 == 0) traj_log.flush();
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
    std::size_t limit = T_geom.size();
    if (limit > linkCount) {
        limit = linkCount;
    }

    for (std::size_t idx = 0; idx < limit; ++idx) {
        const Eigen::MatrixXd& frame = T_geom[idx];
        if (frame.rows() == 4 && frame.cols() == 4) {
            Eigen::Matrix4d transform = frame;

            const VisualLinkSpec& linkSpec = ROBOT_VISUAL_LINKS[idx];
            if (linkSpec.shape == 1) {
                // Cylinder: rotate 90 degrees about X to align Y-axis cylinder with Z-axis
                Eigen::Matrix4d rotation = Eigen::Matrix4d::Identity();
                rotation(1, 1) = std::cos(M_PI / 2.0);
                rotation(1, 2) = -std::sin(M_PI / 2.0);
                rotation(2, 1) = std::sin(M_PI / 2.0);
                rotation(2, 2) = std::cos(M_PI / 2.0);
                transform = transform * rotation;
            }

            viz_client->sendTransform(linkSpec.name, transform, false);
        }
    }
}

void initVisualization() {
    visualization_enabled = true;
    if (viz_client) {
        return;
    }

    viz_client = std::make_unique<VisualizationClient>();

    if (viz_client->connect("127.0.0.1", 9999)) {
        std::cout << "[AcrobotCGA] Connected to visualization server" << std::endl;

        const int grey[3] = {128, 128, 128};
        for (std::size_t k = 0; k < sizeof(ROBOT_VISUAL_LINKS) / sizeof(ROBOT_VISUAL_LINKS[0]); ++k) {
            const VisualLinkSpec& spec = ROBOT_VISUAL_LINKS[k];
            viz_client->createObject(spec.name, spec.shape, spec.dims, grey);
        }

        updateRobotVisualization();
    } else {
        std::cerr << "[AcrobotCGA] Failed to connect to visualization server" << std::endl;
        viz_client.reset();
        visualization_enabled = false;
    }
}

#pragma endregion visualization

// ═══════════════════════════════════════════════════════════════════════════
// API (Platform Engine Interface Implementation)
// ═══════════════════════════════════════════════════════════════════════════
#pragma region api

class Platform1Engine : public IPlatformEngine {
public:
    void initialise() override {
        initGlobals();
        initVisualization();
        std::cout << "[AcrobotCGA] Platform engine initialized" << std::endl;
    }

    void update() override {
        physics_update();
    }

    double getTime() const override {
        return t;
    }

    double getDt() const override {
        return dt;
    }
};

std::unique_ptr<IPlatformEngine> createPlatformEngine() {
    return std::make_unique<Platform1Engine>();
}

// C API for standalone use
extern "C" {
    void platform1_initialise(void) {
        initGlobals();
        initVisualization();
    }

    void platform1_step(void) {
        physics_update();
    }

    double platform1_get_time(void) {
        return t;
    }
}

#pragma endregion api
