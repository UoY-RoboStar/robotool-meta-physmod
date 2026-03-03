pmodel SimpleTestModel {
    const test: int = 1
    
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
    local link Link2 {
        def {
            const number: nat = 2
        }
        local body Body2 {
            def {
                box(length=0.2, width=0.2, height=0.2)
            }
        }
    }
}
