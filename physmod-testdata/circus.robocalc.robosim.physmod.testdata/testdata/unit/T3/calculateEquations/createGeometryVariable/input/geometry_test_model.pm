/*
 * Test model for createGeometryVariable function.
 * Contains different geometry types to test variable creation.
 */

import physmod::SKO::joints::Revolute_x
import physmod::joints::Revolute

pmodel GeometryTestModel {
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
        local body BoxBody {
            def {
                box(length=0.1, width=0.2, height=0.3)
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
        local body CylinderBody {
            def {
                cylinder(radius=0.05, length=0.2)
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
        local body SphereBody {
            def {
                sphere(radius=0.1)
                inertial information {
                    mass 0.3
                    inertia matrix {ixx 0.001 ixy 0 ixz 0 iyy 0.001 iyz 0 izz 0.001}
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
        local body MeshBody {
            def {
                mesh { shape "test.stl" scaling 1.5 }
                inertial information {
                    mass 0.8
                    inertia matrix {ixx 0.005 ixy 0 ixz 0 iyy 0.005 iyz 0 izz 0.005}
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
