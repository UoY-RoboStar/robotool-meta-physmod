import physmod::trivial::sensors::TrivialSensor

pmodel ReferenceSensorTest {
    local link BaseLink {
        def {
            const number: nat = 0
        }
        local body BaseBody {
            def {
                box(length=0.1, width=0.1, height=0.1)
            }
        }
        sref mySensor = TrivialSensor {
            pose {
                x = 0.0
                y = 0.0
                z = 0.1
                roll = 0.0
                pitch = 0.0
                yaw = 0.0
            }
        }
    }
}
