package BodyRefSphere
	import physmod::sdf::annotations::*
	pmodel BodyRefSphere{
		local link Tip {
			def{}
		local body my_body_ref {
			def {
				sphere ( radius = 0.05 )
			}
			pose {
				x = 0.0
				y = 0.0
				z = 0.9
				roll = 0.0
				pitch = 0.0
				yaw = 0.0
			}
		}	
		}	
	}
	
	
body my_body{
	sphere  (radius=0.05)
}
