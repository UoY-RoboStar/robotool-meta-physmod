#ifndef INTERFACES_HPP
#define INTERFACES_HPP

#include <cstddef>
#include <vector>
#include <string>
#include "dmodel_data.h"

// Forward declarations
struct mapping_state_t;
struct sensor_data_t;

/**
 * Abstract entity state.
 * 
 * Entities are state holders representing physical objects/components.
 * Each entity type defines its own State struct with entity-specific variables.
 * 
 * Examples of entities:
 *   - Platform (robot): joint angles, velocities, link transforms
 *   - Object (block, ball): position, velocity, mass, geometry
 *   - Goal (target marker): position, orientation
 * 
 * Key distinction:
 *   - Entity = State holder (position, mass, etc.)
 *   - Engine = Dynamics simulator (computes how state evolves)
 * 
 * Platform is an entity WITH an engine (has dynamics).
 * Objects are entities WITHOUT engines (passive, no autonomous motion).
 * World is NOT an entity - it's a container of entities.
 */
struct IEntityState {
    virtual ~IEntityState() = default;
};

/**
 * Abstract world state.
 * 
 * World is a CONTAINER of entities (objects, environment, etc.).
 * World state includes:
 *   - Collection of entity states (e.g., positions of all objects)
 *   - Global/environmental properties (gravity, air resistance, etc.)
 * 
 * World is NOT an entity - it's the environment where entities interact.
 */
struct IWorldState {
    virtual ~IWorldState() = default;
};

// Platforms are entities (robots, machines that can be controlled)
using IPlatformState = IEntityState;

// EventData and OperationData are defined in dmodel_data.h



struct IDModelIO {
    virtual ~IDModelIO() = default;
    virtual bool registerRead(int* type, void* data, size_t size) = 0;
    virtual void registerWrite(const OperationData* op) = 0;
virtual void tock(int type) = 0;
};

/**
 * Abstract operation interface (platform-agnostic).
 * Operations compute actuator outputs as functions of integrated variables (e.g., phase time, velocity, etc.).
 * Concrete implementations are generated from Mapping.pm and defined in platform_mapping.h.
 */
class IOperation {
public:
    virtual ~IOperation() = default;
    
    /** Get operation name (e.g., "PrePick") */
    virtual const char* getName() const = 0;
    
    /** 
     * Compute actuator outputs given current values of integrated variables.
     * Platform-specific mapping struct is passed by reference (defined in platform_mapping.h).
     * The mapping struct contains all integrated variables and sensor readings.
     * 
     * @param mapping Platform mapping struct to read integrated variables from and write actuator outputs to
     * 
     * Note: Integrated variables (those with derivative(var) == constant in Mapping.pm) are stored
     * in the mapping struct and automatically updated by the orchestrator between computeOutputs calls.
     */
    virtual void computeOutputs(mapping_state_t& mapping) const = 0;
    
    /** 
     * Get list of variables with derivative(var) == 1 (or other constant rates).
     * These are automatically integrated by the orchestrator at their specified rates.
     * Returns pairs of (variable_name, derivative_value).
     * 
     * Example: {"k", 1.0} means dk/dt = 1, so the orchestrator will update mapping.k += 1.0 * dt
     */
    virtual std::vector<std::pair<std::string, double>> getIntegratedVariables() const = 0;
};

/**
 * Abstract event interface (platform-agnostic).
 * Events evaluate predicates on sensor measurements.
 * Concrete implementations are generated from Mapping.pm and defined in platform_mapping.h.
 */
class IEvent {
public:
    virtual ~IEvent() = default;
    
    /** Get event name (e.g., "detectObject") */
    virtual const char* getName() const = 0;
    
    /** 
     * Evaluate event predicate on current sensor readings.
     * Platform-specific mapping struct is passed by reference.
     * 
     * @param mapping Platform mapping struct to read sensors from (forward-declared here)
     * @return true if event predicate is satisfied
     */
    virtual bool evaluate(const mapping_state_t& mapping) const = 0;
};

// Abstract interfaces for engines and mappings

/**
 * Entity: Base class for physical objects in the simulation.
 * Contains state, identity, and time management.
 * 
 * Entity = State + Identity + Time
 * Engine = Dynamics (separate, only for platforms)
 * 
 * Examples: Platform, Object, Goal
 */
class Entity {
protected:
    std::string entity_name;
    int entity_id;
    double simulation_time;

public:
    explicit Entity(const std::string& name = "Entity", int id = -1)
        : entity_name(name)
        , entity_id(id)
        , simulation_time(0.0)
    {}

    virtual ~Entity() = default;

    // Identity
    const std::string& getName() const { return entity_name; }
    void setName(const std::string& name) { entity_name = name; }
    int getID() const { return entity_id; }
    void setID(int id) { entity_id = id; }

    // Time management
    double getTime() const { return simulation_time; }
    virtual void advanceTime(double dt) { simulation_time += dt; }
    virtual void resetTime() { simulation_time = 0.0; }

    // State access
    virtual IEntityState& getState() = 0;
    virtual const IEntityState& getState() const = 0;

    // Type identification
    virtual const char* getType() const = 0;

    virtual void printState() const {
        printf("[Entity] %s (ID=%d, type=%s, time=%.3f)\n",
               entity_name.c_str(), entity_id, getType(), simulation_time);
    }
};

/**
 * Platform - controllable robot/machine entity.
 * Extends Entity (like Object, Goal) for consistency.
 * Active entities (platforms) have engines that update their state.
 */
