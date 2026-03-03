package FlexibleConnection

// Tests the FlexibleConnection metamodel component
// FlexibleConnection connects a joint to another link

import physmod::math::*

pmodel FlexibleConnection {
	local link L1 {
		def { }
		local body B1 {
			def { box(length=0.1, width=0.1, height=0.1) }
		}
	}
	local link L2 {
		def { }
		local body B2 {
			def { box(length=0.1, width=0.1, height=0.1) }
		}
		local joint J1 {
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
			flexibly connected to L1
		}
	}
}
