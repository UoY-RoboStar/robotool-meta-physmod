// The generated SKO engine, included unchanged (see README.md).
#include "platform1_engine.cpp"

#include "acrobot_benchmark.h"

struct SkoAcrobot {
    SkoAcrobot() {
        initGlobals();
        // With dt = 0, physics_update() gives the acceleration without advancing the state.
        dt = 0.0;
    }

    acrobot::Joints acceleration(const acrobot::Joints& position, const acrobot::Joints& rate) {
        // The generated engine numbers joints from the tip: index 0 is the elbow.
        theta[0] = position[1];
        theta[1] = position[0];
        d_theta[0] = rate[1];
        d_theta[1] = rate[0];
        physics_update();
        return acrobot::Joints(dd_theta[1], dd_theta[0]);
    }
};

int main(int argc, char** argv) {
    SkoAcrobot engine;
    return acrobot::run(argc, argv, "sko", engine);
}
