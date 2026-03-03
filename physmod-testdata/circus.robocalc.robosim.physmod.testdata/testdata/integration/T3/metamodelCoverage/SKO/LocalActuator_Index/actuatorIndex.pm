package actuatorIndex

pmodel actuatorIndex {
	local link L1 {
		pose { x=0 y=0 z=0.05 roll=0 pitch=0 yaw=0 }
		def {
			inertial information {
				mass 0.0
				inertia matrix { ixx 0.0 ixy 0.0 ixz 0.0 iyy 0.0 iyz 0.0 izz 0.0 }
			}
		}
		local body B1 {
			def {
				box(length=0.1, width=0.1, height=0.1)
			}
		}
		local actuator A {
			index i : [0,4)
			pose { x=i y=i+1 z=i+2 roll=i+3 pitch=i+4 yaw=i+4 }
			def {
				annotation Light {
				}
			}
		}
	}
	local link L2 {
		pose { x=0 y=0 z=0.1 roll=0 pitch=0 yaw=0 }
		def {
			inertial information {
				mass 0.0
				inertia matrix { ixx 0.0 ixy 0.0 ixz 0.0 iyy 0.0 iyz 0.0 izz 0.0 }
			}
		}
		local body B2 {
			def {
				box(length=0.1, width=0.1, height=0.1)
			}
		}
	}
}
