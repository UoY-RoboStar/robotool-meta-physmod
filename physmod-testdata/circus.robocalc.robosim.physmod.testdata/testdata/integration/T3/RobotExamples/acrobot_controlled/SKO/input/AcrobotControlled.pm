// Acrobot with ControlledMotor actuator (B_ctrl formulation)
// This test validates the B_ctrl control input matrix integration
// Uses reference components from physmod-lib for joints, actuators, and sensors

import physmod::math::*
import physmod::SKO::joints::Revolute_y
import physmod::trivial::actuators::ControlledMotor
import physmod::trivial::sensors::JointEncoder

pmodel AcrobotControlled {
    local link BaseLink {
        def { }
        local body BaseBody {
            def {
                inertial information {
                    mass 0.1
                    inertia matrix { ixx 0.1 ixy 0.0 ixz 0.0 iyy 0.1 iyz 0.0 izz 0.1 }
                    pose { x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
                }
                box ( length = 0.2 , width = 0.2 , height = 0.2 )
            }
            pose { x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
        }
        // Shoulder joint: passive revolute about Y-axis (unactuated)
        jref ShoulderJoint = Revolute_y {
            flexibly connected to Link1
            pose { x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
        }
        // Shoulder encoder measures ShoulderJoint angle and velocity
        sref ShoulderEncoder = JointEncoder {
            pose { x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
        }
        pose { x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
    }

    local link Link1 {
        def { }
        local body Link1Body {
            def {
                inertial information {
                    // Drake: m1=1.0, lc1=0.5, Ic1≈0.083 (about COM)
                    mass 1.0
                    inertia matrix { ixx 0.083 ixy 0.0 ixz 0.0 iyy 0.083 iyz 0.0 izz 0.001 }
                    pose { x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
                }
                cylinder ( radius = 0.05 , length = 1.0 )
            }
            pose { x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
        }
        // Elbow joint: actuated revolute about Y-axis with ControlledMotor
        // B_ctrl relates control input u to torque: TorqueOut = B_ctrl * ControlIn
        jref ElbowJoint = Revolute_y {
            flexibly connected to Link2
            pose { x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
            aref ElbowMotor = ControlledMotor {
                pose { x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
            }
        }
        // Elbow encoder measures ElbowJoint angle and velocity
        sref ElbowEncoder = JointEncoder {
            pose { x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
        }
        pose { x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
    }

    local link Link2 {
        def { }
        local body Link2Body {
            def {
                inertial information {
                    // Drake: m2=1.0, lc2=1.0, Ic2≈0.333 (about COM)
                    mass 1.0
                    inertia matrix { ixx 0.333 ixy 0.0 ixz 0.0 iyy 0.333 iyz 0.0 izz 0.001 }
                    pose { x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
                }
                cylinder ( radius = 0.05 , length = 2.0 )
            }
            pose { x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
        }
        pose { x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
    }
}
