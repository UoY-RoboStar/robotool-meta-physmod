/*
 * Test model for mixed integer and float inertia values.
 * Contains both integer and float values in inertial properties to test mixed type handling.
 */

pmodel MixedInertiaTypesTest {
    local link TestLink {
        pose { 
            x = 0.0 
            y = 0.0 
            z = 0.5 
            roll = 0 
            pitch = 0 
            yaw = 0.0 
        }
        
        def {
            inertial information {
                mass 1.5
                inertia matrix {ixx 1 ixy 0.0 ixz 0 iyy 0.1 iyz 0 izz 1.0}
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
                x = 0 
                y = 0.1 
                z = 0 
                roll = 0.0 
                pitch = 0 
                yaw = 0.0 
            }
            
            def {
                cylinder(radius=0.1, length=1.0)
            }
        }
    }
}
