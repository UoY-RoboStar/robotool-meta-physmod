import physmod::math::*

pmodel EqnCompMainUnit {
	local link Base {
		pose { x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
		def { }
		local body BaseBody {
			def {
				inertial information {
					mass 1.0
					inertia matrix { ixx 0.01 ixy 0.0 ixz 0.0 iyy 0.01 iyz 0.0 izz 0.01 }
					pose { x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
				}
				box(length = 0.1, width = 0.1, height = 0.1)
			}
			pose { x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
		}
		local joint Joint1 {
			pose { x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
			def {
				const H : vector ( real , 6 ) = (| 0 , 0 , 1 , 0 , 0 , 0 |)
			}
			flexibly connected to Link1
		}
	}
	local link Link1 {
		pose { x = 0.0 y = 0.0 z = 1.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
		def { }
		local body Link1Body {
			def {
				inertial information {
					mass 1.0
					inertia matrix { ixx 0.02 ixy 0.0 ixz 0.0 iyy 0.02 iyz 0.0 izz 0.02 }
					pose { x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
				}
				box(length = 0.1, width = 0.1, height = 0.1)
			}
			pose { x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
		}
	}
}
