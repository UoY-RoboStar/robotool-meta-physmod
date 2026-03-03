#ifndef INTERFACES_HPP
#define INTERFACES_HPP

#include <cstddef>
#include <vector>
#include <string>
#include "dmodel_data.h"

// Forward declarations
struct mapping_state_t;
struct sensor_outputs_t;

/**
 * Abstract entity state.
 */
struct IEntityState {
    virtual ~IEntityState() = default;
};

/**
 * Abstract world state.
 */
struct IWorldState {
    virtual ~IWorldState() = default;
};

// Platforms are entities (robots, machines that can be controlled)
using IPlatformState = IEntityState;

struct IDModelIO {
    virtual ~IDModelIO() = default;
    virtual bool registerRead(int* type, void* data, size_t size) = 0;
    virtual void registerWrite(const OperationData* op) = 0;
    virtual void tock(int type) = 0;
};

/**
 * Abstract operation interface (platform-agnostic).
 */
class IOperation {
public:
    virtual ~IOperation() = default;
    virtual const char* getName() const = 0;
    virtual void computeOutputs(mapping_state_t& mapping) const = 0;
    virtual std::vector<std::pair<std::string, double>> getIntegratedVariables() const = 0;
};

/**
 * Abstract event interface (platform-agnostic).
 */
class IEvent {
public:
    virtual ~IEvent() = default;
    virtual const char* getName() const = 0;
    virtual bool evaluate(const mapping_state_t& mapping) const = 0;
};

/**
 * Entity: Base class for physical objects in the simulation.
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

    const std::string& getName() const { return entity_name; }
    void setName(const std::string& name) { entity_name = name; }
    int getID() const { return entity_id; }
    void setID(int id) { entity_id = id; }

    double getTime() const { return simulation_time; }
    virtual void advanceTime(double dt) { simulation_time += dt; }
    virtual void resetTime() { simulation_time = 0.0; }

    virtual IEntityState& getState() = 0;
    virtual const IEntityState& getState() const = 0;

    virtual const char* getType() const = 0;

    virtual void printState() const {
        printf("[Entity] %s (ID=%d, type=%s, time=%.3f)\n",
               entity_name.c_str(), entity_id, getType(), simulation_time);
    }
};

/**
 * Platform - controllable robot/machine entity.
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
 */
class IWorldEngine {
public:
    virtual ~IWorldEngine() = default;
    virtual void initialise() = 0;
    virtual void update() = 0;
    virtual double getTime() const = 0;
    virtual const IWorldState& state() const = 0;
    virtual IWorldState& state() = 0;
};

/**
 * Abstract platform-world mapping interface.
 */
class IPlatformWorldMapping {
public:
    virtual ~IPlatformWorldMapping() = default;
    virtual void initialise() = 0;

    virtual void computeSensorReadings(
        const IWorldState& world_state,
        const IPlatformState& platform_state,
        sensor_outputs_t& sensor_output
    ) = 0;

    virtual void computeWorldInputs(
        const IPlatformState& platform_state,
        IWorldState& world_state
    ) = 0;
};

/**
 * Abstract platform mapping interface (controller's view).
 */
class IPlatformMapping {
public:
    virtual ~IPlatformMapping() = default;
    virtual void initialise() = 0;
    virtual mapping_state_t& mapping() = 0;
    virtual void updateFromSensors(const sensor_outputs_t& sensor_output) = 0;
};

// Accessors for concrete instances (defined in respective .cpp files)
IPlatformEngine* get_platform_engine();
IWorldEngine* get_world_engine();
IPlatformWorldMapping* get_platform_world_mapping();
IPlatformMapping* get_platform_mapping();

// Active D-Model adapter setter used by the C bridge
void set_active_dmodel_io(IDModelIO* io);

#endif // INTERFACES_HPP
