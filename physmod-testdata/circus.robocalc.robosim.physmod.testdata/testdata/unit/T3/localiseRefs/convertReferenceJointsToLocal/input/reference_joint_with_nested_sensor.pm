// Test: Reference joint containing a reference sensor
// Purpose: Verify that when a reference joint is converted to a local joint,
// the nested reference sensor is preserved inside the joint (not lost or moved to link scope)
import physmod::SKO::joints::Revolute_x
import physmod::trivial::sensors::JointEncoder

pmodel ReferenceJointNestedSensorTest {
    local link BaseLink {
        def {
            const number: nat = 0
        }
        local body BaseBody {
            def {
                box(length=0.1, width=0.1, height=0.1)
            }
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
                box(length=0.05, width=0.05, height=0.05)
            }
        }
    }
}





































