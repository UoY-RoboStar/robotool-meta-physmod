import physmod::math::* pmodel ThreeLinkChainSKO {
	local link Base {
		def {
			local number : real = 3
			local poseVec : vector ( real , 6 ) = [| 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 |]
		}
		local joint theta1 {
			def {
				local number : real = 2
				local poseVec : vector ( real , 6 ) = [| 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 |]
				const H : vector ( real , 6 ) = (| 0 , 0 , 1 , 0 , 0 , 0 |)
			}
			flexibly connected to Link1
			pose {
				x = 0.0
				y = 0.0
				z = 0.0
				roll = 0.0
				pitch = 0.0
				yaw = 0.0
			}
		}
		pose {
			x = 0.0
			y = 0.0
			z = 0.0
			roll = 0.0
			pitch = 0.0
			yaw = 0.0
		}
	}
	local link Link1 {
		def {
			local number : real = 2
			local poseVec : vector ( real , 6 ) = [| 0.0 , 0.0 , 1.0 , 0.0 , 0.0 , 0.0 |]
		}
		local joint theta2 {
			def {
				local number : real = 1
				local poseVec : vector ( real , 6 ) = [| 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 |]
				const H : vector ( real , 6 ) = (| 0 , 0 , 1 , 0 , 0 , 0 |)
			}
			flexibly connected to Link2
			pose {
				x = 0.0
				y = 0.0
				z = 0.0
				roll = 0.0
				pitch = 0.0
				yaw = 0.0
			}
		}
		pose {
			x = 0.0
			y = 0.0
			z = 1.0
			roll = 0.0
			pitch = 0.0
			yaw = 0.0
		}
	}
	local link Link2 {
		def {
			local number : real = 1
			local poseVec : vector ( real , 6 ) = [| 0.0 , 0.0 , 2.0 , 0.0 , 0.0 , 0.0 |]
		}
		pose {
			x = 0.0
			y = 0.0
			z = 2.0
			roll = 0.0
			pitch = 0.0
			yaw = 0.0
		}
	}
}
