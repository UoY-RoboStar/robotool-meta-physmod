#include "interfaces.hpp"
#include "world_mapping.h"
#include "visualization_client.h"

#include <Eigen/Dense>
#include <algorithm>
#include <cmath>
#include <iostream>
#include <limits>
#include <memory>
#include <vector>

namespace {
struct Obstacle {
    const char* name;
    int shape;
    double x;
    double y;
    double yaw;
    double size_x;
    double size_y;
    double size_z;
    double radius;
    double length;
    int color[3];
};

struct WorldStateData {
    double time = 0.0;
    double robot_x = -3.5;
    double robot_y = 0.0;
    double robot_yaw = 0.0;
    double linear_vel = 0.0;
    double angular_vel = 0.0;
    std::vector<Obstacle> obstacles;
};

WorldStateData world_state;
constexpr double kPi = 3.141592653589793;
constexpr int kShapeBox = 0;
constexpr int kShapeCylinder = 1;

double clamp_value(double v, double lo, double hi) {
    return std::max(lo, std::min(v, hi));
}

double wrap_angle(double angle) {
    while (angle > kPi) {
        angle -= 2.0 * kPi;
    }
    while (angle < -kPi) {
        angle += 2.0 * kPi;
    }
    return angle;
}
} // namespace

static bool world_visualization_enabled = false;
static std::unique_ptr<VisualizationClient> world_viz_client = nullptr;

static void world_enable_visualization(bool enable);
static void world_update_visualization();

void world_initialize(void) {
    world_state.time = 0.0;
    world_state.robot_x = -3.5;
    world_state.robot_y = 0.0;
    world_state.robot_yaw = 0.0;
    world_state.linear_vel = 0.0;
    world_state.angular_vel = 0.0;

    world_state.obstacles = {
        {"world/south_wall", kShapeBox, -4.05, 0.0, 1.5708, 6.0, 0.15, 0.5, 0.0, 0.0, {0, 0, 0}},
        {"world/west_wall",  kShapeBox, -0.5,  3.05, 0.0,    7.25, 0.15, 0.5, 0.0, 0.0, {0, 0, 0}},
        {"world/north_wall", kShapeBox,  3.05, 0.0, -1.5708, 6.0, 0.15, 0.5, 0.0, 0.0, {0, 0, 0}},
        {"world/east_wall",  kShapeBox, -0.5, -3.05, 3.14159, 7.25, 0.15, 0.5, 0.0, 0.0, {0, 0, 0}},
        {"world/box1", kShapeBox, -1.0, 1.0, 0.785398, 0.5, 0.5, 0.5, 0.0, 0.0, {255, 255, 255}},
        {"world/box2", kShapeBox,  1.0, -1.0, 0.0, 0.5, 0.5, 0.5, 0.0, 0.0, {255, 255, 255}},
        {"world/cylinder1", kShapeCylinder, 1.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.25, 0.5, {255, 255, 255}},
        {"world/cylinder2", kShapeCylinder, -1.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.25, 0.5, {255, 255, 255}},
    };

    world_enable_visualization(true);
}

void world_step(double dt, double linear_vel, double angular_vel) {
    world_state.linear_vel = linear_vel;
    world_state.angular_vel = angular_vel;

    world_state.robot_x += linear_vel * std::cos(world_state.robot_yaw) * dt;
    world_state.robot_y += linear_vel * std::sin(world_state.robot_yaw) * dt;
    world_state.robot_yaw = wrap_angle(world_state.robot_yaw + angular_vel * dt);
    world_state.time += dt;
}

