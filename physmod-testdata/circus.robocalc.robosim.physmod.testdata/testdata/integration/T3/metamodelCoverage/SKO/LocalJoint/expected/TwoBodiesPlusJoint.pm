package TwoBodiesPlusJoint

import physmod::math::*

pmodel TwoBodiesPlusJoint {
	local link base_link {
		pose { x=0.0 y=0.0 z=0.0 roll=0.0 pitch=0.0 yaw=0.0}
		def {
			InOut geom_21 : Geom = Geom (| geomType = "cylinder" , geomVal = [| 0.05 , 0.24 |] |)
			InOut L2_geom : Geom = Geom (| geomType = "cylinder" , geomVal = [| 0.05 , 0.24 |] |)
			InOut M_2 : matrix ( real , 6 , 6 ) = [| 0 , 0.0 , 0.0 , 0.0 , 0 , 0.0 ; 0.0 , 0 , 0.0 , 0 , 0.0 , 0.0 ; 0.0 , 0.0 , 0 , 0.0 , 0.0 , 0.0 ; 0.0 , 0 , 0.0 , 0 , 0.0 , 0.0 ; 0 , 0.0 , 0.0 , 0.0 , 0 , 0.0 ; 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0 |]
			InOut a_2 : vector ( real , 6 )
			InOut b_2 : vector ( real , 6 )
			InOut V_2 : vector ( real , 6 )
			InOut alpha_2 : vector ( real , 6 )
			InOut f_2 : vector ( real , 6 )
			InOut B_2 : matrix ( real , 4 , 4 )
			InOut X_T_2 : matrix ( real , 6 , 6 )
			InOut T_geom_2 : matrix ( real , 4 , 4 )
			InOut T_offset_2 : matrix ( real , 4 , 4 )
			InOut m_2 : real = 0.0
			InOut I_C_2 : matrix ( real , 3 , 3 ) = [| 0 , 0.0 , 0.0 ; 0.0 , 0 , 0.0 ; 0.0 , 0.0 , 0 |]
			InOut c_2 : vector ( real , 3 ) = [| 0.0 , 0.0 , 0.0 |]
			InOut cz_2 : real = 0.0
			InOut _f_1 : vector ( real , 6 )
			InOut phi_2_1 : matrix ( real , 6 , 6 )
			InOut tau_2 : vector ( real , 1 )
			local number : real = 2
			local poseVec : vector ( real , 6 ) = [| 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 |]
			equation submatrix ( M_2 ) ( 0 , 0 , 3 , 3 ) == I_C_2 + m_2 * transpose ( skew ( c_2 ) ) * skew ( c_2 )
			equation submatrix ( M_2 ) ( 0 , 3 , 3 , 3 ) == m_2 * transpose ( skew ( c_2 ) )
			equation submatrix ( M_2 ) ( 3 , 0 , 3 , 3 ) == - m_2 * skew ( c_2 )
			equation submatrix ( M_2 ) ( 3 , 3 , 3 , 3 ) == m_2 * identity ( 3 )
			equation f_2 == phi_2_1 * _f_1 + M_2 * alpha_2 + b_2
			equation V_2 == 0
			equation alpha_2 == a_2
			Constraint ( B_2 ) [ t == 0 ] == [| 1.000000 , 0.000000 , 0.000000 , 0.000000 ; 0.000000 , 1.000000 , 0.000000 , 0.000000 ; - 0.000000 , 0.000000 , 1.000000 , - 0.11999999731779099 ; 0 , 0 , 0 , 1 |]
			Constraint ( T_geom_2 ) [ t == 0 ] == [| 1.000000 , 0.000000 , 0.000000 , 0.000000 ; 0.000000 , 1.000000 , 0.000000 , 0.000000 ; - 0.000000 , 0.000000 , 1.000000 , 0 ; 0 , 0 , 0 , 1 |]
			Constraint ( T_offset_2 ) [ t == 0 ] == [| 1.0 , 0.0 , 0.0 , 0.0 ; 0.0 , 1.0 , 0.0 , 0.0 ; 0.0 , 0.0 , 1.0 , 0 ; 0 , 0 , 0 , 1 |]
			Constraint ( X_T_2 ) [ t == 0 ] == [| 1 , 0 , 0 , 0 , 0 , 0 ; 0 , 1 , 0 , 0 , 0 , 0 ; 0 , 0 , 1 , 0 , 0 , 0 ; 0 , 0 , 0 , 1 , 0 , 0 ; 0 , 0 , 0 , 0 , 1 , 0 ; 0 , 0 , 0 , 0 , 0 , 1 |]
			inertial information{
				mass 10.0
				inertia matrix {ixx 0.4 ixy 0.0 ixz 0.0 iyy 0.4 iyz 0.0 izz 0.2}
			}
		}
		local body base_body {
			def {
				cylinder (radius=0.05, length=0.24)
			local number : real = 0
			}
		}
		local joint my_joint {
			pose {x=0.0 y=0.0 z=0.12 roll=0.0 pitch=0.0 yaw=0.0}
			def {
				const H : vector ( real , 6 ) = [| 1 , 0 , 0 , 0 , 0 , 0 |]
				InOut theta : real
				InOut XJ : matrix ( real , 6 , 6 )
				equation XJ == [|
					1 , 0 , 0 , 0 , 0 , 0 ;
					0 , cos ( theta ) , - sin ( theta ) , 0 , 0 , 0 ;
					0 , sin ( theta ) , cos ( theta ) , 0 , 0 , 0 ;
					0 , 0 , 0 , 1 , 0 , 0 ;
					0 , 0 , 0 , 0 , cos ( theta ) , - sin ( theta ) ;
					0 , 0 , 0 , 0 , sin ( theta ) , cos ( theta )
				|]
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
				local poseVec : vector ( real , 6 ) = [| 0.0 , 0.0 , 0.12 , 0.0 , 0.0 , 0.0 |]
				equation _B_2 == B_2
				equation _V_2 == V_2
				equation _alpha_2 == alpha_2
				equation _f_1 == f_1
			}
			flexibly connected to second_link
		relation B_2 == my_joint . B_2 /\ V_2 == my_joint . V_2 /\ alpha_2 == my_joint . alpha_2 /\ theta [ 0 ] == my_joint . theta /\ H_1 == my_joint . H /\ X_J_1 == my_joint . XJ
		}
		relation B_2 == base_link . B_2 /\ V [ 1 ] == base_link . V_2 /\ a [ 1 ] == base_link . a_2 /\ b [ 1 ] == base_link . b_2 /\ alpha [ 1 ] == base_link . alpha_2 /\ submatrix ( M ) ( 6 , 6 , 6 , 6 ) == base_link . M_2 /\ tau [ 1 ] == base_link . tau_2 /\ L2_geom == geom_21
	}
	local link second_link {
		pose { x=0.0 y=0.0 z=0.12 roll=0.0 pitch=0.0 yaw=0.0}
		def {
			input test_1 : vector ( real , 1 )
			InOut geom_11 : Geom = Geom (| geomType = "cylinder" , geomVal = [| 0.03 , 0.24 |] |)
			InOut L1_geom : Geom = Geom (| geomType = "cylinder" , geomVal = [| 0.03 , 0.24 |] |)
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
			local poseVec : vector ( real , 6 ) = [| 0.0 , 0.0 , 0.12 , 0.0 , 0.0 , 0.0 |]
			equation submatrix ( M_1 ) ( 0 , 0 , 3 , 3 ) == I_C_1 + m_1 * transpose ( skew ( c_1 ) ) * skew ( c_1 )
			equation submatrix ( M_1 ) ( 0 , 3 , 3 , 3 ) == m_1 * transpose ( skew ( c_1 ) )
			equation submatrix ( M_1 ) ( 3 , 0 , 3 , 3 ) == - m_1 * skew ( c_1 )
			equation submatrix ( M_1 ) ( 3 , 3 , 3 , 3 ) == m_1 * identity ( 3 )
			equation V_1 == adj ( phi_2_1 ) * _V_2 + adj ( H_1 ) + derivative ( theta_1 )
			equation alpha_1 == adj ( phi_2_1 ) * _alpha_2 + adj ( H_1 ) * derivative ( theta_1 ) + a_1
			equation tau_1 == H_1 * f_1
			equation B_1 == _B_2 * T_2_1
			equation f_1 == M_1 * alpha_1 + b_1
			Constraint ( B_1 ) [ t == 0 ] == [| 1.000000 , 0.000000 , 0.000000 , 0.000000 ; 0.000000 , 1.000000 , 0.000000 , 0.000000 ; - 0.000000 , 0.000000 , 1.000000 , 0 ; 0 , 0 , 0 , 1 |]
			Constraint ( T_geom_1 ) [ t == 0 ] == [| 1.000000 , 0.000000 , 0.000000 , 0.000000 ; 0.000000 , 1.000000 , 0.000000 , 0.000000 ; - 0.000000 , 0.000000 , 1.000000 , 0.11999999731779099 ; 0 , 0 , 0 , 1 |]
			Constraint ( T_offset_1 ) [ t == 0 ] == [| 1.0 , 0.0 , 0.0 , 0.0 ; 0.0 , 1.0 , 0.0 , 0.0 ; 0.0 , 0.0 , 1.0 , 0.11999999731779099 ; 0 , 0 , 0 , 1 |]
			Constraint ( X_T_1 ) [ t == 0 ] == [| 1 , 0 , 0 , 0 , 0 , 0 ; 0 , 1 , 0 , 0 , 0 , 0 ; 0 , 0 , 1 , 0 , 0 , 0 ; 0 , - 0.23999999463558197 , - 0.000000 , 1 , 0 , 0 ; 0.23999999463558197 , 0 , 0.000000 , 0 , 1 , 0 ; 0.000000 , - 0.000000 , 0 , 0 , 0 , 1 |]
			inertial information{
				mass 10.0
				inertia matrix {ixx 0.0 ixy 0.0002835 ixz 0.0 iyy 0.0002835 iyz 0.0 izz 0.000324}
			}
		}
		local body second_body {
			def {
				cylinder (radius=0.03, length=0.24)
			local number : real = 0
			}
		}
	relation B_1 == second_link . B_1 /\ V [ 0 ] == second_link . V_1 /\ a [ 0 ] == second_link . a_1 /\ b [ 0 ] == second_link . b_1 /\ alpha [ 0 ] == second_link . alpha_1 /\ submatrix ( M ) ( 0 , 0 , 6 , 6 ) == second_link . M_1 /\ tau [ 0 ] == second_link . tau_1 /\ L1_geom == geom_11 /\ submatrix ( H ) ( 0 , 0 , 1 , 6 ) == second_link . H_1
		relation_flexi B_1 == second_link . B_1 /\ f_1 == second_link . f_1 /\ theta_1 == second_link . theta_1 /\ T_2_1 == second_link . T_2_1 /\ phi_2_1 == second_link . phi_2_1 /\ _V_2 == second_link . _V_2 /\ H == second_link . H_1 /\ X_J_1 == second_link . X_J_1
	}
	const n : int = 2
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
	InOut X_J_1 : matrix ( real , 6 , 6 )
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