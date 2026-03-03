package TwoBodiesPlusJoint
pmodel TwoBodiesPlusJoint {
	local link base_link {
		
						pose { x=0.0 y=0.0 z=0.0 roll=0.0 pitch=0.0 yaw=0.0}
		def {
			
								inertial information{ 
								mass 10.0
								inertia matrix {ixx 0.4 ixy 0.0 ixz 0.0 iyy 0.4 iyz 0.0 izz 0.2}
								}
		}
		local body base_body {
			def {
				
											cylinder (radius=0.05, length=0.24)
			}
		}
		local joint my_joint {
			
									pose {x=0.0 y=0.0 z=0.12 roll=0.0 pitch=0.0 yaw=0.0}
			def {
			}
			flexibly connected to second_link
		}
	}
	local link second_link {
		
						pose { x=0.0 y=0.0 z=0.12 roll=0.0 pitch=0.0 yaw=0.0}
		def {
			
								inertial information{ 
								mass 10.0
								inertia matrix {ixx 0.0 ixy 0.0002835 ixz 0.0 iyy 0.0002835 iyz 0.0 izz 0.000324}
								}
		}
		local body second_body {
			def {
				
											cylinder (radius=0.03, length=0.24)
			}
		}
	}
}