void world_get_closest_obstacle(double* distance, double* angle) {
    double best_distance = std::numeric_limits<double>::infinity();
    double best_angle = 0.0;

    for (const auto& obs : world_state.obstacles) {
        if (obs.shape == kShapeCylinder) {
            const double dx = obs.x - world_state.robot_x;
            const double dy = obs.y - world_state.robot_y;
            const double center_dist = std::sqrt(dx * dx + dy * dy);
            const double surface_dist = center_dist - obs.radius;
            const double obs_angle = wrap_angle(std::atan2(dy, dx) - world_state.robot_yaw);
            if (surface_dist < best_distance) {
                best_distance = surface_dist;
                best_angle = obs_angle;
            }
            continue;
        }

        const double dx = world_state.robot_x - obs.x;
        const double dy = world_state.robot_y - obs.y;
        const double c = std::cos(-obs.yaw);
        const double s = std::sin(-obs.yaw);
        const double lx = c * dx - s * dy;
        const double ly = s * dx + c * dy;

        const double hx = obs.size_x * 0.5;
        const double hy = obs.size_y * 0.5;

        double clamped_x = clamp_value(lx, -hx, hx);
        double clamped_y = clamp_value(ly, -hy, hy);
        const bool inside = (std::abs(lx) <= hx) && (std::abs(ly) <= hy);
        if (inside) {
            const double dist_x = hx - std::abs(lx);
            const double dist_y = hy - std::abs(ly);
            if (dist_x < dist_y) {
                clamped_x = (lx >= 0.0) ? hx : -hx;
                clamped_y = ly;
            } else {
                clamped_x = lx;
                clamped_y = (ly >= 0.0) ? hy : -hy;
            }
        }

        const double local_dx = lx - clamped_x;
        const double local_dy = ly - clamped_y;
        const double surface_dist = std::sqrt(local_dx * local_dx + local_dy * local_dy);

        const double wc = std::cos(obs.yaw);
        const double ws = std::sin(obs.yaw);
        const double closest_x = obs.x + (wc * clamped_x - ws * clamped_y);
        const double closest_y = obs.y + (ws * clamped_x + wc * clamped_y);
        const double obs_angle = wrap_angle(std::atan2(closest_y - world_state.robot_y,
                                                       closest_x - world_state.robot_x)
                                            - world_state.robot_yaw);

        if (surface_dist < best_distance) {
            best_distance = surface_dist;
            best_angle = obs_angle;
        }
    }

    if (!std::isfinite(best_distance) || best_distance < 0.0) {
        best_distance = 0.0;
        best_angle = 0.0;
    }

    if (distance) {
        *distance = best_distance;
    }
    if (angle) {
        *angle = best_angle;
    }
}

void world_get_robot_pose(double* x, double* y, double* yaw) {
    if (x) {
        *x = world_state.robot_x;
    }
    if (y) {
        *y = world_state.robot_y;
    }
    if (yaw) {
        *yaw = world_state.robot_yaw;
    }
}

void world_get_robot_velocity(double* linear_vel, double* angular_vel) {
    if (linear_vel) {
        *linear_vel = world_state.linear_vel;
    }
    if (angular_vel) {
        *angular_vel = world_state.angular_vel;
    }
}

double world_get_time(void) {
    return world_state.time;
}

static void world_enable_visualization(bool enable) {
    world_visualization_enabled = enable;
    if (enable && !world_viz_client) {
        world_viz_client = std::make_unique<VisualizationClient>();
        if (world_viz_client->connect("127.0.0.1", 9999)) {
            std::cout << "[World] Connected to visualization server" << std::endl;
            for (const auto& obs : world_state.obstacles) {
                double dims[3] = {0.0, 0.0, 0.0};
                if (obs.shape == kShapeCylinder) {
                    dims[0] = obs.radius;
                    dims[1] = obs.length;
                } else {
                    dims[0] = obs.size_x;
                    dims[1] = obs.size_y;
                    dims[2] = obs.size_z;
                }
                world_viz_client->createObject(obs.name, obs.shape, dims, obs.color);
            }
            world_update_visualization();
        } else {
            std::cerr << "[World] Failed to connect to visualization server" << std::endl;
            world_viz_client.reset();
            world_visualization_enabled = false;
        }
    } else if (!enable && world_viz_client) {
        world_viz_client.reset();
    }
}

static void world_update_visualization() {
    if (!world_visualization_enabled || !world_viz_client || !world_viz_client->isConnected()) {
        return;
    }

    for (const auto& obs : world_state.obstacles) {
        Eigen::Matrix4d transform = Eigen::Matrix4d::Identity();
        const double c = std::cos(obs.yaw);
        const double s = std::sin(obs.yaw);
        transform(0, 0) = c;
        transform(0, 1) = -s;
        transform(1, 0) = s;
        transform(1, 1) = c;
        transform(0, 3) = obs.x;
        transform(1, 3) = obs.y;
        const double height = (obs.shape == kShapeCylinder) ? obs.length : obs.size_z;
        transform(2, 3) = height * 0.5;
        world_viz_client->sendTransform(obs.name, transform, true);
    }
}

namespace world1 {
struct State : public IWorldState {
    WorldStateData* data;
    explicit State(WorldStateData* state) : data(state) {}
};
} // namespace world1

class WorldEngineImpl : public IWorldEngine {
    world1::State state_wrapper;

public:
    WorldEngineImpl() : state_wrapper(&world_state) {}

    void initialise() override {
        world_initialize();
    }

    void update() override {
        world_update_visualization();
    }

    double getTime() const override {
        return world_get_time();
    }

    IWorldState& state() override {
        return state_wrapper;
    }

    const IWorldState& state() const override {
        return state_wrapper;
    }
};

namespace {
WorldEngineImpl world_engine_instance;
}

IWorldEngine* get_world_engine() {
    return &world_engine_instance;
}
