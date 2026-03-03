import physmod::math::*

pmodel SerialChainThreeLink {
	local link Base {
		pose { x=0.0 y=0.0 z=0.0 roll=0.0 pitch=0.0 yaw=0.0 }
		def {
		}
		local joint theta1 {
			pose { x=0.0 y=0.0 z=0.0 roll=0.0 pitch=0.0 yaw=0.0 }
			def {
				const H : vector ( real , 6 ) = (| 0 , 0 , 1 , 0 , 0 , 0 |)
			}
			flexibly connected to Link1
		}
	}
	local link Link1 {
		pose { x=0.0 y=0.0 z=1.0 roll=0.0 pitch=0.0 yaw=0.0 }
		def {
		}
		local joint theta2 {
			pose { x=0.0 y=0.0 z=0.0 roll=0.0 pitch=0.0 yaw=0.0 }
			def {
				const H : vector ( real , 6 ) = (| 0 , 0 , 1 , 0 , 0 , 0 |)
			}
			flexibly connected to Link2
		}
	}
	local link Link2 {
		pose { x=0.0 y=0.0 z=2.0 roll=0.0 pitch=0.0 yaw=0.0 }
		def {
		}
	}
}
