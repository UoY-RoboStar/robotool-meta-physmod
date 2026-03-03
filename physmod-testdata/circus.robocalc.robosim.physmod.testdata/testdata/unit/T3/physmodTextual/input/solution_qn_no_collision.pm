import physmod::math::*

pmodel TestQNs {
    const n: int = 3

    InOut tau: vector(real,2)
    InOut theta: vector(real,2)

    local link BaseLink {
        def {}
    }

    solution {
        solutionExpr tau : vector(real,2)
        order 1
        group 0
        method PlatformMapping
        Input n : int
        Constraint (n) [t==0] == 3
        Constraint (tau) [t==0] == zeroVec(2)
    }
}










































