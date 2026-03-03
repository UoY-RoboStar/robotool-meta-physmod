import  physmod::math::* 
        pmodel SimpleArmSerial {
        InOut N: real = 2
	InOut B_k: Seq(matrix(real,4,4))
	InOut XJ_k: Seq(matrix(real,6,6))
	InOut theta: vector(real,2)
	InOut X_j: vector(real,3) 
	const L: real = 2
	const cos_theta: real
	const sin_theta: real
	
	// Initial conditions [t==0] 
	Constraint (theta)[t==0] == zeroVec(2)
	Constraint (cos_theta)[t==0] == 1
	Constraint (sin_theta)[t==0] == 0
	
	// Algebraic constraints [t==t] - these should be simplified with sin/cos expressions
	Constraint (cos_theta)[t == t] == cos(theta[0])
	Constraint (sin_theta)[t == t] == sin(theta[0])
	Constraint (X_j)[t == t] == (| L * cos_theta , L * sin_theta , 0 |)
	
	        solution{
                solutionExpr B_k: Seq(matrix(real,4,4))
                order 1
                group 1
                method Visual
        }
	
	local link BaseLink {
		def {
		const number : real = 1
		}
	}

}

function zeroVec ( a : real ) : vector ( real , 1 ) { } 