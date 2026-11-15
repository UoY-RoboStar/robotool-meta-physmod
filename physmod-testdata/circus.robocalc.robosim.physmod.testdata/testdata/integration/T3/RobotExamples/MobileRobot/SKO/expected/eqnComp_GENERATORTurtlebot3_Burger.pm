import physmod::math::*
import physmod::SKO::joints::Revolute_y
import physmod::trivial::actuators::ControlledMotor 

pmodel Turtlebot3_Burger {
	local link BaseLink {
		def { InOut geom_31 : Geom = Geom (| geomType = "mesh" , geomVal = [| 0.0 |] , meshUri = "meshes/bases/burger_base.stl" , meshScale = [| 0.001 |] |)
			InOut L3_geom : Geom = Geom (| geomType = "mesh" , geomVal = [| 0.0 |] , meshUri = "meshes/bases/burger_base.stl" , meshScale = [| 0.001 |] |)
			InOut M_3 : matrix ( real , 6 , 6 ) = [| 0.728020031696 , 0.0000000004686399 , 0.0018496355370297 , 0.0 , - 0.0578014528 , 0.0 ; 0.0000000004686399 , 0.72886558437696 , 0.0000000028582649 , 0.0578014528 , 0.0 , 0.02642352128 ; 0.0018496355370297 , 0.0000000028582649 , 0.65389571568096 , 0.0 , - 0.02642352128 , 0.0 ; 0.0 , 0.0578014528 , 0.0 , 0.82573504 , 0.0 , 0.0 ; - 0.0578014528 , 0.0 , - 0.02642352128 , 0.0 , 0.82573504 , 0.0 ; 0.0 , 0.02642352128 , 0.0 , 0.0 , 0.0 , 0.82573504 |]
			InOut a_3 : vector ( real , 6 )
			InOut b_3 : vector ( real , 6 )
			InOut V_3 : vector ( real , 6 )
			InOut alpha_3 : vector ( real , 6 )
			InOut f_3 : vector ( real , 6 )
			InOut B_3 : matrix ( real , 4 , 4 )
			InOut X_T_3 : matrix ( real , 6 , 6 )
			InOut T_geom_3 : matrix ( real , 4 , 4 )
			InOut T_offset_3 : matrix ( real , 4 , 4 )
			InOut m_3 : real = 0.82573504
			InOut I_C_3 : matrix ( real , 3 , 3 ) = [| 0.72397393 , 0.0000000004686399 , - 0.0000000109525703 ; 0.0000000004686399 , 0.72397393 , 0.0000000028582649 ; - 0.0000000109525703 , 0.0000000028582649 , 0.653050163 |]
			InOut c_3 : vector ( real , 3 ) = [| - 0.032 , 0.0 , 0.07 |]
			InOut cz_3 : real = 0.0
			InOut _f_1 : vector ( real , 6 )
			InOut phi_3_1 : matrix ( real , 6 , 6 )
			InOut _f_2 : vector ( real , 6 )
			InOut phi_3_2 : matrix ( real , 6 , 6 )
			local number : real = 3
			local poseVec : vector ( real , 6 ) = [| 0.0 , 0.0 , 0.01 , 0.0 , 0.0 , 0.0 |]
			equation submatrix ( M_3 ) ( 0 , 0 , 3 , 3 ) == I_C_3 + m_3 * transpose ( skew ( c_3 ) ) * skew ( c_3 )
			equation submatrix ( M_3 ) ( 0 , 3 , 3 , 3 ) == m_3 * skew ( c_3 )
			equation submatrix ( M_3 ) ( 3 , 0 , 3 , 3 ) == - m_3 * skew ( c_3 )
			equation submatrix ( M_3 ) ( 3 , 3 , 3 , 3 ) == m_3 * identity ( 3 )
			equation f_3 == phi_3_1 * _f_1 + phi_3_2 * _f_2 + M_3 * alpha_3 + b_3
			equation V_3 == 0
			equation alpha_3 == a_3
			Constraint ( B_3 ) [ t == 0 ] == [| 1.000000 , 0.000000 , 0.000000 , 0.000000 ; 0.000000 , 1.000000 , 0.000000 , 0.000000 ; - 0.000000 , 0.000000 , 1.000000 , 0.01 ; 0 , 0 , 0 , 1 |]
			Constraint ( T_geom_3 ) [ t == 0 ] == [| 1.000000 , 0.000000 , 0.000000 , - 0.032 ; 0.000000 , 1.000000 , 0.000000 , 0.000000 ; - 0.000000 , 0.000000 , 1.000000 , 0.08 ; 0 , 0 , 0 , 1 |]
			Constraint ( T_offset_3 ) [ t == 0 ] == [| 1.0 , 0.0 , 0.0 , - 0.032 ; 0.0 , 1.0 , 0.0 , 0.0 ; 0.0 , 0.0 , 1.0 , 0.07 ; 0 , 0 , 0 , 1 |]
			Constraint ( X_T_3 ) [ t == 0 ] == [| 1 , 0 , 0 , 0 , 0 , 0 ; 0 , 1 , 0 , 0 , 0 , 0 ; 0 , 0 , 1 , 0 , 0 , 0 ; 0 , 0 , 0 , 1 , 0 , 0 ; 0 , 0 , 0 , 0 , 1 , 0 ; 0 , 0 , 0 , 0 , 0 , 1 |]
		}
		local body Chassis {
			def {
				inertial information {
					mass 0.82573504
					inertia matrix { ixx 0.72397393 ixy 0.0000000004686399 ixz -0.0000000109525703 iyy 0.72397393 iyz 0.0000000028582649 izz 0.653050163 }
					pose { x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
				}
				mesh {
					shape "meshes/bases/burger_base.stl"
					scaling 0.001
				}
			local number : real = 0
			}
			pose { x = -0.032 y = 0.0 z = 0.070 roll = 0.0 pitch = 0.0 yaw = 0.0 }
		}
		local joint LeftWheelJoint {
			def {
				InOut theta : real
				InOut XJ : matrix ( real , 6 , 6 )
				InOut B_1 : matrix ( real , 4 , 4 )
				InOut B_3 : matrix ( real , 4 , 4 )
				InOut _B_3 : matrix ( real , 4 , 4 )
				InOut T_3_1 : matrix ( real , 4 , 4 )
				InOut V_3 : vector ( real , 6 )
				InOut _V_3 : vector ( real , 6 )
				InOut alpha_3 : vector ( real , 6 )
				InOut _alpha_3 : vector ( real , 6 )
				InOut f_1 : vector ( real , 6 )
				InOut r_v1 : real = 1
				InOut theta_1 : real
				InOut phi_3_1 : matrix ( real , 6 , 6 )
				local number : real = 1
				local poseVec : vector ( real , 6 ) = [| 0.0 , 0.08 , 0.023 , 0.0 , 0.0 , 0.0 |]
				const H : vector ( real , 6 ) = (| 0 , 1 , 0 , 0 , 0 , 0 |)
				equation XJ == [| cos ( theta ) , 0 , sin ( theta ) , 0 , 0 , 0 ; 0 , 1 , 0 , 0 , 0 , 0 ; - sin ( theta ) , 0 , cos ( theta ) , 0 , 0 , 0 ; 0 , 0 , 0 , cos ( theta ) , 0 , sin ( theta ) ; 0 , 0 , 0 , 0 , 1 , 0 ; 0 , 0 , 0 , - sin ( theta ) , 0 , cos ( theta ) |]
				equation _B_3 == B_3
				equation _V_3 == V_3
				equation _alpha_3 == alpha_3
				equation _f_1 == f_1
			}
			flexibly connected to LeftWheel
			local actuator LeftMotor {
				def {
					input ControlIn : real
					output TorqueOut : real
					const B_ctrl : matrix ( real , 1 , 1 ) = [| 1.0 |]
					equation TorqueOut == B_ctrl * ControlIn
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
			pose {
				x = 0.0
				y = 0.08
				z = 0.023
				roll = 0.0
				pitch = 0.0
				yaw = 0.0
			}
			relation B_3 == LeftWheelJoint . B_3 /\ V_3 == LeftWheelJoint . V_3 /\ alpha_3 == LeftWheelJoint . alpha_3 /\ theta [ 0 ] == LeftWheelJoint . theta /\ H_1 == LeftWheelJoint . H /\ X_J_1 == LeftWheelJoint . XJ
		}
		local joint RightWheelJoint {
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
				local poseVec : vector ( real , 6 ) = [| 0.0 , - 0.08 , 0.023 , 0.0 , 0.0 , 0.0 |]
				const H : vector ( real , 6 ) = (| 0 , 1 , 0 , 0 , 0 , 0 |)
				equation XJ == [| cos ( theta ) , 0 , sin ( theta ) , 0 , 0 , 0 ; 0 , 1 , 0 , 0 , 0 , 0 ; - sin ( theta ) , 0 , cos ( theta ) , 0 , 0 , 0 ; 0 , 0 , 0 , cos ( theta ) , 0 , sin ( theta ) ; 0 , 0 , 0 , 0 , 1 , 0 ; 0 , 0 , 0 , - sin ( theta ) , 0 , cos ( theta ) |]
				equation _B_3 == B_3
				equation _V_3 == V_3
				equation _alpha_3 == alpha_3
				equation _f_2 == f_2
			}
			flexibly connected to RightWheel
			local actuator RightMotor {
				def {
					input ControlIn : real
					output TorqueOut : real
					const B_ctrl : matrix ( real , 1 , 1 ) = [| 1.0 |]
					equation TorqueOut == B_ctrl * ControlIn
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
			pose {
				x = 0.0
				y = - 0.08
				z = 0.023
				roll = 0.0
				pitch = 0.0
				yaw = 0.0
			}
			relation B_3 == RightWheelJoint . B_3 /\ V_3 == RightWheelJoint . V_3 /\ alpha_3 == RightWheelJoint . alpha_3 /\ theta [ 1 ] == RightWheelJoint . theta /\ H_2 == RightWheelJoint . H /\ X_J_2 == RightWheelJoint . XJ
		}
		local sensor TBLidar {
			def {
				input trueDistance : real
				input measuredDistance : real
				input range_max : real
				input w_hit : real
				input w_short : real
				input w_max : real
				input w_rand : real
				input sigma_hit : real
				input lambda_short : real
				input angle_min : real
				output scan : LaserScan
				output measurement : real
				output closestDistance : real
				output closestAngle : real
				local p_hit : real
				local p_short : real
				local p_rand : real
				local p_max : real
				local eta1 : real
				local eta2 : real
				local N : real
				const PI : real = 3.141592653589793
				const e : real = 2.718281828459045
				equation w_hit + w_short + w_max + w_rand == 1
				equation N == 1 / ( sqrt ( 2 * PI * sigma_hit cat 2 ) ) * e cat ( - ( 0.5 / sigma_hit cat 2 ) * ( measuredDistance - trueDistance ) cat 2 )
				equation eta1 == ( integral ( N , 0 , range_max ) ) cat - 1
				equation eta2 == 1 / ( 1 - e cat ( - lambda_short * trueDistance ) )
				equation p_hit == ind ( measuredDistance , 0 , range_max ) * eta1 * N
				equation p_short == ind ( measuredDistance , 0 , trueDistance ) * eta2 * lambda_short * e cat ( - lambda_short * measuredDistance )
				equation p_max == ind ( measuredDistance , range_max , range_max )
				equation p_rand == ind ( measuredDistance , 0 , range_max ) * 1 / range_max
				equation measurement == w_hit * p_hit + w_short * p_short + w_max * p_max + w_rand * p_rand
				equation closestDistance == measuredDistance
				equation closestAngle == angle_min
				equation scan . angle_min == angle_min
				equation scan . angle_max == 0.0
				equation scan . angle_increment == 0.0
				equation scan . time_increment == 0.0
				equation scan . scan_time == 0.0
				equation scan . range_min == 0.0
				equation scan . range_max == range_max
				equation scan . ranges == < measuredDistance >
				equation scan . intensities == < 0.0 >
			}
			pose {
				x = 0.0
				y = 0.0
				z = 0.071
				roll = 0.0
				pitch = 0.0
				yaw = 0.0
			}
		}
		local sensor TBIMU {
			def {
				input angularRateAV : real
				input angularRateLV : real
				output currentLV : real
				output currentAV : real
			}
			pose {
				x = 0.0
				y = 0.0
				z = 0.071
				roll = 0.0
				pitch = 0.0
				yaw = 0.0
			}
		}

		pose { x = 0.0 y = 0.0 z = 0.010 roll = 0.0 pitch = 0.0 yaw = 0.0 }
	relation B_3 == BaseLink . B_3 /\ V [ 2 ] == BaseLink . V_3 /\ a [ 2 ] == BaseLink . a_3 /\ b [ 2 ] == BaseLink . b_3 /\ alpha [ 2 ] == BaseLink . alpha_3 /\ submatrix ( M ) ( 12 , 12 , 6 , 6 ) == BaseLink . M_3 /\ L3_geom == geom_31
	}

	local link LeftWheel {
		def { InOut geom_11 : Geom = Geom (| geomType = "mesh" , geomVal = [| 0.0 |] , meshUri = "meshes/wheels/left_tire.stl" , meshScale = [| 0.001 |] |)
			InOut L1_geom : Geom = Geom (| geomType = "mesh" , geomVal = [| 0.0 |] , meshUri = "meshes/wheels/left_tire.stl" , meshScale = [| 0.001 |] |)
			InOut M_1 : matrix ( real , 6 , 6 ) = [| 0.0018158194 , - 0.0000000000093392 , 0.0000000000104909 , 0.0 , 0.0 , 0.0 ; - 0.0000000000093392 , 0.0032922126 , 0.0000000000575694 , 0.0 , 0.0 , 0.0 ; 0.0000000000104909 , 0.0000000000575694 , 0.0018158194 , 0.0 , 0.0 , 0.0 ; 0.0 , 0.0 , 0.0 , 0.02849894 , 0.0 , 0.0 ; 0.0 , 0.0 , 0.0 , 0.0 , 0.02849894 , 0.0 ; 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.02849894 |]
			InOut a_1 : vector ( real , 6 )
			InOut b_1 : vector ( real , 6 )
			InOut V_1 : vector ( real , 6 )
			InOut alpha_1 : vector ( real , 6 )
			InOut f_1 : vector ( real , 6 )
			InOut B_1 : matrix ( real , 4 , 4 )
			InOut X_T_1 : matrix ( real , 6 , 6 )
			InOut T_geom_1 : matrix ( real , 4 , 4 )
			InOut T_offset_1 : matrix ( real , 4 , 4 )
			InOut m_1 : real = 0.02849894
			InOut I_C_1 : matrix ( real , 3 , 3 ) = [| 0.0018158194 , - 0.0000000000093392 , 0.0000000000104909 ; - 0.0000000000093392 , 0.0032922126 , 0.0000000000575694 ; 0.0000000000104909 , 0.0000000000575694 , 0.0018158194 |]
			InOut c_1 : vector ( real , 3 ) = [| 0.0 , 0.0 , 0.0 |]
			InOut cz_1 : real = 0.0
			InOut theta_1 : real
			InOut phi_3_1 : matrix ( real , 6 , 6 )
			InOut _V_3 : vector ( real , 6 )
			InOut _alpha_3 : vector ( real , 6 )
			InOut _B_3 : matrix ( real , 4 , 4 )
			InOut T_3_1 : matrix ( real , 4 , 4 )
			InOut H_1 : matrix ( real , 1 , 6 )
			InOut X_J_1 : matrix ( real , 6 , 6 )
			InOut r_v1 : real = 1
			InOut tau_1 : vector ( real , 1 )
			local number : real = 1
			local poseVec : vector ( real , 6 ) = [| 0.0 , 0.08 , 0.033 , 0.0 , 0.0 , 0.0 |]
			equation submatrix ( M_1 ) ( 0 , 0 , 3 , 3 ) == I_C_1 + m_1 * transpose ( skew ( c_1 ) ) * skew ( c_1 )
			equation submatrix ( M_1 ) ( 0 , 3 , 3 , 3 ) == m_1 * skew ( c_1 )
			equation submatrix ( M_1 ) ( 3 , 0 , 3 , 3 ) == - m_1 * skew ( c_1 )
			equation submatrix ( M_1 ) ( 3 , 3 , 3 , 3 ) == m_1 * identity ( 3 )
			equation V_1 == adj ( phi_3_1 ) * _V_3 + adj ( H_1 ) * derivative ( theta_1 )
			equation alpha_1 == adj ( phi_3_1 ) * _alpha_3 + adj ( H_1 ) * derivative ( derivative ( theta_1 ) ) + a_1
			equation tau_1 == H_1 * f_1
			equation B_1 == _B_3 * T_3_1
			equation f_1 == M_1 * alpha_1 + b_1
			Constraint ( B_1 ) [ t == 0 ] == [| 1.000000 , 0.000000 , 0.000000 , 0.000000 ; 0.000000 , 1.000000 , 0.000000 , 0.08 ; - 0.000000 , 0.000000 , 1.000000 , 0.033 ; 0 , 0 , 0 , 1 |]
			Constraint ( T_geom_1 ) [ t == 0 ] == [| 1.000000 , 0.000000 , 0.000000 , 0.000000 ; 0.000000 , 1.000000 , 0.000000 , 0.08 ; - 0.000000 , 0.000000 , 1.000000 , 0.033 ; 0 , 0 , 0 , 1 |]
			Constraint ( T_offset_1 ) [ t == 0 ] == [| 1.0 , 0.0 , 0.0 , 0.0 ; 0.0 , 1.0 , 0.0 , 0.0 ; 0.0 , 0.0 , 1.0 , 0 ; 0 , 0 , 0 , 1 |]
			Constraint ( X_T_1 ) [ t == 0 ] == [| 1 , 0 , 0 , 0 , 0 , 0 ; 0 , 1 , 0 , 0 , 0 , 0 ; 0 , 0 , 1 , 0 , 0 , 0 ; 0 , 0.023 , - 0.080000 , 1 , 0 , 0 ; - 0.023 , 0 , 0.000000 , 0 , 1 , 0 ; 0.080000 , - 0.000000 , 0 , 0 , 0 , 1 |]
		}
		local body Wheel {
			def {
				inertial information {
					mass 0.02849894
					inertia matrix { ixx 0.0018158194 ixy -0.0000000000093392 ixz 0.0000000000104909 iyy 0.0032922126 iyz 0.0000000000575694 izz 0.0018158194 }
					pose { x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
				}
				mesh {
					shape "meshes/wheels/left_tire.stl"
					scaling 0.001
				}
			local number : real = 0
			}
			pose { x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
		}
		pose { x = 0.0 y = 0.08 z = 0.033 roll = 0.0 pitch = 0.0 yaw = 0.0 }
	relation B_1 == LeftWheel . B_1 /\ V [ 0 ] == LeftWheel . V_1 /\ a [ 0 ] == LeftWheel . a_1 /\ b [ 0 ] == LeftWheel . b_1 /\ alpha [ 0 ] == LeftWheel . alpha_1 /\ submatrix ( M ) ( 0 , 0 , 6 , 6 ) == LeftWheel . M_1 /\ tau [ 0 ] == LeftWheel . tau_1 /\ L1_geom == geom_11 /\ submatrix ( H ) ( 0 , 0 , 1 , 6 ) == LeftWheel . H_1
		relation_flexi B_1 == LeftWheel . B_1 /\ f_1 == LeftWheel . f_1 /\ theta_1 == LeftWheel . theta_1 /\ T_3_1 == LeftWheel . T_3_1 /\ phi_3_1 == LeftWheel . phi_3_1 /\ _V_3 == LeftWheel . _V_3 /\ H == LeftWheel . H_1 /\ X_J_1 == LeftWheel . X_J_1
	}

	local link RightWheel {
		def { InOut geom_21 : Geom = Geom (| geomType = "mesh" , geomVal = [| 0.0 |] , meshUri = "meshes/wheels/right_tire.stl" , meshScale = [| 0.001 |] |)
			InOut L2_geom : Geom = Geom (| geomType = "mesh" , geomVal = [| 0.0 |] , meshUri = "meshes/wheels/right_tire.stl" , meshScale = [| 0.001 |] |)
			InOut M_2 : matrix ( real , 6 , 6 ) = [| 0.0018158194 , - 0.0000000000093392 , 0.0000000000104909 , 0.0 , 0.0 , 0.0 ; - 0.0000000000093392 , 0.0032922126 , 0.0000000000575694 , 0.0 , 0.0 , 0.0 ; 0.0000000000104909 , 0.0000000000575694 , 0.0018158194 , 0.0 , 0.0 , 0.0 ; 0.0 , 0.0 , 0.0 , 0.02849894 , 0.0 , 0.0 ; 0.0 , 0.0 , 0.0 , 0.0 , 0.02849894 , 0.0 ; 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.02849894 |]
			InOut a_2 : vector ( real , 6 )
			InOut b_2 : vector ( real , 6 )
			InOut V_2 : vector ( real , 6 )
			InOut alpha_2 : vector ( real , 6 )
			InOut f_2 : vector ( real , 6 )
			InOut B_2 : matrix ( real , 4 , 4 )
			InOut X_T_2 : matrix ( real , 6 , 6 )
			InOut T_geom_2 : matrix ( real , 4 , 4 )
			InOut T_offset_2 : matrix ( real , 4 , 4 )
			InOut m_2 : real = 0.02849894
			InOut I_C_2 : matrix ( real , 3 , 3 ) = [| 0.0018158194 , - 0.0000000000093392 , 0.0000000000104909 ; - 0.0000000000093392 , 0.0032922126 , 0.0000000000575694 ; 0.0000000000104909 , 0.0000000000575694 , 0.0018158194 |]
			InOut c_2 : vector ( real , 3 ) = [| 0.0 , 0.0 , 0.0 |]
			InOut cz_2 : real = 0.0
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
			local poseVec : vector ( real , 6 ) = [| 0.0 , - 0.08 , 0.033 , 0.0 , 0.0 , 0.0 |]
			equation submatrix ( M_2 ) ( 0 , 0 , 3 , 3 ) == I_C_2 + m_2 * transpose ( skew ( c_2 ) ) * skew ( c_2 )
			equation submatrix ( M_2 ) ( 0 , 3 , 3 , 3 ) == m_2 * skew ( c_2 )
			equation submatrix ( M_2 ) ( 3 , 0 , 3 , 3 ) == - m_2 * skew ( c_2 )
			equation submatrix ( M_2 ) ( 3 , 3 , 3 , 3 ) == m_2 * identity ( 3 )
			equation V_2 == adj ( phi_3_2 ) * _V_3 + adj ( H_2 ) * derivative ( theta_2 )
			equation alpha_2 == adj ( phi_3_2 ) * _alpha_3 + adj ( H_2 ) * derivative ( derivative ( theta_2 ) ) + a_2
			equation tau_2 == H_2 * f_2
			equation B_2 == _B_3 * T_3_2
			equation f_2 == M_2 * alpha_2 + b_2
			Constraint ( B_2 ) [ t == 0 ] == [| 1.000000 , 0.000000 , 0.000000 , 0.000000 ; 0.000000 , 1.000000 , 0.000000 , - 0.08 ; - 0.000000 , 0.000000 , 1.000000 , 0.033 ; 0 , 0 , 0 , 1 |]
			Constraint ( T_geom_2 ) [ t == 0 ] == [| 1.000000 , 0.000000 , 0.000000 , 0.000000 ; 0.000000 , 1.000000 , 0.000000 , - 0.08 ; - 0.000000 , 0.000000 , 1.000000 , 0.033 ; 0 , 0 , 0 , 1 |]
			Constraint ( T_offset_2 ) [ t == 0 ] == [| 1.0 , 0.0 , 0.0 , 0.0 ; 0.0 , 1.0 , 0.0 , 0.0 ; 0.0 , 0.0 , 1.0 , 0 ; 0 , 0 , 0 , 1 |]
			Constraint ( X_T_2 ) [ t == 0 ] == [| 1 , 0 , 0 , 0 , 0 , 0 ; 0 , 1 , 0 , 0 , 0 , 0 ; 0 , 0 , 1 , 0 , 0 , 0 ; 0 , 0.023 , 0.080000 , 1 , 0 , 0 ; - 0.023 , 0 , 0.000000 , 0 , 1 , 0 ; - 0.080000 , - 0.000000 , 0 , 0 , 0 , 1 |]
		}
		local body Wheel {
			def {
				inertial information {
					mass 0.02849894
					inertia matrix { ixx 0.0018158194 ixy -0.0000000000093392 ixz 0.0000000000104909 iyy 0.0032922126 iyz 0.0000000000575694 izz 0.0018158194 }
					pose { x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
				}
				mesh {
					shape "meshes/wheels/right_tire.stl"
					scaling 0.001
				}
			local number : real = 0
			}
			pose { x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
		}
		pose { x = 0.0 y = -0.08 z = 0.033 roll = 0.0 pitch = 0.0 yaw = 0.0 }
	relation B_2 == RightWheel . B_2 /\ V [ 1 ] == RightWheel . V_2 /\ a [ 1 ] == RightWheel . a_2 /\ b [ 1 ] == RightWheel . b_2 /\ alpha [ 1 ] == RightWheel . alpha_2 /\ submatrix ( M ) ( 6 , 6 , 6 , 6 ) == RightWheel . M_2 /\ tau [ 1 ] == RightWheel . tau_2 /\ L2_geom == geom_21 /\ submatrix ( H ) ( 1 , 6 , 1 , 6 ) == RightWheel . H_2
		relation_flexi B_2 == RightWheel . B_2 /\ f_2 == RightWheel . f_2 /\ theta_2 == RightWheel . theta_2 /\ T_3_2 == RightWheel . T_3_2 /\ phi_3_2 == RightWheel . phi_3_2 /\ _V_3 == RightWheel . _V_3 /\ H == RightWheel . H_2 /\ X_J_2 == RightWheel . X_J_2
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
	InOut T_3_1 : matrix ( real , 4 , 4 )
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
	equation submatrix ( phi ) ( 0 , 0 , 6 , 6 ) == identity ( 6 )
	equation submatrix ( phi ) ( 0 , 6 , 6 , 6 ) == zeroes ( 6 )
	equation submatrix ( phi ) ( 0 , 12 , 6 , 6 ) == zeroes ( 6 )
	equation submatrix ( phi ) ( 6 , 6 , 6 , 6 ) == identity ( 6 )
	equation submatrix ( phi ) ( 6 , 12 , 6 , 6 ) == zeroes ( 6 )
	equation submatrix ( phi ) ( 6 , 0 , 6 , 6 ) == zeroes ( 6 )
	equation submatrix ( phi ) ( 12 , 12 , 6 , 6 ) == identity ( 6 )
	equation submatrix ( phi ) ( 12 , 0 , 6 , 6 ) == Phi ( 3 , 1 , B_k )
	equation submatrix ( phi ) ( 12 , 6 , 6 , 6 ) == Phi ( 3 , 2 , B_k )
	equation B_k == < B_1 , B_2 , B_3 >
	equation X_T == < X_T_1 , X_T_2 , X_T_3 >
	equation X_J == < X_J_1 , X_J_2 >
	equation T_geom == < T_geom_1 , T_geom_2 , T_geom_3 >
	equation T_offset == < T_offset_1 , T_offset_2 , T_offset_3 >
	equation V == adj ( phi ) * adj ( H ) * derivative ( theta )
	equation alpha == adj ( phi ) * ( adj ( H ) * derivative ( derivative ( theta ) ) + a )
	equation f == phi * ( M * alpha + b )
	equation tau == M_mass * derivative ( derivative ( theta ) ) + C
	equation M_mass == H * phi * M * adj ( phi ) * adj ( H )
	equation C == H * phi * ( M * adj ( phi ) * a + b )
	equation B_1 == B_3 * T_3_1
	equation B_2 == B_3 * T_3_2
	equation N == r_v1 + r_v2
	Constraint ( submatrix ( M ) ( 0 , 0 , 6 , 6 ) ) [ t == 0 ] == M_1
	Constraint ( submatrix ( M ) ( 6 , 6 , 6 , 6 ) ) [ t == 0 ] == M_2
	Constraint ( submatrix ( M ) ( 12 , 12 , 6 , 6 ) ) [ t == 0 ] == M_3
	Constraint ( submatrix ( H ) ( 0 , 0 , 1 , 6 ) ) [ t == 0 ] == H_1
	Constraint ( submatrix ( H ) ( 1 , 6 , 1 , 6 ) ) [ t == 0 ] == H_2
}

datatype LaserScan{
	angle_min: real
	angle_max: real
	angle_increment: real
	time_increment: real
	scan_time: real
	range_min: real
	range_max: real
	ranges: Seq(real)
	intensities: Seq(real)
}

sensor Lidar {
	const PI: real = 3.141592653589793
	const e: real = 2.718281828459045
	input trueDistance: real
	input measuredDistance: real
	input range_max: real
	input w_hit: real
	input w_short: real
	input w_max: real
	input w_rand: real
	input sigma_hit: real
	input lambda_short: real
	input angle_min: real
	output scan: LaserScan
	output measurement: real
	output closestDistance: real
	output closestAngle: real
	local p_hit: real
	local p_short: real
	local p_rand: real
	local p_max: real
	local eta1: real
	local eta2: real
	local N: real
	equation w_hit + w_short + w_max + w_rand == 1
	equation N == 1/(sqrt(2*PI*sigma_hit^2))*e^(-(0.5/sigma_hit^2)*(measuredDistance - trueDistance)^2)
	equation eta1 == (integral(N, 0, range_max))^-1
	equation eta2 == 1/(1- e^(-lambda_short*trueDistance))
	equation p_hit == ind(measuredDistance, 0, range_max)*eta1*N
	equation p_short == ind(measuredDistance, 0, trueDistance)*eta2*lambda_short*e^(-lambda_short*measuredDistance)
	equation p_max == ind(measuredDistance, range_max, range_max)
	equation p_rand == ind(measuredDistance, 0, range_max)*1/range_max
	equation measurement == w_hit*p_hit + w_short*p_short + w_max*p_max + w_rand*p_rand
	equation closestDistance == measuredDistance
	equation closestAngle == angle_min
	// Provide a minimal scan message that carries the measured distance as a single-beam range
	equation scan.angle_min == angle_min
	equation scan.angle_max == 0.0
	equation scan.angle_increment == 0.0
	equation scan.time_increment == 0.0
	equation scan.scan_time == 0.0
	equation scan.range_min == 0.0
	equation scan.range_max == range_max
	equation scan.ranges == <measuredDistance>
	equation scan.intensities == <0.0>
}

sensor IMU {
	input angularRateAV: real
	input angularRateLV: real
	output currentLV: real
	output currentAV: real
}
datatype Geom { geomType : string geomVal : vector ( real ) meshUri : string meshScale : vector ( real ) }


function ind(z_t: real, lower: real, upper: real): real {
	precondition lower <= upper
	postcondition result == if z_t >= lower /\ z_t <= upper then 1 else 0 end
}
function identity ( size : real ) : matrix ( real , 6 , 6 ) { } function zeroes ( size : real ) : matrix ( real , 6 , 6 ) { } function Phi ( m : real , n : real , B_k : Seq( matrix ( real , 4 , 4 ) ) ) : matrix ( real , 6 , 6 ) { } function zeroVec ( a : real ) : vector ( real , 1 ) { } function zeroMat ( a : real , b : real ) : matrix ( real , 0 , 0 ) { } function skew ( v : vector ( real , 3 ) ) : matrix ( real , 3 , 3 ) { } function getFramePosition ( k : real , B_n : Seq( matrix ( real , 4 , 4 ) ) ) : vector ( real , 3 ) { }
