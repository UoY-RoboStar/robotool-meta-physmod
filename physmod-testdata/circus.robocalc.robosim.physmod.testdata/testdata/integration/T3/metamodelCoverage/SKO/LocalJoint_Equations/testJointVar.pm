package testJointVar

import physmod::math::*

pmodel testJointVar {
	local link base_link {
		pose { x=0.0 y=0.0 z=0.0 roll=0.0 pitch=0.0 yaw=0.0}
		def { }
		local joint my_joint {
			pose {x=0.0 y=0.0 z=0.12 roll=0.0 pitch=0.0 yaw=0.0}
			def {
				const H : vector ( real , 6 ) = [| 1 , 0 , 0 , 0 , 0 , 0 |]
				const G: real = 8.0
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
				annotation Gearbox{
					gearbox_ratio = G
				}
			}
			flexibly connected to second_link
		}
	}
	local link second_link {
		pose { x=0.0 y=0.0 z=0.12 roll=0.0 pitch=0.0 yaw=0.0}
		def { }
	}
}
