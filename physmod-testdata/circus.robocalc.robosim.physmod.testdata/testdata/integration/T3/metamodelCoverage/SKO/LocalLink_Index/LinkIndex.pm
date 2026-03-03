package LinkIndex

import physmod::sdf::annotations::*

pmodel LinkIndex {
	local link Tip {
		index i : [1,4]
		pose { x=0.0 y=0.0 z=0.0 roll=0.0 pitch=0.0 yaw=i }
		def {
			inertial information {
				mass 0.0
				inertia matrix { ixx 0.0 ixy 0.0 ixz 0.0 iyy 0.0 iyz 0.0 izz 0.0 }
			}
		}
	}
}
