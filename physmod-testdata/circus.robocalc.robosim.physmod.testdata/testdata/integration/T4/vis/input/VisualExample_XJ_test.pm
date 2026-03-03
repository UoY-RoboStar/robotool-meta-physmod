import physmod::math::*
pmodel SimpleXJTest {
    InOut theta_1: real
    InOut theta_2: real  
    InOut XJ_1: matrix(real,6,6)
    InOut XJ_2: matrix(real,6,6)
    
    solution{
        solutionExpr XJ_1: matrix(real,6,6)
        order 1
        group 1
        method Visual
    }
    
    local link L1 {
        def {
            const number: real = 1
        }
        
        local joint J1 {
            def {
                const H: vector(real,6) = (|0,0,1,0,0,0|)
                InOut theta_1: real
                InOut XJ: matrix(real,6,6)
                
                // Algebraic equation for XJ with trigonometric functions
                equation XJ == [| 1, 0, 0, 0, 0, 0 ;
                                 0, cos(theta_1), -sin(theta_1), 0, 0, 0 ;
                                 0, sin(theta_1), cos(theta_1), 0, 0, 0 ;
                                 0, 0, 0, 1, 0, 0 ;
                                 0, 0, 0, 0, cos(theta_1), -sin(theta_1) ;
                                 0, 0, 0, 0, sin(theta_1), cos(theta_1) |]
                
                // Initial condition
                Constraint (XJ)[t==0] == [| 1, 0, 0, 0, 0, 0 ;
                                           0, 1, 0, 0, 0, 0 ;
                                           0, 0, 1, 0, 0, 0 ;
                                           0, 0, 0, 1, 0, 0 ;
                                           0, 0, 0, 0, 1, 0 ;
                                           0, 0, 0, 0, 0, 1 |]
            }
            relation theta_1 == J1.theta_1
            relation XJ_1 == J1.XJ
        }
    }
    
    local link L2 {
        def {
            const number: real = 2
        }
        
        local joint J2 {
            def {
                const H: vector(real,6) = (|1,0,0,0,0,0|)
                InOut theta_2: real
                InOut XJ: matrix(real,6,6)
                
                // Algebraic equation for XJ with trigonometric functions
                equation XJ == [| cos(theta_2), 0, sin(theta_2), 0, 0, 0 ;
                                 0, 1, 0, 0, 0, 0 ;
                                 -sin(theta_2), 0, cos(theta_2), 0, 0, 0 ;
                                 0, 0, 0, cos(theta_2), 0, sin(theta_2) ;
                                 0, 0, 0, 0, 1, 0 ;
                                 0, 0, 0, -sin(theta_2), 0, cos(theta_2) |]
                
                // Initial condition
                Constraint (XJ)[t==0] == [| 1, 0, 0, 0, 0, 0 ;
                                           0, 1, 0, 0, 0, 0 ;
                                           0, 0, 1, 0, 0, 0 ;
                                           0, 0, 0, 1, 0, 0 ;
                                           0, 0, 0, 0, 1, 0 ;
                                           0, 0, 0, 0, 0, 1 |]
            }
            relation theta_2 == J2.theta_2
            relation XJ_2 == J2.XJ
        }
    }
}