#include "interfaces.hpp"
#include "world_mapping.h"

namespace {
constexpr double kRadToDeg = 180.0 / 3.141592653589793;
class PlatformWorldMappingImpl final : public IPlatformWorldMapping {
public:
    void initialise() override {}

    void computeSensorReadings(
        const IWorldState& /*world_state*/,
        const IPlatformState& /*platform_state*/,
        sensor_data_t& out) override {

        double distance = 0.0;
        double angle = 0.0;
        world_get_closest_obstacle(&distance, &angle);
        const double angle_deg = angle * kRadToDeg;

        double lv = 0.0;
        double av = 0.0;
        world_get_robot_velocity(&lv, &av);

        out.World.gravity_world[0] = 0.0;
        out.World.gravity_world[1] = 0.0;
        out.World.gravity_world[2] = -9.81;

        out.Turtlebot3.Burger.BaseLink.TBLidar.trueDistance = distance;
        out.Turtlebot3.Burger.BaseLink.TBLidar.measuredDistance = distance;
        out.Turtlebot3.Burger.BaseLink.TBLidar.angle_min = angle_deg;
        out.Turtlebot3.Burger.BaseLink.TBLidar.closestDistance = distance;
        out.Turtlebot3.Burger.BaseLink.TBLidar.closestAngle = angle_deg;
        out.Turtlebot3.Burger.BaseLink.TBLidar.scan.range_min = distance;
        out.Turtlebot3.Burger.BaseLink.TBLidar.scan.angle_min = angle_deg;
        out.Turtlebot3.Burger.BaseLink.TBIMU.currentLV = lv;
        out.Turtlebot3.Burger.BaseLink.TBIMU.currentAV = av;
        out.time = world_get_time();

        w_mapping.World.gravity_world[0] = out.World.gravity_world[0];
        w_mapping.World.gravity_world[1] = out.World.gravity_world[1];
        w_mapping.World.gravity_world[2] = out.World.gravity_world[2];
        w_mapping.Turtlebot3.Burger.BaseLink.TBLidar.trueDistance = distance;
        w_mapping.Turtlebot3.Burger.BaseLink.TBLidar.measuredDistance = distance;
        w_mapping.Turtlebot3.Burger.BaseLink.TBLidar.angle_min = angle_deg;
        w_mapping.Turtlebot3.Burger.BaseLink.TBLidar.closestDistance = distance;
        w_mapping.Turtlebot3.Burger.BaseLink.TBLidar.closestAngle = angle_deg;
        w_mapping.Turtlebot3.Burger.BaseLink.TBLidar.scan.range_min = distance;
        w_mapping.Turtlebot3.Burger.BaseLink.TBLidar.scan.angle_min = angle_deg;
        w_mapping.Turtlebot3.Burger.BaseLink.TBIMU.currentLV = lv;
        w_mapping.Turtlebot3.Burger.BaseLink.TBIMU.currentAV = av;
    }

    void computeWorldInputs(
        const IPlatformState& /*platform_state*/,
        IWorldState& /*world_state*/) override {
        // World dynamics are driven directly by world_step in the orchestrator.
    }
};

PlatformWorldMappingImpl platform_world_mapping_instance;
} // namespace

IPlatformWorldMapping* get_platform_world_mapping() {
    return &platform_world_mapping_instance;
}
