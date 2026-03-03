/*
 * Test model for inertia variable creation.
 * Contains float values in inertial properties for link-level inertia.
 */

pmodel InertiaTestModel {
    local link TestLink {
        pose { 
            x = 0.0 
            y = 0.0 
            z = 0.0 
            roll = 0.0 
            pitch = 0.0 
            yaw = 0.0 
        }
        
        def {
            inertial information {
                mass 5.0
                inertia matrix {ixx 1.0 ixy 0.0 ixz 0.0 iyy 2.0 iyz 0.0 izz 3.0}
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
        
        local body TestBody {
            pose { 
                x = 0.0 
                y = 0.0 
                z = 0.0 
                roll = 0.0 
                pitch = 0.0 
                yaw = 0.0 
            }
            
            def {
                box(length=1.0, width=1.0, height=1.0)
            }
        }
    }
}
