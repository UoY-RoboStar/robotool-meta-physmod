package TwoLinksPlusFixedConnection

pmodel TwoLinksPlusFixedConnection {
	local link Tip {
		pose { x=0.0 y=0.0 z=0.9 roll=0.0 pitch=0.0 yaw=0.0 }
		def {
			InOut B_2 : matrix ( real , 4 , 4 )
			InOut M_2 : matrix ( real , 6 , 6 )
			InOut b_2 : vector ( real , 6 )
			local number : real = 2
			local poseVec : vector ( real , 6 ) = [| 0.0 , 0.0 , 0.9 , 0.0 , 0.0 , 0.0 |]
			inertial information {
				mass 5.7
				inertia matrix { ixx 0.0 ixy 1.0 ixz 2.3 iyy 1.2 iyz 0.5 izz 0.0 }
			}
		}
		local body Tip {
			def {
				sphere (radius=0.05)
				friction {
					translational {
						coefficient1 0.0
						coefficient2 0.0
						direction (|0,1,0|)
						slip1 1.0
						slip2 1.0
					}
				}
			local number : real = 0
			}
		}
	relation B_2 == Tip . B_2 /\ M_2 == Tip . M_2 /\ b_2 == Tip . b_2
	}
	local link Rod {
		pose { x=0.0 y=0.0 z=0.0 roll=0.0 pitch=0.0 yaw=0.0 }
		def {
			InOut B_1 : matrix ( real , 4 , 4 )
			InOut M_1 : matrix ( real , 6 , 6 )
			InOut b_1 : vector ( real , 6 )
			local number : real = 1
			local poseVec : vector ( real , 6 ) = [| 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 |]
			inertial information {
				mass 0.0
				inertia matrix { ixx 0.0 ixy 0.0 ixz 0.0 iyy 0.0 iyz 0.0 izz 0.0 }
			}
		}
		fixed to Tip
		local body Rod {
			def {
				cylinder (radius=0.05, length=1.8)
			}
		}
	relation B_1 == Rod . B_1 /\ M_1 == Rod . M_1 /\ b_1 == Rod . b_1
	}
	const n : int = 2
	const nTree : int = 1
	InOut nLoop : real = - 1.0
	InOut B_k : Seq( matrix ( real , 4 , 4 ) )
	InOut X_J : Seq( matrix ( real , 6 , 6 ) )
	InOut X_T : Seq( matrix ( real , 6 , 6 ) )
	InOut T_geom : Seq( matrix ( real , 4 , 4 ) )
	InOut T_offset : Seq( matrix ( real , 4 , 4 ) )
	InOut X_J_k : Seq( matrix ( real , 6 , 6 ) )
	InOut phi : matrix ( real , 12 , 12 )
	InOut M : matrix ( real , 12 , 12 )
	InOut H : matrix ( real , 1 , 12 )
	InOut theta : vector ( real , 1 )
	InOut tau : vector ( real , 1 )
	InOut V : vector ( real , 12 )
	InOut alpha : vector ( real , 12 )
	InOut a : vector ( real , 12 )
	InOut b : vector ( real , 12 )
	InOut f : vector ( real , 12 )
	InOut M_mass : matrix ( real , 1 , 1 )
	InOut C : vector ( real , 1 )
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
	equation B_k == < B_1 , B_2 >
	equation X_J == < X_J_1 >
	equation X_J_k == < X_J_1 >
	equation submatrix ( phi ) ( 0 , 0 , 6 , 6 ) == identity ( 6 )
	equation submatrix ( b ) ( 0 , 0 , 6 , 1 ) == b_1
	equation submatrix ( H ) ( 0 , 0 , 1 , 6 ) == H_1
	equation V == adj ( phi ) * adj ( H ) * derivative ( theta )
	equation alpha == adj ( phi ) * ( adj ( H ) * derivative ( derivative ( theta ) ) + a )
	equation f == phi * ( M * alpha + b )
	equation M_mass == H * M * adj ( phi ) * adj ( H )
	equation C == H * phi * ( M * a + b )
	equation tau == M_mass * derivative ( derivative ( theta ) ) + C
	Constraint ( nLoop ) [ t == 0 ] == - 1
	Constraint ( B_2 ) [ t == 0 ] == [| 1 , 0 , 0 , 0 ; 0 , 1 , 0 , 0 ; 0 , 0 , 1 , 0.8999999761581421 ; 0 , 0 , 0 , 1 |]
	Constraint ( T_offset_2 ) [ t == 0 ] == [| 1 , 0 , 0 , 0 ; 0 , 1 , 0 , 0 ; 0 , 0 , 1 , 0 ; 0 , 0 , 0 , 1 |]
	Constraint ( T_geom_2 ) [ t == 0 ] == [| 1 , 0 , 0 , 0 ; 0 , 1 , 0 , 0 ; 0 , 0 , 1 , 0.8999999761581421 ; 0 , 0 , 0 , 1 |]
	Constraint ( X_T_2 ) [ t == 0 ] == [| 1 , 0 , 0 , 0 , 0 , 0 ; 0 , 1 , 0 , 0 , 0 , 0 ; 0 , 0 , 1 , 0 , 0 , 0 ; 0 , 0 , 0 , 1 , 0 , 0 ; 0 , 0 , 0 , 0 , 1 , 0 ; 0 , 0 , 0 , 0 , 0 , 1 |]
	Constraint ( B_1 ) [ t == 0 ] == [| 1 , 0 , 0 , 0 ; 0 , 1 , 0 , 0 ; 0 , 0 , 1 , 0 ; 0 , 0 , 0 , 1 |]
	Constraint ( T_offset_1 ) [ t == 0 ] == [| 1 , 0 , 0 , 0 ; 0 , 1 , 0 , 0 ; 0 , 0 , 1 , 0 ; 0 , 0 , 0 , 1 |]
	Constraint ( T_geom_1 ) [ t == 0 ] == [| 1 , 0 , 0 , 0 ; 0 , 1 , 0 , 0 ; 0 , 0 , 1 , 0 ; 0 , 0 , 0 , 1 |]
	Constraint ( X_T_1 ) [ t == 0 ] == [| 1 , 0 , 0 , 0 , 0 , 0 ; 0 , 1 , 0 , 0 , 0 , 0 ; 0 , 0 , 1 , 0 , 0 , 0 ; 0 , 0 , 0 , 1 , 0 , 0 ; 0 , 0 , 0 , 0 , 1 , 0 ; 0 , 0 , 0 , 0 , 0 , 1 |]
	Constraint ( submatrix ( M ) ( 0 , 0 , 6 , 6 ) ) [ t == 0 ] == M_1
}
function identity ( size : real ) : matrix ( real , 6 , 6 ) { } function zeroes ( size : real ) : matrix ( real , 6 , 6 ) { } function zeroMat ( r : real , c : real ) : matrix ( real , 0 , 0 ) { } function zeroVec ( n : real ) : vector ( real , 0 ) { } function Phi ( m : real , n : real , B_k : Seq( matrix ( real , 4 , 4 ) ) ) : matrix ( real , 6 , 6 ) { }