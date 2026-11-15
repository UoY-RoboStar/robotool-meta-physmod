// Platform1 Physics Engine - Four-Bar Linkage Reference Implementation
// Generation Mode: STANDALONE_VISUALISATION
// Structure: Includes → State → Procedures → Functions → Computation → API
//
// Based on Drake's four_bar example:
//   - 3 moving links (Crank A, Coupler B, Rocker C)
//   - Closed-chain dynamics via Lagrange multipliers
//   - Full 3-DOF coordinates with constraint enforcement

#pragma region includes
#include <iostream>
#include <Eigen/Dense>
#include <vector>
#include <memory>
#include <thread>
#include <chrono>
#include <cmath>
#include <array>
#include <fstream>
#include <iomanip>
#include <cstring>
#include "platform1_state.hpp"

// STANDALONE_VISUALISATION MODE: Minimal orchestrator with visualisation
#include "world_mapping.h"
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

// Reference bindings for backward compatibility with existing code
static std::vector<Eigen::MatrixXd>& B_k = state.B_k;
static std::vector<Eigen::MatrixXd>& X_J = state.X_J;
static std::vector<Eigen::MatrixXd>& X_T = state.X_T;
static int& n = state.n;
static Eigen::MatrixXd& B_1 = state.B_1;
static Eigen::MatrixXd& B_2 = state.B_2;
static Eigen::MatrixXd& B_3 = state.B_3;
static Eigen::MatrixXd& X_J_1 = state.X_J_1;
static Eigen::MatrixXd& X_J_2 = state.X_J_2;
static Eigen::MatrixXd& X_J_3 = state.X_J_3;
static Eigen::MatrixXd& X_T_1 = state.X_T_1;
static Eigen::MatrixXd& X_T_2 = state.X_T_2;
static Eigen::MatrixXd& X_T_3 = state.X_T_3;
static Eigen::VectorXd& theta = state.theta;
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
static Eigen::MatrixXd& M_mass = state.M_mass;
static Eigen::MatrixXd& M_inv = state.M_inv;
static double& N = state.N;
static Eigen::VectorXd& tau_d = state.tau_d;
static Eigen::MatrixXd& damping = state.damping;
static Eigen::VectorXd& tau = state.tau;
static double& dt = state.dt;
static std::vector<Eigen::MatrixXd>& T_geom = state.T_geom;
static std::vector<Eigen::MatrixXd>& T_offset = state.T_offset;
static Eigen::MatrixXd& T_geom_1 = state.T_geom_1;
static Eigen::MatrixXd& T_geom_2 = state.T_geom_2;
static Eigen::MatrixXd& T_geom_3 = state.T_geom_3;
static Eigen::MatrixXd& T_offset_1 = state.T_offset_1;
static Eigen::MatrixXd& T_offset_2 = state.T_offset_2;
static Eigen::MatrixXd& T_offset_3 = state.T_offset_3;

// Additional state variables
static double t = 0.0;

// Geometry datatypes for visualization
struct Geom { const char* geomType; int valCount; double geomVal[3]; };
static const Geom L1_geom = { "box", 3, {4.2, 0.1, 0.2} };  // Link A (crank) - red
static const Geom L2_geom = { "box", 3, {4.2, 0.1, 0.2} };  // Link B (coupler) - blue
static const Geom L3_geom = { "box", 3, {4.2, 0.1, 0.2} };  // Link C (rocker) - yellow

// Visualization runtime state
struct VisualLinkSpec {
    const char* name;
    int shape;       // 0=box, 1=cylinder, 2=sphere
    double dims[3];
};

static bool visualization_enabled = true;
static std::unique_ptr<VisualizationClient> viz_client = nullptr;
static const VisualLinkSpec ROBOT_VISUAL_LINKS[] = {
    {"robot/link_1", 0, {4.2, 0.1, 0.2}},
    {"robot/link_2", 0, {4.2, 0.1, 0.2}},
    {"robot/link_3", 0, {4.2, 0.1, 0.2}}
};

// STANDALONE_VISUALISATION MODE: World mapping for gravity synchronization
world_mapping_t w_mapping = {
    .g = {0.0, 0.0, -9.81}
};

#pragma endregion state

