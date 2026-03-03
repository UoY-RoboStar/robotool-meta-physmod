pmodel IntegerInertiaTestModel {
    local link TestLinkWithIntegers {
        def {
            inertial information {
                mass = 5
                centre_of_mass {
                    x = 0
                    y = 0
                    z = 0
                }
                inertia {
                    ixx = 10
                    ixy = 0
                    ixz = 0
                    iyy = 20
                    iyz = 0
                    izz = 30
                }
            }
        }
    }
}
