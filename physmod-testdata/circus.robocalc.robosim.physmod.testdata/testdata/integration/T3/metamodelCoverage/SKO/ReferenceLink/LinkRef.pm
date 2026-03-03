package LinkRef
	import physmod::sdf::annotations::*
	import physmod::math::*
 	pmodel LinkRef {
		lref my_link=Tip {
				pose {
					x = 0.0
					y = 0.0
					z = 0.0
					roll = 0.0
					pitch = 0.0
					yaw = 0.0
				}	
		}
	}

	//When I delete the pose, it shows error. why?
	
	link Tip{
		inertial information{ 
			mass 5.7
			inertia matrix {ixx 0.0 ixy 1.0 ixz 2.3 iyy 1.2 iyz 0.5 izz 0.0}
		}
	}