pmodel TestModelNoRefJoints {
    local link Link1 {
        def {
            const number: nat = 1
        }
        local body Body1 {
            def {
                box(length=0.1, width=0.1, height=0.1)
            }
        }
    }
}