class Platform : public Entity {
public:
    Platform(const std::string& name, int id) : Entity(name, id) {}
    virtual ~Platform() = default;
    
    const char* getType() const override { return "Platform"; }
};

/**
 * Platform engine interface - computes dynamics for a Platform entity.
 */
class IPlatformEngine {
public:
    virtual ~IPlatformEngine() = default;
    virtual void initialise() = 0;
    virtual void update() = 0;
    virtual double getTime() const = 0;
    virtual Platform& getPlatform() = 0;
    virtual const Platform& getPlatform() const = 0;
};

/**
 * Abstract world engine interface.
 * 
 * World is a CONTAINER that manages:
 *   - Multiple entities (objects, environmental elements)
 *   - Inter-entity interactions (collisions, forces, etc.)
 *   - Global physics (gravity, air resistance, lighting, etc.)
 * 
 * World engine orchestrates all world entities and their interactions.
 * Individual entities (like objects) may have their own IEntityEngine instances,
 * or the world engine may manage them directly.
 * 
 * World does NOT directly receive platform data - mappings bridge entities.
 */
class IWorldEngine {
public:
    virtual ~IWorldEngine() = default;
    virtual void initialise() = 0;
    
    /**
     * Advance world physics/dynamics by one time step.
     * 
     * Reads:
     *   - World inputs from mappings (e.g., platform gripper position affects object)
     * 
     * Updates:
     *   - Entity states (object positions, contact forces, etc.)
     *   - Environmental state (lighting, temperature, etc.)
     *   - Inter-entity interactions (collisions, constraints)
     */
    virtual void update() = 0;
    
    virtual double getTime() const = 0;
    virtual const IWorldState& state() const = 0;   // World state (all entities + environment)
    virtual IWorldState& state() = 0;
};

/**
 * Abstract platform-world mapping interface.
 * 
 * Bidirectional mapping between platform and world engines via global coupling variables:
 * 
 *   Platform Engine ←→ Mapping ←→ World Engine
 *        (theta)    →  FK  →  (gripper_pos) → world input
 *    (sensor_data)  ←  IK  ←  (object_pos)  ← world output
 * 
 * The mapping defines EQUATIONS that relate platform variables to world variables:
 *   1. Platform → World: computeWorldInputs()
 *      Example: gripper_world_position = FK(theta_platform)
 *      Sets world engine input globals (like platform engine reads actuator globals)
 * 
 *   2. World → Platform: computeSensorReadings()  
 *      Example: distance_sensor = ||object_pos - gripper_pos||
 *      Reads world state, computes sensor outputs for platform
 * 
 * Both engines are independent - the mapping is the ONLY coupling.
 */
class IPlatformWorldMapping {
public:
    virtual ~IPlatformWorldMapping() = default;
    virtual void initialise() = 0;
    
    /**
     * Compute sensor readings from world state and platform state.
     * 
     * Reads:
     *   - World state (e.g., object positions from world engine)
     *   - Platform state (e.g., joint angles for FK to get sensor locations)
     * 
     * Writes:
     *   - Sensor data (e.g., distance readings, contact forces)
     * 
     * @param world_state World state (cast to concrete type)
     * @param platform_state Platform state (cast to concrete type)
     * @param sensor_output Computed sensor readings
     */
    virtual void computeSensorReadings(
        const IWorldState& world_state,
        const IPlatformState& platform_state,
        sensor_data_t& sensor_output
    ) = 0;
    
    /**
     * Compute world inputs from platform actuator outputs.
     * 
     * Reads:
     *   - Platform state (e.g., joint angles, actuator forces)
     * 
     * Writes:
     *   - World state inputs (e.g., gripper position affects object position)
     *   - These are global variables that world engine reads in its update()
     * 
     * Just like platform engine reads torque commands from globals set by controller,
     * world engine reads position/force commands from globals set by this mapping.
     * 
     * @param platform_state Platform state (cast to concrete type)
     * @param world_state World state to update (cast to concrete type)
     */
    virtual void computeWorldInputs(
        const IPlatformState& platform_state,
        IWorldState& world_state
    ) = 0;
};

/**
 * Abstract platform mapping interface (controller's view).
 * Manages the mapping state (controller's abstraction of platform sensors/actuators).
 * Updated from sensor readings; provides actuator commands to platform engine.
 */
class IPlatformMapping {
public:
    virtual ~IPlatformMapping() = default;
    virtual void initialise() = 0;
    
    /**
     * Access platform mapping state (controller's view of sensors, actuators, etc.).
     * @return Reference to platform-specific mapping struct
     */
    virtual mapping_state_t& mapping() = 0;
    
    /**
     * Update mapping state from sensor readings.
     * Platform-specific: what sensors are available and how they map to the controller's view.
     * 
     * @param sensor_output Sensor readings from platform-world mapping
     */
    virtual void updateFromSensors(const sensor_data_t& sensor_output) = 0;
};

// Accessors for concrete instances (defined in respective .cpp files)
IPlatformEngine* get_platform_engine();
IWorldEngine* get_world_engine();
IPlatformWorldMapping* get_platform_world_mapping();  // Renamed from IWorldMapping
IPlatformMapping* get_platform_mapping();

// Active D-Model adapter setter used by the C bridge
void set_active_dmodel_io(IDModelIO* io);

#endif // INTERFACES_HPP
