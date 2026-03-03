import physmod::SKO::joints::Revolute_x

// Mixed model with some valid and some invalid links
pmodel MixedValidityModel {
    // Valid link with pose and inertia
    local link ValidLink {
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
        local body ValidBody {
            def {
                box(length=0.1, width=0.1, height=0.1)
            }
        }
    }
    
    // Invalid link with no pose
    local link InvalidLink {
        def {
            const number: nat = 2
        }
        local body InvalidBody {
            def {
                box(length=0.1, width=0.1, height=0.1)
            }
        }
    }
}
