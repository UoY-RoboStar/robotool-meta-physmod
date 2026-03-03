import physmod::math::*

pmodel TestEmptyMaps {
	local link Base {
		pose { x=0.0 y=0.0 z=0.0 roll=0.0 pitch=0.0 yaw=0.0 }
		def {
		}
		local joint theta {
			pose { x=0.0 y=0.0 z=0.0 roll=0.0 pitch=0.0 yaw=0.0 }
			def {
				const H : vector ( real , 6 ) = (| 0 , 0 , 1 , 0 , 0 , 0 |)
			}
			flexibly connected to Arm
		}
	}
	local link Arm {
		pose { x=0.0 y=0.0 z=1.0 roll=0.0 pitch=0.0 yaw=0.0 }
		def {
		}
	}
}
