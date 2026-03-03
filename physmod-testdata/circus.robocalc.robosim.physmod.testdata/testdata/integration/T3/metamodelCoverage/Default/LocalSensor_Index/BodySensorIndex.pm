package BodyPlusSonarSensor
 
	import physmod::sdf::annotations::*
pmodel BodySensorIndex {
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
			
								index i : [0,24)
			
									pose {
										x=(8*cos(2*i*PI/24)/100)m
										y=(8*sin(2*i*PI/24)/100)m
										z=0.0025m
										roll=0.0
										pitch=PI/2
										yaw=2*i*PI //24
									}
			def {
			}
		}
	}
}

	function sin(theta:real): real {}

    function cos(theta:real): real {}

	const PI: real = 3.1415
