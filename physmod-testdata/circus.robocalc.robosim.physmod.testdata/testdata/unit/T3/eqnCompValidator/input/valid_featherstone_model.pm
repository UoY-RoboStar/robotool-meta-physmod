import physmod::math::*

pmodel ValidFeatherstoneModel {
    local link Link1 {
        def {
            const number: nat = 1
            inertial information{
                mass 1.0
                inertia matrix {ixx 0.01 ixy 0.0 ixz 0.0 iyy 0.01 iyz 0.0 izz 0.01}
            }
        }
        pose {
            x = 0.0
            y = 0.0
            z = 0.0
            roll = 0.0
            pitch = 0.0
            yaw = 0.0
        }
        local body Body1 {
            def {
                box(length=0.1, width=0.1, height=0.1)
            }
        }
        local joint Joint1 {
            pose {
                x = 0.0
                y = 0.0
                z = 0.0
                roll = 0.0
                pitch = 0.0
                yaw = 0.0
            }
            def {
                const s : vector ( real , 6 ) = (| 0 , 0 , 1 , 0 , 0 , 0 |)
            }
            flexibly connected to Link2
        }
    }
    local link Link2 {
        def {
            const number: nat = 2
            inertial information{
                mass 2.0
                inertia matrix {ixx 0.02 ixy 0.0 ixz 0.0 iyy 0.02 iyz 0.0 izz 0.02}
            }
        }
        pose {
            x = 1.0
            y = 0.0
            z = 0.0
            roll = 0.0
            pitch = 0.0
            yaw = 0.0
        }
        local body Body2 {
            def {
                box(length=0.1, width=0.1, height=0.1)
            }
        }
    }
}
