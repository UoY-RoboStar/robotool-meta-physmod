package BodyPlusSonarSensor

import physmod::sdf::annotations::*

function sin(theta:real): real {}
function cos(theta:real): real {}
const PI: real = 3.1415

pmodel BodySensorIndex {
	local link Tip {
		pose { x=0.0 y=0.0 z=0.0 roll=0.0 pitch=0.0 yaw=0.0 }
		def {
			inertial information {
				mass 0.0
				inertia matrix { ixx 0.0 ixy 0.0 ixz 0.0 iyy 0.0 iyz 0.0 izz 0.0 }
			}
		}
		local body my_body {
			pose { x=0.0 y=0.0 z=0.9 roll=0.0 pitch=0.0 yaw=0.0 }
			def {
				sphere (radius=0.05)
			}
		}
		local sensor my_sensor {
			index i : [0,24)
			pose {
				x=(8*cos(2*i*PI/24)/100)m
				y=(8*sin(2*i*PI/24)/100)m
				z=0.0025m
				roll=0.0
				pitch=PI/2
				yaw=2*i*PI //24
			}
			def {
			}
		}
	}
}
