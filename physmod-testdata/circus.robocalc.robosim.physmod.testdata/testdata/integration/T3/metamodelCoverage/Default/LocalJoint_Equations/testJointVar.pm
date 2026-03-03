package testJointVar
pmodel testJointVar {
	local link base_link {
		
						pose { x=0.0 y=0.0 z=0.0 roll=0.0 pitch=0.0 yaw=0.0}
		def {
		}
		local joint my_joint {
			
									pose {x=0.0 y=0.0 z=0.12 roll=0.0 pitch=0.0 yaw=0.0}
			def {
				const G: real = 8.0
				annotation Gearbox{
					gearbox_ratio = G
				}
			}
			flexibly connected to second_link
		}
	}
	local link second_link {
		
						pose { x=0.0 y=0.0 z=0.12 roll=0.0 pitch=0.0 yaw=0.0}
		def {
		}
	}
}
