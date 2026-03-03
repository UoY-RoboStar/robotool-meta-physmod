// Acrobot with ControlledMotor actuator (Featherstone formulation)
// Uses reference components from physmod-lib for joints, actuators, and sensors

import physmod::math::*
import physmod::Featherstone::joints::RevoluteJoint_Y
import physmod::trivial::actuators::ControlledMotor
import physmod::trivial::sensors::JointEncoder

pmodel Acrobot {
    local link BaseLink {
        def { InOut geom_01 : Geom = Geom (| geomType = "box" , geomVal = [| 0.2 , 0.2 , 0.2 |] |)
			local number : real = 0
			local poseVec : vector ( real , 6 ) = [| 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 |]
		}
        local body BaseBody {
            def {
                inertial information {
                    mass 0.1
                    inertia matrix { ixx 0.1 ixy 0.0 ixz 0.0 iyy 0.1 iyz 0.0 izz 0.1 }
                    pose { x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
                }
                box ( length = 0.2 , width = 0.2 , height = 0.2 )
            local number : real = 0
			}
            pose { x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
        }
		local joint ShoulderJoint {
			def {
				InOut q : real
				InOut qd : real
				InOut qdd : real
				InOut tau : real
				local poseVec : vector ( real , 6 ) = [| 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 |]
				local number : real = 1
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
		local sensor ShoulderEncoder {
			def {
				input ThetaIn : real
				input DThetaIn : real
				output AngleOut : real
				output VelocityOut : real
				equation AngleOut == ThetaIn
				equation VelocityOut == DThetaIn
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
        pose { x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
    }

    local link Link1 {
        def { InOut geom_11 : Geom = Geom (| geomType = "cylinder" , geomVal = [| 0.05 , 1.0 |] |)
			local number : real = 1
			local poseVec : vector ( real , 6 ) = [| 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 |]
		}
        local body Link1Body {
            def {
                inertial information {
                    mass 1.0
                    inertia matrix { ixx 0.083 ixy 0.0 ixz 0.0 iyy 0.083 iyz 0.0 izz 0.001 }
                    pose { x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
                }
                cylinder ( radius = 0.05 , length = 1.0 )
            local number : real = 0
			}
            pose { x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
        }
		local joint ElbowJoint {
			def {
				InOut q : real
				InOut qd : real
				InOut qdd : real
				InOut tau : real
				local poseVec : vector ( real , 6 ) = [| 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 |]
				local number : real = 2
			}
			flexibly connected to Link2
			local actuator ElbowMotor {
				def {
					input ControlIn : real
					output TorqueOut : real
					const B_ctrl : matrix ( real , 1 , 1 ) = [| 1.0 |]
					equation TorqueOut == B_ctrl * ControlIn
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
			pose {
				x = 0.0
				y = 0.0
				z = 0.0
				roll = 0.0
				pitch = 0.0
				yaw = 0.0
			}
		}
		local sensor ElbowEncoder {
			def {
				input ThetaIn : real
				input DThetaIn : real
				output AngleOut : real
				output VelocityOut : real
				equation AngleOut == ThetaIn
				equation VelocityOut == DThetaIn
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
        pose { x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
    }

    local link Link2 {
        def { InOut geom_21 : Geom = Geom (| geomType = "cylinder" , geomVal = [| 0.05 , 2.0 |] |)
			local number : real = 2
			local poseVec : vector ( real , 6 ) = [| 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 |]
		}
        local body Link2Body {
            def {
                inertial information {
                    mass 1.0
                    inertia matrix { ixx 0.333 ixy 0.0 ixz 0.0 iyy 0.333 iyz 0.0 izz 0.001 }
                    pose { x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
                }
                cylinder ( radius = 0.05 , length = 2.0 )
            local number : real = 0
			}
            pose { x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
        }
        pose { x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
    }
InOut n : int
	InOut N : int
	InOut dt : real
	InOut q : vector ( real , 2 )
	InOut d_q : vector ( real , 2 )
	InOut dd_q : vector ( real , 2 )
	InOut tau : vector ( real , 2 )
	InOut H : matrix ( real , 2 , 2 )
	InOut C : vector ( real , 2 )
	InOut damping : matrix ( real , 2 , 2 )
	InOut tau_d : vector ( real , 2 )
	InOut gravity : real
	InOut XT : Seq( matrix ( real , 6 , 6 ) )
	InOut I : Seq( matrix ( real , 6 , 6 ) )
	InOut jtype : Seq( int )
	InOut XT_1 : matrix ( real , 6 , 6 )
	InOut m_1 : real
	InOut I_C_1 : matrix ( real , 3 , 3 )
	InOut c_1 : vector ( real , 3 )
	InOut I_1 : matrix ( real , 6 , 6 )
	InOut XT_2 : matrix ( real , 6 , 6 )
	InOut m_2 : real
	InOut I_C_2 : matrix ( real , 3 , 3 )
	InOut c_2 : vector ( real , 3 )
	InOut I_2 : matrix ( real , 6 , 6 )
	InOut jtype_1 : int
	InOut jtype_2 : int
	equation submatrix ( I_1 ) ( 0 , 0 , 3 , 3 ) == I_C_1 + m_1 * transpose ( skew ( c_1 ) ) * skew ( c_1 )
	equation submatrix ( I_1 ) ( 0 , 3 , 3 , 3 ) == m_1 * skew ( c_1 )
	equation submatrix ( I_1 ) ( 3 , 0 , 3 , 3 ) == m_1 * transpose ( skew ( c_1 ) )
	equation submatrix ( I_1 ) ( 3 , 3 , 3 , 3 ) == m_1 * identity ( 3 )
	equation submatrix ( I_2 ) ( 0 , 0 , 3 , 3 ) == I_C_2 + m_2 * transpose ( skew ( c_2 ) ) * skew ( c_2 )
	equation submatrix ( I_2 ) ( 0 , 3 , 3 , 3 ) == m_2 * skew ( c_2 )
	equation submatrix ( I_2 ) ( 3 , 0 , 3 , 3 ) == m_2 * transpose ( skew ( c_2 ) )
	equation submatrix ( I_2 ) ( 3 , 3 , 3 , 3 ) == m_2 * identity ( 3 )
	equation XT == < [| 1 , 0 , 0 , 0 , 0 , 0 ; 0 , 1 , 0 , 0 , 0 , 0 ; 0 , 0 , 1 , 0 , 0 , 0 ; 0 , 0 , 0 , 1 , 0 , 0 ; 0 , 0 , 0 , 0 , 1 , 0 ; 0 , 0 , 0 , 0 , 0 , 1 |] , [| 1 , 0 , 0 , 0 , 0 , 0 ; 0 , 1 , 0 , 0 , 0 , 0 ; 0 , 0 , 1 , 0 , 0 , 0 ; 0 , - 1 , 0 , 1 , 0 , 0 ; 1 , 0 , 0 , 0 , 1 , 0 ; 0 , 0 , 0 , 0 , 0 , 1 |] >
	equation I == < [| 0.3329999968409538 , 0 , 0 , 0.0 , 0.5 , 0.0 ; 0 , 0.3329999968409538 , 0 , - 0.5 , 0.0 , 0.0 ; 0 , 0 , 0.0010000000474974513 , 0.0 , 0.0 , 0.0 ; 0.0 , - 0.5 , 0.0 , 1 , 0.0 , 0.0 ; 0.5 , 0.0 , 0.0 , 0.0 , 1 , 0.0 ; 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 1 |] , [| 1.3330000042915344 , 0 , 0 , 0.0 , 1 , 0.0 ; 0 , 1.3330000042915344 , 0 , - 1 , 0.0 , 0.0 ; 0 , 0 , 0.0010000000474974513 , 0.0 , 0.0 , 0.0 ; 0.0 , - 1 , 0.0 , 1 , 0.0 , 0.0 ; 1 , 0.0 , 0.0 , 0.0 , 1 , 0.0 ; 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 1 |] >
	equation jtype == < 1 , 1 >
	equation tau_d == damping * derivative ( q )
	equation tau == H * derivative ( derivative ( q ) ) + C + tau_d
	Constraint ( m_1 ) [ t == 0 ] == 1
	Constraint ( I_C_1 ) [ t == 0 ] == [| 0.08299999684095383 , 0 , 0 ; 0 , 0.08299999684095383 , 0 ; 0 , 0 , 0.0010000000474974513 |]
	Constraint ( c_1 ) [ t == 0 ] == [| 0 , 0 , - 0.5 |]
	Constraint ( I_1 ) [ t == 0 ] == [| 0.3329999968409538 , 0 , 0 , 0.0 , 0.5 , 0.0 ; 0 , 0.3329999968409538 , 0 , - 0.5 , 0.0 , 0.0 ; 0 , 0 , 0.0010000000474974513 , 0.0 , 0.0 , 0.0 ; 0.0 , - 0.5 , 0.0 , 1 , 0.0 , 0.0 ; 0.5 , 0.0 , 0.0 , 0.0 , 1 , 0.0 ; 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 1 |]
	Constraint ( XT_1 ) [ t == 0 ] == [| 1 , 0 , 0 , 0 , 0 , 0 ; 0 , 1 , 0 , 0 , 0 , 0 ; 0 , 0 , 1 , 0 , 0 , 0 ; 0 , 0 , 0 , 1 , 0 , 0 ; 0 , 0 , 0 , 0 , 1 , 0 ; 0 , 0 , 0 , 0 , 0 , 1 |]
	Constraint ( m_2 ) [ t == 0 ] == 1
	Constraint ( I_C_2 ) [ t == 0 ] == [| 0.3330000042915344 , 0 , 0 ; 0 , 0.3330000042915344 , 0 ; 0 , 0 , 0.0010000000474974513 |]
	Constraint ( c_2 ) [ t == 0 ] == [| 0 , 0 , - 1 |]
	Constraint ( I_2 ) [ t == 0 ] == [| 1.3330000042915344 , 0 , 0 , 0.0 , 1 , 0.0 ; 0 , 1.3330000042915344 , 0 , - 1 , 0.0 , 0.0 ; 0 , 0 , 0.0010000000474974513 , 0.0 , 0.0 , 0.0 ; 0.0 , - 1 , 0.0 , 1 , 0.0 , 0.0 ; 1 , 0.0 , 0.0 , 0.0 , 1 , 0.0 ; 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 1 |]
	Constraint ( XT_2 ) [ t == 0 ] == [| 1 , 0 , 0 , 0 , 0 , 0 ; 0 , 1 , 0 , 0 , 0 , 0 ; 0 , 0 , 1 , 0 , 0 , 0 ; 0 , - 1 , 0 , 1 , 0 , 0 ; 1 , 0 , 0 , 0 , 1 , 0 ; 0 , 0 , 0 , 0 , 0 , 1 |]
	Constraint ( XT ) [ t == 0 ] == < [| 1 , 0 , 0 , 0 , 0 , 0 ; 0 , 1 , 0 , 0 , 0 , 0 ; 0 , 0 , 1 , 0 , 0 , 0 ; 0 , 0 , 0 , 1 , 0 , 0 ; 0 , 0 , 0 , 0 , 1 , 0 ; 0 , 0 , 0 , 0 , 0 , 1 |] , [| 1 , 0 , 0 , 0 , 0 , 0 ; 0 , 1 , 0 , 0 , 0 , 0 ; 0 , 0 , 1 , 0 , 0 , 0 ; 0 , - 1 , 0 , 1 , 0 , 0 ; 1 , 0 , 0 , 0 , 1 , 0 ; 0 , 0 , 0 , 0 , 0 , 1 |] >
	Constraint ( I ) [ t == 0 ] == < [| 0.3329999968409538 , 0 , 0 , 0.0 , 0.5 , 0.0 ; 0 , 0.3329999968409538 , 0 , - 0.5 , 0.0 , 0.0 ; 0 , 0 , 0.0010000000474974513 , 0.0 , 0.0 , 0.0 ; 0.0 , - 0.5 , 0.0 , 1 , 0.0 , 0.0 ; 0.5 , 0.0 , 0.0 , 0.0 , 1 , 0.0 ; 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 1 |] , [| 1.3330000042915344 , 0 , 0 , 0.0 , 1 , 0.0 ; 0 , 1.3330000042915344 , 0 , - 1 , 0.0 , 0.0 ; 0 , 0 , 0.0010000000474974513 , 0.0 , 0.0 , 0.0 ; 0.0 , - 1 , 0.0 , 1 , 0.0 , 0.0 ; 1 , 0.0 , 0.0 , 0.0 , 1 , 0.0 ; 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 1 |] >
	Constraint ( jtype_1 ) [ t == 0 ] == 1
	Constraint ( jtype_2 ) [ t == 0 ] == 1
	Constraint ( jtype ) [ t == 0 ] == < 1 , 1 >
}
datatype Geom { geomType : string geomVal : vector ( real ) meshUri : string meshScale : vector ( real ) } function identity ( size : real ) : matrix ( real , 3 , 3 ) { } function skew ( v : vector ( real , 3 ) ) : matrix ( real , 3 , 3 ) { }