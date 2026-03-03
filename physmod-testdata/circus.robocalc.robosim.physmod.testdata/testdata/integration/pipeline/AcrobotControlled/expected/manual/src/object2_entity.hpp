#ifndef OBJECT2_ENTITY_HPP
#define OBJECT2_ENTITY_HPP

#include "interfaces.hpp"
#include <Eigen/Dense>

/**
 * Object2: Another passive entity (goal marker).
 * 
 * This demonstrates that different objects can have different properties.
 * Object2 is a stationary target (goal position) in this scenario.
 */
namespace object2 {

/**
 * Object2 state (goal marker - stationary).
 */
struct State : IEntityState {
    // Kinematic state (world frame)
    Eigen::Vector3d position;      // Fixed position in world frame
    
    // Visual properties (for rendering)
    Eigen::Vector3d color;         // RGB color
    double radius;                 // Radius of marker sphere
    
    // Interaction state
    bool is_target_reached;        // Has platform reached this goal?
    
    // Constructor with default values
    State() 
        : position(Eigen::Vector3d::Zero())
        , color(0.0, 1.0, 0.0)     // Green goal marker
        , radius(0.05)              // 5cm radius
        , is_target_reached(false)
    {}
};

/**
 * Object2 entity (goal marker) - static marker with no dynamics.
 *
 * Goal markers are even simpler than objects - they have fixed position.
 * No engine, no autonomous motion, just a state holder.
 */
class Object2Entity : public Entity {
public:
    State object_state;
    
    Object2Entity() 
        : Entity("Object2_Goal", 3)  // Entity ID=3 (Goal marker)
    {}
    
    void initialise() {
        // Initialize goal position
        object_state.position = Eigen::Vector3d(0, -4.7511, 0.25);  // Goal location
        object_state.color = Eigen::Vector3d(0.0, 1.0, 0.0);  // Green
        object_state.is_target_reached = false;
        
        resetTime();
    }
    
    const char* getType() const override {
        return "Goal";
    }

    IEntityState& getState() override { return object_state; }
    const IEntityState& getState() const override { return object_state; }
};

} // namespace object2

#endif // OBJECT2_ENTITY_HPP

