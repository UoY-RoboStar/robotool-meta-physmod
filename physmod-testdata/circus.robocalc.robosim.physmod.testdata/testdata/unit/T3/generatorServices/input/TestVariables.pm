import physmod::math::*

pmodel TestVariables {
	const n: nat = 3
	const T: real = 1.5
	const PI: real = 3.14159
	
	InOut position: vector(real, 3)
	InOut velocity: vector(real, 3)
	InOut theta: vector(real, 2)
	InOut tau: vector(real, 2)
	InOut m: real
	InOut len: real
	InOut r_v1: int = 1
	InOut N: real = 2
	
	local testVar: real
	local counter: int
	local flag: boolean
	
	equation position == velocity * T
	equation tau == m * 9.81
	
	local link TestLink {
		def { }
		local body TestBody {
			def {
				box(length=1, width=1, height=1)
			}
		}
	}
}
