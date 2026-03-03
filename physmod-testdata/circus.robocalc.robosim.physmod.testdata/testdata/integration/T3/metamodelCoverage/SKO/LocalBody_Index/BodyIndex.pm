package BodyIndex

import physmod::sdf::annotations::*
import physmod::math::*

pmodel BodyIndex {
	local link Tip {
		pose { x=0.0 y=0.0 z=0.0 roll=0.0 pitch=0.0 yaw=0.0 }
		def {
			inertial information {
				mass 0.0
				inertia matrix { ixx 0.0 ixy 0.0 ixz 0.0 iyy 0.0 iyz 0.0 izz 0.0 }
			}
		}
		local body my_body {
			index i : [1,3]
			def {
				sphere (radius=i)
				bounce {
					restitution coefficient 0.2
					threshold 99000
				}
			}
		}
	}
}