// ═══════════════════════════════════════════════════════════════════════════
// FUNCTION FORWARD DECLARATIONS
// ═══════════════════════════════════════════════════════════════════════════
Eigen::MatrixXd Identity(int n);
Eigen::MatrixXd skewSymmetric(Eigen::VectorXd v);
Eigen::MatrixXd RotY(double angle);
Eigen::MatrixXd makeTransform(const Eigen::Matrix3d& R, const Eigen::Vector3d& p);
bool solveLoopClosure(double qA, double& qB, double& qC);
Eigen::Matrix3d computeMassMatrix(const Eigen::Vector3d& q);
Eigen::Vector3d computeBiasForces(const Eigen::Vector3d& q, const Eigen::Vector3d& dq);
Eigen::Matrix<double, 2, 3> computeConstraintJacobian(const Eigen::Vector3d& q);
Eigen::Vector2d computeConstraintUprime(const Eigen::Vector3d& q, const Eigen::Vector3d& dq);
Eigen::Vector2d computeConstraintResidual(const Eigen::Vector3d& q);
void projectConstraints(Eigen::Vector3d& q, Eigen::Vector3d& dq);

void initVisualization();
void updateRobotVisualization();

// ═══════════════════════════════════════════════════════════════════════════
// PROCEDURES (SolutionDSL: procedures { ... })
// ═══════════════════════════════════════════════════════════════════════════
#pragma region procedures

void T_from_RotY(double angle, const Eigen::Vector3d& position, Eigen::MatrixXd& result) {
    double c = std::cos(angle);
    double s = std::sin(angle);
    result.setIdentity();
    result(0, 0) = c;
    result(0, 2) = s;
    result(2, 0) = -s;
    result(2, 2) = c;
    result(0, 3) = position(0);
    result(1, 3) = position(1);
    result(2, 3) = position(2);
}

#pragma endregion procedures

// ═══════════════════════════════════════════════════════════════════════════
// FUNCTIONS (SolutionDSL: functions { ... })
// ═══════════════════════════════════════════════════════════════════════════
#pragma region functions

Eigen::MatrixXd Identity(int n) {
    return Eigen::MatrixXd::Identity(n, n);
}

Eigen::MatrixXd skewSymmetric(Eigen::VectorXd v) {
    Eigen::MatrixXd result = Eigen::MatrixXd::Zero(3, 3);
    result(0, 0) = 0;
    result(0, 1) = -v(2);
    result(0, 2) = v(1);
    result(1, 0) = v(2);
    result(1, 1) = 0;
    result(1, 2) = -v(0);
    result(2, 0) = -v(1);
    result(2, 1) = v(0);
    result(2, 2) = 0;
    return result;
}

Eigen::MatrixXd RotY(double angle) {
    Eigen::MatrixXd R = Eigen::MatrixXd::Identity(3, 3);
    double c = std::cos(angle);
    double s = std::sin(angle);
    R(0, 0) = c;
    R(0, 2) = s;
    R(2, 0) = -s;
    R(2, 2) = c;
    return R;
}

Eigen::MatrixXd makeTransform(const Eigen::Matrix3d& R, const Eigen::Vector3d& p) {
    Eigen::MatrixXd T = Eigen::MatrixXd::Identity(4, 4);
    T.block<3, 3>(0, 0) = R;
    T.block<3, 1>(0, 3) = p;
    return T;
}

// Solve for qB and qC given qA using loop closure constraint
// Uses circle-circle intersection to find joint BC position
bool solveLoopClosure(double qA, double& qB, double& qC) {
    double L = state.link_length;
    double d = state.ground_length;

    // Position of joint AB (end of link A, pivot of link B)
    double xAB = L * std::cos(qA);
    double zAB = -L * std::sin(qA);

    // Position of pivot C (world frame)
    double xWC = d;
    double zWC = 0.0;

    // Distance from joint AB to pivot WC
    double dx = xAB - xWC;
    double dz = zAB - zWC;
    double dist = std::sqrt(dx * dx + dz * dz);

    // Check if mechanism can close
    if (dist > 2 * L - 0.001 || dist < 0.001) {
        return false;
    }

    // Find joint BC using circle-circle intersection
    double midX = (xAB + xWC) / 2.0;
    double midZ = (zAB + zWC) / 2.0;
    double halfDist = dist / 2.0;
    double h = std::sqrt(L * L - halfDist * halfDist);

    // Unit vector perpendicular to AB-WC line
    double perpX = -dz / dist;
    double perpZ = dx / dist;

    // Pick "elbow up" solution
    double xBC = midX + h * perpX;
    double zBC = midZ + h * perpZ;

    // Compute qB: link B goes from joint AB to joint BC
    double vBx = xBC - xAB;
    double vBz = zBC - zAB;
    double qB_abs = std::atan2(-vBz, vBx);
    qB = qB_abs - qA;

    // Compute qC: link C goes from pivot WC to joint BC
    double vCx = xBC - xWC;
    double vCz = zBC - zWC;
    qC = std::atan2(-vCz, vCx);

    // Normalize angles
    while (qB > M_PI) qB -= 2 * M_PI;
    while (qB < -M_PI) qB += 2 * M_PI;
    while (qC > M_PI) qC -= 2 * M_PI;
    while (qC < -M_PI) qC += 2 * M_PI;

    return true;
}

