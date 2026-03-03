/*
 * Test model for integer conversion testing.
 * Contains integer values for numeric conversion helper functions.
 */

pmodel IntegerConversionTest {
    local link TestLink {
        pose { 
            x = 10 
            y = 20 
            z = 30 
            roll = 40 
            pitch = 50 
            yaw = 60 
        }
        
        def {
            inertial information {
                mass 5
                inertia matrix {ixx 10 ixy 20 ixz 30 iyy 40 iyz 50 izz 60}
                pose {
                    x = 0
                    y = 0
                    z = 0
                    roll = 0
                    pitch = 0
                    yaw = 0
                }
            }
        }
    }
}
