/*
 * Test model for integer inertia values.
 * Contains integer values in inertial properties to test IntegerExp conversion.
 */

pmodel IntegerInertiaTest {
    local link TestLink {
        pose { 
            x = 0 
            y = 0 
            z = 0 
            roll = 0 
            pitch = 0 
            yaw = 0 
        }
        
        def {
            inertial information {
                mass 2
                inertia matrix {ixx 1 ixy 0 ixz 0 iyy 1 iyz 0 izz 1}
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
        
        local body TestBody {
            pose { 
                x = 1 
                y = 1 
                z = 1 
                roll = 0 
                pitch = 0 
                yaw = 0 
            }
            
            def {
                box(length=1, width=1, height=1)
                inertial information {
                    mass 1
                    inertia matrix {ixx 0 ixy 0 ixz 0 iyy 0 iyz 0 izz 1}
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
}
