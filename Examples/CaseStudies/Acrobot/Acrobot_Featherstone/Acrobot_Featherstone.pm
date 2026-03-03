import physmod::math::*
import physmod::Featherstone::joints::RevoluteJoint_Y

pmodel Acrobot_Featherstone {
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
		// ShoulderJoint - revolute about y-axis (Featherstone joint library)
		jref ShoulderJoint = RevoluteJoint_Y {
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
		// ElbowJoint - revolute about y-axis (Featherstone joint library)
		jref ElbowJoint = RevoluteJoint_Y {
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