Eigen::Matrix3d computeMassMatrix(const Eigen::Vector3d& q) {
    const double L = state.link_length;
    const double m = state.link_mass;
    const double I = state.link_inertia_yy;

    const double qA = q(0);
    const double qB = q(1);
    const double qC = q(2);

    const double sA = std::sin(qA);
    const double cA = std::cos(qA);
    const double sAB = std::sin(qA + qB);
    const double cAB = std::cos(qA + qB);
    const double sC = std::sin(qC);
    const double cC = std::cos(qC);

    Eigen::Matrix<double, 2, 3> J_A;
    J_A << -0.5 * L * sA, 0.0, 0.0,
           -0.5 * L * cA, 0.0, 0.0;

    Eigen::Matrix<double, 2, 3> J_B;
    J_B << -L * sA - 0.5 * L * sAB, -0.5 * L * sAB, 0.0,
           -L * cA - 0.5 * L * cAB, -0.5 * L * cAB, 0.0;

    Eigen::Matrix<double, 2, 3> J_C;
    J_C << 0.0, 0.0, -0.5 * L * sC,
           0.0, 0.0, -0.5 * L * cC;

    Eigen::Matrix3d M = m * (J_A.transpose() * J_A + J_B.transpose() * J_B + J_C.transpose() * J_C);

    const Eigen::Vector3d Jw_A(1.0, 0.0, 0.0);
    const Eigen::Vector3d Jw_B(1.0, 1.0, 0.0);
    const Eigen::Vector3d Jw_C(0.0, 0.0, 1.0);

    M += I * (Jw_A * Jw_A.transpose() + Jw_B * Jw_B.transpose() + Jw_C * Jw_C.transpose());

    return M;
}

Eigen::Vector3d computeBiasForces(const Eigen::Vector3d& q, const Eigen::Vector3d& dq) {
    const double L = state.link_length;
    const double m = state.link_mass;

    const double qA = q(0);
    const double qB = q(1);
    const double qC = q(2);

    const double sA = std::sin(qA);
    const double cA = std::cos(qA);
    const double sAB = std::sin(qA + qB);
    const double cAB = std::cos(qA + qB);
    const double sC = std::sin(qC);
    const double cC = std::cos(qC);

    Eigen::Matrix<double, 2, 3> J_A;
    J_A << -0.5 * L * sA, 0.0, 0.0,
           -0.5 * L * cA, 0.0, 0.0;

    Eigen::Matrix<double, 2, 3> J_B;
    J_B << -L * sA - 0.5 * L * sAB, -0.5 * L * sAB, 0.0,
           -L * cA - 0.5 * L * cAB, -0.5 * L * cAB, 0.0;

    Eigen::Matrix<double, 2, 3> J_C;
    J_C << 0.0, 0.0, -0.5 * L * sC,
           0.0, 0.0, -0.5 * L * cC;

    const Eigen::Vector2d g_vec(0.0, 9.81);
    Eigen::Vector3d gravity = J_A.transpose() * (m * g_vec)
        + J_B.transpose() * (m * g_vec)
        + J_C.transpose() * (m * g_vec);

    const double eps = 1e-6;
    std::array<Eigen::Matrix3d, 3> dM;
    for (int k = 0; k < 3; ++k) {
        Eigen::Vector3d q_plus = q;
        Eigen::Vector3d q_minus = q;
        q_plus(k) += eps;
        q_minus(k) -= eps;
        dM[k] = (computeMassMatrix(q_plus) - computeMassMatrix(q_minus)) / (2.0 * eps);
    }

    Eigen::Vector3d coriolis = Eigen::Vector3d::Zero();
    for (int i = 0; i < 3; ++i) {
        for (int j = 0; j < 3; ++j) {
            for (int k = 0; k < 3; ++k) {
                const double c_ijk = 0.5 * (dM[k](i, j) + dM[j](i, k) - dM[i](j, k));
                coriolis(i) += c_ijk * dq(j) * dq(k);
            }
        }
    }

    return coriolis + gravity;
}

