import physmod::math::* import physmod::CGA::joints::Revolute_x pmodel Acrobot {
	local link BaseLink {
		def {
			InOut geom_31 : Geom = Geom (| geomType = "box" , geomVal = [| 0.2 , 0.2 , 0.2 |] |)
			local number : real = 3
			local poseVec : vector ( real , 6 ) = [| 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 |]
		}
		local body BaseBody {
			def {
				inertial information {
					mass 0.1
					inertia matrix { ixx 0.1 ixy 0.0 ixz 0.0 iyy 0.1 iyz 0.0 izz 0.1 }
					pose {
						x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
				}
				box ( length = 0.2 , width = 0.2 , height = 0.2 )
				local number : real = 0
			}
			pose {
				x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
		}
		local joint ShoulderJoint {
			def {
				InOut theta : real
				InOut XJ : matrix ( real , 6 , 6 )
				local number : real = 2
				local poseVec : vector ( real , 6 ) = [| 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 |]
				const H : vector ( real , 6 ) = (| 1 , 0 , 0 , 0 , 0 , 0 |)
				equation XJ == [| 1 , 0 , 0 , 0 , 0 , 0 ; 0 , cos ( theta ) , - sin ( theta ) , 0 , 0 , 0 ; 0 , sin ( theta ) , cos ( theta ) , 0 , 0 , 0 ; 0 , 0 , 0 , 1 , 0 , 0 ; 0 , 0 , 0 , 0 , cos ( theta ) , - sin ( theta ) ; 0 , 0 , 0 , 0 , sin ( theta ) , cos ( theta ) |]
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
			x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
	}
	local link Link1 {
		def {
			InOut geom_21 : Geom = Geom (| geomType = "cylinder" , geomVal = [| 0.05 , 1.0 |] |)
			local number : real = 2
			local poseVec : vector ( real , 6 ) = [| 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 |]
		}
		local body Link1Body {
			def {
				inertial information {
					mass 1.0
					inertia matrix { ixx 0.083 ixy 0.0 ixz 0.0 iyy 0.083 iyz 0.0 izz 0.001 }
					pose {
						x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
				}
				cylinder ( radius = 0.05 , length = 1.0 )
				local number : real = 0
			}
			pose {
				x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
		}
		local joint ElbowJoint {
			def {
				InOut theta : real
				InOut XJ : matrix ( real , 6 , 6 )
				local number : real = 1
				local poseVec : vector ( real , 6 ) = [| 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 |]
				const H : vector ( real , 6 ) = (| 1 , 0 , 0 , 0 , 0 , 0 |)
				equation XJ == [| 1 , 0 , 0 , 0 , 0 , 0 ; 0 , cos ( theta ) , - sin ( theta ) , 0 , 0 , 0 ; 0 , sin ( theta ) , cos ( theta ) , 0 , 0 , 0 ; 0 , 0 , 0 , 1 , 0 , 0 ; 0 , 0 , 0 , 0 , cos ( theta ) , - sin ( theta ) ; 0 , 0 , 0 , 0 , sin ( theta ) , cos ( theta ) |]
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
			relation H_1 == ElbowJoint . H /\ theta [ 0 ] == ElbowJoint . theta
		}
		pose {
			x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
	}
	local link Link2 {
		def {
			InOut geom_11 : Geom = Geom (| geomType = "cylinder" , geomVal = [| 0.05 , 2.0 |] |)
			local number : real = 1
			local poseVec : vector ( real , 6 ) = [| 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 |]
		}
		local body Link2Body {
			def {
				inertial information {
					mass 1.0
					inertia matrix { ixx 0.333 ixy 0.0 ixz 0.0 iyy 0.333 iyz 0.0 izz 0.001 }
					pose {
						x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
				}
				cylinder ( radius = 0.05 , length = 2.0 )
				local number : real = 0
			}
			pose {
				x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
		}
		pose {
			x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
	}
	const n : int = 3
	const N : int = 2
	InOut L1_geom : Geom
	InOut L2_geom : Geom
	InOut L3_geom : Geom
	InOut Lk_geom : Seq( Geom )
	InOut theta : vector ( real , 2 )
	InOut d_theta : vector ( real , 2 )
	InOut B_k : Seq( matrix ( real , 4 , 4 ) )
	InOut motor_k : Seq( vector ( real , 8 ) )
	InOut motor_joint : Seq( vector ( real , 8 ) )
	InOut motor_T : Seq( vector ( real , 8 ) )
	InOut T_geom : Seq( matrix ( real , 4 , 4 ) )
	InOut T_offset : Seq( matrix ( real , 4 , 4 ) )
	InOut M_spatial : Seq( matrix ( real , 6 , 6 ) )
	InOut H : Seq( vector ( real , 6 ) )
	InOut theta : vector ( real , 2 )
	InOut tau : vector ( real , 2 )
	InOut M_mass : matrix ( real , 2 , 2 )
	InOut C : vector ( real , 2 )
	InOut damping : matrix ( real , 2 , 2 )
	InOut tau_d : vector ( real , 2 )
	InOut gravity : real
	InOut B_3 : matrix ( real , 4 , 4 )
	InOut T_geom_3 : matrix ( real , 4 , 4 )
	InOut T_offset_3 : matrix ( real , 4 , 4 )
	InOut motor_3 : vector ( real , 8 )
	InOut motor_T_3 : vector ( real , 8 )
	InOut M_3 : matrix ( real , 6 , 6 )
	InOut m_3 : real
	InOut Ic_3 : real
	InOut cz_3 : real
	InOut B_2 : matrix ( real , 4 , 4 )
	InOut T_geom_2 : matrix ( real , 4 , 4 )
	InOut T_offset_2 : matrix ( real , 4 , 4 )
	InOut motor_2 : vector ( real , 8 )
	InOut motor_T_2 : vector ( real , 8 )
	InOut M_2 : matrix ( real , 6 , 6 )
	InOut m_2 : real
	InOut Ic_2 : real
	InOut cz_2 : real
	InOut H_2 : vector ( real , 6 )
	InOut B_1 : matrix ( real , 4 , 4 )
	InOut T_geom_1 : matrix ( real , 4 , 4 )
	InOut T_offset_1 : matrix ( real , 4 , 4 )
	InOut motor_1 : vector ( real , 8 )
	InOut motor_T_1 : vector ( real , 8 )
	InOut M_1 : matrix ( real , 6 , 6 )
	InOut m_1 : real
	InOut Ic_1 : real
	InOut cz_1 : real
	InOut H_1 : vector ( real , 6 )
	InOut motor_joint_1 : vector ( real , 8 )
	InOut motor_joint_2 : vector ( real , 8 )
	local l : vector ( real , 2 )
	local lc : vector ( real , 2 )
	local m : vector ( real , 2 )
	local Ic : vector ( real , 2 )
	local bias : vector ( real , 2 )
	local theta_dot : vector ( real , 2 )
	local b : vector ( real , 2 )
	local theta_dotdot : vector ( real , 2 )
	local d_theta_dot : vector ( real , 2 )
	local dt : real
	equation M_3 [ 0 , 0 ] == m_3
	equation M_3 [ 1 , 1 ] == m_3
	equation M_3 [ 2 , 2 ] == m_3
	equation M_3 [ 3 , 3 ] == Ic_3 + m_3 * cz_3 * cz_3
	equation M_3 [ 4 , 4 ] == Ic_3 + m_3 * cz_3 * cz_3
	equation M_3 [ 5 , 5 ] == Ic_3
	equation M_3 [ 0 , 4 ] == m_3 * cz_3
	equation M_3 [ 4 , 0 ] == m_3 * cz_3
	equation M_3 [ 1 , 3 ] == - m_3 * cz_3
	equation M_3 [ 3 , 1 ] == - m_3 * cz_3
	equation M_2 [ 0 , 0 ] == m_2
	equation M_2 [ 1 , 1 ] == m_2
	equation M_2 [ 2 , 2 ] == m_2
	equation M_2 [ 3 , 3 ] == Ic_2 + m_2 * cz_2 * cz_2
	equation M_2 [ 4 , 4 ] == Ic_2 + m_2 * cz_2 * cz_2
	equation M_2 [ 5 , 5 ] == Ic_2
	equation M_2 [ 0 , 4 ] == m_2 * cz_2
	equation M_2 [ 4 , 0 ] == m_2 * cz_2
	equation M_2 [ 1 , 3 ] == - m_2 * cz_2
	equation M_2 [ 3 , 1 ] == - m_2 * cz_2
	equation M_1 [ 0 , 0 ] == m_1
	equation M_1 [ 1 , 1 ] == m_1
	equation M_1 [ 2 , 2 ] == m_1
	equation M_1 [ 3 , 3 ] == Ic_1 + m_1 * cz_1 * cz_1
	equation M_1 [ 4 , 4 ] == Ic_1 + m_1 * cz_1 * cz_1
	equation M_1 [ 5 , 5 ] == Ic_1
	equation M_1 [ 0 , 4 ] == m_1 * cz_1
	equation M_1 [ 4 , 0 ] == m_1 * cz_1
	equation M_1 [ 1 , 3 ] == - m_1 * cz_1
	equation M_1 [ 3 , 1 ] == - m_1 * cz_1
	equation B_k == < B_3 , B_2 , B_1 >
	equation motor_k == < motor_3 , motor_2 , motor_1 >
	equation motor_T == < motor_T_3 , motor_T_2 , motor_T_1 >
	equation motor_joint == < motor_joint_2 , motor_joint_1 >
	equation T_geom == < T_geom_3 , T_geom_2 , T_geom_1 >
	equation T_offset == < T_offset_3 , T_offset_2 , T_offset_1 >
	equation M_spatial == < M_3 , M_2 , M_1 >
	equation H == < H_2 , H_1 >
	equation tau_d == damping * derivative ( theta )
	equation tau == M_mass * derivative ( derivative ( theta ) ) + C + tau_d
	Constraint ( theta ) [ t == 0 ] == (| 1.0 , 1.0 |)
	Constraint ( d_theta ) [ t == 0 ] == zeroVec ( 2 )
	Constraint ( L1_geom . geomType ) [ t == 0 ] == "cylinder"
	Constraint ( L1_geom . geomVal ) [ t == 0 ] == [| 0.05 , 1.0 |]
	Constraint ( L2_geom . geomType ) [ t == 0 ] == "cylinder"
	Constraint ( L2_geom . geomVal ) [ t == 0 ] == [| 0.05 , 2.0 |]
	Constraint ( L3_geom . geomType ) [ t == 0 ] == "sphere"
	Constraint ( L3_geom . geomVal ) [ t == 0 ] == [| 0.08 |]
	Constraint ( Lk_geom ) [ t == 0 ] == < L1_geom , L2_geom , L3_geom >
	Constraint ( B_3 ) [ t == 0 ] == identity ( 4 )
	Constraint ( T_offset_3 ) [ t == 0 ] == [| 1.0 , 0.0 , 0.0 , 0 ; 0.0 , 1.0 , 0.0 , - 0.10000000149011612 ; 0.0 , 0.0 , 1.0 , 0 ; 0.0 , 0.0 , 0.0 , 1.0 |]
	Constraint ( T_geom_3 ) [ t == 0 ] == B_3 * T_offset_3
	Constraint ( m_3 ) [ t == 0 ] == 0.10000000149011612
	Constraint ( Ic_3 ) [ t == 0 ] == 0.10000000149011612
	Constraint ( cz_3 ) [ t == 0 ] == - 0.10000000149011612
	Constraint ( motor_T_3 ) [ t == 0 ] == [| 1.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 |]
	Constraint ( motor_3 ) [ t == 0 ] == [| 1.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 |]
	Constraint ( B_2 ) [ t == 0 ] == transl ( eulZYX ( 0 , 0 , 0 ) , [| 0 , 0 , 0 |] )
	Constraint ( T_offset_2 ) [ t == 0 ] == [| 1.0 , 0.0 , 0.0 , 0 ; 0.0 , 1.0 , 0.0 , - 0.5 ; 0.0 , 0.0 , 1.0 , 0 ; 0.0 , 0.0 , 0.0 , 1.0 |]
	Constraint ( T_geom_2 ) [ t == 0 ] == B_2 * T_offset_2
	Constraint ( m_2 ) [ t == 0 ] == 1
	Constraint ( Ic_2 ) [ t == 0 ] == 0.08299999684095383
	Constraint ( cz_2 ) [ t == 0 ] == - 0.5
	Constraint ( motor_T_2 ) [ t == 0 ] == [| 1.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , - 0.30000000074505806 , 0.0 |]
	Constraint ( motor_2 ) [ t == 0 ] == [| 1.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 |]
	Constraint ( B_1 ) [ t == 0 ] == transl ( eulZYX ( 0 , 0 , 0 ) , [| 0 , 0 , 0 |] )
	Constraint ( T_offset_1 ) [ t == 0 ] == [| 1.0 , 0.0 , 0.0 , 0 ; 0.0 , 1.0 , 0.0 , - 1 ; 0.0 , 0.0 , 1.0 , 0 ; 0.0 , 0.0 , 0.0 , 1.0 |]
	Constraint ( T_geom_1 ) [ t == 0 ] == B_1 * T_offset_1
	Constraint ( m_1 ) [ t == 0 ] == 1
	Constraint ( Ic_1 ) [ t == 0 ] == 0.3330000042915344
	Constraint ( cz_1 ) [ t == 0 ] == - 1
	Constraint ( H_1 ) [ t == 0 ] == [| 1.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 |]
	Constraint ( motor_T_1 ) [ t == 0 ] == [| 1.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , - 0.75 , 0.0 |]
	Constraint ( motor_1 ) [ t == 0 ] == [| 1.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 |]
	Constraint ( motor_joint_1 ) [ t == 0 ] == [| 1.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 |]
	Constraint ( motor_joint_2 ) [ t == 0 ] == [| 1.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 |]
	solution { solutionExpr B_k : Seq( matrix ( real , 4 , 4 ) ) order 1 group 0 method ForwardKinematics Input theta : vector ( real , 2 ) Input motor_T : Seq( vector ( real , 8 ) ) Input H : Seq( vector ( real , 6 ) ) Input l : vector ( real , 2 ) Input lc : vector ( real , 2 ) Input n : int Input B_1 : matrix ( real , 4 , 4 ) Input B_2 : matrix ( real , 4 , 4 ) Input B_3 : matrix ( real , 4 , 4 ) Input motor_T_3 : vector ( real , 8 ) Input motor_T_2 : vector ( real , 8 ) Input motor_T_1 : vector ( real , 8 ) Input H_2 : vector ( real , 6 ) Input H_1 : vector ( real , 6 ) Constraint ( n ) [ t == 0 ] == 3 Constraint ( theta ) [ t == 0 ] == [| 1.0 , 1.0 |] Constraint ( motor_T ) [ t == 0 ] == < motor_T_3 , motor_T_2 , motor_T_1 > Constraint ( H ) [ t == 0 ] == < H_2 , H_1 > Constraint ( l ) [ t == 0 ] == (| 1.0 , 2.0 |) Constraint ( lc ) [ t == 0 ] == (| 0.5 , 1.0 |) Constraint ( B_1 ) [ t == 0 ] == [| 1.0 , 0.0 , 0.0 , 0.0 ; 0.0 , 1.0 , 0.0 , 0.0 ; 0.0 , 0.0 , 1.0 , 0.0 ; 0.0 , 0.0 , 0.0 , 1.0 |] Constraint ( B_2 ) [ t == 0 ] == [| 1.0 , 0.0 , 0.0 , 0.0 ; 0.0 , 1.0 , 0.0 , 0.0 ; 0.0 , 0.0 , 1.0 , 0.0 ; 0.0 , 0.0 , 0.0 , 1.0 |] Constraint ( B_3 ) [ t == 0 ] == identity ( 4 ) Constraint ( B_k ) [ t == 0 ] == < B_3 , B_2 , B_1 > }
	solution { solutionExpr M_mass : matrix ( real , 2 , 2 ) order 2 group 0 method CalcMassMatrix Input theta : vector ( real , 2 ) Input m : vector ( real , 2 ) Input l : vector ( real , 2 ) Input lc : vector ( real , 2 ) Input Ic : vector ( real , 2 ) Input B_k : Seq( matrix ( real , 4 , 4 ) ) Input H : Seq( vector ( real , 6 ) ) Input M_spatial : Seq( matrix ( real , 6 , 6 ) ) Input B_1 : matrix ( real , 4 , 4 ) Input B_2 : matrix ( real , 4 , 4 ) Input B_3 : matrix ( real , 4 , 4 ) Input n : int Input H_2 : vector ( real , 6 ) Input H_1 : vector ( real , 6 ) Input M_3 : matrix ( real , 6 , 6 ) Input M_2 : matrix ( real , 6 , 6 ) Input M_1 : matrix ( real , 6 , 6 ) Constraint ( n ) [ t == 0 ] == 3 Constraint ( theta ) [ t == 0 ] == [| 1.0 , 1.0 |] Constraint ( m ) [ t == 0 ] == (| 1.0 , 1.0 |) Constraint ( l ) [ t == 0 ] == (| 1.0 , 2.0 |) Constraint ( lc ) [ t == 0 ] == (| 0.5 , 1.0 |) Constraint ( Ic ) [ t == 0 ] == (| 0.083 , 0.33 |) Constraint ( B_1 ) [ t == 0 ] == [| 1.0 , 0.0 , 0.0 , 0.0 ; 0.0 , 1.0 , 0.0 , 0.0 ; 0.0 , 0.0 , 1.0 , 0.0 ; 0.0 , 0.0 , 0.0 , 1.0 |] Constraint ( B_2 ) [ t == 0 ] == [| 1.0 , 0.0 , 0.0 , 0.0 ; 0.0 , 1.0 , 0.0 , 0.0 ; 0.0 , 0.0 , 1.0 , 0.0 ; 0.0 , 0.0 , 0.0 , 1.0 |] Constraint ( B_3 ) [ t == 0 ] == identity ( 4 ) Constraint ( B_k ) [ t == 0 ] == < B_3 , B_2 , B_1 > Constraint ( H ) [ t == 0 ] == < H_2 , H_1 > Constraint ( M_spatial ) [ t == 0 ] == < M_3 , M_2 , M_1 > Constraint ( M_mass ) [ t == 0 ] == unknown_fun ( 2 , 2 ) }
	solution { solutionExpr bias : vector ( real , 2 ) order 3 group 0 method CalcBiasTerm Input theta : vector ( real , 2 ) Input theta_dot : vector ( real , 2 ) Input m : vector ( real , 2 ) Input l : vector ( real , 2 ) Input lc : vector ( real , 2 ) Input Ic : vector ( real , 2 ) Input b : vector ( real , 2 ) Input gravity : real Input B_k : Seq( matrix ( real , 4 , 4 ) ) Input H : Seq( vector ( real , 6 ) ) Input M_spatial : Seq( matrix ( real , 6 , 6 ) ) Input B_1 : matrix ( real , 4 , 4 ) Input B_2 : matrix ( real , 4 , 4 ) Input B_3 : matrix ( real , 4 , 4 ) Input n : int Input H_2 : vector ( real , 6 ) Input H_1 : vector ( real , 6 ) Input M_3 : matrix ( real , 6 , 6 ) Input M_2 : matrix ( real , 6 , 6 ) Input M_1 : matrix ( real , 6 , 6 ) Constraint ( n ) [ t == 0 ] == 3 Constraint ( theta ) [ t == 0 ] == [| 1.0 , 1.0 |] Constraint ( theta_dot ) [ t == 0 ] == (| 0.0 , 0.0 |) Constraint ( m ) [ t == 0 ] == (| 1.0 , 1.0 |) Constraint ( l ) [ t == 0 ] == (| 1.0 , 2.0 |) Constraint ( lc ) [ t == 0 ] == (| 0.5 , 1.0 |) Constraint ( Ic ) [ t == 0 ] == (| 0.083 , 0.33 |) Constraint ( b ) [ t == 0 ] == (| 0.1 , 0.1 |) Constraint ( gravity ) [ t == 0 ] == 9.81 Constraint ( B_1 ) [ t == 0 ] == [| 1.0 , 0.0 , 0.0 , 0.0 ; 0.0 , 1.0 , 0.0 , 0.0 ; 0.0 , 0.0 , 1.0 , 0.0 ; 0.0 , 0.0 , 0.0 , 1.0 |] Constraint ( B_2 ) [ t == 0 ] == [| 1.0 , 0.0 , 0.0 , 0.0 ; 0.0 , 1.0 , 0.0 , 0.0 ; 0.0 , 0.0 , 1.0 , 0.0 ; 0.0 , 0.0 , 0.0 , 1.0 |] Constraint ( B_3 ) [ t == 0 ] == identity ( 4 ) Constraint ( B_k ) [ t == 0 ] == < B_3 , B_2 , B_1 > Constraint ( H ) [ t == 0 ] == < H_2 , H_1 > Constraint ( M_spatial ) [ t == 0 ] == < M_3 , M_2 , M_1 > Constraint ( bias ) [ t == 0 ] == unknown_fun ( 2 ) }
	solution { solutionExpr theta_dotdot : vector ( real , 2 ) order 4 group 0 method ForwardDynamics Input M_mass : matrix ( real , 2 , 2 ) Input bias : vector ( real , 2 ) Input tau : vector ( real , 2 ) Input n : int Constraint ( M_mass ) [ t == 0 ] == unknown_fun ( 2 , 2 ) Constraint ( bias ) [ t == 0 ] == unknown_fun ( 2 ) Constraint ( tau ) [ t == 0 ] == (| 0.0 , 0.0 |) Constraint ( theta_dotdot ) [ t == 0 ] == unknown_fun ( 2 ) Constraint ( n ) [ t == 0 ] == 3 }
	solution { solutionExpr theta_dot : vector ( real , 2 ) order 5 group 0 method Euler Input d_theta_dot : vector ( real , 2 ) Input dt : real Input theta_dotdot : vector ( real , 2 ) Input n : int Constraint ( theta_dotdot ) [ t == 0 ] == unknown_fun ( 2 ) Constraint ( dt ) [ t == 0 ] == 0.01 Constraint ( theta_dot ) [ t == 0 ] == (| 0.0 , 0.0 |) Constraint ( n ) [ t == 0 ] == 3 Constraint ( d_theta_dot ) [ t == 0 ] == 0 }
	solution { solutionExpr theta : vector ( real , 2 ) order 6 group 0 method Euler Input d_theta : vector ( real , 2 ) Input dt : real Input theta_dot : vector ( real , 2 ) Input n : int Constraint ( theta_dot ) [ t == 0 ] == (| 0.0 , 0.0 |) Constraint ( dt ) [ t == 0 ] == 0.01 Constraint ( theta ) [ t == 0 ] == (| 1.0 , 1.0 |) Constraint ( n ) [ t == 0 ] == 3 Constraint ( d_theta ) [ t == 0 ] == 0 }
	solution { solutionExpr B_k : Seq( matrix ( real , 4 , 4 ) ) order 7 group 0 method Visual Input B_k : Seq( matrix ( real , 4 , 4 ) ) Input theta : vector ( real , 2 ) Input l : vector ( real , 2 ) Input lc : vector ( real , 2 ) Input n : int Input L1_geom : Geom Input L2_geom : Geom Input L3_geom : Geom Input B_1 : matrix ( real , 4 , 4 ) Input B_2 : matrix ( real , 4 , 4 ) Input B_3 : matrix ( real , 4 , 4 ) Constraint ( n ) [ t == 0 ] == 3 Constraint ( theta ) [ t == 0 ] == (| 1.0 , 1.0 |) Constraint ( l ) [ t == 0 ] == (| 1.0 , 2.0 |) Constraint ( lc ) [ t == 0 ] == (| 0.5 , 1.0 |) Constraint ( B_1 ) [ t == 0 ] == [| 1.0 , 0.0 , 0.0 , 0.0 ; 0.0 , 1.0 , 0.0 , 0.0 ; 0.0 , 0.0 , 1.0 , 0.0 ; 0.0 , 0.0 , 0.0 , 1.0 |] Constraint ( B_2 ) [ t == 0 ] == [| 1.0 , 0.0 , 0.0 , 0.0 ; 0.0 , 1.0 , 0.0 , 0.0 ; 0.0 , 0.0 , 1.0 , 0.0 ; 0.0 , 0.0 , 0.0 , 1.0 |] Constraint ( B_3 ) [ t == 0 ] == identity ( 4 ) Constraint ( B_k ) [ t == 0 ] == < B_3 , B_2 , B_1 > Constraint ( n ) [ t == 0 ] == 3 }
}
record Geom { geomType : string geomVal : vector ( real ) meshUri : string meshScale : vector ( real ) } function identity ( size : real ) : matrix ( real , 4 , 4 ) { } function transl ( R : matrix ( real , 3 , 3 ) , p : vector ( real , 3 ) ) : matrix ( real , 4 , 4 ) { } function eulZYX ( ^z : real , ^y : real , ^x : real ) : matrix ( real , 3 , 3 ) { }