#include "interfaces.hpp"

void world_initialize() {}

class NullWorldEngine : public IWorldEngine {
public:
    void initialise() override {}
    void update() override {}
    double getTime() const override { return 0.0; }
    const IWorldState& state() const override { return dummy_state_; }
    IWorldState& state() override { return dummy_state_; }
private:
    struct DummyState : public IWorldState {};
    mutable DummyState dummy_state_;
};

class NullPlatformWorldMapping : public IPlatformWorldMapping {
public:
    void initialise() override {}
    void computeSensorReadings(const IWorldState&, const IPlatformState&, sensor_data_t&) override {}
    void computeWorldInputs(const IPlatformState&, IWorldState&) override {}
};

static NullWorldEngine g_null_world_engine;
static NullPlatformWorldMapping g_null_platform_world_mapping;

IWorldEngine* get_world_engine() { return &g_null_world_engine; }
IPlatformWorldMapping* get_platform_world_mapping() { return &g_null_platform_world_mapping; }


