// Test: Reference actuator at link scope (not inside a joint)
// Purpose: Verify that reference actuators directly attached to links are also converted to local
import physmod::trivial::actuators::TrivialMotor

pmodel ReferenceActuatorLinkScopeTest {
    local link BaseLink {
        def {
            const number: nat = 0
        }
        local body BaseBody {
            def {
                box(length=0.1, width=0.1, height=0.1)
            }
        }
        local joint theta {
            def {
                const H : vector ( real , 6 ) = (| 0.0 , 1.0 , 0.0 , 0 , 0 , 0 |)
            }
            flexibly connected to EndEffector
            pose {
                x = 0.0
                y = 0.0
                z = 0.0
                roll = 0.0
                pitch = 0.0
                yaw = 0.0
            }
        }
        // Reference actuator at link scope (not inside joint)
        aref linkActuator = TrivialMotor {
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





































