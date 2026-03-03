package BaseModule

pmodel Treel {
	local link Wheel {
		pose { x=0.0 y=-0.3 z=0.0 roll=1.57 pitch=0.0 yaw=0.0 }
		def {
			InOut B_2 : matrix ( real , 4 , 4 )
			InOut M_2 : matrix ( real , 6 , 6 )
			InOut b_2 : vector ( real , 6 )
			local number : real = 2
			local poseVec : vector ( real , 6 ) = [| 0.0 , - 0.3 , 0.0 , 1.57 , 0.0 , 0.0 |]
			inertial information {
				mass 0.0
				inertia matrix { ixx 0.0 ixy 0.0 ixz 0.0 iyy 0.0 iyz 0.0 izz 0.0 }
			}
		}
		local body wheel {
			def {
				cylinder (radius=0.25, length=0.3)
			local number : real = 0
			}
		}
	relation B_2 == Wheel . B_2 /\ M_2 == Wheel . M_2 /\ b_2 == Wheel . b_2
	}
	local link Track {
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
		local body FrontWheel {
			pose { x=-0.6 y=0.0 z=0.0 roll=1.57 pitch=0.0 yaw=0.0 }
			def {
				cylinder (radius=0.25, length=0.3)
			}
		}
		local body BackWheel {
			pose { x=0.6 y=0.0 z=0.0 roll=1.57 pitch=0.0 yaw=0.0 }
			def {
				cylinder (radius=0.25, length=0.3)
			}
		}
		local body Top {
			pose { x=0.0 y=0.0 z=0.25 roll=0.0 pitch=0.0 yaw=0.0 }
			def {
				box (length=1.2, width=0.3, height=0.0)
			}
		}
		local body Bottom {
			pose { x=0.0 y=0.0 z=-0.25 roll=0.0 pitch=0.0 yaw=0.0 }
			def {
				box (length=1.2, width=0.3, height=0.0)
			}
		}
	relation B_1 == Track . B_1 /\ M_1 == Track . M_1 /\ b_1 == Track . b_1
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
	Constraint ( B_2 ) [ t == 0 ] == [| 1 , 0 , 0 , 0 ; 0 , 1 , 0 , - 0.30000001192092896 ; 0 , 0 , 1 , 0 ; 0 , 0 , 0 , 1 |]
	Constraint ( T_offset_2 ) [ t == 0 ] == [| 1 , 0 , 0 , 0 ; 0 , 1 , 0 , 0 ; 0 , 0 , 1 , 0 ; 0 , 0 , 0 , 1 |]
	Constraint ( T_geom_2 ) [ t == 0 ] == [| 1 , 0 , 0 , 0 ; 0 , 1 , 0 , - 0.30000001192092896 ; 0 , 0 , 1 , 0 ; 0 , 0 , 0 , 1 |]
	Constraint ( X_T_2 ) [ t == 0 ] == [| 1 , 0 , 0 , 0 , 0 , 0 ; 0 , 1 , 0 , 0 , 0 , 0 ; 0 , 0 , 1 , 0 , 0 , 0 ; 0 , 0 , 0 , 1 , 0 , 0 ; 0 , 0 , 0 , 0 , 1 , 0 ; 0 , 0 , 0 , 0 , 0 , 1 |]
	Constraint ( B_1 ) [ t == 0 ] == [| 1 , 0 , 0 , 0 ; 0 , 1 , 0 , 0 ; 0 , 0 , 1 , 0 ; 0 , 0 , 0 , 1 |]
	Constraint ( T_offset_1 ) [ t == 0 ] == [| 1 , 0 , 0 , 0 ; 0 , 1 , 0 , 0 ; 0 , 0 , 1 , 0 ; 0 , 0 , 0 , 1 |]
	Constraint ( T_geom_1 ) [ t == 0 ] == [| 1 , 0 , 0 , 0 ; 0 , 1 , 0 , 0 ; 0 , 0 , 1 , 0 ; 0 , 0 , 0 , 1 |]
	Constraint ( X_T_1 ) [ t == 0 ] == [| 1 , 0 , 0 , 0 , 0 , 0 ; 0 , 1 , 0 , 0 , 0 , 0 ; 0 , 0 , 1 , 0 , 0 , 0 ; 0 , 0 , 0 , 1 , 0 , 0 ; 0 , 0 , 0 , 0 , 1 , 0 ; 0 , 0 , 0 , 0 , 0 , 1 |]
	Constraint ( submatrix ( M ) ( 0 , 0 , 6 , 6 ) ) [ t == 0 ] == M_1
}

pmodel BaseModule {
	const PI: real = 3.1415
	part LTREEL = Treel {
		pose { x=0.0 y=0.3 z=0.25 roll=3.14 pitch=0.0 yaw=0.0 }
	}
	part RTREEL = Treel {
		pose { x=0.0 y=-0.3 z=0.25 roll=0.0 pitch=0.0 yaw=0.0 }
	}
	local link Core {
		pose { x=0.0 y=0.0 z=0.575 roll=0.0 pitch=0.0 yaw=0.0 }
		def {
			inertial information {
				mass 0.0
				inertia matrix { ixx 0.0 ixy 0.0 ixz 0.0 iyy 0.0 iyz 0.0 izz 0.0 }
			}
		}
		local body Spine {
			pose { x=0.0 y=0.0 z=-0.225 roll=0.0 pitch=0.0 yaw=1.57 }
			def {
				box (length=0.3, width=1.6, height=0.4)
			}
		}
		local body Frame {
			def {
				cylinder (radius=0.85, length=0.05)
			}
		}
		fixed to Track in LTREEL
		fixed to Track in RTREEL
	}
}
function sin(theta:real): real {}
function cos(theta:real): real {} function identity ( size : real ) : matrix ( real , 6 , 6 ) { } function zeroes ( size : real ) : matrix ( real , 6 , 6 ) { } function zeroMat ( r : real , c : real ) : matrix ( real , 0 , 0 ) { } function zeroVec ( n : real ) : vector ( real , 0 ) { } function Phi ( m : real , n : real , B_k : Seq( matrix ( real , 4 , 4 ) ) ) : matrix ( real , 6 , 6 ) { }