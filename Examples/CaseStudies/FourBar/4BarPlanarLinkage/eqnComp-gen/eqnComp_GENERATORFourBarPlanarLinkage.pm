import physmod::math::*
import physmod::SKO::joints::Revolute_y

pmodel FourBarPlanarLinkage {
	// Four-bar planar linkage with SKO-style joint definitions
	// Reference geometry: link length 4.0 (along +X), ground length 2.0 (along +X)

	local link Ground {
		// Anchor the ground frame at the left pivot (x = 0.0).
		pose { x=0.0 y=0.0 z=0.0 roll=0.0 pitch=0.0 yaw=0.0 }
		def { InOut B_4 : matrix ( real , 4 , 4 )
			InOut M_4 : matrix ( real , 6 , 6 )
			InOut b_4 : vector ( real , 6 )
			local number : real = 4
			local poseVec : vector ( real , 6 ) = [| 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 |]
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
				InOut H_3 : matrix ( real , 1 , 6 )
				InOut T_4_3 : matrix ( real , 4 , 4 )
				InOut theta_3 : real
				InOut tau_3 : real
				local number : real = 3
				local poseVec : vector ( real , 6 ) = [| 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 |]
				const H : vector ( real , 6 ) = (| 0 , 1 , 0 , 0 , 0 , 0 |)
				equation XJ == [| cos ( theta ) , 0 , sin ( theta ) , 0 , 0 , 0 ; 0 , 1 , 0 , 0 , 0 , 0 ; - sin ( theta ) , 0 , cos ( theta ) , 0 , 0 , 0 ; 0 , 0 , 0 , cos ( theta ) , 0 , sin ( theta ) ; 0 , 0 , 0 , 0 , 1 , 0 ; 0 , 0 , 0 , - sin ( theta ) , 0 , cos ( theta ) |]
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
			relation H_3 == theta1 . H /\ T_4_3 == theta1 . T_4_3 /\ theta [ 2 ] == theta1 . theta_3 /\ tau [ 2 ] == theta1 . tau_3 /\ X_J_3 == theta1 . XJ
		}
		local joint theta4 {
			def {
				InOut theta : real
				InOut XJ : matrix ( real , 6 , 6 )
				local poseVec : vector ( real , 6 ) = [| 2.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 |]
				local number : real = 3
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
		relation B_4 == Ground . B_4 /\ M_4 == Ground . M_4 /\ b_4 == Ground . b_4
	}

	local link Link1 {
		pose { x=0.0 y=0.0 z=0.0 roll=0.0 pitch=0.0 yaw=0.0 }
		def { InOut B_3 : matrix ( real , 4 , 4 )
			InOut M_3 : matrix ( real , 6 , 6 )
			InOut b_3 : vector ( real , 6 )
			local number : real = 3
			local poseVec : vector ( real , 6 ) = [| 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 |]
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
				InOut H_2 : matrix ( real , 1 , 6 )
				InOut T_3_2 : matrix ( real , 4 , 4 )
				InOut theta_2 : real
				InOut tau_2 : real
				local number : real = 2
				local poseVec : vector ( real , 6 ) = [| 4.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 |]
				const H : vector ( real , 6 ) = (| 0 , 1 , 0 , 0 , 0 , 0 |)
				equation XJ == [| cos ( theta ) , 0 , sin ( theta ) , 0 , 0 , 0 ; 0 , 1 , 0 , 0 , 0 , 0 ; - sin ( theta ) , 0 , cos ( theta ) , 0 , 0 , 0 ; 0 , 0 , 0 , cos ( theta ) , 0 , sin ( theta ) ; 0 , 0 , 0 , 0 , 1 , 0 ; 0 , 0 , 0 , - sin ( theta ) , 0 , cos ( theta ) |]
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
			relation H_2 == theta2 . H /\ T_3_2 == theta2 . T_3_2 /\ theta [ 1 ] == theta2 . theta_2 /\ tau [ 1 ] == theta2 . tau_2 /\ X_J_2 == theta2 . XJ
		}
		relation B_3 == Link1 . B_3 /\ M_3 == Link1 . M_3 /\ b_3 == Link1 . b_3
	}

	local link Link2 {
		pose { x=0.0 y=0.0 z=0.0 roll=0.0 pitch=0.0 yaw=0.0 }
		def { InOut B_2 : matrix ( real , 4 , 4 )
			InOut M_2 : matrix ( real , 6 , 6 )
			InOut b_2 : vector ( real , 6 )
			local number : real = 2
			local poseVec : vector ( real , 6 ) = [| 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 |]
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
				InOut H_1 : matrix ( real , 1 , 6 )
				InOut T_2_1 : matrix ( real , 4 , 4 )
				InOut theta_1 : real
				InOut tau_1 : real
				local number : real = 1
				local poseVec : vector ( real , 6 ) = [| 4.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 |]
				const H : vector ( real , 6 ) = (| 0 , 1 , 0 , 0 , 0 , 0 |)
				equation XJ == [| cos ( theta ) , 0 , sin ( theta ) , 0 , 0 , 0 ; 0 , 1 , 0 , 0 , 0 , 0 ; - sin ( theta ) , 0 , cos ( theta ) , 0 , 0 , 0 ; 0 , 0 , 0 , cos ( theta ) , 0 , sin ( theta ) ; 0 , 0 , 0 , 0 , 1 , 0 ; 0 , 0 , 0 , - sin ( theta ) , 0 , cos ( theta ) |]
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
			relation H_1 == theta3 . H /\ T_2_1 == theta3 . T_2_1 /\ theta [ 0 ] == theta3 . theta_1 /\ tau [ 0 ] == theta3 . tau_1 /\ X_J_1 == theta3 . XJ
		}
		relation B_2 == Link2 . B_2 /\ M_2 == Link2 . M_2 /\ b_2 == Link2 . b_2
	}

	local link Link3 {
		pose { x=0.0 y=0.0 z=0.0 roll=0.0 pitch=0.0 yaw=0.0 }
		def { InOut B_1 : matrix ( real , 4 , 4 )
			InOut M_1 : matrix ( real , 6 , 6 )
			InOut b_1 : vector ( real , 6 )
			local number : real = 1
			local poseVec : vector ( real , 6 ) = [| 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 |]
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
	relation B_1 == Link3 . B_1 /\ M_1 == Link3 . M_1 /\ b_1 == Link3 . b_1
	}
	const n : int = 4
	const nTree : int = 3
	InOut nLoop : real = 1
	InOut B_k : Seq( matrix ( real , 4 , 4 ) )
	InOut X_J : Seq( matrix ( real , 6 , 6 ) )
	InOut X_T : Seq( matrix ( real , 6 , 6 ) )
	InOut T_geom : Seq( matrix ( real , 4 , 4 ) )
	InOut T_offset : Seq( matrix ( real , 4 , 4 ) )
	InOut X_J_k : Seq( matrix ( real , 6 , 6 ) )
	InOut phi : matrix ( real , 24 , 24 )
	InOut M : matrix ( real , 24 , 24 )
	InOut H : matrix ( real , 3 , 24 )
	InOut theta : vector ( real , 3 )
	InOut tau : vector ( real , 3 )
	InOut V : vector ( real , 24 )
	InOut alpha : vector ( real , 24 )
	InOut a : vector ( real , 24 )
	InOut b : vector ( real , 24 )
	InOut f : vector ( real , 24 )
	InOut M_mass : matrix ( real , 3 , 3 )
	InOut C : vector ( real , 3 )
	InOut B_sel : matrix ( real , 12 , 24 )
	InOut Q_c : matrix ( real , 6 , 12 )
	InOut G_c : matrix ( real , 6 , 3 )
	InOut lambda_c : vector ( real , 6 )
	InOut Uprime : vector ( real , 6 )
	InOut g_pos : vector ( real , 3 )
	InOut B_4 : matrix ( real , 4 , 4 )
	InOut M_4 : matrix ( real , 6 , 6 )
	InOut b_4 : vector ( real , 6 )
	InOut X_T_4 : matrix ( real , 6 , 6 )
	InOut T_geom_4 : matrix ( real , 4 , 4 )
	InOut T_offset_4 : matrix ( real , 4 , 4 )
	InOut B_3 : matrix ( real , 4 , 4 )
	InOut M_3 : matrix ( real , 6 , 6 )
	InOut b_3 : vector ( real , 6 )
	InOut X_T_3 : matrix ( real , 6 , 6 )
	InOut T_geom_3 : matrix ( real , 4 , 4 )
	InOut T_offset_3 : matrix ( real , 4 , 4 )
	InOut B_2 : matrix ( real , 4 , 4 )
	InOut M_2 : matrix ( real , 6 , 6 )
	InOut b_2 : vector ( real , 6 )
	InOut X_T_2 : matrix ( real , 6 , 6 )
	InOut T_geom_2 : matrix ( real , 4 , 4 )
	InOut T_offset_2 : matrix ( real , 4 , 4 )
	InOut B_1 : matrix ( real , 4 , 4 )
	InOut M_1 : matrix ( real , 6 , 6 )
	InOut b_1 : vector ( real , 6 )
	InOut X_T_1 : matrix ( real , 6 , 6 )
	InOut T_geom_1 : matrix ( real , 4 , 4 )
	InOut T_offset_1 : matrix ( real , 4 , 4 )
	InOut H_3 : matrix ( real , 1 , 6 )
	InOut T_4_3 : matrix ( real , 4 , 4 )
	InOut X_J_3 : matrix ( real , 6 , 6 )
	InOut H_2 : matrix ( real , 1 , 6 )
	InOut T_3_2 : matrix ( real , 4 , 4 )
	InOut X_J_2 : matrix ( real , 6 , 6 )
	InOut H_1 : matrix ( real , 1 , 6 )
	InOut T_2_1 : matrix ( real , 4 , 4 )
	InOut X_J_1 : matrix ( real , 6 , 6 )
	equation B_3 == B_4 * T_4_3
	equation B_2 == B_3 * T_3_2
	equation B_k == < B_1 , B_2 , B_3 , B_4 >
	equation X_J == < X_J_1 , X_J_2 , X_J_3 >
	equation X_J_k == < X_J_1 , X_J_2 , X_J_3 >
	equation submatrix ( g_pos ) ( 0 , 0 , 3 , 1 ) == submatrix ( B_4 ) ( 0 , 3 , 3 , 1 ) + submatrix ( B_4 ) ( 0 , 0 , 3 , 3 ) * [| 2.0 ; 0.0 ; 0.0 |] - submatrix ( B_1 ) ( 0 , 3 , 3 , 1 )
	equation submatrix ( phi ) ( 0 , 0 , 6 , 6 ) == identity ( 6 )
	equation submatrix ( phi ) ( 0 , 6 , 6 , 6 ) == zeroes ( 6 )
	equation submatrix ( phi ) ( 0 , 12 , 6 , 6 ) == zeroes ( 6 )
	equation submatrix ( phi ) ( 6 , 0 , 6 , 6 ) == Phi ( 2 , 1 , B_k )
	equation submatrix ( phi ) ( 6 , 6 , 6 , 6 ) == identity ( 6 )
	equation submatrix ( phi ) ( 6 , 12 , 6 , 6 ) == zeroes ( 6 )
	equation submatrix ( phi ) ( 12 , 0 , 6 , 6 ) == Phi ( 3 , 1 , B_k )
	equation submatrix ( phi ) ( 12 , 6 , 6 , 6 ) == Phi ( 3 , 2 , B_k )
	equation submatrix ( phi ) ( 12 , 12 , 6 , 6 ) == identity ( 6 )
	equation submatrix ( b ) ( 0 , 0 , 6 , 1 ) == b_1
	equation submatrix ( b ) ( 6 , 0 , 6 , 1 ) == b_2
	equation submatrix ( b ) ( 12 , 0 , 6 , 1 ) == b_3
	equation submatrix ( H ) ( 0 , 0 , 1 , 6 ) == H_1
	equation submatrix ( H ) ( 1 , 6 , 1 , 6 ) == H_2
	equation submatrix ( H ) ( 2 , 12 , 1 , 6 ) == H_3
	equation V == adj ( phi ) * adj ( H ) * derivative ( theta )
	equation alpha == adj ( phi ) * ( adj ( H ) * derivative ( derivative ( theta ) ) + a )
	equation f == phi * ( M * alpha + b )
	equation M_mass == H * M * adj ( phi ) * adj ( H )
	equation C == H * phi * ( M * a + b )
	equation G_c == Q_c * B_sel * adj ( phi ) * adj ( H )
	equation Uprime + Q_c * B_sel * adj ( phi ) * a == 0
	equation tau + adj ( G_c ) * lambda_c == M_mass * derivative ( derivative ( theta ) ) + C
	equation G_c * derivative ( derivative ( theta ) ) == Uprime
	equation Q_c * B_sel * V == zeroVec ( 6 )
	Constraint ( nLoop ) [ t == 0 ] == 1
	Constraint ( B_4 ) [ t == 0 ] == [| 1 , 0 , 0 , 0 ; 0 , 1 , 0 , 0 ; 0 , 0 , 1 , 0 ; 0 , 0 , 0 , 1 |]
	Constraint ( T_offset_4 ) [ t == 0 ] == [| 1 , 0 , 0 , 0 ; 0 , 1 , 0 , 0 ; 0 , 0 , 1 , 0 ; 0 , 0 , 0 , 1 |]
	Constraint ( T_geom_4 ) [ t == 0 ] == [| 1 , 0 , 0 , 0 ; 0 , 1 , 0 , 0 ; 0 , 0 , 1 , 0 ; 0 , 0 , 0 , 1 |]
	Constraint ( X_T_4 ) [ t == 0 ] == [| 1 , 0 , 0 , 0 , 0 , 0 ; 0 , 1 , 0 , 0 , 0 , 0 ; 0 , 0 , 1 , 0 , 0 , 0 ; 0 , 0 , 0 , 1 , 0 , 0 ; 0 , 0 , 0 , 0 , 1 , 0 ; 0 , 0 , 0 , 0 , 0 , 1 |]
	Constraint ( B_3 ) [ t == 0 ] == [| 1 , 0 , 0 , 0 ; 0 , 1 , 0 , 0 ; 0 , 0 , 1 , 0 ; 0 , 0 , 0 , 1 |]
	Constraint ( T_offset_3 ) [ t == 0 ] == [| 1 , 0 , 0 , 0 ; 0 , 1 , 0 , 0 ; 0 , 0 , 1 , 0 ; 0 , 0 , 0 , 1 |]
	Constraint ( T_geom_3 ) [ t == 0 ] == [| 1 , 0 , 0 , 0 ; 0 , 1 , 0 , 0 ; 0 , 0 , 1 , 0 ; 0 , 0 , 0 , 1 |]
	Constraint ( X_T_3 ) [ t == 0 ] == [| 1 , 0 , 0 , 0 , 0 , 0 ; 0 , 1 , 0 , 0 , 0 , 0 ; 0 , 0 , 1 , 0 , 0 , 0 ; 0 , 0 , 0 , 1 , 0 , 0 ; 0 , 0 , 0 , 0 , 1 , 0 ; 0 , 0 , 0 , 0 , 0 , 1 |]
	Constraint ( B_2 ) [ t == 0 ] == [| 1 , 0 , 0 , 0 ; 0 , 1 , 0 , 0 ; 0 , 0 , 1 , 0 ; 0 , 0 , 0 , 1 |]
	Constraint ( T_offset_2 ) [ t == 0 ] == [| 1 , 0 , 0 , 0 ; 0 , 1 , 0 , 0 ; 0 , 0 , 1 , 0 ; 0 , 0 , 0 , 1 |]
	Constraint ( T_geom_2 ) [ t == 0 ] == [| 1 , 0 , 0 , 0 ; 0 , 1 , 0 , 0 ; 0 , 0 , 1 , 0 ; 0 , 0 , 0 , 1 |]
	Constraint ( X_T_2 ) [ t == 0 ] == [| 1 , 0 , 0 , 0 , 0 , 0 ; 0 , 1 , 0 , 0 , 0 , 0 ; 0 , 0 , 1 , 0 , 0 , 0 ; 0 , 0 , 0 , 1 , 0 , 0 ; 0 , 0 , 4 , 0 , 1 , 0 ; 0 , - 4 , 0 , 0 , 0 , 1 |]
	Constraint ( B_1 ) [ t == 0 ] == [| 1 , 0 , 0 , 0 ; 0 , 1 , 0 , 0 ; 0 , 0 , 1 , 0 ; 0 , 0 , 0 , 1 |]
	Constraint ( T_offset_1 ) [ t == 0 ] == [| 1 , 0 , 0 , 0 ; 0 , 1 , 0 , 0 ; 0 , 0 , 1 , 0 ; 0 , 0 , 0 , 1 |]
	Constraint ( T_geom_1 ) [ t == 0 ] == [| 1 , 0 , 0 , 0 ; 0 , 1 , 0 , 0 ; 0 , 0 , 1 , 0 ; 0 , 0 , 0 , 1 |]
	Constraint ( X_T_1 ) [ t == 0 ] == [| 1 , 0 , 0 , 0 , 0 , 0 ; 0 , 1 , 0 , 0 , 0 , 0 ; 0 , 0 , 1 , 0 , 0 , 0 ; 0 , 0 , 0 , 1 , 0 , 0 ; 0 , 0 , 4 , 0 , 1 , 0 ; 0 , - 4 , 0 , 0 , 0 , 1 |]
	Constraint ( submatrix ( B_sel ) ( 0 , 0 , 6 , 6 ) ) [ t == 0 ] == zeroMat ( 6 , 6 )
	Constraint ( submatrix ( B_sel ) ( 0 , 6 , 6 , 6 ) ) [ t == 0 ] == zeroMat ( 6 , 6 )
	Constraint ( submatrix ( B_sel ) ( 0 , 12 , 6 , 6 ) ) [ t == 0 ] == zeroMat ( 6 , 6 )
	Constraint ( submatrix ( B_sel ) ( 0 , 18 , 6 , 6 ) ) [ t == 0 ] == identity ( 6 )
	Constraint ( submatrix ( B_sel ) ( 6 , 0 , 6 , 6 ) ) [ t == 0 ] == identity ( 6 )
	Constraint ( submatrix ( B_sel ) ( 6 , 6 , 6 , 6 ) ) [ t == 0 ] == zeroMat ( 6 , 6 )
	Constraint ( submatrix ( B_sel ) ( 6 , 12 , 6 , 6 ) ) [ t == 0 ] == zeroMat ( 6 , 6 )
	Constraint ( submatrix ( B_sel ) ( 6 , 18 , 6 , 6 ) ) [ t == 0 ] == zeroMat ( 6 , 6 )
	Constraint ( submatrix ( Q_c ) ( 0 , 0 , 6 , 6 ) ) [ t == 0 ] == [| 1 , 0 , 0 , 0 , 0 , 0 ; 0 , 1 , 0 , 0 , 0 , 0 ; 0 , 0 , 1 , 0 , 0 , 0 ; 0 , 0 , 0 , 1 , 0 , 0 ; 0 , 0 , 2 , 0 , 1 , 0 ; 0 , - 2 , 0 , 0 , 0 , 1 |]
	Constraint ( submatrix ( Q_c ) ( 0 , 6 , 6 , 6 ) ) [ t == 0 ] == - identity ( 6 )
	Constraint ( submatrix ( M ) ( 0 , 0 , 6 , 6 ) ) [ t == 0 ] == M_1
	Constraint ( submatrix ( M ) ( 6 , 6 , 6 , 6 ) ) [ t == 0 ] == M_2
	Constraint ( submatrix ( M ) ( 12 , 12 , 6 , 6 ) ) [ t == 0 ] == M_3
}
function identity ( size : real ) : matrix ( real , 6 , 6 ) { } function zeroes ( size : real ) : matrix ( real , 6 , 6 ) { } function zeroMat ( r : real , c : real ) : matrix ( real , 0 , 0 ) { } function zeroVec ( n : real ) : vector ( real , 0 ) { } function Phi ( m : real , n : real , B_k : Seq( matrix ( real , 4 , 4 ) ) ) : matrix ( real , 6 , 6 ) { }