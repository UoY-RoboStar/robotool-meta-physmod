/*
 * Test model for mixed type conversion testing.
 * Contains mixed float and integer values.
 */

pmodel MixedConversionTest {
    local link TestLink {
        pose { 
            x = 1.0 
            y = 2 
            z = 3.0 
            roll = 4 
            pitch = 5.0 
            yaw = 6 
        }
        
        def {
            inertial information {
                mass 2.5
                inertia matrix {ixx 1.0 ixy 2 ixz 3.0 iyy 4 iyz 5.0 izz 6}
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
