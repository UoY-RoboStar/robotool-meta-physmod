// world_engine.cpp - World model managing entities and their interactions
#include <Eigen/Dense>
#include <iostream>
#include <vector>
#include <cmath>
#include <memory>
#include <thread>
#include <chrono>
#include "visualization_client.h"
#include "interfaces.hpp"
#include "object1_entity.hpp"  // Object (block) entity
#include "object2_entity.hpp"  // Goal marker entity

// Entity types in the world
enum EntityType {
    ENTITY_ROBOT_BASE = 0,
    ENTITY_GRIPPER = 1,
    ENTITY_OBJECT = 2,
    ENTITY_GOAL = 3,
    ENTITY_COUNT = 4
};

/**
 * World state structure.
 *
 * Design: World contains references to entities, not duplicated data.
 * - Object entities (object1, object2) have their own .hpp files with state
 * - World state just tracks positions for quick spatial queries
 * - World engine orchestrates entity interactions (gravity, collisions, etc.)
 *
 * Current implementation: Position duplication for simplicity
 * - positions[] vector is updated from entity states and gripper FK
 * - Distance matrix provides O(1) spatial queries
 *
 * Future refactoring plan (when more entities are added):
 * 1. Replace std::vector<Eigen::Vector3d> positions with std::vector<Entity*> entities
 * 2. Query positions directly: entities[i]->getState().position
 * 3. Update distance matrix to call entity->getState() instead of positions[i]
 * 4. Benefits: Single source of truth, no duplication, easier to add entity properties
 * 5. Current approach is acceptable for small number of entities (4) in this example
 */
struct WorldState {
    // Entity positions indexed by EntityType
    // Currently duplicated for fast spatial queries (acceptable for 4 entities)
    // See refactoring plan above for migration to entity references
    std::vector<Eigen::Vector3d> positions;
    
    // Distance matrix for efficient distance queries
    // distances[i][j] = distance from entity i to entity j
    Eigen::MatrixXd distances;
    
    // Legacy member names for compatibility (references to vector elements)
    Eigen::Vector3d& robot_base_position;
    Eigen::Vector3d& gripper_position;
    Eigen::Vector3d& block1_position;
    Eigen::Vector3d& block2_position;
    
    // Entity names for debugging
    std::vector<std::string> entity_names;
    
    // Robot configuration
    double link1_length = 2.25;  // Length of first link
    double link2_length = 2.25;  // Length of second link
    
    // Initialize with default positions matching Drake implementation
    WorldState() : 
        positions(ENTITY_COUNT),
        distances(ENTITY_COUNT, ENTITY_COUNT),
        robot_base_position(positions[ENTITY_ROBOT_BASE]),
        gripper_position(positions[ENTITY_GRIPPER]),
        block1_position(positions[ENTITY_OBJECT]),
        block2_position(positions[ENTITY_GOAL])
    {
        // Initialize entity names
        entity_names = {"RobotBase", "Gripper", "Object", "Goal"};
        
        // Initialize positions matching Drake setup
        positions[ENTITY_ROBOT_BASE] = Eigen::Vector3d(0, 0, 0);
        positions[ENTITY_GRIPPER] = Eigen::Vector3d(0, 0, 4.75);  // Initial gripper position
        positions[ENTITY_OBJECT] = Eigen::Vector3d(0, 4.7511, 0.075);   // Object position matching Drake brick.sdf
        positions[ENTITY_GOAL] = Eigen::Vector3d(0, -4.7511, 0.25);     // Goal position matching Drake brick2.sdf
        
        // Initialize distance matrix
        update_distance_matrix();
    }
    
    // Update the distance matrix after position changes
    void update_distance_matrix() {
        for (int i = 0; i < ENTITY_COUNT; ++i) {
            for (int j = 0; j < ENTITY_COUNT; ++j) {
                if (i == j) {
                    distances(i, j) = 0.0;
                } else {
                    distances(i, j) = (positions[i] - positions[j]).norm();
                }
            }
        }
    }
    
    // Get distance between two entities
    double get_distance(EntityType from, EntityType to) const {
        return distances(from, to);
    }
    
