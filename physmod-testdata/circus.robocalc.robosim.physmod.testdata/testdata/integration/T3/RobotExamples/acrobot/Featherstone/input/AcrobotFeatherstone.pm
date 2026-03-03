import physmod::math::*

pmodel AcrobotFeatherstone {
	// BaseLink - fixed base with base body
	local link BaseLink {
		def { }
		local body BaseBody {
			def {
				inertial information {
					mass 0.1
					inertia matrix { ixx 0.1 ixy 0.0 ixz 0.0 iyy 0.1 iyz 0.0 izz 0.1 }
					pose { x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
				}
				box ( length = 0.2 , width = 0.2 , height = 0.2 )
			}
			pose { x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
		}
		// ShoulderJoint - revolute about y-axis using Featherstone/RBDL formulation
		// Uses 'S' (motion subspace) to trigger Featherstone detection
		// Uses 'X_lambda' (total spatial transform) following RBDL naming
		local joint ShoulderJoint {
			def {
				// RBDL motion subspace for revolute y-axis: S = [0,1,0,0,0,0]^T
				const S : vector ( real , 6 ) = (| 0 , 1 , 0 , 0 , 0 , 0 |)
				InOut q : real
				InOut X_lambda : matrix ( real , 6 , 6 )
				// X_lambda: total spatial transform (X_J * X_T) for rotation about y
				equation X_lambda == [| cos ( q ) , 0 , - sin ( q ) , 0 , 0 , 0 ;
				                        0 , 1 , 0 , 0 , 0 , 0 ;
				                        sin ( q ) , 0 , cos ( q ) , 0 , 0 , 0 ;
				                        0 , 0 , 0 , cos ( q ) , 0 , - sin ( q ) ;
				                        0 , 0 , 0 , 0 , 1 , 0 ;
				                        0 , 0 , 0 , sin ( q ) , 0 , cos ( q ) |]
			}
			flexibly connected to Link1
			pose { x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
		}
		pose { x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
	}

	// Link1 - first pendulum link
	// RBDL parameters: m=1.0kg, l=1.0m, COM at (0,0.5,0) relative to link frame
	// Inertia: Ixx=Izz=ml^2/3=0.333, Iyy=ml^2/30=0.033
	local link Link1 {
		def { }
		local body Link1Body {
			def {
				inertial information {
					mass 1.0
					inertia matrix { ixx 0.333 ixy 0.0 ixz 0.0 iyy 0.033 iyz 0.0 izz 0.333 }
					pose { x = 0.0 y = 0.5 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
				}
				cylinder ( radius = 0.05 , length = 1.0 )
			}
			pose { x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
		}
		// ElbowJoint - revolute about y-axis (local frame)
		local joint ElbowJoint {
			def {
				// RBDL motion subspace for revolute y-axis
				const S : vector ( real , 6 ) = (| 0 , 1 , 0 , 0 , 0 , 0 |)
				InOut q : real
				InOut X_lambda : matrix ( real , 6 , 6 )
				// X_lambda: total spatial transform for rotation about y
				equation X_lambda == [| cos ( q ) , 0 , - sin ( q ) , 0 , 0 , 0 ;
				                        0 , 1 , 0 , 0 , 0 , 0 ;
				                        sin ( q ) , 0 , cos ( q ) , 0 , 0 , 0 ;
				                        0 , 0 , 0 , cos ( q ) , 0 , - sin ( q ) ;
				                        0 , 0 , 0 , 0 , 1 , 0 ;
				                        0 , 0 , 0 , sin ( q ) , 0 , cos ( q ) |]
			}
			flexibly connected to Link2
			pose { x = 0.0 y = 1.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
		}
		pose { x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
	}

	// Link2 - second pendulum link (end effector)
	// RBDL parameters: m=1.0kg, l=1.0m, COM at (0.5,0,0)
	// Inertia: Ixx=ml^2/30=0.033, Iyy=Izz=ml^2/3=0.333
	local link Link2 {
		def { }
		local body Link2Body {
			def {
				inertial information {
					mass 1.0
					inertia matrix { ixx 0.033 ixy 0.0 ixz 0.0 iyy 0.333 iyz 0.0 izz 0.333 }
					pose { x = 0.5 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
				}
				cylinder ( radius = 0.05 , length = 1.0 )
			}
			pose { x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
		}
		pose { x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
	}
}
