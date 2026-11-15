// RobCoGen forward dynamics, generated from robcogen/acrobot.kindsl (see README.md).
#include "declarations.h"
#include "transforms.h"
#include "inertia_properties.h"
#include "forward_dynamics.h"

#include "acrobot_benchmark.h"

struct RobcogenAcrobot {
    Acrobot::rcg::InertiaProperties inertia;
    Acrobot::rcg::MotionTransforms transforms;
    Acrobot::rcg::ForwardDynamics dynamics;
    Acrobot::rcg::JointState q, v, tau, a;

    RobcogenAcrobot() : dynamics(inertia, transforms) {}

    acrobot::Joints acceleration(const acrobot::Joints& position, const acrobot::Joints& rate) {
        q = position;
        v = rate;
        tau = -acrobot::DAMPING * rate;
        dynamics.fd(a, q, v, tau);
        return acrobot::Joints(a(0), a(1));
    }
};

int main(int argc, char** argv) {
    RobcogenAcrobot engine;
    return acrobot::run(argc, argv, "robcogen", engine);
}
