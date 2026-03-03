package SimpleBody

import physmod::sdf::annotations::*

pmodel SimpleBody {
	local link Tip {
		pose { x=0.0 y=0.0 z=0.9 roll=0.0 pitch=0.0 yaw=0.0 }
		def {
			inertial information {
				mass 0.0
				inertia matrix { ixx 0.0 ixy 0.0 ixz 0.0 iyy 0.0 iyz 0.0 izz 0.0 }
			}
		}
		local body my_body {
			def {
				sphere (radius=0.05)
			}
		}
	}
}
