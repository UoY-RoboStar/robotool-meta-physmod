package BodyBox
	import physmod::sdf::annotations::*
	pmodel BodyBox {
		local link Tip {
			def{}
			local body my_body {
				pose { x=0.0 y=0.0 z=0.9 roll=0.0 pitch=0.0 yaw=0.0}
				def {
					box	(length=0.1, width=0.2, height=0.3)
				}
			}	
		}	
	}