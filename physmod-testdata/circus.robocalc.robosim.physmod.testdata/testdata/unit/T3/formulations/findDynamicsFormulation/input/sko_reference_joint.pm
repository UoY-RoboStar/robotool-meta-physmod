import physmod::SKO::joints::Revolute_z

pmodel TestSKORef {
    local link Base {
        def {}
        jref theta = Revolute_z
    }
    local link Arm {
        def {}
    }
}
