package BodyPlusSensorRef
 
	import physmod::sdf::annotations::*
pmodel BodyPlusSensorRef {
	local link Tip {
		def {
		}
		local body my_body {
			
									pose { x=0.0 y=0.0 z=0.9 roll=0.0 pitch=0.0 yaw=0.0}
			def {
				
											sphere  (radius=0.05)
			}
		}
		sref my_sensor_ref = my_sensor {
			
									pose {
										x=0.0
										y=0.0
										z=0.9
										roll=0.0
										pitch=0.0
										yaw=0.0
									}
		}
	}
}

	
	
sensor my_sensor {
	}
