import physmod::SKO::joints::Revolute_x

pmodel ReferenceJointTest {
    local link BaseLink {
        def {
            const number: nat = 0
        }
        local body BaseBody {
            def {
                box(length=0.1, width=0.1, height=0.1)
            }
        }
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
