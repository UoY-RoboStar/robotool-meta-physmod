pmodel TestModelFourLinks {
    local link LinkD {
        def {
            const number: nat = 4
        }
        local body BodyD {
            def {
                box(length=0.1, width=0.1, height=0.1)
            }
        }
    }
    local link LinkB {
        def {
            const number: nat = 2
        }
        local body BodyB {
            def {
                box(length=0.1, width=0.1, height=0.1)
            }
        }
    }
    local link LinkA {
        def {
            const number: nat = 1
        }
        local body BodyA {
            def {
                box(length=0.1, width=0.1, height=0.1)
            }
        }
    }
    local link LinkC {
        def {
            const number: nat = 3
        }
        local body BodyC {
            def {
                box(length=0.1, width=0.1, height=0.1)
            }
        }
    }
}
