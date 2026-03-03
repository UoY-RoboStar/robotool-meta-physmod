import physmod::Featherstone::joints::RevoluteJoint_Z

pmodel TestFeatherstoneRef {
    local link Base {
        def {}
        jref theta = RevoluteJoint_Z
    }
    local link Arm {
        def {}
    }
}
