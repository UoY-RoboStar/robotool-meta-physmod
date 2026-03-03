import  physmod::math::* 
	pmodel SimpleArmSerial {
	solution{ 
        solutionExpr 
        tau : vector ( real , 2 ) order 1 group 0 method PlatformMapping Input tau : vector ( real , 2 ) Input n : int Constraint ( n ) [ t == 0 ] == 3 Constraint ( tau ) [ t == 0 ] == zeroVec ( 2 ) }

	solution{
        solutionExpr 
        phi : matrix ( real , 18 , 18 ) order 2 group 0 method Eval Input B_1 : matrix ( real , 4 , 4 ) Input B_2 : matrix ( real , 4 , 4 ) Input B_3 : matrix ( real , 4 , 4 ) Input B_k : Seq( matrix ( real , 4 , 4 ) ) Input n : int Constraint ( n ) [ t == 0 ] == 3 Constraint ( n ) [ t == 0 ] == 3 Constraint ( B_1 ) [ t == 0 ] == [| 1.0 , 0.0 , 0.0 , 0.0 ; 0.0 , 1.0 , 0.0 , 0.0 ; - 0.0 , 0.0 , 1.0 , 4.75 ; 0 , 0 , 0 , 1 |] Constraint ( B_2 ) [ t == 0 ] == [| 1.0 , 0.0 , 0.0 , 0.0 ; 0.0 , 1.0 , 0.0 , 0.0 ; - 0.0 , 0.0 , 1.0 , 2.5 ; 0 , 0 , 0 , 1 |] Constraint ( B_3 ) [ t == 0 ] == [| 1.0 , 0.0 , 0.0 , 0.0 ; 0.0 , 1.0 , 0.0 , 0.0 ; - 0.0 , 0.0 , 1.0 , 0.0 ; 0 , 0 , 0 , 1 |] Constraint ( B_k ) [ t == 0 ] == < B_1 , B_2 , B_3 > Constraint ( phi ) [ t == 0 ] == zeroMat ( 18 , 18 ) }

	solution{
        solutionExpr 
        C : vector ( real , 2 ) order 3 group 0 method NewtonEulerInverseDynamics Input M_1 : matrix ( real , 6 , 6 ) Input M_2 : matrix ( real , 6 , 6 ) Input M_3 : matrix ( real , 6 , 6 ) Input n : int Input theta : vector ( real , 2 ) Input phi : matrix ( real , 18 , 18 ) Input H : matrix ( real , 2 , 18 ) Input d_theta : vector ( real , 2 ) Input dd_theta : vector ( real , 2 ) Input alpha : vector ( real , 18 ) Input V : vector ( real , 18 ) Input a : vector ( real , 18 ) Input b : vector ( real , 18 ) Input f : vector ( real , 18 ) Input M : matrix ( real , 18 , 18 ) Input N : real Constraint ( n ) [ t == 0 ] == 3 Constraint ( M_1 ) [ t == 0 ] == zeroMat ( 6 , 6 ) Constraint ( submatrix ( M ) ( 0 , 0 , 6 , 6 ) ) [ t == 0 ] == [| 0.052050002 , 0.0 , 0.0 , 0.0 , - 0.125 , 0.0 ; 0.0 , 0.052050002 , 0.0 , 0.125 , 0.0 , 0.0 ; 0.0 , 0.0 , 0.0208 , 0.0 , 0.0 , 0.0 ; 0.0 , 0.125 , 0.0 , 0.5 , 0.0 , 0.0 ; - 0.125 , 0.0 , 0.0 , 0.0 , 0.5 , 0.0 ; 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.5 |] Constraint ( submatrix ( H ) ( 0 , 0 , 1 , 6 ) ) [ t == 0 ] == [| 0 , 0 , 1 , 0 , 0 , 0 |] Constraint ( M_2 ) [ t == 0 ] == zeroMat ( 6 , 6 ) Constraint ( submatrix ( M ) ( 6 , 6 , 6 , 6 ) ) [ t == 0 ] == [| 5.349 , 0.0 , 0.0 , 0.0 , - 2.0 , 0.0 ; 0.0 , 5.349 , 0.0 , 2.0 , 0.0 , 0.0 ; 0.0 , 0.0 , 0.0313 , 0.0 , 0.0 , 0.0 ; 0.0 , 2.0 , 0.0 , 1.0 , 0.0 , 0.0 ; - 2.0 , 0.0 , 0.0 , 0.0 , 1.0 , 0.0 ; 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 1.0 |] Constraint ( submatrix ( H ) ( 1 , 6 , 1 , 6 ) ) [ t == 0 ] == [| 1 , 0 , 0 , 0 , 0 , 0 |] Constraint ( M_3 ) [ t == 0 ] == zeroMat ( 6 , 6 ) Constraint ( submatrix ( M ) ( 12 , 12 , 6 , 6 ) ) [ t == 0 ] == [| 16.667 , 0.0 , 0.0 , 0.0 , - 25.0 , 0.0 ; 0.0 , 22.917 , 0.0 , 25.0 , 0.0 , 0.0 ; 0.0 , 0.0 , 10.417 , 0.0 , 0.0 , 0.0 ; 0.0 , 25.0 , 0.0 , 100.0 , 0.0 , 0.0 ; - 25.0 , 0.0 , 0.0 , 0.0 , 100.0 , 0.0 ; 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 100.0 |] Constraint ( C ) [ t == 0 ] == zeroVec ( 2 ) Constraint ( N ) [ t == 0 ] == 2 Constraint ( phi ) [ t == 0 ] == zeroMat ( 18 , 18 ) Constraint ( H ) [ t == 0 ] == [| 0 , 0 , 1 , 0 , 0 , 0 |] Constraint ( theta ) [ t == 0 ] == zeroVec ( 2 ) Constraint ( d_theta ) [ t == 0 ] == zeroVec ( 2 ) Constraint ( dd_theta ) [ t == 0 ] == zeroVec ( 2 ) Constraint ( alpha ) [ t == 0 ] ==  zeroVec ( 18 ) Constraint ( V ) [ t == 0 ] == zeroVec ( 18 ) Constraint ( a ) [ t == 0 ] == zeroVec ( 18 ) Constraint ( b ) [ t == 0 ] == zeroVec ( 18 ) Constraint ( f ) [ t == 0 ] == zeroVec ( 18 ) }

	solution{
        solutionExpr 
        M_mass : matrix ( real , 2 , 2 ) order 4 group 0 method CompositeBodyAlgorithm Input M_1 : matrix ( real , 6 , 6 ) Input M_2 : matrix ( real , 6 , 6 ) Input M_3 : matrix ( real , 6 , 6 ) Input H : matrix ( real , 2 , 18 ) Input phi : matrix ( real , 18 , 18 ) Input n : int Input M : matrix ( real , 18 , 18 ) Constraint ( n ) [ t == 0 ] == 3 Constraint ( M_1 ) [ t == 0 ] == zeroMat ( 6 , 6 ) Constraint ( submatrix ( M ) ( 0 , 0 , 6 , 6 ) ) [ t == 0 ] == [| 0.052050002 , 0.0 , 0.0 , 0.0 , - 0.125 , 0.0 ; 0.0 , 0.052050002 , 0.0 , 0.125 , 0.0 , 0.0 ; 0.0 , 0.0 , 0.0208 , 0.0 , 0.0 , 0.0 ; 0.0 , 0.125 , 0.0 , 0.5 , 0.0 , 0.0 ; - 0.125 , 0.0 , 0.0 , 0.0 , 0.5 , 0.0 ; 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.5 |] Constraint ( submatrix ( H ) ( 0 , 0 , 1 , 6 ) ) [ t == 0 ] == [| 0 , 0 , 1 , 0 , 0 , 0 |] Constraint ( M_2 ) [ t == 0 ] == zeroMat ( 6 , 6 ) Constraint ( submatrix ( M ) ( 6 , 6 , 6 , 6 ) ) [ t == 0 ] == [| 5.349 , 0.0 , 0.0 , 0.0 , - 2.0 , 0.0 ; 0.0 , 5.349 , 0.0 , 2.0 , 0.0 , 0.0 ; 0.0 , 0.0 , 0.0313 , 0.0 , 0.0 , 0.0 ; 0.0 , 2.0 , 0.0 , 1.0 , 0.0 , 0.0 ; - 2.0 , 0.0 , 0.0 , 0.0 , 1.0 , 0.0 ; 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 1.0 |] Constraint ( submatrix ( H ) ( 1 , 6 , 1 , 6 ) ) [ t == 0 ] == [| 1 , 0 , 0 , 0 , 0 , 0 |] Constraint ( M_3 ) [ t == 0 ] == zeroMat ( 6 , 6 ) Constraint ( submatrix ( M ) ( 12 , 12 , 6 , 6 ) ) [ t == 0 ] == [| 16.667 , 0.0 , 0.0 , 0.0 , - 25.0 , 0.0 ; 0.0 , 22.917 , 0.0 , 25.0 , 0.0 , 0.0 ; 0.0 , 0.0 , 10.417 , 0.0 , 0.0 , 0.0 ; 0.0 , 25.0 , 0.0 , 100.0 , 0.0 , 0.0 ; - 25.0 , 0.0 , 0.0 , 0.0 , 100.0 , 0.0 ; 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 100.0 |] Constraint ( M_mass ) [ t == 0 ] == zeroMat ( 2 , 2 ) Constraint ( phi ) [ t == 0 ] == zeroMat ( 18 , 18 ) Constraint ( H ) [ t == 0 ] == [| 0 , 0 , 1 , 0 , 0 , 0 |] }
	local link BaseLink {
		def {
		InOut geom_31 : Geom = Geom (| geomType = "box" , geomVal = [| 1.0 , 1.0 , 0.5 |] |)
			InOut M_3 : matrix ( real , 6 , 6 ) = [| 16.667 , 0.0 , 0.0 , 0.0 , - 25.0 , 0.0 ; 0.0 , 22.917 , 0.0 , 25.0 , 0.0 , 0.0 ; 0.0 , 0.0 , 10.417 , 0.0 , 0.0 , 0.0 ; 0.0 , 25.0 , 0.0 , 100.0 , 0.0 , 0.0 ; - 25.0 , 0.0 , 0.0 , 0.0 , 100.0 , 0.0 ; 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 100.0 |]
			InOut a_3 : vector ( real , 6 )
			InOut b_3 : vector ( real , 6 )
			InOut V_3 : vector ( real , 6 )
			InOut alpha_3 : vector ( real , 6 )
			InOut f_3 : vector ( real , 6 )
			InOut B_3 : matrix ( real , 4 , 4 )
			InOut X_T_3 : matrix ( real , 6 , 6 )
			InOut T_geom_3 : matrix ( real , 4 , 4 )
			InOut T_offset_3 : matrix ( real , 4 , 4 )
			InOut m_3 : real = 100.0
			InOut I_C_3 : matrix ( real , 3 , 3 ) = [| 10.417 , 0.0 , 0.0 ; 0.0 , 16.667 , 0.0 ; 0.0 , 0.0 , 10.417 |]
			InOut c_3 : vector ( real , 3 ) = [| 0.0 , 0.0 , 0.0 |]
			InOut cz_3 : real = 0.0
			InOut _f_2 : vector ( real , 6 )
			InOut phi_3_2 : matrix ( real , 6 , 6 )
			InOut tau_3 : vector ( real , 1 )
			local number : real = 3
			local poseVec : vector ( real , 6 ) = [| 0.0 , 0.0 , 0.25 , 0.0 , 0.0 , 0.0 |]
			equation submatrix ( M_3 ) ( 0 , 0 , 3 , 3 ) == I_C_3 + m_3 * transpose ( skew ( c_3 ) ) * skew ( c_3 )
			equation submatrix ( M_3 ) ( 0 , 3 , 3 , 3 ) == m_3 * transpose ( skew ( c_3 ) )
			equation submatrix ( M_3 ) ( 3 , 0 , 3 , 3 ) == - m_3 * skew ( c_3 )
			equation submatrix ( M_3 ) ( 3 , 3 , 3 , 3 ) == m_3 * identity ( 3 )
			equation f_3 == phi_3_2 * _f_2 + M_3 * alpha_3 + b_3
			equation V_3 == 0
			equation alpha_3 == a_3
			Constraint ( B_3 ) [ t == 0 ] == [| 1.000000 , 0.000000 , 0.000000 , 0.000000 ; 0.000000 , 1.000000 , 0.000000 , 0.000000 ; - 0.000000 , 0.000000 , 1.000000 , 0.000000 ; 0 , 0 , 0 , 1 |]
			Constraint ( T_geom_3 ) [ t == 0 ] == [| 1.000000 , 0.000000 , 0.000000 , 0.000000 ; 0.000000 , 1.000000 , 0.000000 , 0.000000 ; - 0.000000 , 0.000000 , 1.000000 , 0.250000 ; 0 , 0 , 0 , 1 |]
			Constraint ( T_offset_3 ) [ t == 0 ] == [| 1.0 , 0.0 , 0.0 , 0.0 ; 0.0 , 1.0 , 0.0 , 0.0 ; 0.0 , 0.0 , 1.0 , 0.250000 ; 0 , 0 , 0 , 1 |]
			Constraint ( X_T_3 ) [ t == 0 ] == [| 1 , 0 , 0 , 0 , 0 , 0 ; 0 , 1 , 0 , 0 , 0 , 0 ; 0 , 0 , 1 , 0 , 0 , 0 ; 0 , 0 , 0 , 1 , 0 , 0 ; 0 , 0 , 0 , 0 , 1 , 0 ; 0 , 0 , 0 , 0 , 0 , 1 |]
		}
		local body BaseLink {
			def {
				inertial information {
					mass 
					
					
				100.0
					inertia matrix { ixx 10.417 ixy 0.0 ixz 0.0 iyy 16.667 iyz 0.0 izz 10.417 }
					pose {
						x = 0.0
						y = 0.0
						z = 0.0
						roll = 0.0
						pitch = 0.0
						yaw = 0.0
					}
				}
				box ( length = 1.0 , width = 1.0 , height = 0.5 )
			local number : real = 0
			}
			pose {
				x = 
				
				0.0
				y = 0.0
				z = 0.0
				roll = 0.0
				pitch = 0.0
				yaw = 0.0
			}
		}
		local sensor BaseSensor {
			def {
				input SignalIn : real
				output MeasurementOut : real
				equation SignalIn == MeasurementOut
			}
			pose {
				x = 0.0
				y = - 0.5
				z = - 0.25
				roll = 0.0
				pitch = 0.0
				yaw = 0.0
			}
		}
		local joint ElbowJoint {
			def {
				const H : vector ( real , 6 ) = [| 1 , 0 , 0 , 0 , 0 , 0 |]
				InOut theta : real
				InOut X_J : matrix ( real , 6 , 6 )
				equation X_J == [| 1 , 0 , 0 , 0 , 0 , 0 ; 0 , cos ( theta ) , - sin ( theta ) , 0 , 0 , 0 ; 0 , sin ( theta ) , cos ( theta ) , 0 , 0 , 0 ; 0 , 0 , 0 , 1 , 0 , 0 ; 0 , 0 , 0 , 0 , cos ( theta ) , - sin ( theta ) ; 0 , 0 , 0 , 0 , sin ( theta ) , cos ( theta ) |]
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
                
				InOut phi_3_2 : matrix ( real , 6 , 6 )
				local number : real = 2
				local poseVec : vector ( real , 6 ) = [| 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 |]
				equation _B_3 == B_3
				equation _V_3 == V_3
				equation _alpha_3 == alpha_3
				equation _f_2 == f_2
			}
			flexibly connected to IntermediateLink
			pose {
				x = 
				
				0.0
				y = 0.0
				z = 0.0
				roll = 0.0
				pitch = 0.0
				yaw = 0.0
			}
			local actuator ElbowActuator {
				def {
					input TorqueIn : real
					output TorqueOut : real
					equation TorqueIn == TorqueOut
				}
				pose {
					x = 0.0
					y = 0.0
					z = 0.0
					roll = 0.0
					pitch = 0.0
					yaw = 0.0
				}
			}
			local sensor ElbowSensor {
				def {
					input SignalIn : real
					output MeasurementOut : real
					equation SignalIn == MeasurementOut
				}
				pose {
					x = 0.0
					y = 0.0
					z = 0.0
					roll = 0.0
					pitch = 0.0
					yaw = 0.0
				}
			}
			relation B_3 == ElbowJoint . B_3 /\ V_3 == ElbowJoint . V_3 /\ alpha_3 == ElbowJoint . alpha_3 /\ theta [ 1 ] == ElbowJoint . theta /\ H_2 == ElbowJoint . H /\ X_J_2 == ElbowJoint . X_J
		}
		pose {
				x = 
				
				0.0
				y = 0.0
				z = 0.25
				roll = 0.0
				pitch = 0.0
				yaw = 0.0
			}
	relation B_3 == BaseLink . B_3 /\ T_geom_3 == BaseLink . T_geom_3 /\ T_offset_3 == BaseLink . T_offset_3 /\ V [ 2 ] == BaseLink . V_3 /\ a [ 2 ] == BaseLink . a_3 /\ b [ 2 ] == BaseLink . b_3 /\ alpha [ 2 ] == BaseLink . alpha_3 /\ submatrix ( M ) ( 12 , 12 , 6 , 6 ) == BaseLink . M_3 /\ tau [ 2 ] == BaseLink . tau_3
	}
	local link IntermediateLink {
		def {
		input test_2 : vector ( real , 1 )
			InOut geom_21 : Geom = Geom (| geomType = "cylinder" , geomVal = [| 0.25 , 4.0 |] |)
			InOut M_2 : matrix ( real , 6 , 6 ) = [| 5.349 , 0.0 , 0.0 , 0.0 , - 2.0 , 0.0 ; 0.0 , 5.349 , 0.0 , 2.0 , 0.0 , 0.0 ; 0.0 , 0.0 , 0.0313 , 0.0 , 0.0 , 0.0 ; 0.0 , 2.0 , 0.0 , 1.0 , 0.0 , 0.0 ; - 2.0 , 0.0 , 0.0 , 0.0 , 1.0 , 0.0 ; 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 1.0 |]
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
			InOut I_C_2 : matrix ( real , 3 , 3 ) = [| 1.349 , 0.0 , 0.0 ; 0.0 , 1.349 , 0.0 ; 0.0 , 0.0 , 0.0313 |]
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
			local poseVec : vector ( real , 6 ) = [| 0.0 , 0.0 , 2.5 , 0.0 , 0.0 , 0.0 |]
			equation submatrix ( M_2 ) ( 0 , 0 , 3 , 3 ) == I_C_2 + m_2 * transpose ( skew ( c_2 ) ) * skew ( c_2 )
			equation submatrix ( M_2 ) ( 0 , 3 , 3 , 3 ) == m_2 * transpose ( skew ( c_2 ) )
			equation submatrix ( M_2 ) ( 3 , 0 , 3 , 3 ) == - m_2 * skew ( c_2 )
			equation submatrix ( M_2 ) ( 3 , 3 , 3 , 3 ) == m_2 * identity ( 3 )
			equation V_2 == adj ( phi_3_2 ) * _V_3 + adj ( H_2 ) + derivative ( theta_2 )
			equation alpha_2 == adj ( phi_3_2 ) * _alpha_3 + adj ( H_2 ) * derivative ( theta_2 ) + a_2
			equation tau_2 == H_2 * f_2
			equation B_2 == _B_3 * T_3_2
			equation f_2 == phi_2_1 * _f_1 + M_2 * alpha_2 + b_2
			Constraint ( B_2 ) [ t == 0 ] == [| 1.000000 , 0.000000 , 0.000000 , 0.000000 ; 0.000000 , 1.000000 , 0.000000 , 0.000000 ; - 0.000000 , 0.000000 , 1.000000 , 2.500000 ; 0 , 0 , 0 , 1 |]
			Constraint ( T_geom_2 ) [ t == 0 ] == [| 1.000000 , 0.000000 , 0.000000 , 0.000000 ; 0.000000 , 1.000000 , 0.000000 , 0.000000 ; - 0.000000 , 0.000000 , 1.000000 , 2.500000 ; 0 , 0 , 0 , 1 |]
			Constraint ( T_offset_2 ) [ t == 0 ] == [| 1.0 , 0.0 , 0.0 , 0.0 ; 0.0 , 1.0 , 0.0 , 0.0 ; 0.0 , 0.0 , 1.0 , 2.000000 ; 0 , 0 , 0 , 1 |]
			Constraint ( X_T_2 ) [ t == 0 ] == [| 1 , 0 , 0 , 0 , 0 , 0 ; 0 , 1 , 0 , 0 , 0 , 0 ; 0 , 0 , 1 , 0 , 0 , 0 ; 0 , 0.500000 , - 0.000000 , 1 , 0 , 0 ; - 0.500000 , 0 , 0.000000 , 0 , 1 , 0 ; 0.000000 , - 0.000000 , 0 , 0 , 0 , 1 |]
		}
		local body IntermediateLink {
			def {
				inertial information {
					mass 1.0
					inertia matrix { ixx 1.349 ixy 0.0 ixz 0.0 iyy 1.349 iyz 0.0 izz 0.0313 }
					pose {
						x = 0.0
						y = 0.0
						z = 0.0
						roll = 0.0
						pitch = 0.0
						yaw = 0.0
					}
				}
				cylinder ( radius =  0.25 , length = 4.0 )
			local number : real = 0
			}
			pose {
				x = 
				
				0.0
				y = 0.0
				z = 0.0
				roll = 0.0
				pitch = 0.0
				yaw = 0.0
			}
		}
		local joint WristJoint {
			def {
				const  H : vector ( real , 6 ) = [| 0 , 0 , 1 , 0 , 0 , 0 |]
				InOut theta : real
				InOut X_J : matrix ( real , 6 , 6 )
				equation X_J == [| cos ( theta ) , - sin ( theta ) , 0 , 0 , 0 , 0 ; sin ( theta ) , cos ( theta ) , 0 , 0 , 0 , 0 ; 0 , 0 , 1 , 0 , 0 , 0 ; 0 , 0 , 0 , cos ( theta ) , - sin ( theta ) , 0 ; 0 , 0 , 0 , sin ( theta ) , cos ( theta ) , 0 ; 0 , 0 , 0 , 0 , 0 , 1 |]
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
                
				InOut phi_2_1 : matrix ( real , 6 , 6 )
				local number : real = 1
				local poseVec : vector ( real , 6 ) = [| 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 |]
				equation _B_2 == B_2
				equation _V_2 == V_2
				equation _alpha_2 == alpha_2
				equation _f_1 == f_1
			}
			flexibly connected to Gripper
			pose {
				x = 
				
				0.0
				y = 0.0
				z = 0.0
				roll = 0.0
				pitch = 0.0
				yaw = 0.0
			}
			local actuator WristActuator {
				def {
					input TorqueIn : real
					output TorqueOut : real
					equation TorqueIn == TorqueOut
				}
				pose {
					x = 0.0
					y = 0.0
					z = 0.0
					roll = 0.0
					pitch = 0.0
					yaw = 0.0
				}
			}
			local sensor WristSensor {
				def {
					input SignalIn : real
					output MeasurementOut : real
					equation SignalIn == MeasurementOut
				}
				pose {
					x = 0.0
					y = 0.0
					z = 0.0
					roll = 0.0
					pitch = 0.0
					yaw = 0.0
				}
			}
			relation B_2 == WristJoint . B_2 /\ V_2 == WristJoint . V_2 /\ alpha_2 == WristJoint . alpha_2 /\ theta [ 0 ] == WristJoint . theta /\ H_1 == WristJoint . H /\ X_J_1 == WristJoint . X_J
		}
		pose {
			x = 
			
			
			0.0
			y = 0.0
			z = 2.5
			roll = 0.0
			pitch = 0.0
			yaw = 0.0
		}
	relation B_2 == IntermediateLink . B_2 /\ T_geom_2 == IntermediateLink . T_geom_2 /\ T_offset_2 == IntermediateLink . T_offset_2 /\ V [ 1 ] == IntermediateLink . V_2 /\ a [ 1 ] == IntermediateLink . a_2 /\ b [ 1 ] == IntermediateLink . b_2 /\ alpha [ 1 ] == IntermediateLink . alpha_2 /\ submatrix ( M ) ( 6 , 6 , 6 , 6 ) == IntermediateLink . M_2 /\ tau [ 1 ] == IntermediateLink . tau_2 /\ submatrix ( H ) ( 1 , 6 , 1 , 6 ) == IntermediateLink . H_2
        relation_flexi B_2 == IntermediateLink . B_2 /\ f_2 == IntermediateLink . f_2 /\ theta == IntermediateLink . theta_2 /\ T_3_2 == IntermediateLink . T_3_2 /\ phi_3_2 == IntermediateLink . phi_3_2 /\ _V_3 == IntermediateLink . _V_3 /\ H == IntermediateLink . H_2 /\ X_J == IntermediateLink . X_J_2
	}
	local link Gripper {
		def {
		input test_1 : vector ( real , 1 )
			InOut geom_11 : Geom = Geom (| geomType = "box" , geomVal = [| 0.5 , 0.5 , 0.5 |] |)
			InOut M_1 : matrix ( real , 6 , 6 ) = [| 0.052050002 , 0.0 , 0.0 , 0.0 , - 0.125 , 0.0 ; 0.0 , 0.052050002 , 0.0 , 0.125 , 0.0 , 0.0 ; 0.0 , 0.0 , 0.0208 , 0.0 , 0.0 , 0.0 ; 0.0 , 0.125 , 0.0 , 0.5 , 0.0 , 0.0 ; - 0.125 , 0.0 , 0.0 , 0.0 , 0.5 , 0.0 ; 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.5 |]
			InOut a_1 : vector ( real , 6 )
			InOut b_1 : vector ( real , 6 )
			InOut V_1 : vector ( real , 6 )
			InOut alpha_1 : vector ( real , 6 )
			InOut f_1 : vector ( real , 6 )
			InOut B_1 : matrix ( real , 4 , 4 )
			InOut X_T_1 : matrix ( real , 6 , 6 )
			InOut T_geom_1 : matrix ( real , 4 , 4 )
			InOut T_offset_1 : matrix ( real , 4 , 4 )
			InOut m_1 : real = 0.5
			InOut I_C_1 : matrix ( real , 3 , 3 ) = [| 0.0208 , 0.0 , 0.0 ; 0.0 , 0.0208 , 0.0 ; 0.0 , 0.0 , 0.0208 |]
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
			local poseVec : vector ( real , 6 ) = [| 0.0 , 0.0 , 4.75 , 0.0 , 0.0 , 0.0 |]
			equation submatrix ( M_1 ) ( 0 , 0 , 3 , 3 ) == I_C_1 + m_1 * transpose ( skew ( c_1 ) ) * skew ( c_1 )
			equation submatrix ( M_1 ) ( 0 , 3 , 3 , 3 ) == m_1 * transpose ( skew ( c_1 ) )
			equation submatrix ( M_1 ) ( 3 , 0 , 3 , 3 ) == - m_1 * skew ( c_1 )
			equation submatrix ( M_1 ) ( 3 , 3 , 3 , 3 ) == m_1 * identity ( 3 )
			equation V_1 == adj ( phi_2_1 ) * _V_2 + adj ( H_1 ) + derivative ( theta_1 )
			equation alpha_1 == adj ( phi_2_1 ) * _alpha_2 + adj ( H_1 ) * derivative ( theta_1 ) + a_1
			equation tau_1 == H_1 * f_1
			equation B_1 == _B_2 * T_2_1
			equation f_1 == M_1 * alpha_1 + b_1
			Constraint ( B_1 ) [ t == 0 ] == [| 1.000000 , 0.000000 , 0.000000 , 0.000000 ; 0.000000 , 1.000000 , 0.000000 , 0.000000 ; - 0.000000 , 0.000000 , 1.000000 , 4.750000 ; 0 , 0 , 0 , 1 |]
			Constraint ( T_geom_1 ) [ t == 0 ] == [| 1.000000 , 0.000000 , 0.000000 , 0.000000 ; 0.000000 , 1.000000 , 0.000000 , 0.000000 ; - 0.000000 , 0.000000 , 1.000000 , 4.750000 ; 0 , 0 , 0 , 1 |]
			Constraint ( T_offset_1 ) [ t == 0 ] == [| 1.0 , 0.0 , 0.0 , 0.0 ; 0.0 , 1.0 , 0.0 , 0.0 ; 0.0 , 0.0 , 1.0 , 0.250000 ; 0 , 0 , 0 , 1 |]
			Constraint ( X_T_1 ) [ t == 0 ] == [| 1 , 0 , 0 , 0 , 0 , 0 ; 0 , 1 , 0 , 0 , 0 , 0 ; 0 , 0 , 1 , 0 , 0 , 0 ; 0 , 4.000000 , - 0.000000 , 1 , 0 , 0 ; - 4.000000 , 0 , 0.000000 , 0 , 1 , 0 ; 0.000000 , - 0.000000 , 0 , 0 , 0 , 1 |]
		}
		local body Gripper {
			def {
				inertial information {
					mass 0.5
					inertia matrix { ixx 0.0208 ixy 0.0 ixz 0.0 iyy 0.0208 iyz 0.0 izz 0.0208 }
					pose {
						x = 0.0
						y = 0.0
						z = 0.0
						roll = 0.0
						pitch = 0.0
						yaw = 0.0
					}
				}
				box ( length =  0.5 , width = 0.5 , height = 0.5 )
			local number : real = 0
			}
			pose {
				x = 
				0.0
				y = 0.0
				z = 0.0
				roll = 0.0
				pitch = 0.0
				yaw = 0.0
			}
		}
		pose {
			x = 0.0
			y = 0.0
			z = 4.75
			roll = 0.0
			pitch = 0.0
			yaw = 0.0
		}
	relation B_1 == Gripper . B_1 /\ T_geom_1 == Gripper . T_geom_1 /\ T_offset_1 == Gripper . T_offset_1 /\ V [ 0 ] == Gripper . V_1 /\ a [ 0 ] == Gripper . a_1 /\ b [ 0 ] == Gripper . b_1 /\ alpha [ 0 ] == Gripper . alpha_1 /\ submatrix ( M ) ( 0 , 0 , 6 , 6 ) == Gripper . M_1 /\ tau [ 0 ] == Gripper . tau_1 /\ submatrix ( H ) ( 0 , 0 , 1 , 6 ) == Gripper . H_1
        relation_flexi B_1 == Gripper . B_1 /\ f_1 == Gripper . f_1 /\ theta == Gripper . theta_1 /\ T_2_1 == Gripper . T_2_1 /\ phi_2_1 == Gripper . phi_2_1 /\ _V_2 == Gripper . _V_2 /\ H == Gripper . H_1 /\ X_J == Gripper . X_J_1
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
	InOut T_geom_1 : matrix ( real , 4 , 4 )
	InOut T_offset_1 : matrix ( real , 4 , 4 )
	InOut M_1 : matrix ( real , 6 , 6 )
	InOut r_v1 : real = 1
	InOut T_2_1 : matrix ( real , 4 , 4 )
	InOut B_2 : matrix ( real , 4 , 4 )
	InOut X_T_2 : matrix ( real , 6 , 6 )
	InOut T_geom_2 : matrix ( real , 4 , 4 )
	InOut T_offset_2 : matrix ( real , 4 , 4 )
	InOut M_2 : matrix ( real , 6 , 6 )
	InOut r_v2 : real = 1
	InOut T_3_2 : matrix ( real , 4 , 4 )
	InOut B_3 : matrix ( real , 4 , 4 )
	InOut X_T_3 : matrix ( real , 6 , 6 )
	InOut T_geom_3 : matrix ( real , 4 , 4 )
	InOut T_offset_3 : matrix ( real , 4 , 4 )
	InOut M_3 : matrix ( real , 6 , 6 )
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
	Constraint ( submatrix ( M ) ( 0 , 0 , 6 , 6 ) ) [ t == 0 ] == M_1 Constraint ( submatrix ( M ) ( 6 , 6 , 6 , 6 ) ) [ t == 0 ] == M_2 Constraint ( submatrix ( M ) ( 12 , 12 , 6 , 6 ) ) [ t == 0 ] == M_3 Constraint ( submatrix ( H ) ( 0 , 0 , 1 , 6 ) ) [ t == 0 ] == H_1 Constraint ( submatrix ( H ) ( 1 , 6 , 1 , 6 ) ) [ t == 0 ] == H_2 local d_theta : vector ( real , 2 )
	local dd_theta : vector ( real , 2 )
	local M_inv : matrix ( real , 2 , 2 )
	local dt : real
	solution { solutionExpr M_inv : matrix ( real , 2 , 2 ) order 5 group 0 method CholeskyAlgorithm Input M_mass : matrix ( real , 2 , 2 ) Input N : real Input n : int Constraint ( n ) [ t == 0 ] == 3 Constraint ( N ) [ t == 0 ] == 2 Constraint ( M_mass ) [ t == 0 ] == zeroMat ( 2 , 2 ) Constraint ( M_inv ) [ t == 0 ] == zeroMat ( 2 , 2 ) }
	solution { solutionExpr dd_theta : vector ( real , 2 ) order 6 group 0 method DirectForwardDynamics Input n : int Input tau : vector ( real , 2 ) Input M_inv : matrix ( real , 2 , 2 ) Input C : vector ( real , 2 ) Constraint ( n ) [ t == 0 ] == 3 Constraint ( n ) [ t == 0 ] == 3 Constraint ( M_inv ) [ t == 0 ] == zeroMat ( 2 , 2 ) Constraint ( tau ) [ t == 0 ] == zeroVec ( 2 ) Constraint ( dd_theta ) [ t == 0 ] == zeroVec ( 2 ) Constraint ( C ) [ t == 0 ] == zeroVec ( 2 ) }
	solution { solutionExpr d_theta : vector ( real , 2 ) order 7 group 0 method Euler Input dd_theta : vector ( real , 2 ) Input dt : real Input n : int Constraint ( n ) [ t == 0 ] == 3 Constraint ( dd_theta ) [ t == 0 ] == zeroVec ( 2 ) Constraint ( dt ) [ t == 0 ] == 0.01 Constraint ( d_theta ) [ t == 0 ] == zeroVec ( 2 ) Constraint ( dd_theta ) [ t == 0 ] == zeroVec ( 2 ) }
	solution { solutionExpr theta : vector ( real , 2 ) order 8 group 0 method Euler Input d_theta : vector ( real , 2 ) Input dt : real Input n : int Constraint ( n ) [ t == 0 ] == 3 Constraint ( d_theta ) [ t == 0 ] == 0 Constraint ( dt ) [ t == 0 ] == 0.01 Constraint ( theta ) [ t == 0 ] == zeroVec ( 2 ) }
	solution { solutionExpr B_k : Seq( matrix ( real , 4 , 4 ) ) order 3 group 0 method ForwardKinematics Input B_k : Seq( matrix ( real , 4 , 4 ) ) Input X_J : Seq( matrix ( real , 6 , 6 ) ) Input X_T : Seq( matrix ( real , 6 , 6 ) ) Input n : int Input theta : vector ( real , 2 ) Input B_1 : matrix ( real , 4 , 4 ) Input B_2 : matrix ( real , 4 , 4 ) Input B_3 : matrix ( real , 4 , 4 ) Input X_J_1 : matrix ( real , 6 , 6 ) Input X_J_2 : matrix ( real , 6 , 6 ) Input X_T_1 : matrix ( real , 6 , 6 ) Input X_T_2 : matrix ( real , 6 , 6 ) Input X_T_3 : matrix ( real , 6 , 6 ) Constraint ( n ) [ t == 0 ] == 3 Constraint ( n ) [ t == 0 ] == 3 Constraint ( B_1 ) [ t == 0 ] == [| 1.0 , 0.0 , 0.0 , 0.0 ; 0.0 , 1.0 , 0.0 , 0.0 ; - 0.0 , 0.0 , 1.0 , 4.75 ; 0 , 0 , 0 , 1 |] Constraint ( B_2 ) [ t == 0 ] == [| 1.0 , 0.0 , 0.0 , 0.0 ; 0.0 , 1.0 , 0.0 , 0.0 ; - 0.0 , 0.0 , 1.0 , 2.5 ; 0 , 0 , 0 , 1 |] Constraint ( B_3 ) [ t == 0 ] == [| 1.0 , 0.0 , 0.0 , 0.0 ; 0.0 , 1.0 , 0.0 , 0.0 ; - 0.0 , 0.0 , 1.0 , 0.0 ; 0 , 0 , 0 , 1 |] Constraint ( X_J_1 ) [ t == 0 ] == zeroMat ( 6 , 6 ) Constraint ( X_J_1 ) [ t == t ] == [| cos ( theta ( 0 ) ) , - sin ( theta ( 0 ) ) , 0 , 0 , 0 , 0 ; sin ( theta ( 0 ) ) , cos ( theta ( 0 ) ) , 0 , 0 , 0 , 0 ; 0 , 0 , 1 , 0 , 0 , 0 ; 0 , 0 , 0 , cos ( theta ( 0 ) ) , - sin ( theta ( 0 ) ) , 0 ; 0 , 0 , 0 , sin ( theta ( 0 ) ) , cos ( theta ( 0 ) ) , 0 ; 0 , 0 , 0 , 0 , 0 , 1 |] Constraint ( X_J_2 ) [ t == 0 ] == zeroMat ( 6 , 6 ) Constraint ( X_J_2 ) [ t == t ] == [| 1 , 0 , 0 , 0 , 0 , 0 ; 0 , cos ( theta ( 1 ) ) , - sin ( theta ( 1 ) ) , 0 , 0 , 0 ; 0 , sin ( theta ( 1 ) ) , cos ( theta ( 1 ) ) , 0 , 0 , 0 ; 0 , 0 , 0 , 1 , 0 , 0 ; 0 , 0 , 0 , 0 , cos ( theta ( 1 ) ) , - sin ( theta ( 1 ) ) ; 0 , 0 , 0 , 0 , sin ( theta ( 1 ) ) , cos ( theta ( 1 ) ) |] Constraint ( X_T_1 ) [ t == 0 ] == [| 1 , 0 , 0 , 0 , 0 , 0 ; 0 , 1 , 0 , 0 , 0 , 0 ; 0 , 0 , 1 , 0 , 0 , 0 ; 0 , 4.0 , - 0.0 , 1 , 0 , 0 ; - 4.0 , 0 , 0.0 , 0 , 1 , 0 ; 0.0 , - 0.0 , 0 , 0 , 0 , 1 |] Constraint ( X_T_2 ) [ t == 0 ] == [| 1 , 0 , 0 , 0 , 0 , 0 ; 0 , 1 , 0 , 0 , 0 , 0 ; 0 , 0 , 1 , 0 , 0 , 0 ; 0 , 0.5 , - 0.0 , 1 , 0 , 0 ; - 0.5 , 0 , 0.0 , 0 , 1 , 0 ; 0.0 , - 0.0 , 0 , 0 , 0 , 1 |] Constraint ( X_T_3 ) [ t == 0 ] == [| 1 , 0 , 0 , 0 , 0 , 0 ; 0 , 1 , 0 , 0 , 0 , 0 ; 0 , 0 , 1 , 0 , 0 , 0 ; 0 , 0 , 0 , 1 , 0 , 0 ; 0 , 0 , 0 , 0 , 1 , 0 ; 0 , 0 , 0 , 0 , 0 , 1 |] Constraint ( B_k ) [ t == 0 ] == < B_1 , B_2 , B_3 > Constraint ( X_J ) [ t == 0 ] == < X_J_1 , X_J_2 > Constraint ( X_J ) [ t == t ] == < X_J_1 , X_J_2 > Constraint ( X_T ) [ t == 0 ] == < X_T_1 , X_T_2 , X_T_3 > }
	solution { solutionExpr T_geom : Seq( matrix ( real , 4 , 4 ) ) order 4 group 0 method Visualisation Input B_k : Seq( matrix ( real , 4 , 4 ) ) Input T_offset : Seq( matrix ( real , 4 , 4 ) ) Input B_1 : matrix ( real , 4 , 4 ) Input T_offset_1 : matrix ( real , 4 , 4 ) Input B_2 : matrix ( real , 4 , 4 ) Input T_offset_2 : matrix ( real , 4 , 4 ) Input B_3 : matrix ( real , 4 , 4 ) Input T_offset_3 : matrix ( real , 4 , 4 ) Input n : int Input T_geom_1 : matrix ( real , 4 , 4 ) Input T_geom_2 : matrix ( real , 4 , 4 ) Input T_geom_3 : matrix ( real , 4 , 4 ) Constraint ( n ) [ t == 0 ] == 3 Constraint ( n ) [ t == 0 ] == 3 Constraint ( T_geom_1 ) [ t == 0 ] == [| 1.0 , 0.0 , 0.0 , 0.0 ; 0.0 , 1.0 , 0.0 , 0.0 ; - 0.0 , 0.0 , 1.0 , 4.75 ; 0 , 0 , 0 , 1 |] Constraint ( T_geom_2 ) [ t == 0 ] == [| 1.0 , 0.0 , 0.0 , 0.0 ; 0.0 , 1.0 , 0.0 , 0.0 ; - 0.0 , 0.0 , 1.0 , 2.5 ; 0 , 0 , 0 , 1 |] Constraint ( T_geom_3 ) [ t == 0 ] == [| 1.0 , 0.0 , 0.0 , 0.0 ; 0.0 , 1.0 , 0.0 , 0.0 ; - 0.0 , 0.0 , 1.0 , 0.25 ; 0 , 0 , 0 , 1 |] Constraint ( T_geom_1 ) [ t == t ] == B_1 * T_offset_1 Constraint ( T_geom_2 ) [ t == t ] == B_2 * T_offset_2 Constraint ( T_geom_3 ) [ t == t ] == B_3 * T_offset_3 Constraint ( T_geom ) [ t == t ] == < T_geom_1 , T_geom_2 , T_geom_3 > }
}
	sensor TrivialSensor {
		input SignalIn : real
		output MeasurementOut : real
		equation SignalIn == MeasurementOut
	}
	datatype Geom { geomType : string geomVal : vector ( real ) }
	actuator TrivialMotor {
		input TorqueIn : real
		output TorqueOut : real
		equation TorqueIn == TorqueOut
	}
	function identity ( size : real ) : matrix ( real , 3 , 3 ) { } function zeroes ( size : real ) : matrix ( real , 3 , 3 ) { } function Phi ( m : real , n : real , B_k : Seq( matrix ( real , 4 , 4 ) ) ) : matrix ( real , 6 , 6 ) { } function zeroVec ( a : real ) : vector ( real , 1 ) { } function zeroMat ( a : real , b : real ) : matrix ( real , 0 , 0 ) { } function skew ( v : vector ( real , 3 ) ) : matrix ( real , 3 , 3 ) { } function getFramePosition ( k : real , B_n : Seq( matrix ( real , 4 , 4 ) ) ) : vector ( real , 3 ) { }
