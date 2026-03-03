package BodyIndex
	import physmod::sdf::annotations::*
	import physmod::math::*
	pmodel BodyIndex {
		local link Tip {
			def{}		
			local body my_body {
				index i:[1,3]
				def {
					sphere  (radius=i)	
					bounce {
						restitution coefficient 0.2 
						threshold 99000
					}
				}
			}					
		}	
	}