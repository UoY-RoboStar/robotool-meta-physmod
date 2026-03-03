import physmod::math::*
import physmod::CGA::joints::RevoluteJoint_CGA
import physmod::CGA::joints::*

pmodel Acrobot {
	InOut L1_geom: Geom
	InOut L2_geom: Geom
	InOut L3_geom: Geom
	InOut Lk_geom: Seq(Geom)

	InOut theta: vector(real,2)
	InOut d_theta: vector(real,2)

	Constraint (theta)[t==0] == (|1.0, 1.0|)
	Constraint (d_theta)[t==0] == zeroVec(2)

	Constraint (L1_geom.geomType)[t==0] == "cylinder"
	Constraint (L1_geom.geomVal)[t==0] == [|0.05, 1.0|]
	Constraint (L2_geom.geomType)[t==0] == "cylinder"
	Constraint (L2_geom.geomVal)[t==0] == [|0.05, 2.0|]
	Constraint (L3_geom.geomType)[t==0] == "sphere"
	Constraint (L3_geom.geomVal)[t==0] == [|0.08|]
	Constraint (Lk_geom)[t==0] == <L1_geom, L2_geom, L3_geom>

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
		jref ShoulderJoint = RevoluteJoint_CGA {
			flexibly connected to Link1
			pose { x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
		}
		pose { x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
	}

	local link Link1 {
		def { }
		local body Link1Body {
			def {
				inertial information {
					mass 1.0
					inertia matrix { ixx 0.083 ixy 0.0 ixz 0.0 iyy 0.083 iyz 0.0 izz 0.001 }
					pose { x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
				}
				cylinder ( radius = 0.05 , length = 1.0 )
			}
			pose { x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
		}
		jref ElbowJoint = RevoluteJoint_CGA {
			flexibly connected to Link2
			pose { x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
		}
		pose { x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
	}

	local link Link2 {
		def { }
		local body Link2Body {
			def {
				inertial information {
					mass 1.0
					inertia matrix { ixx 0.333 ixy 0.0 ixz 0.0 iyy 0.333 iyz 0.0 izz 0.001 }
					pose { x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
				}
				cylinder ( radius = 0.05 , length = 2.0 )
			}
			pose { x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
		}
		pose { x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
	}
}
