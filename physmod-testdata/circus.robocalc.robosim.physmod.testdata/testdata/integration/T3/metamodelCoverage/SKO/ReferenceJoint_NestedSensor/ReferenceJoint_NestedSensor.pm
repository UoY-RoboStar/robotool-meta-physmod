// SKO Metamodel coverage test: Reference joint containing a nested reference sensor
// Purpose: Verify that eqnComp localises the reference joint and preserves the nested
// reference sensor inside it (not moved to link scope)
import physmod::SKO::joints::Revolute_x
import physmod::trivial::sensors::JointEncoder

pmodel ReferenceJoint_NestedSensor {
    local link BaseLink {
        def {
            const number: nat = 0
        }
        pose { x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
        local body BaseBody {
            def {
                inertial information {
                    mass 1.0
                    inertia matrix { ixx 0.1 ixy 0.0 ixz 0.0 iyy 0.1 iyz 0.0 izz 0.1 }
                    pose { x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
                }
                box(length=0.1, width=0.1, height=0.1)
            }
            pose { x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
        }
        // Reference joint containing a reference sensor
        jref revolute_joint = Revolute_x {
            pose { 
                x = 0.0 
                y = 0.0 
                z = 0.1 
                roll = 0.0 
                pitch = 0.0 
                yaw = 0.0 
            }
            flexibly connected to EndEffector
            // Nested reference sensor inside the joint
            sref encoder = JointEncoder {
                pose {
                    x = 0.0
                    y = 0.0
                    z = 0.0
                    roll = 0.0
                    pitch = 0.0
                    yaw = 0.0
                }
            }
        }
    }
    
    local link EndEffector {
        pose { 
            x = 0.0 
            y = 0.0 
            z = 0.2 
            roll = 0.0 
            pitch = 0.0 
            yaw = 0.0 
        }
        def {
            const number: nat = 1
        }
        local body EndBody {
            def {
                inertial information {
                    mass 0.5
                    inertia matrix { ixx 0.05 ixy 0.0 ixz 0.0 iyy 0.05 iyz 0.0 izz 0.05 }
                    pose { x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
                }
                box(length=0.05, width=0.05, height=0.05)
            }
            pose { x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
        }
    }
}

