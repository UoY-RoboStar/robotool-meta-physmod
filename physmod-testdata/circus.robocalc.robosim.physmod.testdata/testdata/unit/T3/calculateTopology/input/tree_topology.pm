import physmod::math::*

pmodel TreeTopology {
	local link Base {
		pose { x=0.0 y=0.0 z=0.0 roll=0.0 pitch=0.0 yaw=0.0 }
		def {
		}
		local joint thetaLeft {
			pose { x=0.0 y=-0.5 z=0.0 roll=0.0 pitch=0.0 yaw=0.0 }
			def {
				const H : vector ( real , 6 ) = (| 0 , 0 , 1 , 0 , 0 , 0 |)
			}
			flexibly connected to LeftArm
		}
		local joint thetaRight {
			pose { x=0.0 y=0.5 z=0.0 roll=0.0 pitch=0.0 yaw=0.0 }
			def {
				const H : vector ( real , 6 ) = (| 0 , 0 , 1 , 0 , 0 , 0 |)
			}
			flexibly connected to RightArm
		}
	}
	local link LeftArm {
		pose { x=0.0 y=-0.5 z=1.0 roll=0.0 pitch=0.0 yaw=0.0 }
		def {
		}
	}
	local link RightArm {
		pose { x=0.0 y=0.5 z=1.0 roll=0.0 pitch=0.0 yaw=0.0 }
		def {
		}
	}
}