Eigen::Matrix<double, 2, 3> computeConstraintJacobian(const Eigen::Vector3d& q) {
    const double L = state.link_length;

    const double qA = q(0);
    const double qB = q(1);
    const double qC = q(2);

    const double sA = std::sin(qA);
    const double cA = std::cos(qA);
    const double sAB = std::sin(qA + qB);
    const double cAB = std::cos(qA + qB);
    const double sC = std::sin(qC);
    const double cC = std::cos(qC);

    Eigen::Matrix<double, 2, 3> G_c;
    G_c(0, 0) = -L * sA - L * sAB;
    G_c(0, 1) = -L * sAB;
    G_c(0, 2) = L * sC;

    G_c(1, 0) = -L * cA - L * cAB;
    G_c(1, 1) = -L * cAB;
    G_c(1, 2) = L * cC;

    return G_c;
}

Eigen::Vector2d computeConstraintUprime(const Eigen::Vector3d& q, const Eigen::Vector3d& dq) {
    const double L = state.link_length;

    const double qA = q(0);
    const double qB = q(1);
    const double qC = q(2);

    const double dA = dq(0);
    const double dB = dq(1);
    const double dC = dq(2);
    const double dAB = dA + dB;

    const double cA = std::cos(qA);
    const double sA = std::sin(qA);
    const double cAB = std::cos(qA + qB);
    const double sAB = std::sin(qA + qB);
    const double cC = std::cos(qC);
    const double sC = std::sin(qC);

    Eigen::Vector2d Uprime;
    Uprime(0) = L * cA * dA * dA + L * cAB * dAB * dAB - L * cC * dC * dC;
    Uprime(1) = -L * sA * dA * dA - L * sAB * dAB * dAB + L * sC * dC * dC;

    return Uprime;
}

Eigen::Vector2d computeConstraintResidual(const Eigen::Vector3d& q) {
    const double L = state.link_length;
    const double d = state.ground_length;

    const double qA = q(0);
    const double qB = q(1);
    const double qC = q(2);

    Eigen::Vector2d g;
    g(0) = L * std::cos(qA) + L * std::cos(qA + qB) - d - L * std::cos(qC);
    g(1) = -L * std::sin(qA) - L * std::sin(qA + qB) + L * std::sin(qC);
    return g;
}

void projectConstraints(Eigen::Vector3d& q, Eigen::Vector3d& dq) {
    const int max_iters = 5;
    const double tol = 1e-12;

    // Position projection via Gauss-Newton on g(q) = 0
    for (int i = 0; i < max_iters; ++i) {
        const Eigen::Vector2d g = computeConstraintResidual(q);
        if (g.norm() < tol) {
            break;
        }
        const Eigen::Matrix<double, 2, 3> G = computeConstraintJacobian(q);
        const Eigen::Matrix2d S = G * G.transpose();
        const Eigen::Vector2d delta = S.fullPivLu().solve(-g);
        q += G.transpose() * delta;
    }

    // Velocity projection to enforce G(q) * dq = 0
    const Eigen::Matrix<double, 2, 3> G = computeConstraintJacobian(q);
    const Eigen::Matrix2d S = G * G.transpose();
    const Eigen::Vector2d vres = G * dq;
    const Eigen::Vector2d corr = S.fullPivLu().solve(vres);
    dq -= G.transpose() * corr;
}

#pragma endregion functions

// ═══════════════════════════════════════════════════════════════════════════
// INITIALIZATION (SolutionDSL: state { ... } with initial values)
// ═══════════════════════════════════════════════════════════════════════════
#pragma region initialization

