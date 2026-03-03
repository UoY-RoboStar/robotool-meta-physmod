package testflexible

import physmod::math::*

pmodel testflexible {
	local link L1 {
		pose {
			x = 0
			y = 0
			z = 0.05
			roll = 0
			pitch = 0
			yaw = 0
		}
		def {
		}
		local body B1 {
			def {
				box(length=0.1,width=0.1,height=0.1)
			}
		}
		local joint R {
			def {
				const H : vector ( real , 6 ) = [| 1 , 0 , 0 , 0 , 0 , 0 |]
				InOut theta : real
				InOut XJ : matrix ( real , 6 , 6 )
				equation XJ == [|
					1 , 0 , 0 , 0 , 0 , 0 ;
					0 , cos ( theta ) , - sin ( theta ) , 0 , 0 , 0 ;
					0 , sin ( theta ) , cos ( theta ) , 0 , 0 , 0 ;
					0 , 0 , 0 , 1 , 0 , 0 ;
					0 , 0 , 0 , 0 , cos ( theta ) , - sin ( theta ) ;
					0 , 0 , 0 , 0 , sin ( theta ) , cos ( theta )
				|]
			}
			flexibly connected to L2
		}
	}
	local link L2 {
		pose {
			x = 0
			y = 0
			z = 0.1
			roll = 0
			pitch = 0
			yaw = 0
		}
		def {}
		local body B2 {
			def {
				box(length=0.1,width=0.1,height=0.1)
			}
		}
	}
}
