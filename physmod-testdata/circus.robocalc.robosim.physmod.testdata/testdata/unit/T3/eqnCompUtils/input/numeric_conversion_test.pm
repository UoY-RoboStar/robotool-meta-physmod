/*
 * Test model for numeric conversion helper functions.
 * Contains float values in inertial properties to test FloatExp handling.
 */

pmodel NumericConversionTest {
    local link TestLink {
        pose { 
            x = 1.5 
            y = 2.0 
            z = 3.5 
            roll = 4.0 
            pitch = 5.5 
            yaw = 6.0 
        }
        
        def {
            inertial information {
                mass 1.5
                inertia matrix {ixx 1.5 ixy 2.0 ixz 3.5 iyy 4.0 iyz 5.5 izz 6.0}
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