void initGlobals() {
    // Number of links
    n = 3;

    // Physical parameters (Drake four_bar model)
    state.link_length = 4.0;
    state.link_mass = 20.0;
    state.ground_length = 2.0;
    state.link_inertia_yy = state.link_mass * state.link_length * state.link_length / 12.0;

    // Timestep
    dt = 0.001;

    // Initialize link transforms (4x4)
    B_1.resize(4, 4);
    B_1 << 1.0, 0.0, 0.0, 0.0,
           0.0, 1.0, 0.0, 0.0,
           0.0, 0.0, 1.0, 0.0,
           0, 0, 0, 1;
    B_2.resize(4, 4);
    B_2 << 1.0, 0.0, 0.0, 0.0,
           0.0, 1.0, 0.0, 0.0,
           0.0, 0.0, 1.0, 0.0,
           0, 0, 0, 1;
    B_3.resize(4, 4);
    B_3 << 1.0, 0.0, 0.0, state.ground_length,
           0.0, 1.0, 0.0, 0.0,
           0.0, 0.0, 1.0, 0.0,
           0, 0, 0, 1;

    // Initialize joint angles (theta)
    // theta(0) = qA (crank), theta(1) = qB (coupler relative), theta(2) = qC (rocker)
    theta.resize(3);
    const double qA_drake = std::atan2(std::sqrt(15.0), 1.0);
    double qA_init = M_PI - qA_drake;  // Map Drake's frame to this reference frame
    double qB_init = 0.0;
    double qC_init = 0.0;
    if (!solveLoopClosure(qA_init, qB_init, qC_init)) {
        std::cerr << "[FourBar] Loop closure failed at init; using zero angles." << std::endl;
        qB_init = 0.0;
        qC_init = 0.0;
    }
    theta << qA_init, qB_init, qC_init;

    // Initialize velocities
    const double dqA_init = 3.0;  // Drake four_bar initial angular rate
    d_theta = Eigen::VectorXd::Zero(3);
    {
        const Eigen::Vector3d q_init(theta);
        const Eigen::Matrix<double, 2, 3> G_c_init = computeConstraintJacobian(q_init);
        Eigen::Matrix2d G_bc;
        G_bc << G_c_init(0, 1), G_c_init(0, 2),
                G_c_init(1, 1), G_c_init(1, 2);
        const Eigen::Vector2d rhs = -G_c_init.col(0) * dqA_init;
        const Eigen::Vector2d dq_bc = G_bc.fullPivLu().solve(rhs);
        d_theta << dqA_init, dq_bc(0), dq_bc(1);
    }
    dd_theta = Eigen::VectorXd::Zero(3);

    // Initialize bias forces
    C = Eigen::VectorXd::Zero(3);

    // Initialize applied torques (passive simulation)
    tau = Eigen::VectorXd::Zero(3);

    // Initialize damping
    tau_d = Eigen::VectorXd::Zero(3);
    damping = Eigen::MatrixXd::Zero(3, 3);

    // Initialize mass matrix (full 3-DOF formulation)
    M_mass = computeMassMatrix(theta);
    M_inv = M_mass.inverse();

    N = 1;  // Single DOF

    // Visualization offsets (geometric center is at L/2 along local X)
    T_offset_1.resize(4, 4);
    T_offset_1 << 1.0, 0.0, 0.0, state.link_length / 2.0,
                  0.0, 1.0, 0.0, 0.0,
                  0.0, 0.0, 1.0, 0.0,
                  0, 0, 0, 1;
    T_offset_2.resize(4, 4);
    T_offset_2 << 1.0, 0.0, 0.0, state.link_length / 2.0,
                  0.0, 1.0, 0.0, 0.0,
                  0.0, 0.0, 1.0, 0.0,
                  0, 0, 0, 1;
    T_offset_3.resize(4, 4);
    T_offset_3 << 1.0, 0.0, 0.0, state.link_length / 2.0,
                  0.0, 1.0, 0.0, 0.0,
                  0.0, 0.0, 1.0, 0.0,
                  0, 0, 0, 1;

    // Initialize T_geom
    T_geom_1.resize(4, 4);
    T_geom_1.setIdentity();
    T_geom_2.resize(4, 4);
    T_geom_2.setIdentity();
    T_geom_3.resize(4, 4);
    T_geom_3.setIdentity();

    // Build vectors
    B_k = std::vector<Eigen::MatrixXd>({ B_1, B_2, B_3 });
    T_geom = std::vector<Eigen::MatrixXd>({ T_geom_1, T_geom_2, T_geom_3 });
    T_offset = std::vector<Eigen::MatrixXd>({ T_offset_1, T_offset_2, T_offset_3 });

    std::cout << "[FourBar] Physics globals initialized" << std::endl;
    std::cout << "[FourBar] Initial configuration:" << std::endl;
    std::cout << "  qA = " << theta(0) * 180.0 / M_PI << " deg" << std::endl;
    std::cout << "  qB = " << theta(1) * 180.0 / M_PI << " deg" << std::endl;
    std::cout << "  qC = " << theta(2) * 180.0 / M_PI << " deg" << std::endl;
    std::cout << "  dqA = " << d_theta(0) << " rad/s" << std::endl;

    visualization_enabled = true;
}

