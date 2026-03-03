import physmod::math::*

pmodel TreeTopologySKO {
	// Base link with two branches
	local link Base {
		pose { x=0.0 y=0.0 z=0.0 roll=0.0 pitch=0.0 yaw=0.0 }
		def {
		}
		// First branch
		local joint theta1 {
			pose { x=0.0 y=0.0 z=0.0 roll=0.0 pitch=0.0 yaw=0.0 }
			def {
				const H : vector ( real , 6 ) = (| 0 , 0 , 1 , 0 , 0 , 0 |)
			}
			flexibly connected to LeftArm
		}
		// Second branch
		local joint theta2 {
			pose { x=0.0 y=0.0 z=0.0 roll=0.0 pitch=0.0 yaw=0.0 }
			def {
				const H : vector ( real , 6 ) = (| 0 , 0 , 1 , 0 , 0 , 0 |)
			}
			flexibly connected to RightArm
		}
	}
	// Left branch
	local link LeftArm {
		pose { x=-1.0 y=0.0 z=1.0 roll=0.0 pitch=0.0 yaw=0.0 }
		def {
		}
	}
	// Right branch
	local link RightArm {
		pose { x=1.0 y=0.0 z=1.0 roll=0.0 pitch=0.0 yaw=0.0 }
		def {
		}
	}
}

