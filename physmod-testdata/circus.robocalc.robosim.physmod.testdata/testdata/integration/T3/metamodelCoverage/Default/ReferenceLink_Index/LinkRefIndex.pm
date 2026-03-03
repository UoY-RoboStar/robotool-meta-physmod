package LinkRefIndex
	import physmod::sdf::annotations::*
	import physmod::math::*
	pmodel LinkRefIndex {
		lref my_link=Tip {
				index i : [0,4)
				pose {
					x = (0.085*cos(i*3.14159/4))m
					y = (0.085*sin(i*3.14159/4))m
					z = 0.0
					roll = 0.0
					pitch = 0
					yaw = i*3.14159/4 
				}	
		}
	}
	
	link Tip{}