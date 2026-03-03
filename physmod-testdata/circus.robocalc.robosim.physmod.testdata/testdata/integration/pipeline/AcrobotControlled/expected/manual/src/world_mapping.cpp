#include "interfaces.hpp"
#include "platform1_state.hpp"  // For platform1::State
#include "world_mapping.h"

namespace {
class PlatformWorldMappingImpl final : public IPlatformWorldMapping {
public:
    void initialise() override {}

    void computeSensorReadings(
        const IWorldState& /*world_state*/,
        const IPlatformState& platform_state,
        sensor_data_t& out) override {
        // Provide gravity as a world sensor (world-frame 3D vector)
        // For this example, use constant Earth gravity in -Z
        out.World.gravity_world[0] = 0.0;
        out.World.gravity_world[1] = 0.0;
        out.World.gravity_world[2] = -9.81;

        // Joint encoder sensors: slnRef now correctly assigns theta indices to sensors
        // Platform internal order is [theta(0)=elbow, theta(1)=shoulder]
        // slnRef maps: ShoulderEncoder <- theta(1), ElbowEncoder <- theta(0)
        // So generated state variables match their names; pass through directly
        const platform1::State& st = static_cast<const platform1::State&>(platform_state);

        out.AcrobotControlled.BaseLink.ShoulderEncoder.AngleOut = st.ShoulderEncoderAngle;
        out.AcrobotControlled.BaseLink.ShoulderEncoder.VelocityOut = st.ShoulderEncoderVelocity;
        out.AcrobotControlled.Link1.ElbowEncoder.AngleOut = st.ElbowEncoderAngle;
        out.AcrobotControlled.Link1.ElbowEncoder.VelocityOut = st.ElbowEncoderVelocity;

        // Dynamics sensor: convert from platform to controller convention
        // Platform order: [theta(0)=elbow, theta(1)=shoulder] = Drake's [q2, q1]
        // Controller expects Drake order: [q1=shoulder, q2=elbow]
        // So swap indices: platform(i,j) -> controller(1-i, 1-j)
        out.AcrobotControlled.BaseLink.DynamicsSensor.M_inv[0][0] = st.M_inv(1, 1);
        out.AcrobotControlled.BaseLink.DynamicsSensor.M_inv[0][1] = st.M_inv(1, 0);
        out.AcrobotControlled.BaseLink.DynamicsSensor.M_inv[1][0] = st.M_inv(0, 1);
        out.AcrobotControlled.BaseLink.DynamicsSensor.M_inv[1][1] = st.M_inv(0, 0);
        out.AcrobotControlled.BaseLink.DynamicsSensor.bias[0] = st.C(1);
        out.AcrobotControlled.BaseLink.DynamicsSensor.bias[1] = st.C(0);

        // Mirror into world mapping snapshot (optional; allows debugging)
        w_mapping.World.gravity_world[0] = out.World.gravity_world[0];
        w_mapping.World.gravity_world[1] = out.World.gravity_world[1];
        w_mapping.World.gravity_world[2] = out.World.gravity_world[2];
        w_mapping.AcrobotControlled.BaseLink.ShoulderEncoder.AngleOut =
            out.AcrobotControlled.BaseLink.ShoulderEncoder.AngleOut;
        w_mapping.AcrobotControlled.BaseLink.ShoulderEncoder.VelocityOut =
            out.AcrobotControlled.BaseLink.ShoulderEncoder.VelocityOut;
        w_mapping.AcrobotControlled.Link1.ElbowEncoder.AngleOut =
            out.AcrobotControlled.Link1.ElbowEncoder.AngleOut;
        w_mapping.AcrobotControlled.Link1.ElbowEncoder.VelocityOut =
            out.AcrobotControlled.Link1.ElbowEncoder.VelocityOut;
        for (int i = 0; i < 2; ++i) {
            for (int j = 0; j < 2; ++j) {
                w_mapping.AcrobotControlled.BaseLink.DynamicsSensor.M_inv[i][j] =
                    out.AcrobotControlled.BaseLink.DynamicsSensor.M_inv[i][j];
            }
            w_mapping.AcrobotControlled.BaseLink.DynamicsSensor.bias[i] =
                out.AcrobotControlled.BaseLink.DynamicsSensor.bias[i];
        }

        out.time = 0.0; // Orchestrator will set if needed
    }
    
    void computeWorldInputs(
        const IPlatformState& platform_state,
        IWorldState& world_state) override {
        
        // In this simple example, world positions are set directly by scenario_update_sensors
        // For a more complex example, this would compute gripper position from FK
        // and update world entity positions based on platform actuator outputs
    }
};

PlatformWorldMappingImpl platform_world_mapping_instance;
} // namespace

IPlatformWorldMapping* get_platform_world_mapping() {
    return &platform_world_mapping_instance;
}
