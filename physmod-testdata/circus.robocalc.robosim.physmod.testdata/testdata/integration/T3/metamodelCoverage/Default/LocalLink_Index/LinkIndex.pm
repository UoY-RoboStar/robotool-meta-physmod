package LinkIndex
	import physmod::sdf::annotations::*
	pmodel LinkIndex {
		local link Tip {
			def{}
			index i : [1,4]
			pose {
				x = 0.0
				y = 0.0
				z = 0.0
				roll = 0.0
				pitch = 0
				yaw = i 
			}		
		}	
	}