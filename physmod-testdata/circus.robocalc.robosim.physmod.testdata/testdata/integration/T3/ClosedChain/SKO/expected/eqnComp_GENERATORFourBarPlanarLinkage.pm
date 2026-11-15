import physmod::math::*
import physmod::SKO::joints::Revolute_y

pmodel FourBarPlanarLinkage {
	// Four-bar planar linkage with SKO-style joint definitions
	// Reference geometry: link length 4.0 (along +X), ground length 2.0 (along +X)

	local link Ground {
		// Anchor the ground frame at the left pivot (x = 0.0).
		pose { x=0.0 y=0.0 z=0.0 roll=0.0 pitch=0.0 yaw=0.0 }
		def { InOut geom_41 : Geom = Geom (| geomType = "box" , geomVal = [| 2.0 , 0.1 , 0.2 |] |)
			InOut L4_geom : Geom = Geom (| geomType = "box" , geomVal = [| 2.0 , 0.1 , 0.2 |] |)
			InOut M_4 : matrix ( real , 6 , 6 ) = [| 0.1 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 ; 0.0 , 1.1 , 0.0 , 0.0 , 0.0 , - 1.0 ; 0.0 , 0.0 , 1.1 , 0.0 , 1.0 , 0.0 ; 0.0 , 0.0 , 0.0 , 1.0 , 0.0 , 0.0 ; 0.0 , 0.0 , 1.0 , 0.0 , 1.0 , 0.0 ; 0.0 , - 1.0 , 0.0 , 0.0 , 0.0 , 1.0 |]
			InOut a_4 : vector ( real , 6 )
			InOut b_4 : vector ( real , 6 )
			InOut V_4 : vector ( real , 6 )
			InOut alpha_4 : vector ( real , 6 )
			InOut f_4 : vector ( real , 6 )
			InOut B_4 : matrix ( real , 4 , 4 )
			InOut X_T_4 : matrix ( real , 6 , 6 )
			InOut T_geom_4 : matrix ( real , 4 , 4 )
			InOut T_offset_4 : matrix ( real , 4 , 4 )
			InOut m_4 : real = 1.0
			InOut I_C_4 : matrix ( real , 3 , 3 ) = [| 0.1 , 0.0 , 0.0 ; 0.0 , 0.1 , 0.0 ; 0.0 , 0.0 , 0.1 |]
			InOut c_4 : vector ( real , 3 ) = [| 1.0 , 0.0 , 0.0 |]
			InOut cz_4 : real = 0.0
			InOut _f_3 : vector ( real , 6 )
			InOut phi_4_3 : matrix ( real , 6 , 6 )
			local number : real = 4
			local poseVec : vector ( real , 6 ) = [| 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 |]
			equation submatrix ( M_4 ) ( 0 , 0 , 3 , 3 ) == I_C_4 + m_4 * transpose ( skew ( c_4 ) ) * skew ( c_4 )
			equation submatrix ( M_4 ) ( 0 , 3 , 3 , 3 ) == m_4 * skew ( c_4 )
			equation submatrix ( M_4 ) ( 3 , 0 , 3 , 3 ) == - m_4 * skew ( c_4 )
			equation submatrix ( M_4 ) ( 3 , 3 , 3 , 3 ) == m_4 * identity ( 3 )
			equation f_4 == phi_4_3 * _f_3 + M_4 * alpha_4 + b_4
			equation V_4 == 0
			equation alpha_4 == a_4
			Constraint ( B_4 ) [ t == 0 ] == [| 1 , 0 , 0 , 0 ; 0 , 1 , 0 , 0 ; 0 , 0 , 1 , 0 ; 0 , 0 , 0 , 1 |]
			Constraint ( T_geom_4 ) [ t == 0 ] == [| 1 , 0 , 0 , 1 ; 0 , 1 , 0 , 0 ; 0 , 0 , 1 , 0 ; 0 , 0 , 0 , 1 |]
			Constraint ( T_offset_4 ) [ t == 0 ] == [| 1 , 0 , 0 , 1 ; 0 , 1 , 0 , 0 ; 0 , 0 , 1 , 0 ; 0 , 0 , 0 , 1 |]
			Constraint ( X_T_4 ) [ t == 0 ] == [| 1 , 0 , 0 , 0 , 0 , 0 ; 0 , 1 , 0 , 0 , 0 , 0 ; 0 , 0 , 1 , 0 , 0 , 0 ; 0 , 0 , 0 , 1 , 0 , 0 ; 0 , 0 , 0 , 0 , 1 , 0 ; 0 , 0 , 0 , 0 , 0 , 1 |]
		}
		local body GroundBody {
			def {
				inertial information {
					mass 1.0
					inertia matrix { ixx 0.1 ixy 0.0 ixz 0.0 iyy 0.1 iyz 0.0 izz 0.1 }
					pose { x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
				}
				box ( length = 2.0 , width = 0.1 , height = 0.2 )
			local number : real = 0
			}
			// Center ground geometry between pivots (x = 1.0 in world frame).
			pose { x = 1.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
		}
		local joint theta1 {
			def {
				InOut theta : real
				InOut XJ : matrix ( real , 6 , 6 )
				InOut B_3 : matrix ( real , 4 , 4 )
				InOut B_4 : matrix ( real , 4 , 4 )
				InOut _B_4 : matrix ( real , 4 , 4 )
				InOut T_4_3 : matrix ( real , 4 , 4 )
				InOut V_4 : vector ( real , 6 )
				InOut _V_4 : vector ( real , 6 )
				InOut alpha_4 : vector ( real , 6 )
				InOut _alpha_4 : vector ( real , 6 )
				InOut f_3 : vector ( real , 6 )
				InOut r_v3 : real = 1
				InOut theta_3 : real
				InOut phi_4_3 : matrix ( real , 6 , 6 )
				local number : real = 3
				local poseVec : vector ( real , 6 ) = [| 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 |]
				const H : vector ( real , 6 ) = (| 0 , 1 , 0 , 0 , 0 , 0 |)
				equation XJ == [| cos ( theta ) , 0 , sin ( theta ) , 0 , 0 , 0 ; 0 , 1 , 0 , 0 , 0 , 0 ; - sin ( theta ) , 0 , cos ( theta ) , 0 , 0 , 0 ; 0 , 0 , 0 , cos ( theta ) , 0 , sin ( theta ) ; 0 , 0 , 0 , 0 , 1 , 0 ; 0 , 0 , 0 , - sin ( theta ) , 0 , cos ( theta ) |]
				equation _B_4 == B_4
				equation _V_4 == V_4
				equation _alpha_4 == alpha_4
				equation _f_3 == f_3
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
			relation B_4 == theta1 . B_4 /\ V_4 == theta1 . V_4 /\ alpha_4 == theta1 . alpha_4 /\ theta [ 2 ] == theta1 . theta /\ H_3 == theta1 . H /\ X_J_3 == theta1 . XJ
		}
		local joint theta4 {
			def {
				InOut theta : real
				InOut XJ : matrix ( real , 6 , 6 )
				local number : real = 3
				local poseVec : vector ( real , 6 ) = [| 2.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 |]
				const H : vector ( real , 6 ) = (| 0 , 1 , 0 , 0 , 0 , 0 |)
				equation XJ == [| cos ( theta ) , 0 , sin ( theta ) , 0 , 0 , 0 ; 0 , 1 , 0 , 0 , 0 , 0 ; - sin ( theta ) , 0 , cos ( theta ) , 0 , 0 , 0 ; 0 , 0 , 0 , cos ( theta ) , 0 , sin ( theta ) ; 0 , 0 , 0 , 0 , 1 , 0 ; 0 , 0 , 0 , - sin ( theta ) , 0 , cos ( theta ) |]
			}
			flexibly connected to Link3
			pose {
				x = 2.0
				y = 0.0
				z = 0.0
				roll = 0.0
				pitch = 0.0
				yaw = 0.0
			}
		}
	relation B_4 == Ground . B_4 /\ V [ 3 ] == Ground . V_4 /\ a [ 3 ] == Ground . a_4 /\ b [ 3 ] == Ground . b_4 /\ alpha [ 3 ] == Ground . alpha_4 /\ submatrix ( M ) ( 18 , 18 , 6 , 6 ) == Ground . M_4 /\ L4_geom == geom_41
	}

	local link Link1 {
		pose { x=0.0 y=0.0 z=0.0 roll=0.0 pitch=1.8234765819369751 yaw=0.0 }
		def { InOut geom_31 : Geom = Geom (| geomType = "box" , geomVal = [| 4.0 , 0.1 , 0.2 |] |)
			InOut L3_geom : Geom = Geom (| geomType = "box" , geomVal = [| 4.0 , 0.1 , 0.2 |] |)
			InOut M_3 : matrix ( real , 6 , 6 ) = [| 0.025 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 ; 0.0 , 106.6667 , 0.0 , 0.0 , 0.0 , - 40.0 ; 0.0 , 0.0 , 106.6667 , 0.0 , 40.0 , 0.0 ; 0.0 , 0.0 , 0.0 , 20.0 , 0.0 , 0.0 ; 0.0 , 0.0 , 40.0 , 0.0 , 20.0 , 0.0 ; 0.0 , - 40.0 , 0.0 , 0.0 , 0.0 , 20.0 |]
			InOut a_3 : vector ( real , 6 )
			InOut b_3 : vector ( real , 6 )
			InOut V_3 : vector ( real , 6 )
			InOut alpha_3 : vector ( real , 6 )
			InOut f_3 : vector ( real , 6 )
			InOut B_3 : matrix ( real , 4 , 4 )
			InOut X_T_3 : matrix ( real , 6 , 6 )
			InOut T_geom_3 : matrix ( real , 4 , 4 )
			InOut T_offset_3 : matrix ( real , 4 , 4 )
			InOut m_3 : real = 20.0
			InOut I_C_3 : matrix ( real , 3 , 3 ) = [| 0.025 , 0.0 , 0.0 ; 0.0 , 26.6667 , 0.0 ; 0.0 , 0.0 , 26.6667 |]
			InOut c_3 : vector ( real , 3 ) = [| 2.0 , 0.0 , 0.0 |]
			InOut cz_3 : real = 0.0
			InOut _f_2 : vector ( real , 6 )
			InOut phi_3_2 : matrix ( real , 6 , 6 )
			InOut theta_3 : real
			InOut phi_4_3 : matrix ( real , 6 , 6 )
			InOut _V_4 : vector ( real , 6 )
			InOut _alpha_4 : vector ( real , 6 )
			InOut _B_4 : matrix ( real , 4 , 4 )
			InOut T_4_3 : matrix ( real , 4 , 4 )
			InOut H_3 : matrix ( real , 1 , 6 )
			InOut X_J_3 : matrix ( real , 6 , 6 )
			InOut r_v3 : real = 1
			InOut tau_3 : vector ( real , 1 )
			local number : real = 3
			local poseVec : vector ( real , 6 ) = [| 0.0 , 0.0 , 0.0 , 0.0 , 1.8234765819369751 , 0.0 |]
			equation submatrix ( M_3 ) ( 0 , 0 , 3 , 3 ) == I_C_3 + m_3 * transpose ( skew ( c_3 ) ) * skew ( c_3 )
			equation submatrix ( M_3 ) ( 0 , 3 , 3 , 3 ) == m_3 * skew ( c_3 )
			equation submatrix ( M_3 ) ( 3 , 0 , 3 , 3 ) == - m_3 * skew ( c_3 )
			equation submatrix ( M_3 ) ( 3 , 3 , 3 , 3 ) == m_3 * identity ( 3 )
			equation V_3 == adj ( phi_4_3 ) * _V_4 + adj ( H_3 ) * derivative ( theta_3 )
			equation alpha_3 == adj ( phi_4_3 ) * _alpha_4 + adj ( H_3 ) * derivative ( derivative ( theta_3 ) ) + a_3
			equation tau_3 == H_3 * f_3
			equation B_3 == _B_4 * T_4_3
			equation f_3 == phi_3_2 * _f_2 + M_3 * alpha_3 + b_3
			Constraint ( B_3 ) [ t == 0 ] == [| - 0.25 , 0 , 0.9682458365518543 , 0 ; 0 , 1 , 0 , 0 ; - 0.9682458365518543 , 0 , - 0.25 , 0 ; 0 , 0 , 0 , 1 |]
			Constraint ( T_geom_3 ) [ t == 0 ] == [| - 0.25 , 0 , 0.9682458365518543 , - 0.5 ; 0 , 1 , 0 , 0 ; - 0.9682458365518543 , 0 , - 0.25 , - 1.9364916731037085 ; 0 , 0 , 0 , 1 |]
			Constraint ( T_offset_3 ) [ t == 0 ] == [| 1 , 0 , 0 , 2 ; 0 , 1 , 0 , 0 ; 0 , 0 , 1 , 0 ; 0 , 0 , 0 , 1 |]
			Constraint ( X_T_3 ) [ t == 0 ] == [| 1 , 0 , 0 , 0 , 0 , 0 ; 0 , 1 , 0 , 0 , 0 , 0 ; 0 , 0 , 1 , 0 , 0 , 0 ; 0 , 0 , 0 , 1 , 0 , 0 ; 0 , 0 , 0 , 0 , 1 , 0 ; 0 , 0 , 0 , 0 , 0 , 1 |]
		}
		local body Link1Body {
			def {
				inertial information {
					mass 20.0
					inertia matrix { ixx 0.025 ixy 0.0 ixz 0.0 iyy 26.6667 iyz 0.0 izz 26.6667 }
					pose { x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
				}
				box ( length = 4.0 , width = 0.1 , height = 0.2 )
			local number : real = 0
			}
			pose { x = 2.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
		}
		local joint theta2 {
			def {
				InOut theta : real
				InOut XJ : matrix ( real , 6 , 6 )
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
				local poseVec : vector ( real , 6 ) = [| 4.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 |]
				const H : vector ( real , 6 ) = (| 0 , 1 , 0 , 0 , 0 , 0 |)
				equation XJ == [| cos ( theta ) , 0 , sin ( theta ) , 0 , 0 , 0 ; 0 , 1 , 0 , 0 , 0 , 0 ; - sin ( theta ) , 0 , cos ( theta ) , 0 , 0 , 0 ; 0 , 0 , 0 , cos ( theta ) , 0 , sin ( theta ) ; 0 , 0 , 0 , 0 , 1 , 0 ; 0 , 0 , 0 , - sin ( theta ) , 0 , cos ( theta ) |]
				equation _B_3 == B_3
				equation _V_3 == V_3
				equation _alpha_3 == alpha_3
				equation _f_2 == f_2
			}
			flexibly connected to Link2
			pose {
				x = 4.0
				y = 0.0
				z = 0.0
				roll = 0.0
				pitch = 0.0
				yaw = 0.0
			}
			relation B_3 == theta2 . B_3 /\ V_3 == theta2 . V_3 /\ alpha_3 == theta2 . alpha_3 /\ theta [ 1 ] == theta2 . theta /\ H_2 == theta2 . H /\ X_J_2 == theta2 . XJ
		}
	relation B_3 == Link1 . B_3 /\ V [ 2 ] == Link1 . V_3 /\ a [ 2 ] == Link1 . a_3 /\ b [ 2 ] == Link1 . b_3 /\ alpha [ 2 ] == Link1 . alpha_3 /\ submatrix ( M ) ( 12 , 12 , 6 , 6 ) == Link1 . M_3 /\ tau [ 2 ] == Link1 . tau_3 /\ L3_geom == geom_31 /\ submatrix ( H ) ( 2 , 12 , 1 , 6 ) == Link1 . H_3
		relation_flexi B_3 == Link1 . B_3 /\ f_3 == Link1 . f_3 /\ theta_3 == Link1 . theta_3 /\ T_4_3 == Link1 . T_4_3 /\ phi_4_3 == Link1 . phi_4_3 /\ _V_4 == Link1 . _V_4 /\ H == Link1 . H_3 /\ X_J_3 == Link1 . X_J_3
	}

	local link Link2 {
		pose { x=-1.0 y=0.0 z=-3.872983346207417 roll=0.0 pitch=0.0 yaw=0.0 }
		def { InOut geom_21 : Geom = Geom (| geomType = "box" , geomVal = [| 4.0 , 0.1 , 0.2 |] |)
			InOut L2_geom : Geom = Geom (| geomType = "box" , geomVal = [| 4.0 , 0.1 , 0.2 |] |)
			InOut M_2 : matrix ( real , 6 , 6 ) = [| 0.025 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 ; 0.0 , 106.6667 , 0.0 , 0.0 , 0.0 , - 40.0 ; 0.0 , 0.0 , 106.6667 , 0.0 , 40.0 , 0.0 ; 0.0 , 0.0 , 0.0 , 20.0 , 0.0 , 0.0 ; 0.0 , 0.0 , 40.0 , 0.0 , 20.0 , 0.0 ; 0.0 , - 40.0 , 0.0 , 0.0 , 0.0 , 20.0 |]
			InOut a_2 : vector ( real , 6 )
			InOut b_2 : vector ( real , 6 )
			InOut V_2 : vector ( real , 6 )
			InOut alpha_2 : vector ( real , 6 )
			InOut f_2 : vector ( real , 6 )
			InOut B_2 : matrix ( real , 4 , 4 )
			InOut X_T_2 : matrix ( real , 6 , 6 )
			InOut T_geom_2 : matrix ( real , 4 , 4 )
			InOut T_offset_2 : matrix ( real , 4 , 4 )
			InOut m_2 : real = 20.0
			InOut I_C_2 : matrix ( real , 3 , 3 ) = [| 0.025 , 0.0 , 0.0 ; 0.0 , 26.6667 , 0.0 ; 0.0 , 0.0 , 26.6667 |]
			InOut c_2 : vector ( real , 3 ) = [| 2.0 , 0.0 , 0.0 |]
			InOut cz_2 : real = 0.0
			InOut _f_1 : vector ( real , 6 )
			InOut phi_2_1 : matrix ( real , 6 , 6 )
			InOut theta_2 : real
			InOut phi_3_2 : matrix ( real , 6 , 6 )
			InOut _V_3 : vector ( real , 6 )
			InOut _alpha_3 : vector ( real , 6 )
			InOut _B_3 : matrix ( real , 4 , 4 )
			InOut T_3_2 : matrix ( real , 4 , 4 )
			InOut H_2 : matrix ( real , 1 , 6 )
			InOut X_J_2 : matrix ( real , 6 , 6 )
			InOut r_v2 : real = 1
			InOut tau_2 : vector ( real , 1 )
			local number : real = 2
			local poseVec : vector ( real , 6 ) = [| - 1.0 , 0.0 , - 3.872983346207417 , 0.0 , 0.0 , 0.0 |]
			equation submatrix ( M_2 ) ( 0 , 0 , 3 , 3 ) == I_C_2 + m_2 * transpose ( skew ( c_2 ) ) * skew ( c_2 )
			equation submatrix ( M_2 ) ( 0 , 3 , 3 , 3 ) == m_2 * skew ( c_2 )
			equation submatrix ( M_2 ) ( 3 , 0 , 3 , 3 ) == - m_2 * skew ( c_2 )
			equation submatrix ( M_2 ) ( 3 , 3 , 3 , 3 ) == m_2 * identity ( 3 )
			equation V_2 == adj ( phi_3_2 ) * _V_3 + adj ( H_2 ) * derivative ( theta_2 )
			equation alpha_2 == adj ( phi_3_2 ) * _alpha_3 + adj ( H_2 ) * derivative ( derivative ( theta_2 ) ) + a_2
			equation tau_2 == H_2 * f_2
			equation B_2 == _B_3 * T_3_2
			equation f_2 == phi_2_1 * _f_1 + M_2 * alpha_2 + b_2
			Constraint ( B_2 ) [ t == 0 ] == [| 1 , 0 , 0 , - 1 ; 0 , 1 , 0 , 0 ; 0 , 0 , 1 , - 3.872983346207417 ; 0 , 0 , 0 , 1 |]
			Constraint ( T_geom_2 ) [ t == 0 ] == [| 1 , 0 , 0 , 1 ; 0 , 1 , 0 , 0 ; 0 , 0 , 1 , - 3.872983346207417 ; 0 , 0 , 0 , 1 |]
			Constraint ( T_offset_2 ) [ t == 0 ] == [| 1 , 0 , 0 , 2 ; 0 , 1 , 0 , 0 ; 0 , 0 , 1 , 0 ; 0 , 0 , 0 , 1 |]
			Constraint ( X_T_2 ) [ t == 0 ] == [| 1 , 0 , 0 , 0 , 0 , 0 ; 0 , 1 , 0 , 0 , 0 , 0 ; 0 , 0 , 1 , 0 , 0 , 0 ; 0 , 0 , 0 , 1 , 0 , 0 ; 0 , 0 , 4 , 0 , 1 , 0 ; 0 , - 4 , 0 , 0 , 0 , 1 |]
		}
		local body Link2Body {
			def {
				inertial information {
					mass 20.0
					inertia matrix { ixx 0.025 ixy 0.0 ixz 0.0 iyy 26.6667 iyz 0.0 izz 26.6667 }
					pose { x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
				}
				box ( length = 4.0 , width = 0.1 , height = 0.2 )
			local number : real = 0
			}
			pose { x = 2.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
		}
		local joint theta3 {
			def {
				InOut theta : real
				InOut XJ : matrix ( real , 6 , 6 )
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
				local poseVec : vector ( real , 6 ) = [| 4.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 |]
				const H : vector ( real , 6 ) = (| 0 , 1 , 0 , 0 , 0 , 0 |)
				equation XJ == [| cos ( theta ) , 0 , sin ( theta ) , 0 , 0 , 0 ; 0 , 1 , 0 , 0 , 0 , 0 ; - sin ( theta ) , 0 , cos ( theta ) , 0 , 0 , 0 ; 0 , 0 , 0 , cos ( theta ) , 0 , sin ( theta ) ; 0 , 0 , 0 , 0 , 1 , 0 ; 0 , 0 , 0 , - sin ( theta ) , 0 , cos ( theta ) |]
				equation _B_2 == B_2
				equation _V_2 == V_2
				equation _alpha_2 == alpha_2
				equation _f_1 == f_1
			}
			flexibly connected to Link3
			pose {
				x = 4.0
				y = 0.0
				z = 0.0
				roll = 0.0
				pitch = 0.0
				yaw = 0.0
			}
			relation B_2 == theta3 . B_2 /\ V_2 == theta3 . V_2 /\ alpha_2 == theta3 . alpha_2 /\ theta [ 0 ] == theta3 . theta /\ H_1 == theta3 . H /\ X_J_1 == theta3 . XJ
		}
	relation B_2 == Link2 . B_2 /\ V [ 1 ] == Link2 . V_2 /\ a [ 1 ] == Link2 . a_2 /\ b [ 1 ] == Link2 . b_2 /\ alpha [ 1 ] == Link2 . alpha_2 /\ submatrix ( M ) ( 6 , 6 , 6 , 6 ) == Link2 . M_2 /\ tau [ 1 ] == Link2 . tau_2 /\ L2_geom == geom_21 /\ submatrix ( H ) ( 1 , 6 , 1 , 6 ) == Link2 . H_2
		relation_flexi B_2 == Link2 . B_2 /\ f_2 == Link2 . f_2 /\ theta_2 == Link2 . theta_2 /\ T_3_2 == Link2 . T_3_2 /\ phi_3_2 == Link2 . phi_3_2 /\ _V_3 == Link2 . _V_3 /\ H == Link2 . H_2 /\ X_J_2 == Link2 . X_J_2
	}

	local link Link3 {
		pose { x=3.0 y=0.0 z=-3.872983346207417 roll=0.0 pitch=-1.8234765819369751 yaw=0.0 }
		def { InOut geom_11 : Geom = Geom (| geomType = "box" , geomVal = [| 4.0 , 0.1 , 0.2 |] |)
			InOut L1_geom : Geom = Geom (| geomType = "box" , geomVal = [| 4.0 , 0.1 , 0.2 |] |)
			InOut M_1 : matrix ( real , 6 , 6 ) = [| 0.025 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 ; 0.0 , 106.6667 , 0.0 , 0.0 , 0.0 , - 40.0 ; 0.0 , 0.0 , 106.6667 , 0.0 , 40.0 , 0.0 ; 0.0 , 0.0 , 0.0 , 20.0 , 0.0 , 0.0 ; 0.0 , 0.0 , 40.0 , 0.0 , 20.0 , 0.0 ; 0.0 , - 40.0 , 0.0 , 0.0 , 0.0 , 20.0 |]
			InOut a_1 : vector ( real , 6 )
			InOut b_1 : vector ( real , 6 )
			InOut V_1 : vector ( real , 6 )
			InOut alpha_1 : vector ( real , 6 )
			InOut f_1 : vector ( real , 6 )
			InOut B_1 : matrix ( real , 4 , 4 )
			InOut X_T_1 : matrix ( real , 6 , 6 )
			InOut T_geom_1 : matrix ( real , 4 , 4 )
			InOut T_offset_1 : matrix ( real , 4 , 4 )
			InOut m_1 : real = 20.0
			InOut I_C_1 : matrix ( real , 3 , 3 ) = [| 0.025 , 0.0 , 0.0 ; 0.0 , 26.6667 , 0.0 ; 0.0 , 0.0 , 26.6667 |]
			InOut c_1 : vector ( real , 3 ) = [| 2.0 , 0.0 , 0.0 |]
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
			local poseVec : vector ( real , 6 ) = [| 3.0 , 0.0 , - 3.872983346207417 , 0.0 , - 1.8234765819369751 , 0.0 |]
			equation submatrix ( M_1 ) ( 0 , 0 , 3 , 3 ) == I_C_1 + m_1 * transpose ( skew ( c_1 ) ) * skew ( c_1 )
			equation submatrix ( M_1 ) ( 0 , 3 , 3 , 3 ) == m_1 * skew ( c_1 )
			equation submatrix ( M_1 ) ( 3 , 0 , 3 , 3 ) == - m_1 * skew ( c_1 )
			equation submatrix ( M_1 ) ( 3 , 3 , 3 , 3 ) == m_1 * identity ( 3 )
			equation V_1 == adj ( phi_2_1 ) * _V_2 + adj ( H_1 ) * derivative ( theta_1 )
			equation alpha_1 == adj ( phi_2_1 ) * _alpha_2 + adj ( H_1 ) * derivative ( derivative ( theta_1 ) ) + a_1
			equation tau_1 == H_1 * f_1
			equation B_1 == _B_2 * T_2_1
			equation f_1 == M_1 * alpha_1 + b_1
			Constraint ( B_1 ) [ t == 0 ] == [| - 0.25 , 0 , - 0.9682458365518543 , 3 ; 0 , 1 , 0 , 0 ; 0.9682458365518543 , 0 , - 0.25 , - 3.872983346207417 ; 0 , 0 , 0 , 1 |]
			Constraint ( T_geom_1 ) [ t == 0 ] == [| - 0.25 , 0 , - 0.9682458365518543 , 2.5 ; 0 , 1 , 0 , 0 ; 0.9682458365518543 , 0 , - 0.25 , - 1.9364916731037085 ; 0 , 0 , 0 , 1 |]
			Constraint ( T_offset_1 ) [ t == 0 ] == [| 1 , 0 , 0 , 2 ; 0 , 1 , 0 , 0 ; 0 , 0 , 1 , 0 ; 0 , 0 , 0 , 1 |]
			Constraint ( X_T_1 ) [ t == 0 ] == [| 1 , 0 , 0 , 0 , 0 , 0 ; 0 , 1 , 0 , 0 , 0 , 0 ; 0 , 0 , 1 , 0 , 0 , 0 ; 0 , 0 , 0 , 1 , 0 , 0 ; 0 , 0 , 4 , 0 , 1 , 0 ; 0 , - 4 , 0 , 0 , 0 , 1 |]
		}
		local body Link3Body {
			def {
				inertial information {
					mass 20.0
					inertia matrix { ixx 0.025 ixy 0.0 ixz 0.0 iyy 26.6667 iyz 0.0 izz 26.6667 }
					pose { x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
				}
				box ( length = 4.0 , width = 0.1 , height = 0.2 )
			local number : real = 0
			}
			pose { x = 2.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
		}
	relation B_1 == Link3 . B_1 /\ V [ 0 ] == Link3 . V_1 /\ a [ 0 ] == Link3 . a_1 /\ b [ 0 ] == Link3 . b_1 /\ alpha [ 0 ] == Link3 . alpha_1 /\ submatrix ( M ) ( 0 , 0 , 6 , 6 ) == Link3 . M_1 /\ tau [ 0 ] == Link3 . tau_1 /\ L1_geom == geom_11 /\ submatrix ( H ) ( 0 , 0 , 1 , 6 ) == Link3 . H_1
		relation_flexi B_1 == Link3 . B_1 /\ f_1 == Link3 . f_1 /\ theta_1 == Link3 . theta_1 /\ T_2_1 == Link3 . T_2_1 /\ phi_2_1 == Link3 . phi_2_1 /\ _V_2 == Link3 . _V_2 /\ H == Link3 . H_1 /\ X_J_1 == Link3 . X_J_1
	}
	const n : int = 4
	const nTree : int = 3
	InOut N : real = 3
	InOut nLoop : real = 1
	InOut B_k : Seq( matrix ( real , 4 , 4 ) )
	InOut X_J : Seq( matrix ( real , 6 , 6 ) )
	InOut X_T : Seq( matrix ( real , 6 , 6 ) )
	InOut T_geom : Seq( matrix ( real , 4 , 4 ) )
	InOut T_offset : Seq( matrix ( real , 4 , 4 ) )
	InOut X_J_k : Seq( matrix ( real , 6 , 6 ) )
	InOut V : vector ( real , 24 )
	InOut f : vector ( real , 24 )
	InOut a : vector ( real , 24 )
	InOut b : vector ( real , 24 )
	InOut alpha : vector ( real , 24 )
	InOut phi : matrix ( real , 24 , 24 )
	InOut M : matrix ( real , 24 , 24 )
	InOut theta : vector ( real , 3 )
	InOut tau : vector ( real , 3 )
	InOut C : vector ( real , 3 )
	InOut H : matrix ( real , 3 , 24 )
	InOut M_mass : matrix ( real , 3 , 3 )
	InOut B_sel : matrix ( real , 12 , 24 )
	InOut Q_c : matrix ( real , 6 , 12 )
	InOut G_c : matrix ( real , 6 , 3 )
	InOut lambda_c : vector ( real , 6 )
	InOut Uprime : vector ( real , 6 )
	InOut g_pos : vector ( real , 3 )
	InOut H_1 : matrix ( real , 1 , 6 )
	InOut H_2 : matrix ( real , 1 , 6 )
	InOut H_3 : matrix ( real , 1 , 6 )
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
	InOut r_v3 : real = 1
	InOut T_4_3 : matrix ( real , 4 , 4 )
	InOut B_4 : matrix ( real , 4 , 4 )
	InOut X_T_4 : matrix ( real , 6 , 6 )
	InOut M_4 : matrix ( real , 6 , 6 )
	InOut T_geom_4 : matrix ( real , 4 , 4 )
	InOut T_offset_4 : matrix ( real , 4 , 4 )
	InOut X_J_1 : matrix ( real , 6 , 6 )
	InOut X_J_2 : matrix ( real , 6 , 6 )
	InOut X_J_3 : matrix ( real , 6 , 6 )
	equation submatrix ( phi ) ( 0 , 0 , 6 , 6 ) == identity ( 6 )
	equation submatrix ( phi ) ( 0 , 6 , 6 , 6 ) == zeroes ( 6 )
	equation submatrix ( phi ) ( 0 , 12 , 6 , 6 ) == zeroes ( 6 )
	equation submatrix ( phi ) ( 0 , 18 , 6 , 6 ) == zeroes ( 6 )
	equation submatrix ( phi ) ( 6 , 6 , 6 , 6 ) == identity ( 6 )
	equation submatrix ( phi ) ( 6 , 12 , 6 , 6 ) == zeroes ( 6 )
	equation submatrix ( phi ) ( 6 , 18 , 6 , 6 ) == zeroes ( 6 )
	equation submatrix ( phi ) ( 6 , 0 , 6 , 6 ) == Phi ( 2 , 1 , B_k )
	equation submatrix ( phi ) ( 12 , 12 , 6 , 6 ) == identity ( 6 )
	equation submatrix ( phi ) ( 12 , 18 , 6 , 6 ) == zeroes ( 6 )
	equation submatrix ( phi ) ( 12 , 0 , 6 , 6 ) == Phi ( 3 , 1 , B_k )
	equation submatrix ( phi ) ( 12 , 6 , 6 , 6 ) == Phi ( 3 , 2 , B_k )
	equation submatrix ( phi ) ( 18 , 18 , 6 , 6 ) == identity ( 6 )
	equation submatrix ( phi ) ( 18 , 0 , 6 , 6 ) == Phi ( 4 , 1 , B_k )
	equation submatrix ( phi ) ( 18 , 6 , 6 , 6 ) == Phi ( 4 , 2 , B_k )
	equation submatrix ( phi ) ( 18 , 12 , 6 , 6 ) == Phi ( 4 , 3 , B_k )
	equation B_k == < B_1 , B_2 , B_3 , B_4 >
	equation X_T == < X_T_1 , X_T_2 , X_T_3 , X_T_4 >
	equation X_J == < X_J_1 , X_J_2 , X_J_3 >
	equation X_J_k == < X_J_1 , X_J_2 , X_J_3 >
	equation T_geom == < T_geom_1 , T_geom_2 , T_geom_3 , T_geom_4 >
	equation T_offset == < T_offset_1 , T_offset_2 , T_offset_3 , T_offset_4 >
	equation V == adj ( phi ) * adj ( H ) * derivative ( theta )
	equation alpha == adj ( phi ) * ( adj ( H ) * derivative ( derivative ( theta ) ) + a )
	equation f == phi * ( M * alpha + b )
	equation M_mass == H * phi * M * adj ( phi ) * adj ( H )
	equation C == H * phi * ( M * adj ( phi ) * a + b )
	equation G_c == Q_c * B_sel * adj ( phi ) * adj ( H )
	equation Uprime + Q_c * B_sel * adj ( phi ) * a == 0
	equation tau + adj ( G_c ) * lambda_c == M_mass * derivative ( derivative ( theta ) ) + C
	equation G_c * derivative ( derivative ( theta ) ) == Uprime
	equation Q_c * B_sel * V == zeroVec ( 6 )
	equation submatrix ( g_pos ) ( 0 , 0 , 3 , 1 ) == submatrix ( B_4 ) ( 0 , 3 , 3 , 1 ) + submatrix ( B_4 ) ( 0 , 0 , 3 , 3 ) * [| 2.0 ; 0.0 ; 0.0 |] - ( submatrix ( B_1 ) ( 0 , 3 , 3 , 1 ) + submatrix ( B_1 ) ( 0 , 0 , 3 , 3 ) * [| 4.0 ; 0.0 ; 0.0 |] )
	equation B_1 == B_4 * T_4_3 * T_3_2 * T_2_1
	equation B_2 == B_4 * T_4_3 * T_3_2
	equation B_3 == B_4 * T_4_3
	equation N == r_v1 + r_v2 + r_v3
	Constraint ( nLoop ) [ t == 0 ] == 1
	Constraint ( submatrix ( B_sel ) ( 0 , 0 , 6 , 6 ) ) [ t == 0 ] == zeroMat ( 6 , 6 )
	Constraint ( submatrix ( B_sel ) ( 0 , 6 , 6 , 6 ) ) [ t == 0 ] == zeroMat ( 6 , 6 )
	Constraint ( submatrix ( B_sel ) ( 0 , 12 , 6 , 6 ) ) [ t == 0 ] == zeroMat ( 6 , 6 )
	Constraint ( submatrix ( B_sel ) ( 0 , 18 , 6 , 6 ) ) [ t == 0 ] == identity ( 6 )
	Constraint ( submatrix ( B_sel ) ( 6 , 0 , 6 , 6 ) ) [ t == 0 ] == identity ( 6 )
	Constraint ( submatrix ( B_sel ) ( 6 , 6 , 6 , 6 ) ) [ t == 0 ] == zeroMat ( 6 , 6 )
	Constraint ( submatrix ( B_sel ) ( 6 , 12 , 6 , 6 ) ) [ t == 0 ] == zeroMat ( 6 , 6 )
	Constraint ( submatrix ( B_sel ) ( 6 , 18 , 6 , 6 ) ) [ t == 0 ] == zeroMat ( 6 , 6 )
	Constraint ( submatrix ( Q_c ) ( 0 , 0 , 6 , 6 ) ) [ t == 0 ] == [| 1 , 0 , 0 , 0 , 0 , 0 ; 0 , 1 , 0 , 0 , 0 , 0 ; 0 , 0 , 1 , 0 , 0 , 0 ; 0 , 0 , 0 , 1 , 0 , 0 ; 0 , 0 , 2 , 0 , 1 , 0 ; 0 , - 2 , 0 , 0 , 0 , 1 |]
	Constraint ( submatrix ( Q_c ) ( 0 , 6 , 6 , 6 ) ) [ t == 0 ] == [| - 1 , 0 , 0 , 0 , 0 , 0 ; 0 , - 1 , 0 , 0 , 0 , 0 ; 0 , 0 , - 1 , 0 , 0 , 0 ; 0 , 0 , 0 , - 1 , 0 , 0 ; 0 , 0 , - 4 , 0 , - 1 , 0 ; 0 , 4 , 0 , 0 , 0 , - 1 |]
	Constraint ( submatrix ( M ) ( 0 , 0 , 6 , 6 ) ) [ t == 0 ] == M_1
	Constraint ( submatrix ( M ) ( 6 , 6 , 6 , 6 ) ) [ t == 0 ] == M_2
	Constraint ( submatrix ( M ) ( 12 , 12 , 6 , 6 ) ) [ t == 0 ] == M_3
	Constraint ( submatrix ( M ) ( 18 , 18 , 6 , 6 ) ) [ t == 0 ] == M_4
	Constraint ( submatrix ( H ) ( 0 , 0 , 1 , 6 ) ) [ t == 0 ] == H_1
	Constraint ( submatrix ( H ) ( 1 , 6 , 1 , 6 ) ) [ t == 0 ] == H_2
	Constraint ( submatrix ( H ) ( 2 , 12 , 1 , 6 ) ) [ t == 0 ] == H_3
}
datatype Geom { geomType : string geomVal : vector ( real ) meshUri : string meshScale : vector ( real ) } function identity ( size : real ) : matrix ( real , 6 , 6 ) { } function zeroes ( size : real ) : matrix ( real , 6 , 6 ) { } function Phi ( m : real , n : real , B_k : Seq( matrix ( real , 4 , 4 ) ) ) : matrix ( real , 6 , 6 ) { } function zeroVec ( a : real ) : vector ( real , 1 ) { } function zeroMat ( a : real , b : real ) : matrix ( real , 0 , 0 ) { } function skew ( v : vector ( real , 3 ) ) : matrix ( real , 3 , 3 ) { } function getFramePosition ( k : real , B_n : Seq( matrix ( real , 4 , 4 ) ) ) : vector ( real , 3 ) { }
