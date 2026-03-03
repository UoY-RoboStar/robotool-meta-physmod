package testActuatorVar

pmodel testActuatorVar {
	local link L {
		pose { x=0.0 y=0.0 z=0.0 roll=0.0 pitch=0.0 yaw=0.0 }
		def {
			inertial information {
				mass 0.0
				inertia matrix { ixx 0.0 ixy 0.0 ixz 0.0 iyy 0.0 iyz 0.0 izz 0.0 }
			}
		}
		local actuator my_light {
			def {
				const G : boolean = true
				annotation Light {
					cast_shadows=false
				}
			}
		}
	}
}
