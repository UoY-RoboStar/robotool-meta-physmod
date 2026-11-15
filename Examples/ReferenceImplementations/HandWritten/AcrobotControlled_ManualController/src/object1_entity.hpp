#ifndef OBJECT1_ENTITY_HPP
#define OBJECT1_ENTITY_HPP

#include "interfaces.hpp"
#include <Eigen/Dense>

/**
 * Object1: A passive entity (e.g., block, ball).
 * 
 * Objects are entities that:
 *   - Have state (position, velocity, geometry, mass)
 *   - Do NOT have autonomous dynamics (no actuators, no self-motion)
 *   - Are affected by: gravity, constraints, interactions with active entities
 * 
 * Object state is defined in world frame.
 * World engine references this entity without duplicating its parameters.
 */
namespace object1 {

/**
 * Object1 state (defined in world frame).
 */
struct State : IEntityState {
    // Kinematic state (world frame)
    Eigen::Vector3d position;      // Position in world frame
    Eigen::Vector3d velocity;      // Linear velocity
    Eigen::Vector3d angular_velocity;  // Angular velocity
    
    // Geometric properties
    Eigen::Vector3d dimensions;    // Width, height, depth (for box)
    
    // Physical properties
    double mass;
    Eigen::Matrix3d inertia;       // Inertia tensor
    
    // Interaction state
    bool is_grasped;               // Is object being held by gripper?
    int grasped_by_entity;         // ID of entity holding this (-1 if none)
    
    // Constructor with default values
    State() 
        : position(Eigen::Vector3d::Zero())
        , velocity(Eigen::Vector3d::Zero())
        , angular_velocity(Eigen::Vector3d::Zero())
        , dimensions(0.1, 0.1, 0.1)  // 10cm cube by default
        , mass(0.5)                   // 0.5 kg
        , inertia(Eigen::Matrix3d::Identity() * 0.001)  // Simple inertia
        , is_grasped(false)
        , grasped_by_entity(-1)
    {}
};

/**
 * Object1 entity - passive object with no autonomous dynamics.
 *
 * Objects are simple entities that:
 *   - Have state (position, velocity, mass, geometry)
 *   - Have NO engine (no autonomous dynamics)
 *   - Are affected by world (gravity) and platform interactions (grasping)
 */
class Object1Entity : public Entity {
public:
    State object_state;

    Object1Entity()
        : Entity("Object1", 2)  // Entity ID=2 (Platform=0, Gripper=1, Object=2, Goal=3)
    {}

    void initialise() {
        // Initialize with specific scenario values
        object_state.position = Eigen::Vector3d(0, 4.7511, 0.075);  // Near gripper
        object_state.velocity = Eigen::Vector3d::Zero();
        object_state.dimensions = Eigen::Vector3d(0.05, 0.05, 0.05);  // 5cm cube
        object_state.mass = 0.2;  // 200g
        object_state.is_grasped = false;

        resetTime();  // Initialize time to 0
    }

    const char* getType() const override {
        return "Object";
    }

    IEntityState& getState() override { return object_state; }
    const IEntityState& getState() const override { return object_state; }

    void printState() const override {
        Entity::printState();
        printf("  Position: (%.3f, %.3f, %.3f)\n",
               object_state.position.x(),
               object_state.position.y(),
               object_state.position.z());
        printf("  Velocity: (%.3f, %.3f, %.3f)\n",
               object_state.velocity.x(),
               object_state.velocity.y(),
               object_state.velocity.z());
        printf("  Mass: %.3f kg, Grasped: %s\n",
               object_state.mass,
               object_state.is_grasped ? "yes" : "no");
    }
};

} // namespace object1

#endif // OBJECT1_ENTITY_HPP

