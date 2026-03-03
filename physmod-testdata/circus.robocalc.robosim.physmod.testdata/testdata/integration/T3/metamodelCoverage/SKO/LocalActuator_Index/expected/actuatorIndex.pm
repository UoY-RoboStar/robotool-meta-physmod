package actuatorIndex

pmodel actuatorIndex {
	local link L1 {
		pose { x=0 y=0 z=0.05 roll=0 pitch=0 yaw=0 }
		def {
			InOut B_2 : matrix ( real , 4 , 4 )
			InOut M_2 : matrix ( real , 6 , 6 )
			InOut b_2 : vector ( real , 6 )
			local number : real = 2
			local poseVec : vector ( real , 6 ) = [| 0.0 , 0.0 , 0.05 , 0.0 , 0.0 , 0.0 |]
			inertial information {
				mass 0.0
				inertia matrix { ixx 0.0 ixy 0.0 ixz 0.0 iyy 0.0 iyz 0.0 izz 0.0 }
			}
		}
		local body B1 {
			def {
				box(length=0.1, width=0.1, height=0.1)
			local number : real = 0
			}
		}
		local actuator A {
			def {
				annotation Light {
				}
			}
		pose { x=i y=i+1 z=i+2 roll=i+3 pitch=i+4 yaw=i+4 }
			index i : [0,4)
		}
	relation B_2 == L1 . B_2 /\ M_2 == L1 . M_2 /\ b_2 == L1 . b_2
	}
	local link L2 {
		pose { x=0 y=0 z=0.1 roll=0 pitch=0 yaw=0 }
		def {
			InOut B_1 : matrix ( real , 4 , 4 )
			InOut M_1 : matrix ( real , 6 , 6 )
			InOut b_1 : vector ( real , 6 )
			local number : real = 1
			local poseVec : vector ( real , 6 ) = [| 0.0 , 0.0 , 0.1 , 0.0 , 0.0 , 0.0 |]
			inertial information {
				mass 0.0
				inertia matrix { ixx 0.0 ixy 0.0 ixz 0.0 iyy 0.0 iyz 0.0 izz 0.0 }
			}
		}
		local body B2 {
			def {
				box(length=0.1, width=0.1, height=0.1)
			}
		}
	relation B_1 == L2 . B_1 /\ M_1 == L2 . M_1 /\ b_1 == L2 . b_1
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
	Constraint ( B_2 ) [ t == 0 ] == [| 1 , 0 , 0 , 0 ; 0 , 1 , 0 , 0 ; 0 , 0 , 1 , 0.05000000074505806 ; 0 , 0 , 0 , 1 |]
	Constraint ( T_offset_2 ) [ t == 0 ] == [| 1 , 0 , 0 , 0 ; 0 , 1 , 0 , 0 ; 0 , 0 , 1 , 0 ; 0 , 0 , 0 , 1 |]
	Constraint ( T_geom_2 ) [ t == 0 ] == [| 1 , 0 , 0 , 0 ; 0 , 1 , 0 , 0 ; 0 , 0 , 1 , 0.05000000074505806 ; 0 , 0 , 0 , 1 |]
	Constraint ( X_T_2 ) [ t == 0 ] == [| 1 , 0 , 0 , 0 , 0 , 0 ; 0 , 1 , 0 , 0 , 0 , 0 ; 0 , 0 , 1 , 0 , 0 , 0 ; 0 , 0 , 0 , 1 , 0 , 0 ; 0 , 0 , 0 , 0 , 1 , 0 ; 0 , 0 , 0 , 0 , 0 , 1 |]
	Constraint ( B_1 ) [ t == 0 ] == [| 1 , 0 , 0 , 0 ; 0 , 1 , 0 , 0 ; 0 , 0 , 1 , 0.10000000149011612 ; 0 , 0 , 0 , 1 |]
	Constraint ( T_offset_1 ) [ t == 0 ] == [| 1 , 0 , 0 , 0 ; 0 , 1 , 0 , 0 ; 0 , 0 , 1 , 0 ; 0 , 0 , 0 , 1 |]
	Constraint ( T_geom_1 ) [ t == 0 ] == [| 1 , 0 , 0 , 0 ; 0 , 1 , 0 , 0 ; 0 , 0 , 1 , 0.10000000149011612 ; 0 , 0 , 0 , 1 |]
	Constraint ( X_T_1 ) [ t == 0 ] == [| 1 , 0 , 0 , 0 , 0 , 0 ; 0 , 1 , 0 , 0 , 0 , 0 ; 0 , 0 , 1 , 0 , 0 , 0 ; 0 , 0 , 0 , 1 , 0 , 0 ; 0 , 0 , 0 , 0 , 1 , 0 ; 0 , 0 , 0 , 0 , 0 , 1 |]
	Constraint ( submatrix ( M ) ( 0 , 0 , 6 , 6 ) ) [ t == 0 ] == M_1
}
function identity ( size : real ) : matrix ( real , 6 , 6 ) { } function zeroes ( size : real ) : matrix ( real , 6 , 6 ) { } function zeroMat ( r : real , c : real ) : matrix ( real , 0 , 0 ) { } function zeroVec ( n : real ) : vector ( real , 0 ) { } function Phi ( m : real , n : real , B_k : Seq( matrix ( real , 4 , 4 ) ) ) : matrix ( real , 6 , 6 ) { }