#pragma endregion initialization

// ═══════════════════════════════════════════════════════════════════════════
// COMPUTATION (SolutionDSL: computation { ... })
// ═══════════════════════════════════════════════════════════════════════════
#pragma region computation

void physics_update_impl() {
    const double L = state.link_length;
    const double d = state.ground_length;

    Eigen::Vector3d q(theta);
    Eigen::Vector3d dq(d_theta);

    // Keep the state on the constraint manifold before dynamics evaluation.
    projectConstraints(q, dq);
    theta = q;
    d_theta = dq;

    // ─────────────────────────────────────────────────────────────────────────
    // Step 1: Compute mass matrix and bias forces (Coriolis + gravity)
    // ─────────────────────────────────────────────────────────────────────────
    M_mass = computeMassMatrix(q);
    M_inv = M_mass.inverse();
    C = computeBiasForces(q, dq);

    // ─────────────────────────────────────────────────────────────────────────
    // Step 2: Compute damping torque
    // ─────────────────────────────────────────────────────────────────────────
    tau_d = damping * d_theta;

    // ─────────────────────────────────────────────────────────────────────────
    // Step 3: Unconstrained acceleration
    // ─────────────────────────────────────────────────────────────────────────
    const Eigen::Vector3d dd_theta_0 = M_inv * (tau - C - tau_d);

    // ─────────────────────────────────────────────────────────────────────────
    // Step 4: Closed-chain constraints via Lagrange multipliers
    // ─────────────────────────────────────────────────────────────────────────
    const Eigen::Matrix<double, 2, 3> G_c = computeConstraintJacobian(q);
    const Eigen::Vector2d Uprime = computeConstraintUprime(q, dq);
    const Eigen::Matrix2d S = G_c * M_inv * G_c.transpose();
    const Eigen::Vector2d rhs = Uprime - (G_c * dd_theta_0);
    const Eigen::Vector2d lambda_c = S.fullPivLu().solve(rhs);

    const Eigen::Vector3d dd_theta_vec = dd_theta_0 + M_inv * G_c.transpose() * lambda_c;
    dd_theta = dd_theta_vec;

    // ─────────────────────────────────────────────────────────────────────────
    // Step 5: Integrate velocities
    // ─────────────────────────────────────────────────────────────────────────
    d_theta = d_theta + dt * dd_theta;

    // ─────────────────────────────────────────────────────────────────────────
    // Step 6: Integrate positions
    // ─────────────────────────────────────────────────────────────────────────
    theta = theta + dt * d_theta;

    // Project again after integration to avoid constraint drift.
    {
        Eigen::Vector3d q_proj(theta);
        Eigen::Vector3d dq_proj(d_theta);
        projectConstraints(q_proj, dq_proj);
        theta = q_proj;
        d_theta = dq_proj;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Step 7: Forward Kinematics - compute B_k transforms
    // ─────────────────────────────────────────────────────────────────────────
    {
        const double qA = theta(0);
        const double qB = theta(1);
        const double qC = theta(2);

        // Link A: pivot at world origin, rotates about Y
        const Eigen::Matrix3d R_A = RotY(qA).block<3, 3>(0, 0);
        const Eigen::Vector3d p_A(0, 0, 0);
        T_from_RotY(qA, p_A, B_1);
        B_k[0] = B_1;

        // Joint AB position (end of link A)
        const Eigen::Vector3d p_AB = R_A * Eigen::Vector3d(L, 0, 0);

        // Link B: pivot at joint AB, absolute rotation qA + qB
        const double qB_abs = qA + qB;
        T_from_RotY(qB_abs, p_AB, B_2);
        B_k[1] = B_2;

        // Link C: pivot at world position (d, 0, 0), rotates about Y
        const Eigen::Vector3d p_C(d, 0, 0);
        T_from_RotY(qC, p_C, B_3);
        B_k[2] = B_3;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Step 8: Update visualization transforms
    // ─────────────────────────────────────────────────────────────────────────
    {
        T_geom_1 = B_k[0] * T_offset[0];
        T_geom_2 = B_k[1] * T_offset[1];
        T_geom_3 = B_k[2] * T_offset[2];
        T_geom[0] = T_geom_1;
        T_geom[1] = T_geom_2;
        T_geom[2] = T_geom_3;
    }

    // Update time
    t += dt;

    // Update visualization
    if (visualization_enabled) {
        updateRobotVisualization();
    }
}

void physics_update() {
    // Initialize trajectory log on first call
    if (!traj_initialized) {
        traj_log.open("trajectory_fourbar.csv");
        traj_log << "time,theta0,theta1,theta2" << std::endl;
        traj_initialized = true;
    }

    // Run physics computation
    physics_update_impl();

    // Log trajectory data
    if (traj_initialized && traj_log.is_open()) {
        traj_log << std::fixed << std::setprecision(6) << t
                 << "," << theta(0) << "," << theta(1) << "," << theta(2)
                 << std::endl;
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
            viz_client->sendTransform(ROBOT_VISUAL_LINKS[idx].name, transform, false);
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
        std::cout << "[FourBar] Connected to visualization server" << std::endl;

        // Ground link (fixed) between pivots
        const int gray[3] = {160, 160, 160};
        double ground_dims[3] = {state.ground_length, 0.1, 0.2};
        viz_client->createObject("robot/link_0", 0, ground_dims, gray);
        Eigen::Matrix4d T_ground = Eigen::Matrix4d::Identity();
        T_ground(0, 3) = state.ground_length / 2.0;
        viz_client->sendTransform("robot/link_0", T_ground, false);

        // Create link objects with Drake colors: A=red, B=blue, C=yellow
        const int red[3] = {255, 0, 0};
        const int blue[3] = {0, 0, 255};
        const int yellow[3] = {255, 255, 0};
        const int* colors[3] = {red, blue, yellow};

        auto shape_from = [](const Geom& g) -> int {
            const char c = g.geomType[0];
            return (c == 'b' ? 0 : (c == 'c' ? 1 : (c == 's' ? 2 : 0)));
        };

        const Geom geoms[] = { L1_geom, L2_geom, L3_geom };
        const int count = static_cast<int>(std::min<std::size_t>(B_k.size(), 3));

        for (int k = 0; k < count; ++k) {
            const Geom& g = geoms[k];
            const int shape = shape_from(g);
            double dims[3] = {0.0, 0.0, 0.0};
            const int m = std::min(g.valCount, 3);
            for (int i = 0; i < m; ++i) dims[i] = g.geomVal[i];
            const char* name = ROBOT_VISUAL_LINKS[k].name;
            viz_client->createObject(name, shape, dims, colors[k]);
        }

        // Create pivot point markers (small green spheres)
        const int green[3] = {0, 255, 0};
        double pivot_dims[3] = {0.15, 0.0, 0.0};

        viz_client->createObject("robot/pivot_WA", 2, pivot_dims, green);
        viz_client->createObject("robot/pivot_WC", 2, pivot_dims, green);

        // Set pivot transforms
        Eigen::Matrix4d T_pivot_WA = Eigen::Matrix4d::Identity();
        viz_client->sendTransform("robot/pivot_WA", T_pivot_WA, false);

        Eigen::Matrix4d T_pivot_WC = Eigen::Matrix4d::Identity();
        T_pivot_WC(0, 3) = state.ground_length;
        viz_client->sendTransform("robot/pivot_WC", T_pivot_WC, false);

        updateRobotVisualization();
    } else {
        std::cerr << "[FourBar] Failed to connect to visualization server" << std::endl;
        viz_client.reset();
        visualization_enabled = false;
    }
}

#pragma endregion visualization

// ═══════════════════════════════════════════════════════════════════════════
// API (STANDALONE_VISUALISATION Mode)
// ═══════════════════════════════════════════════════════════════════════════
#pragma region api

extern "C" {
    void platform1_initialise(void) {
        initGlobals();
        initVisualization();
        std::cout << "[FourBar] Platform1 physics engine initialized (STANDALONE)" << std::endl;
    }

    void platform1_step(void) {
        physics_update();
    }

    double platform1_get_time(void) {
        return t;
    }
}

#pragma endregion api
