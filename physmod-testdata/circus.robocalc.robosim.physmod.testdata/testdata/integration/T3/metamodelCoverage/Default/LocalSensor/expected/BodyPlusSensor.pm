package BodyPlusSensor
 
	import physmod::sdf::annotations::*
pmodel BodyPlusSensor {
	local link Tip {
		def {
		}
		local body my_body {
			
									pose { x=0.0 y=0.0 z=0.9 roll=0.0 pitch=0.0 yaw=0.0}
			def {
				
											sphere  (radius=0.05)
			}
		}
		local sensor my_sensor {
			def {
			}
		}
	}
}

	function sin(theta:real): real {}

    function cos(theta:real): real {}

	const PI: real = 3.1415
