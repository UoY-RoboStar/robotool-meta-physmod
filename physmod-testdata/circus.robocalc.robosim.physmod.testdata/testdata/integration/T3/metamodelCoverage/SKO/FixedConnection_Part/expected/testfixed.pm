package testfixed

pmodel testfixed {
	local link TLB_linkB {
		def {
			InOut B_2 : matrix ( real , 4 , 4 )
			InOut M_2 : matrix ( real , 6 , 6 )
			InOut b_2 : vector ( real , 6 )
			local number : real = 2
			local poseVec : vector ( real , 6 ) = [| 0.0 , - 0.5 , 0.5 , 1.0472 , - 0.785398 , 1.0472 |]
			inertial information {
				mass 1.0
				inertia matrix { ixx 0.0 ixy 0.0 ixz 0.0 iyy 0.0 iyz 0.0 izz 0.0 }
			}
		}
		local body bodyB {
			def {
				box ( length = 1.0 , width = 1.0 , height = 1.0 )
				local number : real = 0
			}
		}
		pose {
			x = 0.0
			y = - 0.5
			z = 0.5
			roll = 1.0472
			pitch = - 0.785398
			yaw = 1.0472
		}
		relation B_2 == TLB_linkB . B_2 /\ M_2 == TLB_linkB . M_2 /\ b_2 == TLB_linkB . b_2
	}
	local link TLA_linkA {
		def {
			InOut B_1 : matrix ( real , 4 , 4 )
			InOut M_1 : matrix ( real , 6 , 6 )
			InOut b_1 : vector ( real , 6 )
			local number : real = 1
			local poseVec : vector ( real , 6 ) = [| 1.0 , 0.5 , 0.5 , 1.5708 , 3.14159 , - 1.0472 |]
			inertial information {
				mass 0.0
				inertia matrix { ixx 0.0 ixy 0.0 ixz 0.0 iyy 0.0 iyz 0.0 izz 0.0 }
			}
		}
		local body bodyA {
			def {
				box ( length = 1.0 , width = 1.0 , height = 1.0 )
			}
		}
		pose {
			x = 1.0
			y = 0.5
			z = 0.5
			roll = 1.5708
			pitch = 3.14159
			yaw = - 1.0472
		}
		relation B_1 == TLA_linkA . B_1 /\ M_1 == TLA_linkA . M_1 /\ b_1 == TLA_linkA . b_1
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
	Constraint ( B_2 ) [ t == 0 ] == [| 1 , 0 , 0 , 0 ; 0 , 1 , 0 , - 0.5 ; 0 , 0 , 1 , 0.5 ; 0 , 0 , 0 , 1 |]
	Constraint ( T_offset_2 ) [ t == 0 ] == [| 1 , 0 , 0 , 0 ; 0 , 1 , 0 , 0 ; 0 , 0 , 1 , 0 ; 0 , 0 , 0 , 1 |]
	Constraint ( T_geom_2 ) [ t == 0 ] == [| 1 , 0 , 0 , 0 ; 0 , 1 , 0 , - 0.5 ; 0 , 0 , 1 , 0.5 ; 0 , 0 , 0 , 1 |]
	Constraint ( X_T_2 ) [ t == 0 ] == [| 1 , 0 , 0 , 0 , 0 , 0 ; 0 , 1 , 0 , 0 , 0 , 0 ; 0 , 0 , 1 , 0 , 0 , 0 ; 0 , 0 , 0 , 1 , 0 , 0 ; 0 , 0 , 0 , 0 , 1 , 0 ; 0 , 0 , 0 , 0 , 0 , 1 |]
	Constraint ( B_1 ) [ t == 0 ] == [| 1 , 0 , 0 , 1 ; 0 , 1 , 0 , 0.5 ; 0 , 0 , 1 , 0.5 ; 0 , 0 , 0 , 1 |]
	Constraint ( T_offset_1 ) [ t == 0 ] == [| 1 , 0 , 0 , 0 ; 0 , 1 , 0 , 0 ; 0 , 0 , 1 , 0 ; 0 , 0 , 0 , 1 |]
	Constraint ( T_geom_1 ) [ t == 0 ] == [| 1 , 0 , 0 , 1 ; 0 , 1 , 0 , 0.5 ; 0 , 0 , 1 , 0.5 ; 0 , 0 , 0 , 1 |]
	Constraint ( X_T_1 ) [ t == 0 ] == [| 1 , 0 , 0 , 0 , 0 , 0 ; 0 , 1 , 0 , 0 , 0 , 0 ; 0 , 0 , 1 , 0 , 0 , 0 ; 0 , 0 , 0 , 1 , 0 , 0 ; 0 , 0 , 0 , 0 , 1 , 0 ; 0 , 0 , 0 , 0 , 0 , 1 |]
	Constraint ( submatrix ( M ) ( 0 , 0 , 6 , 6 ) ) [ t == 0 ] == M_1
}

pmodel testlinka {
	local link linkA {
		pose { x=1.0 y=0.5 z=0.5 roll=1.5708 pitch=3.14159 yaw=-1.0472 }
		def {
			inertial information {
				mass 0.0
				inertia matrix { ixx 0.0 ixy 0.0 ixz 0.0 iyy 0.0 iyz 0.0 izz 0.0 }
			}
		}
		local body bodyA {
			def {
				box (length=1.0, width=1.0, height=1.0)
			}
		}
	}
}

pmodel testlinkb {
	local link linkB {
		pose { x=0.0 y=-0.5 z=0.5 roll=1.0472 pitch=-0.785398 yaw=1.0472 }
		def {
			inertial information {
				mass 1.0
				inertia matrix { ixx 0.0 ixy 0.0 ixz 0.0 iyy 0.0 iyz 0.0 izz 0.0 }
			}
		}
		local body bodyB {
			def {
				box (length=1.0, width=1.0, height=1.0)
			}
		}
	}
}
function identity ( size : real ) : matrix ( real , 6 , 6 ) { } function zeroes ( size : real ) : matrix ( real , 6 , 6 ) { } function zeroMat ( r : real , c : real ) : matrix ( real , 0 , 0 ) { } function zeroVec ( n : real ) : vector ( real , 0 ) { } function Phi ( m : real , n : real , B_k : Seq( matrix ( real , 4 , 4 ) ) ) : matrix ( real , 6 , 6 ) { }