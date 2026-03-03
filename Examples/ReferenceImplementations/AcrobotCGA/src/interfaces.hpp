#ifndef INTERFACES_HPP
#define INTERFACES_HPP

#include <memory>

// Platform engine interface - standalone pattern (no d-model integration)
// Follows manualImplementationCPP_v2 architecture but simplified for standalone mode
class IPlatformEngine {
public:
    virtual ~IPlatformEngine() = default;
    virtual void initialise() = 0;
    virtual void update() = 0;
    virtual double getTime() const = 0;
    virtual double getDt() const = 0;
};

// Factory function declaration - implemented in platform1_engine_dq.cpp
std::unique_ptr<IPlatformEngine> createPlatformEngine();

#endif // INTERFACES_HPP
