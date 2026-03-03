pmodel TestScoping {
    const n: int = 3

    InOut theta: vector(real,2)
    InOut phi: matrix(real,18,18)
    InOut M: matrix(real,18,18)
    InOut H: matrix(real,2,18)
    InOut tau: vector(real,2)
    InOut C: vector(real,2)
    InOut M_mass: matrix(real,2,2)
    InOut M_inv: matrix(real,2,2)
    InOut dd_theta: vector(real,2)
    InOut d_theta: vector(real,2)
    InOut N: real

    local link BaseLink {
        def {}
    }

    solution {
        solutionExpr phi_sol : matrix(real,18,18)
        order 2
        group 0
        method Eval
        Input theta_in : vector(real,2)
        Input M_in : matrix(real,18,18)
        Input H_in : matrix(real,2,18)
        Constraint (n) [t==0] == 3
    }

    solution {
        solutionExpr C_sol : vector(real,2)
        order 3
        group 0
        method NewtonEulerInverseDynamics
        Input numLinks : int
        Input theta_in2 : vector(real,2)
        Input H_in2 : matrix(real,2,18)
        Input M_in2 : matrix(real,18,18)
        Constraint (n) [t==0] == 3
    }

    solution {
        solutionExpr M_mass_sol : matrix(real,2,2)
        order 4
        group 0
        method CompositeBodyAlgorithm
        Input H_in3 : matrix(real,2,18)
        Input linkCount : int
        Input M_in3 : matrix(real,18,18)
        Constraint (n) [t==0] == 3
    }
}
