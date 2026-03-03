package BodyRefCylinder
	import physmod::sdf::annotations::*
	pmodel BodyRefCylinder {
		local link Tip {
			def{}
			bref my_body_ref=my_body{
				pose { x=0.0 y=0.0 z=0.9 roll=0.0 pitch=0.0 yaw=0.0}		
			}	
		}	
	}
	
	body my_body{
		cylinder (radius = 0.1, length = 1.2)
	}