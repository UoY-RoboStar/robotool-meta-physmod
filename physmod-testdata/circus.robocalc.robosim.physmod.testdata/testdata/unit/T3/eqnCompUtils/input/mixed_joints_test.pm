import physmod::SKO::joints::Revolute_x

pmodel MixedJointsTest {
    local link BaseLink {
        def {
            const number: nat = 0
        }
        local body BaseBody {
            def {
                box(length=0.1, width=0.1, height=0.1)
            }
        }
        jref ref_joint = Revolute_x {
            pose { 
                x = 0.0 
                y = 0.0 
                z = 0.1 
                roll = 0.0 
                pitch = 0.0 
                yaw = 0.0 
            }
            flexibly connected to MiddleLink
        }
        local joint local_joint {
            pose { 
                x = 0.1 
                y = 0.0 
                z = 0.1 
                roll = 0.0 
                pitch = 0.0 
                yaw = 0.0 
            }
            def {
                annotation Revolute {
                    axis = Axis {
                        xyz = (|0,0,1|)
                    }
                }
            }
            flexibly connected to MiddleLink
        }
    }
    
    local link MiddleLink {
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
        local body MiddleBody {
            def {
                box(length=0.08, width=0.08, height=0.08)
            }
        }
    }
}
