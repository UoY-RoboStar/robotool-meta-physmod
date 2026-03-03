import physmod::SKO::joints::Revolute_x

pmodel TestBot {
    local link Core {
        def {}
        jref revolute_joint = Revolute_x
    }
    local link Arm {
        def {}
    }
}
