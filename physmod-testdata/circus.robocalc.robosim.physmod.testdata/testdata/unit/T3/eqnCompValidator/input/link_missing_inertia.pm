// Model with link that has pose but no inertia
pmodel LinkMissingInertiaModel {
    local link LinkWithoutInertia {
        def {
            const number: nat = 1
        }
        pose { 
            x = 0.0 
            y = 0.0 
            z = 0.0 
            roll = 0.0 
            pitch = 0.0 
            yaw = 0.0 
        }
        local body BodyWithoutInertia {
            def {
                box(length=0.1, width=0.1, height=0.1)
                // No inertial properties
            }
        }
    }
}