    // Set entity position and update distance matrix
    void set_position(EntityType entity, const Eigen::Vector3d& pos) {
        positions[entity] = pos;
        // Update only the affected row and column for efficiency
        for (int i = 0; i < ENTITY_COUNT; ++i) {
            if (i != entity) {
                double dist = (positions[entity] - positions[i]).norm();
                distances(entity, i) = dist;
                distances(i, entity) = dist;
            }
        }
    }
};

// Global world state
static WorldState world;

// World visualization state
static bool world_visualization_enabled = false;
static std::unique_ptr<VisualizationClient> world_viz_client = nullptr;

// Forward declarations
extern "C" void world_enable_visualization(bool enable);
extern "C" void world_update_visualization();

// Forward kinematics: extract gripper position from physics-computed Bk matrices
void world_update_gripper_position(const std::vector<Eigen::MatrixXd>& Bk) {
    // Extract gripper position from Bk[0] (end-effector frame)
    // Bk matrices are computed by the physics engine using correct forward kinematics
    if (Bk.size() > 0) {
        // Physics arm operates in Y-Z plane with Z-axis vertical
        // World coordinates use Y-axis as the primary movement axis
        // Mapping: physics_Z → world_Y, physics_Y → world_Z
        double gripper_x = Bk[0](0, 3);           // X unchanged (always 0 for planar motion)
        double gripper_y = Bk[0](2, 3);           // Physics Z → World Y (vertical arm motion)
        double gripper_z = 0.075;                 // Fixed height for object detection

        // Update gripper position in world state
        world.set_position(ENTITY_GRIPPER, Eigen::Vector3d(gripper_x, gripper_y, gripper_z));

        // Debug: print gripper position for first few updates
        static int debug_count = 0;
        if (debug_count < 3) {
            printf("[World] Gripper at: (%.3f, %.3f, %.3f) from Bk[0] (physics Z=%.3f→world Y)\n",
                   gripper_x, gripper_y, gripper_z, Bk[0](2,3));
            debug_count++;
        }

        // Update world visualization when gripper moves
        world_update_visualization();
    }
}

// Get distance from gripper to object using efficient distance matrix
double world_get_distance_to_object() {
    return world.get_distance(ENTITY_GRIPPER, ENTITY_OBJECT);
}

// Get distance from gripper to goal using efficient distance matrix
double world_get_distance_to_goal() {
    return world.get_distance(ENTITY_GRIPPER, ENTITY_GOAL);
}

// Set object position in world frame
void world_set_object_position(double x, double y, double z) {
    world.set_position(ENTITY_OBJECT, Eigen::Vector3d(x, y, z));
    world_update_visualization();
}

// Set goal position in world frame
void world_set_goal_position(double x, double y, double z) {
    world.set_position(ENTITY_GOAL, Eigen::Vector3d(x, y, z));
    world_update_visualization();
}

// Get current gripper position
void world_get_gripper_position(double* x, double* y, double* z) {
    const Eigen::Vector3d& gripper_pos = world.positions[ENTITY_GRIPPER];
    if (x) *x = gripper_pos(0);
    if (y) *y = gripper_pos(1);
    if (z) *z = gripper_pos(2);
}

// Get object block position  
void world_get_object_position(double* x, double* y, double* z) {
    if (x) *x = world.block1_position(0);
    if (y) *y = world.block1_position(1); 
    if (z) *z = world.block1_position(2);
}

// Get goal block position
void world_get_goal_position(double* x, double* y, double* z) {
    if (x) *x = world.block2_position(0);
    if (y) *y = world.block2_position(1);
    if (z) *z = world.block2_position(2);
}

// Entity instances managed by world
static object1::Object1Entity object1_entity;  // The block to pick
static object2::Object2Entity object2_entity;  // The goal marker

// World state wrapper for interface
namespace world1 {
    struct State : IWorldState {
        // Reference to global world state
        WorldState* world_ref;
        
        // References to entities managed by this world
        object1::Object1Entity* object1;
        object2::Object2Entity* object2;
        
        State() 
            : world_ref(&world)
            , object1(&object1_entity)
            , object2(&object2_entity)
        {}
    };
}

