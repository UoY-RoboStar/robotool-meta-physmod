import physmod::math::*
import physmod::SKO::joints::Revolute_y

pmodel FourBarPlanarLinkage {
	// Four-bar planar linkage with SKO-style joint definitions
	// Reference geometry: link length 4.0 (along +X), ground length 2.0 (along +X)

	local link Ground {
		// Anchor the ground frame at the left pivot (x = 0.0).
		pose { x=0.0 y=0.0 z=0.0 roll=0.0 pitch=0.0 yaw=0.0 }
		def { }
		local body GroundBody {
			def {
				inertial information {
					mass 1.0
					inertia matrix { ixx 0.1 ixy 0.0 ixz 0.0 iyy 0.1 iyz 0.0 izz 0.1 }
					pose { x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
				}
				box ( length = 2.0 , width = 0.1 , height = 0.2 )
			}
			// Center ground geometry between pivots (x = 1.0 in world frame).
			pose { x = 1.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
		}
		jref theta1 = Revolute_y {
			flexibly connected to Link1
			// Left pivot at the ground origin.
			pose { x=0.0 y=0.0 z=0.0 roll=0.0 pitch=0.0 yaw=0.0 }
		}
		// Rocker joint at the right pivot (part of the spanning tree).
		jref theta4 = Revolute_y {
			flexibly connected to Link3
			pose { x=2.0 y=0.0 z=0.0 roll=0.0 pitch=0.0 yaw=0.0 }
		}
	}

	local link Link1 {
		pose { x=0.0 y=0.0 z=0.0 roll=0.0 pitch=0.0 yaw=0.0 }
		def { }
		local body Link1Body {
			def {
				inertial information {
					mass 20.0
					inertia matrix { ixx 0.025 ixy 0.0 ixz 0.0 iyy 26.6667 iyz 0.0 izz 26.6667 }
					pose { x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
				}
				box ( length = 4.0 , width = 0.1 , height = 0.2 )
			}
			pose { x = 2.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
		}
		jref theta2 = Revolute_y {
			flexibly connected to Link2
			pose { x=4.0 y=0.0 z=0.0 roll=0.0 pitch=0.0 yaw=0.0 }
		}
	}

	local link Link2 {
		pose { x=0.0 y=0.0 z=0.0 roll=0.0 pitch=0.0 yaw=0.0 }
		def { }
		local body Link2Body {
			def {
				inertial information {
					mass 20.0
					inertia matrix { ixx 0.025 ixy 0.0 ixz 0.0 iyy 26.6667 iyz 0.0 izz 26.6667 }
					pose { x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
				}
				box ( length = 4.0 , width = 0.1 , height = 0.2 )
			}
			pose { x = 2.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
		}
		jref theta3 = Revolute_y {
			flexibly connected to Link3
			pose { x=4.0 y=0.0 z=0.0 roll=0.0 pitch=0.0 yaw=0.0 }
		}
	}

	local link Link3 {
		pose { x=0.0 y=0.0 z=0.0 roll=0.0 pitch=0.0 yaw=0.0 }
		def { }
		local body Link3Body {
			def {
				inertial information {
					mass 20.0
					inertia matrix { ixx 0.025 ixy 0.0 ixz 0.0 iyy 26.6667 iyz 0.0 izz 26.6667 }
					pose { x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
				}
				box ( length = 4.0 , width = 0.1 , height = 0.2 )
			}
			pose { x = 2.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
		}
	}
}
