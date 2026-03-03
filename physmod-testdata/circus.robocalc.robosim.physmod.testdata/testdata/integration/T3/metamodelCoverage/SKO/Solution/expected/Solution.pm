package Solution

// Tests the Solution metamodel component

pmodel Solution {
	local link L1 {
		pose { x=0.0 y=0.0 z=0.0 roll=0.0 pitch=0.0 yaw=0.0 }
		def {
			InOut geom_11 : Geom = Geom (| geomType = "box" , geomVal = [| 0.1 , 0.1 , 0.1 |] |)
			InOut L1_geom : Geom = Geom (| geomType = "box" , geomVal = [| 0.1 , 0.1 , 0.1 |] |)
			InOut M_1 : matrix ( real , 6 , 6 ) = [| 0 , 0.0 , 0.0 , 0.0 , 0 , 0.0 ; 0.0 , 0 , 0.0 , 0 , 0.0 , 0.0 ; 0.0 , 0.0 , 0 , 0.0 , 0.0 , 0.0 ; 0.0 , 0 , 0.0 , 0 , 0.0 , 0.0 ; 0 , 0.0 , 0.0 , 0.0 , 0 , 0.0 ; 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0 |]
			InOut a_1 : vector ( real , 6 )
			InOut b_1 : vector ( real , 6 )
			InOut V_1 : vector ( real , 6 )
			InOut alpha_1 : vector ( real , 6 )
			InOut f_1 : vector ( real , 6 )
			InOut B_1 : matrix ( real , 4 , 4 )
			InOut X_T_1 : matrix ( real , 6 , 6 )
			InOut T_geom_1 : matrix ( real , 4 , 4 )
			InOut T_offset_1 : matrix ( real , 4 , 4 )
			InOut m_1 : real = 0.0
			InOut I_C_1 : matrix ( real , 3 , 3 ) = [| 0 , 0.0 , 0.0 ; 0.0 , 0 , 0.0 ; 0.0 , 0.0 , 0 |]
			InOut c_1 : vector ( real , 3 ) = [| 0.0 , 0.0 , 0.0 |]
			InOut cz_1 : real = 0.0
			InOut tau_1 : vector ( real , 1 )
			local number : real = 1
			local poseVec : vector ( real , 6 ) = [| 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 |]
			equation submatrix ( M_1 ) ( 0 , 0 , 3 , 3 ) == I_C_1 + m_1 * transpose ( skew ( c_1 ) ) * skew ( c_1 )
			equation submatrix ( M_1 ) ( 0 , 3 , 3 , 3 ) == m_1 * transpose ( skew ( c_1 ) )
			equation submatrix ( M_1 ) ( 3 , 0 , 3 , 3 ) == - m_1 * skew ( c_1 )
			equation submatrix ( M_1 ) ( 3 , 3 , 3 , 3 ) == m_1 * identity ( 3 )
			equation f_1 == phi_1_0 * _f_0 + M_1 * alpha_1 + b_1
			equation V_1 == 0
			equation alpha_1 == a_1
			Constraint ( B_1 ) [ t == 0 ] == [| 1.000000 , 0.000000 , 0.000000 , 0.000000 ; 0.000000 , 1.000000 , 0.000000 , 0.000000 ; - 0.000000 , 0.000000 , 1.000000 , - 0.05000000074505806 ; 0 , 0 , 0 , 1 |]
			Constraint ( T_geom_1 ) [ t == 0 ] == [| 1.000000 , 0.000000 , 0.000000 , 0.000000 ; 0.000000 , 1.000000 , 0.000000 , 0.000000 ; - 0.000000 , 0.000000 , 1.000000 , 0 ; 0 , 0 , 0 , 1 |]
			Constraint ( T_offset_1 ) [ t == 0 ] == [| 1.0 , 0.0 , 0.0 , 0.0 ; 0.0 , 1.0 , 0.0 , 0.0 ; 0.0 , 0.0 , 1.0 , 0 ; 0 , 0 , 0 , 1 |]
			Constraint ( X_T_1 ) [ t == 0 ] == [| 1 , 0 , 0 , 0 , 0 , 0 ; 0 , 1 , 0 , 0 , 0 , 0 ; 0 , 0 , 1 , 0 , 0 , 0 ; 0 , 0 , 0 , 1 , 0 , 0 ; 0 , 0 , 0 , 0 , 1 , 0 ; 0 , 0 , 0 , 0 , 0 , 1 |]
			inertial information {
				mass 0.0
				inertia matrix { ixx 0.0 ixy 0.0 ixz 0.0 iyy 0.0 iyz 0.0 izz 0.0 }
			}
		}
		local body B1 {
			def { box(length=0.1, width=0.1, height=0.1) local number : real = 0
			}
		}
	relation B_1 == L1 . B_1 /\ V [ 0 ] == L1 . V_1 /\ a [ 0 ] == L1 . a_1 /\ b [ 0 ] == L1 . b_1 /\ alpha [ 0 ] == L1 . alpha_1 /\ submatrix ( M ) ( 0 , 0 , 6 , 6 ) == L1 . M_1 /\ tau [ 0 ] == L1 . tau_1 /\ L1_geom == geom_11
	}

	solution {
		solutionExpr phi : real
		order 1
		group 0
		method Eval
		Input theta : real
		Input omega : real
	}
const n : int = 1
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
	InOut B_1 : matrix ( real , 4 , 4 )
	InOut X_T_1 : matrix ( real , 6 , 6 )
	InOut M_1 : matrix ( real , 6 , 6 )
	InOut T_geom_1 : matrix ( real , 4 , 4 )
	InOut T_offset_1 : matrix ( real , 4 , 4 )
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