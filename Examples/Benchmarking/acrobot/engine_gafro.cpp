// GAFRO forward dynamics on gafro/acrobot.yaml.
#include <memory>
#include <string>

#include <gafro/gafro.hpp>
#include <gafro_robot_descriptions/serialization/SystemSerialization.hpp>

#include "acrobot_benchmark.h"

struct GafroAcrobot {
    std::unique_ptr<gafro::Manipulator<double, 2>> manipulator;

    explicit GafroAcrobot(const std::string& description) {
        gafro::SystemSerialization serialization(description);
        gafro::System<double> system = serialization.load();
        manipulator = std::make_unique<gafro::Manipulator<double, 2>>(std::move(system), "elbow");
    }

    acrobot::Joints acceleration(const acrobot::Joints& position, const acrobot::Joints& rate) {
        const acrobot::Joints tau = -acrobot::DAMPING * rate;
        return manipulator->getJointAccelerations(position, rate, tau);
    }
};

int main(int argc, char** argv) {
    // ACROBOT_YAML is defined in CMakeLists.txt.
    GafroAcrobot engine(ACROBOT_YAML);
    return acrobot::run(argc, argv, "gafro", engine);
}
