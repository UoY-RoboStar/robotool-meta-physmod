import physmod::math::*
import physmod::CGA::joints::RevoluteJoint_CGA
import physmod::CGA::joints::*

pmodel AcrobotCGA {
	local link BaseLink {
		def { InOut geom_31 : Geom = Geom (| geomType = "box" , geomVal = [| 0.2 , 0.2 , 0.2 |] |)
			local number : real = 3
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
				InOut axis_rot : vector ( real , 3 ) = (| 0 , 1 , 0 |)
				InOut motor_frame : vector ( real , 8 )
				InOut motor_joint : vector ( real , 8 )
				local number : real = 2
				local poseVec : vector ( real , 6 ) = [| 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 |]
				equation motor_joint == motorProduct ( motor_frame , (| cos ( 0.5 * q ) , sin ( 0.5 * q ) * axis_rot [ 0 ] , sin ( 0.5 * q ) * axis_rot [ 1 ] , sin ( 0.5 * q ) * axis_rot [ 2 ] , 0 , 0 , 0 , 0 |) )
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
		pose { x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
	}

	local link Link1 {
		def { InOut geom_21 : Geom = Geom (| geomType = "cylinder" , geomVal = [| 0.05 , 1.0 |] |)
			local number : real = 2
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
				InOut axis_rot : vector ( real , 3 ) = (| 0 , 1 , 0 |)
				InOut motor_frame : vector ( real , 8 )
				InOut motor_joint : vector ( real , 8 )
				local number : real = 1
				local poseVec : vector ( real , 6 ) = [| 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 |]
				equation motor_joint == motorProduct ( motor_frame , (| cos ( 0.5 * q ) , sin ( 0.5 * q ) * axis_rot [ 0 ] , sin ( 0.5 * q ) * axis_rot [ 1 ] , sin ( 0.5 * q ) * axis_rot [ 2 ] , 0 , 0 , 0 , 0 |) )
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
		pose { x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
	}

	local link Link2 {
		def { InOut geom_11 : Geom = Geom (| geomType = "cylinder" , geomVal = [| 0.05 , 2.0 |] |)
			local number : real = 1
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
	InOut theta : vector ( real , 2 )
	InOut d_theta : vector ( real , 2 )
	InOut dd_theta : vector ( real , 2 )
	InOut tau : vector ( real , 2 )
	InOut damping : matrix ( real , 2 , 2 )
	InOut gravity : real
	InOut B_k : Seq( matrix ( real , 4 , 4 ) )
	InOut motor_T : Seq( vector ( real , 8 ) )
	InOut motor_k : Seq( vector ( real , 8 ) )
	InOut motor_joint : Seq( vector ( real , 8 ) )
	InOut axis_rot : Seq( vector ( real , 3 ) )
	InOut axis_lin : Seq( vector ( real , 3 ) )
	InOut joint_type : Seq( int )
	InOut mass_k : Seq( real )
	InOut com_k : Seq( vector ( real , 3 ) )
	InOut inertia_k : Seq( matrix ( real , 3 , 3 ) )
	InOut T_geom : Seq( matrix ( real , 4 , 4 ) )
	InOut T_offset : Seq( matrix ( real , 4 , 4 ) )
	InOut B_1 : matrix ( real , 4 , 4 )
	InOut motor_T_1 : vector ( real , 8 )
	InOut motor_1 : vector ( real , 8 )
	InOut T_geom_1 : matrix ( real , 4 , 4 )
	InOut T_offset_1 : matrix ( real , 4 , 4 )
	InOut m_1 : real
	InOut com_1 : vector ( real , 3 )
	InOut Icom_1 : matrix ( real , 3 , 3 )
	InOut B_2 : matrix ( real , 4 , 4 )
	InOut motor_T_2 : vector ( real , 8 )
	InOut motor_2 : vector ( real , 8 )
	InOut T_geom_2 : matrix ( real , 4 , 4 )
	InOut T_offset_2 : matrix ( real , 4 , 4 )
	InOut m_2 : real
	InOut com_2 : vector ( real , 3 )
	InOut Icom_2 : matrix ( real , 3 , 3 )
	InOut B_3 : matrix ( real , 4 , 4 )
	InOut motor_T_3 : vector ( real , 8 )
	InOut motor_3 : vector ( real , 8 )
	InOut T_geom_3 : matrix ( real , 4 , 4 )
	InOut T_offset_3 : matrix ( real , 4 , 4 )
	InOut m_3 : real
	InOut com_3 : vector ( real , 3 )
	InOut Icom_3 : matrix ( real , 3 , 3 )
	InOut motor_joint_1 : vector ( real , 8 )
	InOut axis_rot_1 : vector ( real , 3 )
	InOut axis_lin_1 : vector ( real , 3 )
	InOut joint_type_1 : int
	InOut motor_joint_2 : vector ( real , 8 )
	InOut axis_rot_2 : vector ( real , 3 )
	InOut axis_lin_2 : vector ( real , 3 )
	InOut joint_type_2 : int
	equation B_k == < B_1 , B_2 , B_3 >
	equation motor_k == < motor_1 , motor_2 , motor_3 >
	equation motor_T == < motor_T_1 , motor_T_2 , motor_T_3 >
	equation motor_joint == < motor_joint_1 , motor_joint_2 >
	equation axis_rot == < axis_rot_1 , axis_rot_2 >
	equation axis_lin == < axis_lin_1 , axis_lin_2 >
	equation joint_type == < joint_type_1 , joint_type_2 >
	equation mass_k == < m_1 , m_2 >
	equation com_k == < com_1 , com_2 >
	equation inertia_k == < Icom_1 , Icom_2 >
	equation T_geom == < T_geom_1 , T_geom_2 , T_geom_3 >
	equation T_offset == < T_offset_1 , T_offset_2 , T_offset_3 >
	Constraint ( m_3 ) [ t == 0 ] == 0.10000000149011612
	Constraint ( com_3 ) [ t == 0 ] == [| 0 , 0 , - 0.10000000149011612 |]
	Constraint ( Icom_3 ) [ t == 0 ] == [| 0.10000000149011612 , 0 , 0 ; 0 , 0.10000000149011612 , 0 ; 0 , 0 , 0.10000000149011612 |]
	Constraint ( B_3 ) [ t == 0 ] == identity ( 4 )
	Constraint ( motor_3 ) [ t == 0 ] == [| 1.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 |]
	Constraint ( motor_T_3 ) [ t == 0 ] == [| 1.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.05000000074505806 , 0.0 |]
	Constraint ( T_offset_3 ) [ t == 0 ] == [| 1.0 , 0.0 , 0.0 , 0 ; 0.0 , 1.0 , 0.0 , 0 ; 0.0 , 0.0 , 1.0 , 0 ; 0.0 , 0.0 , 0.0 , 1.0 |]
	Constraint ( T_geom_3 ) [ t == 0 ] == B_3 * T_offset_3
	Constraint ( m_2 ) [ t == 0 ] == 1
	Constraint ( com_2 ) [ t == 0 ] == [| 0 , 0 , - 0.5 |]
	Constraint ( Icom_2 ) [ t == 0 ] == [| 0.08299999684095383 , 0 , 0 ; 0 , 0.08299999684095383 , 0 ; 0 , 0 , 0.0010000000474974513 |]
	Constraint ( B_2 ) [ t == 0 ] == identity ( 4 )
	Constraint ( motor_2 ) [ t == 0 ] == [| 1.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 |]
	Constraint ( motor_T_2 ) [ t == 0 ] == [| 1.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.10000000149011612 , 0.0 |]
	Constraint ( T_offset_2 ) [ t == 0 ] == [| 1.0 , 0.0 , 0.0 , 0 ; 0.0 , 1.0 , 0.0 , 0 ; 0.0 , 0.0 , 1.0 , - 0.5 ; 0.0 , 0.0 , 0.0 , 1.0 |]
	Constraint ( T_geom_2 ) [ t == 0 ] == B_2 * T_offset_2
	Constraint ( m_1 ) [ t == 0 ] == 1
	Constraint ( com_1 ) [ t == 0 ] == [| 0 , 0 , - 1 |]
	Constraint ( Icom_1 ) [ t == 0 ] == [| 0.3330000042915344 , 0 , 0 ; 0 , 0.3330000042915344 , 0 ; 0 , 0 , 0.0010000000474974513 |]
	Constraint ( B_1 ) [ t == 0 ] == identity ( 4 )
	Constraint ( motor_1 ) [ t == 0 ] == [| 1.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 |]
	Constraint ( motor_T_1 ) [ t == 0 ] == [| 1.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.5 , 0.0 |]
	Constraint ( T_offset_1 ) [ t == 0 ] == [| 1.0 , 0.0 , 0.0 , 0 ; 0.0 , 1.0 , 0.0 , 0 ; 0.0 , 0.0 , 1.0 , - 1 ; 0.0 , 0.0 , 0.0 , 1.0 |]
	Constraint ( T_geom_1 ) [ t == 0 ] == B_1 * T_offset_1
	Constraint ( axis_rot_2 ) [ t == 0 ] == [| 0 , 1 , 0 |]
	Constraint ( axis_lin_2 ) [ t == 0 ] == [| 0 , 0 , 0 |]
	Constraint ( joint_type_2 ) [ t == 0 ] == 0
	Constraint ( axis_rot_1 ) [ t == 0 ] == [| 0 , 1 , 0 |]
	Constraint ( axis_lin_1 ) [ t == 0 ] == [| 0 , 0 , 0 |]
	Constraint ( joint_type_1 ) [ t == 0 ] == 0
	Constraint ( gravity ) [ t == 0 ] == 9.81
}
datatype Geom { geomType : string geomVal : vector ( real ) meshUri : string meshScale : vector ( real ) } function identity ( size : real ) : matrix ( real , 4 , 4 ) { } function transl ( R : matrix ( real , 3 , 3 ) , p : vector ( real , 3 ) ) : matrix ( real , 4 , 4 ) { } function eulZYX ( ^z : real , ^y : real , ^x : real ) : matrix ( real , 3 , 3 ) { } function sin ( v : real ) : real { } function cos ( v : real ) : real { } function motorProduct ( m1 : vector ( real , 8 ) , m2 : vector ( real , 8 ) ) : vector ( real , 8 ) { }