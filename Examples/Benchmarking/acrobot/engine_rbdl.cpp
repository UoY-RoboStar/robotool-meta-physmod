// RBDL forward dynamics.
#include <rbdl/rbdl.h>

#include "acrobot_benchmark.h"

using namespace RigidBodyDynamics;
using namespace RigidBodyDynamics::Math;

struct RbdlAcrobot {
    Model model;
    VectorNd q = VectorNd::Zero(2), v = VectorNd::Zero(2), tau = VectorNd::Zero(2), a = VectorNd::Zero(2);

    RbdlAcrobot() {
        model.gravity = Vector3d(0.0, 0.0, -acrobot::GRAVITY);
        Matrix3d inertia1 = Matrix3d::Zero(), inertia2 = Matrix3d::Zero();
        inertia1.diagonal() << acrobot::INERTIA1[0], acrobot::INERTIA1[1], acrobot::INERTIA1[2];
        inertia2.diagonal() << acrobot::INERTIA2[0], acrobot::INERTIA2[1], acrobot::INERTIA2[2];
        Body link1(acrobot::MASS, Vector3d(0.0, 0.0, -acrobot::COM1), inertia1);
        Body link2(acrobot::MASS, Vector3d(0.0, 0.0, -acrobot::COM2), inertia2);
        Joint hinge(JointTypeRevolute, Vector3d(1.0, 0.0, 0.0));
        unsigned int shoulder = model.AddBody(0, Xtrans(Vector3d(0.0, 0.0, 0.0)), hinge, link1);
        model.AddBody(shoulder, Xtrans(Vector3d(0.0, 0.0, -acrobot::LINK1_LENGTH)), hinge, link2);
    }

    acrobot::Joints acceleration(const acrobot::Joints& position, const acrobot::Joints& rate) {
        q = position;
        v = rate;
        tau = -acrobot::DAMPING * rate;
        ForwardDynamics(model, q, v, tau, a);
        return acrobot::Joints(a[0], a[1]);
    }
};

int main(int argc, char** argv) {
    RbdlAcrobot engine;
    return acrobot::run(argc, argv, "rbdl", engine);
}
