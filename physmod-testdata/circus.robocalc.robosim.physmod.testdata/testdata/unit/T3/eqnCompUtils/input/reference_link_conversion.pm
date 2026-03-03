import physmod::trivial::links::TrivialLink

pmodel ReferenceLinkTest {
    lref myLink = TrivialLink {
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
