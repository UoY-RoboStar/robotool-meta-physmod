pmodel GeneratorServicesTestModel {
    // Test model for GeneratorServices headless functionality
    local phi: matrix(real,6,6)
    local B_k: matrix(real,4,4)
    
    // Simple variables for testing
    local x: real
    local y: real
    local theta: real
    
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
                box(length=0.2, width=0.05, height=0.05)
            }
        }
    }
}
