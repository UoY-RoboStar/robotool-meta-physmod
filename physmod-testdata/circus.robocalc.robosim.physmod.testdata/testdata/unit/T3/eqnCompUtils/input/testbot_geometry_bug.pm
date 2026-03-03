/*
 * Test model that reproduces the potential bug with createGeometryVariable.
 * This is the exact model provided by the user that seems to cause issues.
 */

import physmod::SKO::joints::Revolute_x
import physmod::joints::Revolute

pmodel TestBot {
    local link Core {
        pose { 
            x = 0.0 
            y = 0.0 
            z = 0.0 
            roll = 0.0 
            pitch = 0.0 
            yaw = 0.0 
        }
        def {
        }
        local body CoreBody {
            def {
                box(length=0.1, width=0.1, height=0.1)
                inertial information {
                    mass 1.0
                    inertia matrix {ixx 0.01 ixy 0 ixz 0 iyy 0.01 iyz 0 izz 0.01}
                    pose {
                        x = 0
                        y = 0
                        z = 0
                        roll = 0.0
                        pitch = 0.0
                        yaw = 0.0
                    }
                }
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
            flexibly connected to Arm
        }
    }
    local link Arm {
        pose { 
            x = 0.0 
            y = 0.0 
            z = 0.2 
            roll = 0.0 
            pitch = 0.0 
            yaw = 0.0 
        }
        def {
        }
        local body ArmBody {
            def {
                box(length=0.2, width=0.05, height=0.05)
                inertial information {
                    mass 0.5
                    inertia matrix {ixx 0.002 ixy 0 ixz 0 iyy 0.007 iyz 0 izz 0.007}
                    pose {
                        x = 0
                        y = 0
                        z = 0
                        roll = 0.0
                        pitch = 0.0
                        yaw = 0.0
                    }
                }
            }
        }
    }
}
