import  physmod::math::*
	pmodel Acrobot {
	solution{
    solutionExpr theta: vector(real,2)
    order 1
    group 1
    method GeneralisedPosition_method1_gravity_damping
}

	solution{
    solutionExpr B_k: Seq(matrix(real,4,4))
    order 2
    group 1
    method Eval
}

	solution{
    solutionExpr B_k: Seq(matrix(real,4,4))
    order 10
    group 1
    method Visual
    Input L1_geom: Geom
    Input L2_geom: Geom
    Input L3_geom: Geom
}


	InOut L1_geom: Geom
	InOut L2_geom: Geom
	InOut L3_geom: Geom
	InOut Lk_geom: Seq(Geom)

	InOut theta: vector(real,2)
	InOut d_theta: vector(real,2)

	Constraint (theta)[t==0] == (|1.0, 1.0|)
	Constraint (d_theta)[t==0] == zeroVec(2)

	Constraint (L1_geom.geomType)[t==0] == "cylinder"
	Constraint (L1_geom.geomVal)[t==0] == [|0.05, 2.0|]
	Constraint (L2_geom.geomType)[t==0] == "cylinder"
	Constraint (L2_geom.geomVal)[t==0] == [|0.05, 1.0|]
	Constraint (L3_geom.geomType)[t==0] == "box"
	Constraint (L3_geom.geomVal)[t==0] == [|0.2, 0.2, 0.2|]
	Constraint (Lk_geom)[t==0] == <L1_geom, L2_geom, L3_geom>

	local link BaseLink {
		def { InOut geom_31 : Geom = Geom (| geomType = "box" , geomVal = [| 0.2 , 0.2 , 0.2 |] |)
			InOut L3_geom : Geom = Geom (| geomType = "box" , geomVal = [| 0.2 , 0.2 , 0.2 |] |)
			InOut M_3 : matrix ( real , 6 , 6 ) = [| 0.101 , 0.0 , 0.0 , 0.0 , 0.010000001 , 0.0 ; 0.0 , 0.101 , 0.0 , - 0.010000001 , 0.0 , 0.0 ; 0.0 , 0.0 , 0.1 , 0.0 , 0.0 , 0.0 ; 0.0 , - 0.010000001 , 0.0 , 0.1 , 0.0 , 0.0 ; 0.010000001 , 0.0 , 0.0 , 0.0 , 0.1 , 0.0 ; 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.1 |]
			InOut a_3 : vector ( real , 6 )
			InOut b_3 : vector ( real , 6 )
			InOut V_3 : vector ( real , 6 )
			InOut alpha_3 : vector ( real , 6 )
			InOut f_3 : vector ( real , 6 )
			InOut B_3 : matrix ( real , 4 , 4 )
			InOut X_T_3 : matrix ( real , 6 , 6 )
			InOut T_geom_3 : matrix ( real , 4 , 4 )
			InOut T_offset_3 : matrix ( real , 4 , 4 )
			InOut m_3 : real = 0.1
			InOut I_C_3 : matrix ( real , 3 , 3 ) = [| 0.1 , 0.0 , 0.0 ; 0.0 , 0.1 , 0.0 ; 0.0 , 0.0 , 0.1 |]
			InOut c_3 : vector ( real , 3 ) = [| 0.0 , 0.0 , 0.0 |]
			InOut cz_3 : real = 0.0
			InOut _f_2 : vector ( real , 6 )
			InOut phi_3_2 : matrix ( real , 6 , 6 )
			InOut tau_3 : vector ( real , 1 )
			local number : real = 3
			local poseVec : vector ( real , 6 ) = [| 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 |]
			equation submatrix ( M_3 ) ( 0 , 0 , 3 , 3 ) == I_C_3 + m_3 * transpose ( skew ( c_3 ) ) * skew ( c_3 )
			equation submatrix ( M_3 ) ( 0 , 3 , 3 , 3 ) == m_3 * transpose ( skew ( c_3 ) )
			equation submatrix ( M_3 ) ( 3 , 0 , 3 , 3 ) == - m_3 * skew ( c_3 )
			equation submatrix ( M_3 ) ( 3 , 3 , 3 , 3 ) == m_3 * identity ( 3 )
			equation f_3 == phi_3_2 * _f_2 + M_3 * alpha_3 + b_3
			equation V_3 == 0
			equation alpha_3 == a_3
			Constraint ( B_3 ) [ t == 0 ] == [| 1.000000 , 0.000000 , 0.000000 , 0.000000 ; 0.000000 , 1.000000 , 0.000000 , 0.000000 ; - 0.000000 , 0.000000 , 1.000000 , - 0.10000000149011612 ; 0 , 0 , 0 , 1 |]
			Constraint ( T_geom_3 ) [ t == 0 ] == [| 1.000000 , 0.000000 , 0.000000 , 0.000000 ; 0.000000 , 1.000000 , 0.000000 , 0.000000 ; - 0.000000 , 0.000000 , 1.000000 , 0 ; 0 , 0 , 0 , 1 |]
			Constraint ( T_offset_3 ) [ t == 0 ] == [| 1.0 , 0.0 , 0.0 , 0.0 ; 0.0 , 1.0 , 0.0 , 0.0 ; 0.0 , 0.0 , 1.0 , 0 ; 0 , 0 , 0 , 1 |]
			Constraint ( X_T_3 ) [ t == 0 ] == [| 1 , 0 , 0 , 0 , 0 , 0 ; 0 , 1 , 0 , 0 , 0 , 0 ; 0 , 0 , 1 , 0 , 0 , 0 ; 0 , 0 , 0 , 1 , 0 , 0 ; 0 , 0 , 0 , 0 , 1 , 0 ; 0 , 0 , 0 , 0 , 0 , 1 |]
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
				const H : vector ( real , 6 ) = [| 0 , 1 , 0 , 0 , 0 , 0 |]
				InOut theta : real
				InOut XJ : matrix ( real , 6 , 6 )
				equation XJ == [| cos ( theta ) , 0 ,  sin ( theta ) , 0 , 0 , 0 ;
										 0 , 1 , 0 , 0 , 0 , 0 ;
										 - sin ( theta ) , 0 ,  cos ( theta ) , 0 , 0 , 0 ;
										 0 , 0 , 0 ,  cos ( theta ) , 0 ,  sin ( theta ) ;
										 0 , 0 , 0 , 0 , 1 , 0 ;
										 0 , 0 , 0 ,  - sin ( theta ) , 0 ,  cos ( theta ) |]
			InOut B_2 : matrix ( real , 4 , 4 )
				InOut B_3 : matrix ( real , 4 , 4 )
				InOut _B_3 : matrix ( real , 4 , 4 )
				InOut T_3_2 : matrix ( real , 4 , 4 )
				InOut V_3 : vector ( real , 6 )
				InOut _V_3 : vector ( real , 6 )
				InOut alpha_3 : vector ( real , 6 )
				InOut _alpha_3 : vector ( real , 6 )
				InOut f_2 : vector ( real , 6 )
				InOut r_v2 : real = 1
				InOut theta_2 : real
				InOut phi_3_2 : matrix ( real , 6 , 6 )
				local number : real = 2
				local poseVec : vector ( real , 6 ) = [| 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 |]
				equation _B_3 == B_3
				equation _V_3 == V_3
				equation _alpha_3 == alpha_3
				equation _f_2 == f_2
			}
			flexibly connected to Link1
			pose { x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
		relation B_3 == ShoulderJoint . B_3 /\ V_3 == ShoulderJoint . V_3 /\ alpha_3 == ShoulderJoint . alpha_3 /\ theta [ 1 ] == ShoulderJoint . theta /\ H_2 == ShoulderJoint . H /\ X_J_2 == ShoulderJoint . XJ
		}
		pose { x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
	relation B_3 == BaseLink . B_3 /\ V [ 2 ] == BaseLink . V_3 /\ a [ 2 ] == BaseLink . a_3 /\ b [ 2 ] == BaseLink . b_3 /\ alpha [ 2 ] == BaseLink . alpha_3 /\ submatrix ( M ) ( 12 , 12 , 6 , 6 ) == BaseLink . M_3 /\ tau [ 2 ] == BaseLink . tau_3 /\ L3_geom == geom_31
	}

	local link Link1 {
		def { input test_2 : vector ( real , 1 )
			InOut geom_21 : Geom = Geom (| geomType = "cylinder" , geomVal = [| 0.05 , 1.0 |] |)
			InOut L2_geom : Geom = Geom (| geomType = "cylinder" , geomVal = [| 0.05 , 1.0 |] |)
			InOut M_2 : matrix ( real , 6 , 6 ) = [| 0.333 , 0.0 , 0.0 , 0.0 , 0.5 , 0.0 ; 0.0 , 0.333 , 0.0 , - 0.5 , 0.0 , 0.0 ; 0.0 , 0.0 , 0.001 , 0.0 , 0.0 , 0.0 ; 0.0 , - 0.5 , 0.0 , 1 , 0.0 , 0.0 ; 0.5 , 0.0 , 0.0 , 0.0 , 1 , 0.0 ; 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 1 |]
			InOut a_2 : vector ( real , 6 )
			InOut b_2 : vector ( real , 6 )
			InOut V_2 : vector ( real , 6 )
			InOut alpha_2 : vector ( real , 6 )
			InOut f_2 : vector ( real , 6 )
			InOut B_2 : matrix ( real , 4 , 4 )
			InOut X_T_2 : matrix ( real , 6 , 6 )
			InOut T_geom_2 : matrix ( real , 4 , 4 )
			InOut T_offset_2 : matrix ( real , 4 , 4 )
			InOut m_2 : real = 1.0
			InOut I_C_2 : matrix ( real , 3 , 3 ) = [| 0.083 , 0.0 , 0.0 ; 0.0 , 0.083 , 0.0 ; 0.0 , 0.0 , 0.001 |]
			InOut c_2 : vector ( real , 3 ) = [| 0.0 , 0.0 , 0.0 |]
			InOut cz_2 : real = 0.0
			InOut theta_2 : real
			InOut phi_3_2 : matrix ( real , 6 , 6 )
			InOut _V_3 : vector ( real , 6 )
			InOut _alpha_3 : vector ( real , 6 )
			InOut _B_3 : matrix ( real , 4 , 4 )
			InOut T_3_2 : matrix ( real , 4 , 4 )
			InOut _f_1 : vector ( real , 6 )
			InOut phi_2_1 : matrix ( real , 6 , 6 )
			InOut H_2 : matrix ( real , 1 , 6 )
			InOut X_J_2 : matrix ( real , 6 , 6 )
			InOut r_v2 : real = 1
			InOut tau_2 : vector ( real , 1 )
			local number : real = 2
			local poseVec : vector ( real , 6 ) = [| 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 |]
			equation submatrix ( M_2 ) ( 0 , 0 , 3 , 3 ) == I_C_2 + m_2 * transpose ( skew ( c_2 ) ) * skew ( c_2 )
			equation submatrix ( M_2 ) ( 0 , 3 , 3 , 3 ) == m_2 * transpose ( skew ( c_2 ) )
			equation submatrix ( M_2 ) ( 3 , 0 , 3 , 3 ) == - m_2 * skew ( c_2 )
			equation submatrix ( M_2 ) ( 3 , 3 , 3 , 3 ) == m_2 * identity ( 3 )
			equation V_2 == adj ( phi_3_2 ) * _V_3 + adj ( H_2 ) + derivative ( theta_2 )
			equation alpha_2 == adj ( phi_3_2 ) * _alpha_3 + adj ( H_2 ) * derivative ( theta_2 ) + a_2
			equation tau_2 == H_2 * f_2
			equation B_2 == _B_3 * T_3_2
			equation f_2 == phi_2_1 * _f_1 + M_2 * alpha_2 + b_2
			Constraint ( B_2 ) [ t == 0 ] == [| 1.000000 , 0.000000 , 0.000000 , 0.000000 ; 0.000000 , 1.000000 , 0.000000 , 0.000000 ; - 0.000000 , 0.000000 , 1.000000 , - 0.5 ; 0 , 0 , 0 , 1 |]
			Constraint ( T_geom_2 ) [ t == 0 ] == [| 1.000000 , 0.000000 , 0.000000 , 0.000000 ; 0.000000 , 1.000000 , 0.000000 , 0.000000 ; - 0.000000 , 0.000000 , 1.000000 , 0 ; 0 , 0 , 0 , 1 |]
			Constraint ( T_offset_2 ) [ t == 0 ] == [| 1.0 , 0.0 , 0.0 , 0.0 ; 0.0 , 1.0 , 0.0 , 0.0 ; 0.0 , 0.0 , 1.0 , 0 ; 0 , 0 , 0 , 1 |]
			Constraint ( X_T_2 ) [ t == 0 ] == [| 1 , 0 , 0 , 0 , 0 , 0 ; 0 , 1 , 0 , 0 , 0 , 0 ; 0 , 0 , 1 , 0 , 0 , 0 ; 0 , - 0.20000000298023224 , - 0.000000 , 1 , 0 , 0 ; 0.20000000298023224 , 0 , 0.000000 , 0 , 1 , 0 ; 0.000000 , - 0.000000 , 0 , 0 , 0 , 1 |]
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
				const H : vector ( real , 6 ) = [| 0 , 1 , 0 , 0 , 0 , 0 |]
				InOut theta : real
				InOut XJ : matrix ( real , 6 , 6 )
				equation XJ == [| cos ( theta ) , 0 ,  sin ( theta ) , 0 , 0 , 0 ;
										 0 , 1 , 0 , 0 , 0 , 0 ;
										 - sin ( theta ) , 0 ,  cos ( theta ) , 0 , 0 , 0 ;
										 0 , 0 , 0 ,  cos ( theta ) , 0 ,  sin ( theta ) ;
										 0 , 0 , 0 , 0 , 1 , 0 ;
										 0 , 0 , 0 ,  - sin ( theta ) , 0 ,  cos ( theta ) |]
			InOut B_1 : matrix ( real , 4 , 4 )
				InOut B_2 : matrix ( real , 4 , 4 )
				InOut _B_2 : matrix ( real , 4 , 4 )
				InOut T_2_1 : matrix ( real , 4 , 4 )
				InOut V_2 : vector ( real , 6 )
				InOut _V_2 : vector ( real , 6 )
				InOut alpha_2 : vector ( real , 6 )
				InOut _alpha_2 : vector ( real , 6 )
				InOut f_1 : vector ( real , 6 )
				InOut r_v1 : real = 1
				InOut theta_1 : real
				InOut phi_2_1 : matrix ( real , 6 , 6 )
				local number : real = 1
				local poseVec : vector ( real , 6 ) = [| 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 |]
				equation _B_2 == B_2
				equation _V_2 == V_2
				equation _alpha_2 == alpha_2
				equation _f_1 == f_1
			}
			flexibly connected to Link2
			pose { x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
		relation B_2 == ElbowJoint . B_2 /\ V_2 == ElbowJoint . V_2 /\ alpha_2 == ElbowJoint . alpha_2 /\ theta [ 0 ] == ElbowJoint . theta /\ H_1 == ElbowJoint . H /\ X_J_1 == ElbowJoint . XJ
		}
		pose { x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
	relation B_2 == Link1 . B_2 /\ V [ 1 ] == Link1 . V_2 /\ a [ 1 ] == Link1 . a_2 /\ b [ 1 ] == Link1 . b_2 /\ alpha [ 1 ] == Link1 . alpha_2 /\ submatrix ( M ) ( 6 , 6 , 6 , 6 ) == Link1 . M_2 /\ tau [ 1 ] == Link1 . tau_2 /\ L2_geom == geom_21 /\ submatrix ( H ) ( 1 , 6 , 1 , 6 ) == Link1 . H_2
		relation_flexi B_2 == Link1 . B_2 /\ f_2 == Link1 . f_2 /\ theta_2 == Link1 . theta_2 /\ T_3_2 == Link1 . T_3_2 /\ phi_3_2 == Link1 . phi_3_2 /\ _V_3 == Link1 . _V_3 /\ H == Link1 . H_2 /\ XJ == Link1 . X_J_2
	}

	local link Link2 {
		def { input test_1 : vector ( real , 1 )
			InOut geom_11 : Geom = Geom (| geomType = "cylinder" , geomVal = [| 0.05 , 2.0 |] |)
			InOut L1_geom : Geom = Geom (| geomType = "cylinder" , geomVal = [| 0.05 , 2.0 |] |)
			InOut M_1 : matrix ( real , 6 , 6 ) = [| 1.333 , 0.0 , 0.0 , 0.0 , 1 , 0.0 ; 0.0 , 1.333 , 0.0 , - 1.0 , 0.0 , 0.0 ; 0.0 , 0.0 , 0.001 , 0.0 , 0.0 , 0.0 ; 0.0 , - 1.0 , 0.0 , 1 , 0.0 , 0.0 ; 1 , 0.0 , 0.0 , 0.0 , 1 , 0.0 ; 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 1 |]
			InOut a_1 : vector ( real , 6 )
			InOut b_1 : vector ( real , 6 )
			InOut V_1 : vector ( real , 6 )
			InOut alpha_1 : vector ( real , 6 )
			InOut f_1 : vector ( real , 6 )
			InOut B_1 : matrix ( real , 4 , 4 )
			InOut X_T_1 : matrix ( real , 6 , 6 )
			InOut T_geom_1 : matrix ( real , 4 , 4 )
			InOut T_offset_1 : matrix ( real , 4 , 4 )
			InOut m_1 : real = 1.0
			InOut I_C_1 : matrix ( real , 3 , 3 ) = [| 0.333 , 0.0 , 0.0 ; 0.0 , 0.333 , 0.0 ; 0.0 , 0.0 , 0.001 |]
			InOut c_1 : vector ( real , 3 ) = [| 0.0 , 0.0 , 0.0 |]
			InOut cz_1 : real = 0.0
			InOut theta_1 : real
			InOut phi_2_1 : matrix ( real , 6 , 6 )
			InOut _V_2 : vector ( real , 6 )
			InOut _alpha_2 : vector ( real , 6 )
			InOut _B_2 : matrix ( real , 4 , 4 )
			InOut T_2_1 : matrix ( real , 4 , 4 )
			InOut H_1 : matrix ( real , 1 , 6 )
			InOut X_J_1 : matrix ( real , 6 , 6 )
			InOut r_v1 : real = 1
			InOut tau_1 : vector ( real , 1 )
			local number : real = 1
			local poseVec : vector ( real , 6 ) = [| 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 |]
			equation submatrix ( M_1 ) ( 0 , 0 , 3 , 3 ) == I_C_1 + m_1 * transpose ( skew ( c_1 ) ) * skew ( c_1 )
			equation submatrix ( M_1 ) ( 0 , 3 , 3 , 3 ) == m_1 * transpose ( skew ( c_1 ) )
			equation submatrix ( M_1 ) ( 3 , 0 , 3 , 3 ) == - m_1 * skew ( c_1 )
			equation submatrix ( M_1 ) ( 3 , 3 , 3 , 3 ) == m_1 * identity ( 3 )
			equation V_1 == adj ( phi_2_1 ) * _V_2 + adj ( H_1 ) + derivative ( theta_1 )
			equation alpha_1 == adj ( phi_2_1 ) * _alpha_2 + adj ( H_1 ) * derivative ( theta_1 ) + a_1
			equation tau_1 == H_1 * f_1
			equation B_1 == _B_2 * T_2_1
			equation f_1 == M_1 * alpha_1 + b_1
			Constraint ( B_1 ) [ t == 0 ] == [| 1.000000 , 0.000000 , 0.000000 , 0.000000 ; 0.000000 , 1.000000 , 0.000000 , 0.000000 ; - 0.000000 , 0.000000 , 1.000000 , - 1 ; 0 , 0 , 0 , 1 |]
			Constraint ( T_geom_1 ) [ t == 0 ] == [| 1.000000 , 0.000000 , 0.000000 , 0.000000 ; 0.000000 , 1.000000 , 0.000000 , 0.000000 ; - 0.000000 , 0.000000 , 1.000000 , 0 ; 0 , 0 , 0 , 1 |]
			Constraint ( T_offset_1 ) [ t == 0 ] == [| 1.0 , 0.0 , 0.0 , 0.0 ; 0.0 , 1.0 , 0.0 , 0.0 ; 0.0 , 0.0 , 1.0 , 0 ; 0 , 0 , 0 , 1 |]
			Constraint ( X_T_1 ) [ t == 0 ] == [| 1 , 0 , 0 , 0 , 0 , 0 ; 0 , 1 , 0 , 0 , 0 , 0 ; 0 , 0 , 1 , 0 , 0 , 0 ; 0 , - 1 , - 0.000000 , 1 , 0 , 0 ; 1 , 0 , 0.000000 , 0 , 1 , 0 ; 0.000000 , - 0.000000 , 0 , 0 , 0 , 1 |]
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
	relation B_1 == Link2 . B_1 /\ V [ 0 ] == Link2 . V_1 /\ a [ 0 ] == Link2 . a_1 /\ b [ 0 ] == Link2 . b_1 /\ alpha [ 0 ] == Link2 . alpha_1 /\ submatrix ( M ) ( 0 , 0 , 6 , 6 ) == Link2 . M_1 /\ tau [ 0 ] == Link2 . tau_1 /\ L1_geom == geom_11 /\ submatrix ( H ) ( 0 , 0 , 1 , 6 ) == Link2 . H_1
		relation_flexi B_1 == Link2 . B_1 /\ f_1 == Link2 . f_1 /\ theta_1 == Link2 . theta_1 /\ T_2_1 == Link2 . T_2_1 /\ phi_2_1 == Link2 . phi_2_1 /\ _V_2 == Link2 . _V_2 /\ H == Link2 . H_1 /\ XJ == Link2 . X_J_1
	}
	const n : int = 3
	InOut N : real = 2
	InOut B_k : Seq( matrix ( real , 4 , 4 ) )
	InOut X_J : Seq( matrix ( real , 6 , 6 ) )
	InOut X_T : Seq( matrix ( real , 6 , 6 ) )
	InOut T_geom : Seq( matrix ( real , 4 , 4 ) )
	InOut T_offset : Seq( matrix ( real , 4 , 4 ) )
	InOut V : vector ( real , 18 )
	InOut f : vector ( real , 18 )
	InOut a : vector ( real , 18 )
	InOut b : vector ( real , 18 )
	InOut alpha : vector ( real , 18 )
	InOut phi : matrix ( real , 18 , 18 )
	InOut M : matrix ( real , 18 , 18 )
	InOut theta : vector ( real , 2 )
	InOut tau : vector ( real , 2 )
	InOut C : vector ( real , 2 )
	InOut H : matrix ( real , 2 , 18 )
	InOut M_mass : matrix ( real , 2 , 2 )
	InOut H_1 : matrix ( real , 1 , 6 )
	InOut H_2 : matrix ( real , 1 , 6 )
	InOut B_1 : matrix ( real , 4 , 4 )
	InOut X_T_1 : matrix ( real , 6 , 6 )
	InOut M_1 : matrix ( real , 6 , 6 )
	InOut T_geom_1 : matrix ( real , 4 , 4 )
	InOut T_offset_1 : matrix ( real , 4 , 4 )
	InOut r_v1 : real = 1
	InOut T_2_1 : matrix ( real , 4 , 4 )
	InOut B_2 : matrix ( real , 4 , 4 )
	InOut X_T_2 : matrix ( real , 6 , 6 )
	InOut M_2 : matrix ( real , 6 , 6 )
	InOut T_geom_2 : matrix ( real , 4 , 4 )
	InOut T_offset_2 : matrix ( real , 4 , 4 )
	InOut r_v2 : real = 1
	InOut T_3_2 : matrix ( real , 4 , 4 )
	InOut B_3 : matrix ( real , 4 , 4 )
	InOut X_T_3 : matrix ( real , 6 , 6 )
	InOut M_3 : matrix ( real , 6 , 6 )
	InOut T_geom_3 : matrix ( real , 4 , 4 )
	InOut T_offset_3 : matrix ( real , 4 , 4 )
	InOut X_J_1 : matrix ( real , 6 , 6 )
	InOut X_J_2 : matrix ( real , 6 , 6 )
	equation submatrix ( phi ) ( 0 , 0 , 3 , 3 ) == identity ( 3 )
	equation submatrix ( phi ) ( 0 , 3 , 3 , 3 ) == zeroes ( 3 )
	equation submatrix ( phi ) ( 0 , 6 , 3 , 3 ) == zeroes ( 3 )
	equation submatrix ( phi ) ( 3 , 3 , 3 , 3 ) == identity ( 3 )
	equation submatrix ( phi ) ( 3 , 6 , 3 , 3 ) == zeroes ( 3 )
	equation submatrix ( phi ) ( 3 , 0 , 3 , 3 ) == Phi ( 2 , 1 , B_k )
	equation submatrix ( phi ) ( 6 , 6 , 3 , 3 ) == identity ( 3 )
	equation submatrix ( phi ) ( 6 , 0 , 3 , 3 ) == Phi ( 3 , 1 , B_k )
	equation submatrix ( phi ) ( 6 , 3 , 3 , 3 ) == Phi ( 3 , 2 , B_k )
	equation B_k == < B_1 , B_2 , B_3 >
	equation X_T == < X_T_1 , X_T_2 , X_T_3 >
	equation X_J == < X_J_1 , X_J_2 >
	equation T_geom == < T_geom_1 , T_geom_2 , T_geom_3 >
	equation T_offset == < T_offset_1 , T_offset_2 , T_offset_3 >
	equation V == adj ( phi ) * adj ( H ) * derivative ( theta )
	equation alpha == adj ( phi ) * adj ( H ) * derivative ( theta ) + a
	equation f == phi * ( M * alpha + b )
	equation tau == M_mass * derivative ( derivative ( theta ) ) + C
	equation M_mass == H * phi * M * adj ( phi ) * adj ( H )
	equation C == H * phi ( M * adj ( phi ) * a + b )
	equation B_1 == B_3 * T_3_2 * T_2_1
	equation B_2 == B_3 * T_3_2
	equation N == r_v1 + r_v2
	Constraint ( submatrix ( M ) ( 0 , 0 , 6 , 6 ) ) [ t == 0 ] == M_1
	Constraint ( submatrix ( M ) ( 6 , 6 , 6 , 6 ) ) [ t == 0 ] == M_2
	Constraint ( submatrix ( M ) ( 12 , 12 , 6 , 6 ) ) [ t == 0 ] == M_3
	Constraint ( submatrix ( H ) ( 0 , 0 , 1 , 6 ) ) [ t == 0 ] == H_1
	Constraint ( submatrix ( H ) ( 1 , 6 , 1 , 6 ) ) [ t == 0 ] == H_2
}
datatype Geom { geomType : string geomVal : vector ( real ) meshUri : string meshScale : vector ( real ) } function identity ( size : real ) : matrix ( real , 3 , 3 ) { } function zeroes ( size : real ) : matrix ( real , 3 , 3 ) { } function Phi ( m : real , n : real , B_k : Seq( matrix ( real , 4 , 4 ) ) ) : matrix ( real , 6 , 6 ) { } function zeroVec ( a : real ) : vector ( real , 1 ) { } function zeroMat ( a : real , b : real ) : matrix ( real , 0 , 0 ) { } function skew ( v : vector ( real , 3 ) ) : matrix ( real , 3 , 3 ) { } function getFramePosition ( k : real , B_n : Seq( matrix ( real , 4 , 4 ) ) ) : vector ( real , 3 ) { }