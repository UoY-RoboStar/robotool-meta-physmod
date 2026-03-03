import physmod::trivial::bodies::TrivialBody

pmodel ReferenceBodyTest {
    local link BaseLink {
        def {
            const number: nat = 0
        }
        bref myBody = TrivialBody {
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