// WorldEngine concrete implementing IWorldEngine
class WorldEngineImpl : public IWorldEngine {
    world1::State world_state_wrapper;
    
public:
    void initialise() override {
        // Initialize object entities (they set their own state)
        object1_entity.initialise();
        object2_entity.initialise();
        
        // Sync world positions with entity positions
        // (Current design: world has positions vector for fast spatial queries)
        // See WorldState comment above for refactoring plan when scaling to more entities
        world.positions[ENTITY_ROBOT_BASE] = Eigen::Vector3d(0, 0, 0);
        world.positions[ENTITY_GRIPPER] = Eigen::Vector3d(0, 4.75, 0.075);
        world.positions[ENTITY_OBJECT] = Eigen::Vector3d(0, 4.7511, 0.075);
        world.positions[ENTITY_GOAL] = Eigen::Vector3d(0, -4.7511, 0.25);
        world.update_distance_matrix();
        printf("[World] Initialized with:\n");
        for (int i = 0; i < ENTITY_COUNT; ++i) {
            const Eigen::Vector3d& pos = world.positions[i];
            printf("[World]   %s at: (%6.4g %6.4g %6.4g)\n", 
                   world.entity_names[i].c_str(), pos.x(), pos.y(), pos.z());
        }
        printf("[World] Initial distances:\n");
        printf("[World]   Gripper-Object: %.4f m\n", world.get_distance(ENTITY_GRIPPER, ENTITY_OBJECT));
        printf("[World]   Gripper-Goal: %.4f m\n", world.get_distance(ENTITY_GRIPPER, ENTITY_GOAL));
        world_enable_visualization(true);
    }
    
    void update() override {
        // World is currently kinematic (positions set directly by mapping)
        // No dynamics to update in this simple example
        world.update_distance_matrix();
    }
    
    double getTime() const override {
        return 0.0; // World doesn't have its own time in this example
    }
    
    const IWorldState& state() const override {
        return world_state_wrapper;
    }
    
    IWorldState& state() override {
        return world_state_wrapper;
    }
};

static WorldEngineImpl world_engine_instance;
IWorldEngine* get_world_engine() { return &world_engine_instance; }

// Initialize world with specific scenario
void world_initialize() {
    world_engine_instance.initialise();
}

// Print current world state for debugging
void world_print_state() {
    std::cout << "[World State]" << std::endl;
    std::cout << "  Gripper: (" << world.gripper_position.transpose() << ")" << std::endl;
    std::cout << "  Object: (" << world.block1_position.transpose() << ")" << std::endl;
    std::cout << "  Goal: (" << world.block2_position.transpose() << ")" << std::endl;
    std::cout << "  Distance to object: " << world_get_distance_to_object() << " m" << std::endl;
    std::cout << "  Distance to goal: " << world_get_distance_to_goal() << " m" << std::endl;
}

// Enable world visualization  
void world_enable_visualization(bool enable) {
    world_visualization_enabled = enable;
    if (enable && !world_viz_client) {
        world_viz_client = std::make_unique<VisualizationClient>();
        
        // Try to connect to visualization server
        if (world_viz_client->connect("127.0.0.1", 9999)) {
            std::cout << "[World] Connected to visualization server" << std::endl;
            // Create world geometries (example-specific, sent from client)
            {
                // Object: red cube 0.3m
                const double obj_dims[3] = {0.3, 0.3, 0.3};
                const int obj_col[3] = {255, 0, 0};
                world_viz_client->createObject("world/object", /*box*/0, obj_dims, obj_col);

                // Goal: green cube 0.3m
                const double goal_dims[3] = {0.3, 0.3, 0.3};
                const int goal_col[3] = {0, 255, 0};
                world_viz_client->createObject("world/goal", /*box*/0, goal_dims, goal_col);
            }

            // Send initial world object transforms
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

// Update world object visualization
void world_update_visualization() {
    if (world_visualization_enabled && world_viz_client && world_viz_client->isConnected()) {
        // Create transform matrices for world objects
        Eigen::Matrix4d object_transform = Eigen::Matrix4d::Identity();
        object_transform(0, 3) = world.block1_position(0);
        object_transform(1, 3) = world.block1_position(1); 
        object_transform(2, 3) = world.block1_position(2);
        
        Eigen::Matrix4d goal_transform = Eigen::Matrix4d::Identity();
        goal_transform(0, 3) = world.block2_position(0);
        goal_transform(1, 3) = world.block2_position(1);
        goal_transform(2, 3) = world.block2_position(2);
        
        // Send transforms to visualization server
        world_viz_client->sendTransform("world/object", object_transform, true);
        world_viz_client->sendTransform("world/goal", goal_transform, true);
    }
}
