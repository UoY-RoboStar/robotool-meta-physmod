package BodyCyliner
	import physmod::sdf::annotations::*
	pmodel BodyCylinder {
		local link Tip {
			def{}
			local body my_body {
				pose { x=0.0 y=0.0 z=0.9 roll=0.0 pitch=0.0 yaw=0.0}
				def {
					cylinder	(radius=0.3, length=0.1)
				}
			}	
		}	
	}
