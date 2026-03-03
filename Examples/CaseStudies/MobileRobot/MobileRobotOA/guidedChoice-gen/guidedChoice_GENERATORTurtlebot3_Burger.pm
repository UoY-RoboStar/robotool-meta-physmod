import physmod::math::* import physmod::SKO::joints::Revolute_y import physmod::trivial::actuators::ControlledMotor pmodel Turtlebot3_Burger {
	local link BaseLink {
		def {
			InOut geom_31 : Geom = Geom (| geomType = "mesh" , geomVal = [| 0.0 |] , meshUri = "meshes/bases/burger_base.stl" , meshScale = [| 0.001 |] |)
			InOut L3_geom : Geom = Geom (| geomType = "mesh" , geomVal = [| 0.0 |] , meshUri = "meshes/bases/burger_base.stl" , meshScale = [| 0.001 |] |)
			InOut B_3 : matrix ( real , 4 , 4 )
			InOut M_3 : matrix ( real , 6 , 6 )
			InOut a_3 : vector ( real , 6 )
			InOut b_3 : vector ( real , 6 )
			InOut T_offset_3 : matrix ( real , 4 , 4 )
			local number : real = 3
			local poseVec : vector ( real , 6 ) = [| 0.0 , 0.0 , 0.01 , 0.0 , 0.0 , 0.0 |]
			Constraint ( B_3 ) [ t == 0 ] == [| 1.000000 , 0.000000 , 0.000000 , 0.000000 ; 0.000000 , 1.000000 , 0.000000 , 0.000000 ; - 0.000000 , 0.000000 , 1.000000 , 0.009999999776482582 ; 0 , 0 , 0 , 1 |]
			Constraint ( T_offset_3 ) [ t == 0 ] == [| 1.0 , 0.0 , 0.0 , 0.0 ; 0.0 , 1.0 , 0.0 , 0.0 ; 0.0 , 0.0 , 1.0 , 0.009999999776482582 ; 0 , 0 , 0 , 1 |]
		}
		local body Chassis {
			def {
				inertial information {
					mass 0.82573504
					inertia matrix { ixx 0.72397393 ixy 0.0000000004686399 ixz - 0.0000000109525703 iyy 0.72397393 iyz 0.0000000028582649 izz 0.653050163 }
					pose {
						x = - 0.032 y = 0.0 z = 0.070 roll = 0.0 pitch = 0.0 yaw = 0.0 }
				}
				mesh { scaling 0.001
				shape "meshes/bases/burger_base.stl"
					}
				local number : real = 0
			}
			pose {
				x = - 0.032 y = 0.0 z = 0.070 roll = 0.0 pitch = 0.0 yaw = 0.0 }
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
				const PI : real = 3.1415927
				const e : real = 2.7182817
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
		local joint LeftWheelJoint {
			def {
				InOut theta : real
				InOut XJ : matrix ( real , 6 , 6 )
				InOut H_1 : matrix ( real , 1 , 6 )
				InOut T_3_1 : matrix ( real , 4 , 4 )
				InOut theta_1 : real
				InOut tau_1 : real
				local number : real = 1
				local poseVec : vector ( real , 6 ) = [| 0.0 , 0.08 , 0.0 , 0.0 , 0.0 , 0.0 |]
				const H : vector ( real , 6 ) = (| 0 , 1 , 0 , 0 , 0 , 0 |)
				equation XJ == [| cos ( theta ) , 0 , sin ( theta ) , 0 , 0 , 0 ; 0 , 1 , 0 , 0 , 0 , 0 ; - sin ( theta ) , 0 , cos ( theta ) , 0 , 0 , 0 ; 0 , 0 , 0 , cos ( theta ) , 0 , sin ( theta ) ; 0 , 0 , 0 , 0 , 1 , 0 ; 0 , 0 , 0 , - sin ( theta ) , 0 , cos ( theta ) |]
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
				z = 0.0
				roll = 0.0
				pitch = 0.0
				yaw = 0.0
			}
			relation H_1 == LeftWheelJoint . H_1 /\ T_3_1 == LeftWheelJoint . T_3_1 /\ theta [ 0 ] == LeftWheelJoint . theta_1 /\ tau [ 0 ] == LeftWheelJoint . tau_1
		}
		local joint RightWheelJoint {
			def {
				InOut theta : real
				InOut XJ : matrix ( real , 6 , 6 )
				InOut H_2 : matrix ( real , 1 , 6 )
				InOut T_3_2 : matrix ( real , 4 , 4 )
				InOut theta_2 : real
				InOut tau_2 : real
				local number : real = 2
				local poseVec : vector ( real , 6 ) = [| 0.0 , - 0.08 , 0.0 , 0.0 , 0.0 , 0.0 |]
				const H : vector ( real , 6 ) = (| 0 , 1 , 0 , 0 , 0 , 0 |)
				equation XJ == [| cos ( theta ) , 0 , sin ( theta ) , 0 , 0 , 0 ; 0 , 1 , 0 , 0 , 0 , 0 ; - sin ( theta ) , 0 , cos ( theta ) , 0 , 0 , 0 ; 0 , 0 , 0 , cos ( theta ) , 0 , sin ( theta ) ; 0 , 0 , 0 , 0 , 1 , 0 ; 0 , 0 , 0 , - sin ( theta ) , 0 , cos ( theta ) |]
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
				z = 0.0
				roll = 0.0
				pitch = 0.0
				yaw = 0.0
			}
			relation H_2 == RightWheelJoint . H_2 /\ T_3_2 == RightWheelJoint . T_3_2 /\ theta [ 1 ] == RightWheelJoint . theta_2 /\ tau [ 1 ] == RightWheelJoint . tau_2
		}
		pose {
			x = 0.0 y = 0.0 z = 0.010 roll = 0.0 pitch = 0.0 yaw = 0.0 }
		relation B_3 == BaseLink . B_3 /\ M_3 == BaseLink . M_3 /\ a [ 2 ] == BaseLink . a_3 /\ b [ 2 ] == BaseLink . b_3
	}
	local link LeftWheel {
		def {
			InOut geom_11 : Geom = Geom (| geomType = "mesh" , geomVal = [| 0.0 |] , meshUri = "meshes/wheels/left_tire.stl" , meshScale = [| 0.001 |] |)
			InOut L1_geom : Geom = Geom (| geomType = "mesh" , geomVal = [| 0.0 |] , meshUri = "meshes/wheels/left_tire.stl" , meshScale = [| 0.001 |] |)
			InOut B_1 : matrix ( real , 4 , 4 )
			InOut M_1 : matrix ( real , 6 , 6 )
			InOut a_1 : vector ( real , 6 )
			InOut b_1 : vector ( real , 6 )
			InOut T_offset_1 : matrix ( real , 4 , 4 )
			local number : real = 1
			local poseVec : vector ( real , 6 ) = [| 0.0 , 0.08 , 0.023 , 0.0 , 0.0 , 0.0 |]
			Constraint ( B_1 ) [ t == 0 ] == [| 1.000000 , 0.000000 , 0.000000 , 0.000000 ; 0.000000 , 1.000000 , 0.000000 , 0.000000 ; - 0.000000 , 0.000000 , 1.000000 , 0.023000000044703484 ; 0 , 0 , 0 , 1 |]
			Constraint ( T_offset_1 ) [ t == 0 ] == [| 1.0 , 0.0 , 0.0 , 0.0 ; 0.0 , 1.0 , 0.0 , 0.0 ; 0.0 , 0.0 , 1.0 , 0.023000000044703484 ; 0 , 0 , 0 , 1 |]
		}
		local body Wheel {
			def {
				inertial information {
					mass 0.02849894
					inertia matrix { ixx 0.0018158194 ixy - 0.0000000000093392 ixz 0.0000000000104909 iyy 0.0032922126 iyz 0.0000000000575694 izz 0.0018158194 }
					pose {
						x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
				}
				mesh { scaling 0.001
				shape "meshes/wheels/left_tire.stl"
					}
				local number : real = 0
			}
			pose {
				x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
		}
		pose {
			x = 0.0 y = 0.08 z = 0.023 roll = 0.0 pitch = 0.0 yaw = 0.0 }
		relation B_1 == LeftWheel . B_1 /\ M_1 == LeftWheel . M_1 /\ a [ 0 ] == LeftWheel . a_1 /\ b [ 0 ] == LeftWheel . b_1
	}
	local link RightWheel {
		def {
			InOut geom_21 : Geom = Geom (| geomType = "mesh" , geomVal = [| 0.0 |] , meshUri = "meshes/wheels/right_tire.stl" , meshScale = [| 0.001 |] |)
			InOut L2_geom : Geom = Geom (| geomType = "mesh" , geomVal = [| 0.0 |] , meshUri = "meshes/wheels/right_tire.stl" , meshScale = [| 0.001 |] |)
			InOut B_2 : matrix ( real , 4 , 4 )
			InOut M_2 : matrix ( real , 6 , 6 )
			InOut a_2 : vector ( real , 6 )
			InOut b_2 : vector ( real , 6 )
			InOut T_offset_2 : matrix ( real , 4 , 4 )
			local number : real = 2
			local poseVec : vector ( real , 6 ) = [| 0.0 , - 0.08 , 0.023 , 0.0 , 0.0 , 0.0 |]
			Constraint ( B_2 ) [ t == 0 ] == [| 1.000000 , 0.000000 , 0.000000 , 0.000000 ; 0.000000 , 1.000000 , 0.000000 , 0.000000 ; - 0.000000 , 0.000000 , 1.000000 , 0.023000000044703484 ; 0 , 0 , 0 , 1 |]
			Constraint ( T_offset_2 ) [ t == 0 ] == [| 1.0 , 0.0 , 0.0 , 0.0 ; 0.0 , 1.0 , 0.0 , 0.0 ; 0.0 , 0.0 , 1.0 , 0.023000000044703484 ; 0 , 0 , 0 , 1 |]
		}
		local body Wheel {
			def {
				inertial information {
					mass 0.02849894
					inertia matrix { ixx 0.0018158194 ixy - 0.0000000000093392 ixz 0.0000000000104909 iyy 0.0032922126 iyz 0.0000000000575694 izz 0.0018158194 }
					pose {
						x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
				}
				mesh { scaling 0.001
				shape "meshes/wheels/right_tire.stl"
					}
				local number : real = 0
			}
			pose {
				x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
		}
		pose {
			x = 0.0 y = - 0.08 z = 0.023 roll = 0.0 pitch = 0.0 yaw = 0.0 }
		relation B_2 == RightWheel . B_2 /\ M_2 == RightWheel . M_2 /\ a [ 1 ] == RightWheel . a_2 /\ b [ 1 ] == RightWheel . b_2
	}
	InOut n : real = 3
	InOut nTree : real = 2
	InOut B_k : Seq( matrix ( real , 4 , 4 ) )
	InOut T_offset : Seq( matrix ( real , 4 , 4 ) )
	InOut phi : matrix ( real , 18 , 18 )
	InOut M : matrix ( real , 18 , 18 )
	InOut H : matrix ( real , 2 , 18 )
	InOut theta : vector ( real , 2 )
	InOut tau : vector ( real , 2 )
	InOut V : vector ( real , 18 )
	InOut alpha : vector ( real , 18 )
	InOut a : vector ( real , 18 )
	InOut b : vector ( real , 18 )
	InOut f : vector ( real , 18 )
	InOut M_mass : matrix ( real , 2 , 2 )
	InOut C : vector ( real , 2 )
	InOut B_3 : matrix ( real , 4 , 4 )
	InOut M_3 : matrix ( real , 6 , 6 )
	InOut T_offset_3 : matrix ( real , 4 , 4 )
	InOut B_1 : matrix ( real , 4 , 4 )
	InOut M_1 : matrix ( real , 6 , 6 )
	InOut T_offset_1 : matrix ( real , 4 , 4 )
	InOut B_2 : matrix ( real , 4 , 4 )
	InOut M_2 : matrix ( real , 6 , 6 )
	InOut T_offset_2 : matrix ( real , 4 , 4 )
	InOut H_1 : matrix ( real , 1 , 6 )
	InOut T_3_1 : matrix ( real , 4 , 4 )
	InOut H_2 : matrix ( real , 1 , 6 )
	InOut T_3_2 : matrix ( real , 4 , 4 )
	local u : vector ( real , 2 )
	local B_ctrl : matrix ( real , 2 , 2 )
	local d_theta : vector ( real , 2 )
	local dd_theta : vector ( real , 2 )
	local N : real
	local M_inv : matrix ( real , 2 , 2 )
	local tau_d : vector ( real , 2 )
	local damping : matrix ( real , 2 , 2 )
	local dt : real
	local X_J : Seq( matrix ( real , 6 , 6 ) )
	local X_T : Seq( matrix ( real , 6 , 6 ) )
	local T_geom : Seq( matrix ( real , 4 , 4 ) )
	local L_k_geom : Seq( Geom )
	local X_J_1 : matrix ( real , 6 , 6 )
	local X_J_2 : matrix ( real , 6 , 6 )
	local X_T_1 : matrix ( real , 6 , 6 )
	local X_T_2 : matrix ( real , 6 , 6 )
	local X_T_3 : matrix ( real , 6 , 6 )
	local L1_geom : Geom
	local L2_geom : Geom
	local L3_geom : Geom
	local T_geom_1 : matrix ( real , 4 , 4 )
	local T_geom_2 : matrix ( real , 4 , 4 )
	local T_geom_3 : matrix ( real , 4 , 4 )
	local X_J_k : Seq( matrix ( real , 6 , 6 ) )
	equation B_1 == B_3 * T_3_1
	equation B_2 == B_3 * T_3_2
	equation B_k == < B_1 , B_2 , B_3 >
	equation T_offset == < T_offset_1 , T_offset_2 , T_offset_3 >
	equation submatrix ( phi ) ( 0 , 0 , 6 , 6 ) == Identity ( 6 )
	equation submatrix ( phi ) ( 0 , 6 , 6 , 6 ) == zeroMat ( 6 , 6 )
	equation submatrix ( phi ) ( 0 , 12 , 6 , 6 ) == zeroMat ( 6 , 6 )
	equation submatrix ( phi ) ( 6 , 0 , 6 , 6 ) == zeroMat ( 6 , 6 )
	equation submatrix ( phi ) ( 6 , 6 , 6 , 6 ) == Identity ( 6 )
	equation submatrix ( phi ) ( 6 , 12 , 6 , 6 ) == zeroMat ( 6 , 6 )
	equation submatrix ( phi ) ( 12 , 0 , 6 , 6 ) == zeroMat ( 6 , 6 )
	equation submatrix ( phi ) ( 12 , 6 , 6 , 6 ) == zeroMat ( 6 , 6 )
	equation submatrix ( phi ) ( 12 , 12 , 6 , 6 ) == Identity ( 6 )
	equation submatrix ( H ) ( 0 , 0 , 1 , 6 ) == H_1
	equation submatrix ( H ) ( 1 , 6 , 1 , 6 ) == H_2
	equation V == adj ( phi ) * adj ( H ) * derivative ( theta )
	equation alpha == adj ( phi ) * ( adj ( H ) * derivative ( derivative ( theta ) ) + a )
	equation f == phi * ( M * alpha + b )
	equation M_mass == H * phi * M * adj ( phi ) * adj ( H )
	equation C == H * phi * ( M * adj ( phi ) * a + b )
	equation tau == M_mass * derivative ( derivative ( theta ) ) + C
	equation tau == H * f
	Constraint ( n ) [ t == 0 ] == 3
	Constraint ( nTree ) [ t == 0 ] == 2
	Constraint ( submatrix ( M ) ( 0 , 0 , 6 , 6 ) ) [ t == 0 ] == M_1
	Constraint ( submatrix ( M ) ( 6 , 6 , 6 , 6 ) ) [ t == 0 ] == M_2
	Constraint ( submatrix ( M ) ( 12 , 12 , 6 , 6 ) ) [ t == 0 ] == M_3
solution { solutionExpr u : vector ( real , 2 ) order 0 group 0 method PlatformMapping Input u : vector ( real , 2 ) Input n : real Constraint ( n ) [ t == 0 ] == 3 Constraint ( u ) [ t == 0 ] == zeroVec ( 2 ) }
	solution { solutionExpr tau : vector ( real , 2 ) order 1 group 0 method ControlledActuator Input B_ctrl : matrix ( real , 2 , 2 ) Input u : vector ( real , 2 ) Input tau : vector ( real , 2 ) Input n : real Constraint ( n ) [ t == 0 ] == 3 Constraint ( tau ) [ t == 0 ] == zeroVec ( 2 ) Constraint ( tau ) [ t == t ] == B_ctrl * u }
	solution { solutionExpr phi : matrix ( real , 18 , 18 ) order 2 group 0 method Eval Input B_1 : matrix ( real , 4 , 4 ) Input B_2 : matrix ( real , 4 , 4 ) Input B_3 : matrix ( real , 4 , 4 ) Input B_k : Seq( matrix ( real , 4 , 4 ) ) Input n : real Constraint ( n ) [ t == 0 ] == 3 Constraint ( n ) [ t == 0 ] == 3 Constraint ( B_1 ) [ t == 0 ] == [| 1.0 , 0.0 , 0.0 , 0.0 ; 0.0 , 1.0 , 0.0 , 0.0 ; - 0.0 , 0.0 , 1.0 , 0.023 ; 0 , 0 , 0 , 1 |] Constraint ( B_2 ) [ t == 0 ] == [| 1.0 , 0.0 , 0.0 , 0.0 ; 0.0 , 1.0 , 0.0 , 0.0 ; - 0.0 , 0.0 , 1.0 , 0.023 ; 0 , 0 , 0 , 1 |] Constraint ( B_3 ) [ t == 0 ] == [| 1.0 , 0.0 , 0.0 , 0.0 ; 0.0 , 1.0 , 0.0 , 0.0 ; - 0.0 , 0.0 , 1.0 , 0.01 ; 0 , 0 , 0 , 1 |] Constraint ( B_k ) [ t == 0 ] == < B_1 , B_2 , B_3 > Constraint ( phi ) [ t == 0 ] == zeroMat ( 18 , 18 ) }
	solution { solutionExpr C : vector ( real , 2 ) order 3 group 0 method NewtonEulerInverseDynamics_gravity Input M_1 : matrix ( real , 6 , 6 ) Input M_2 : matrix ( real , 6 , 6 ) Input M_3 : matrix ( real , 6 , 6 ) Input n : real Input theta : vector ( real , 2 ) Input phi : matrix ( real , 18 , 18 ) Input H : matrix ( real , 2 , 18 ) Input d_theta : vector ( real , 2 ) Input dd_theta : vector ( real , 2 ) Input alpha : vector ( real , 18 ) Input V : vector ( real , 18 ) Input a : vector ( real , 18 ) Input b : vector ( real , 18 ) Input f : vector ( real , 18 ) Input M : matrix ( real , 18 , 18 ) Input N : real Input H_1 : matrix ( real , 1 , 6 ) Input H_2 : matrix ( real , 1 , 6 ) Constraint ( n ) [ t == 0 ] == 3 Constraint ( M_1 ) [ t == 0 ] == zeroMat ( 6 , 6 ) Constraint ( submatrix ( M ) ( 0 , 0 , 6 , 6 ) ) [ t == 0 ] == M_1 Constraint ( submatrix ( H ) ( 0 , 0 , 1 , 6 ) ) [ t == 0 ] == H_1 Constraint ( M_2 ) [ t == 0 ] == zeroMat ( 6 , 6 ) Constraint ( submatrix ( M ) ( 6 , 6 , 6 , 6 ) ) [ t == 0 ] == M_2 Constraint ( submatrix ( H ) ( 1 , 6 , 1 , 6 ) ) [ t == 0 ] == H_2 Constraint ( M_3 ) [ t == 0 ] == zeroMat ( 6 , 6 ) Constraint ( submatrix ( M ) ( 12 , 12 , 6 , 6 ) ) [ t == 0 ] == M_3 Constraint ( C ) [ t == 0 ] == zeroVec ( 2 ) Constraint ( N ) [ t == 0 ] == 2 Constraint ( phi ) [ t == 0 ] == zeroMat ( 18 , 18 ) Constraint ( H ) [ t == 0 ] == zeroMat ( 2 , 18 ) Constraint ( theta ) [ t == 0 ] == zeroVec ( 2 ) Constraint ( d_theta ) [ t == 0 ] == zeroVec ( 2 ) Constraint ( dd_theta ) [ t == 0 ] == zeroVec ( 2 ) Constraint ( alpha ) [ t == 0 ] == zeroVec ( 18 ) Constraint ( V ) [ t == 0 ] == zeroVec ( 18 ) Constraint ( a ) [ t == 0 ] == zeroVec ( 18 ) Constraint ( b ) [ t == 0 ] == zeroVec ( 18 ) Constraint ( f ) [ t == 0 ] == zeroVec ( 18 ) }
	solution { solutionExpr M_mass : matrix ( real , 2 , 2 ) order 4 group 0 method CompositeBodyAlgorithm Input M_1 : matrix ( real , 6 , 6 ) Input M_2 : matrix ( real , 6 , 6 ) Input M_3 : matrix ( real , 6 , 6 ) Input H : matrix ( real , 2 , 18 ) Input phi : matrix ( real , 18 , 18 ) Input n : real Input M : matrix ( real , 18 , 18 ) Input H_1 : matrix ( real , 1 , 6 ) Input H_2 : matrix ( real , 1 , 6 ) Constraint ( n ) [ t == 0 ] == 3 Constraint ( M_1 ) [ t == 0 ] == zeroMat ( 6 , 6 ) Constraint ( submatrix ( M ) ( 0 , 0 , 6 , 6 ) ) [ t == 0 ] == M_1 Constraint ( submatrix ( H ) ( 0 , 0 , 1 , 6 ) ) [ t == 0 ] == H_1 Constraint ( M_2 ) [ t == 0 ] == zeroMat ( 6 , 6 ) Constraint ( submatrix ( M ) ( 6 , 6 , 6 , 6 ) ) [ t == 0 ] == M_2 Constraint ( submatrix ( H ) ( 1 , 6 , 1 , 6 ) ) [ t == 0 ] == H_2 Constraint ( M_3 ) [ t == 0 ] == zeroMat ( 6 , 6 ) Constraint ( submatrix ( M ) ( 12 , 12 , 6 , 6 ) ) [ t == 0 ] == M_3 Constraint ( M_mass ) [ t == 0 ] == zeroMat ( 2 , 2 ) Constraint ( phi ) [ t == 0 ] == zeroMat ( 18 , 18 ) Constraint ( H ) [ t == 0 ] == zeroMat ( 2 , 18 ) }
	solution { solutionExpr M_inv : matrix ( real , 2 , 2 ) order 5 group 0 method CholeskyAlgorithm Input M_mass : matrix ( real , 2 , 2 ) Input N : real Input n : real Constraint ( n ) [ t == 0 ] == 3 Constraint ( N ) [ t == 0 ] == 2 Constraint ( M_mass ) [ t == 0 ] == zeroMat ( 2 , 2 ) Constraint ( M_inv ) [ t == 0 ] == zeroMat ( 2 , 2 ) }
	solution { solutionExpr tau_d : vector ( real , 2 ) order 6 group 0 method ViscousDamping Input damping : matrix ( real , 2 , 2 ) Input d_theta : vector ( real , 2 ) Input dt : real Input n : real Constraint ( n ) [ t == 0 ] == 3 Constraint ( tau_d ) [ t == 0 ] == zeroVec ( 2 ) Constraint ( damping ) [ t == 0 ] == zeroMat ( 2 , 2 ) Constraint ( tau_d ) [ t == 0 ] == zeroVec ( 2 ) Constraint ( damping ) [ t == 0 ] == zeroMat ( 2 , 2 ) }
	solution { solutionExpr dd_theta : vector ( real , 2 ) order 7 group 0 method DirectForwardDynamics Input n : real Input tau : vector ( real , 2 ) Input M_inv : matrix ( real , 2 , 2 ) Input C : vector ( real , 2 ) Constraint ( n ) [ t == 0 ] == 3 Constraint ( n ) [ t == 0 ] == 3 Constraint ( M_inv ) [ t == 0 ] == zeroMat ( 2 , 2 ) Constraint ( tau ) [ t == 0 ] == zeroVec ( 2 ) Constraint ( dd_theta ) [ t == 0 ] == zeroVec ( 2 ) Constraint ( C ) [ t == 0 ] == zeroVec ( 2 ) }
	solution { solutionExpr d_theta : vector ( real , 2 ) order 8 group 0 method Euler Input dd_theta : vector ( real , 2 ) Input dt : real Constraint ( dd_theta ) [ t == 0 ] == zeroVec ( 2 ) Constraint ( dt ) [ t == 0 ] == 0.01 Constraint ( d_theta ) [ t == 0 ] == zeroVec ( 2 ) Constraint ( dd_theta ) [ t == 0 ] == zeroVec ( 2 ) }
	solution { solutionExpr theta : vector ( real , 2 ) order 9 group 0 method Euler Input d_theta : vector ( real , 2 ) Input dt : real Input n : real Constraint ( theta ) [ t == 0 ] == [| 0.0 ; 0.0 |] Constraint ( n ) [ t == 0 ] == 3 Constraint ( d_theta ) [ t == 0 ] == 0 Constraint ( dt ) [ t == 0 ] == 0.01 }
	solution { solutionExpr B_k : Seq( matrix ( real , 4 , 4 ) ) order 3 group 0 method ForwardKinematics Input B_k : Seq( matrix ( real , 4 , 4 ) ) Input X_J : Seq( matrix ( real , 6 , 6 ) ) Input X_T : Seq( matrix ( real , 6 , 6 ) ) Input n : real Input theta : vector ( real , 2 ) Input B_1 : matrix ( real , 4 , 4 ) Input B_2 : matrix ( real , 4 , 4 ) Input B_3 : matrix ( real , 4 , 4 ) Input X_J_1 : matrix ( real , 6 , 6 ) Input X_J_2 : matrix ( real , 6 , 6 ) Input X_T_1 : matrix ( real , 6 , 6 ) Input X_T_2 : matrix ( real , 6 , 6 ) Input X_T_3 : matrix ( real , 6 , 6 ) Constraint ( n ) [ t == 0 ] == 3 Constraint ( n ) [ t == 0 ] == 3 Constraint ( B_1 ) [ t == 0 ] == [| 1.0 , 0.0 , 0.0 , 0.0 ; 0.0 , 1.0 , 0.0 , 0.0 ; - 0.0 , 0.0 , 1.0 , 0.023 ; 0 , 0 , 0 , 1 |] Constraint ( B_2 ) [ t == 0 ] == [| 1.0 , 0.0 , 0.0 , 0.0 ; 0.0 , 1.0 , 0.0 , 0.0 ; - 0.0 , 0.0 , 1.0 , 0.023 ; 0 , 0 , 0 , 1 |] Constraint ( B_3 ) [ t == 0 ] == [| 1.0 , 0.0 , 0.0 , 0.0 ; 0.0 , 1.0 , 0.0 , 0.0 ; - 0.0 , 0.0 , 1.0 , 0.01 ; 0 , 0 , 0 , 1 |] Constraint ( X_J_1 ) [ t == 0 ] == zeroMat ( 6 , 6 ) Constraint ( X_J_1 ) [ t == t ] == zeroMat ( 6 , 6 ) Constraint ( X_J_2 ) [ t == 0 ] == zeroMat ( 6 , 6 ) Constraint ( X_J_2 ) [ t == t ] == zeroMat ( 6 , 6 ) Constraint ( X_T_1 ) [ t == 0 ] == identity ( 6 , 6 ) Constraint ( X_T_2 ) [ t == 0 ] == identity ( 6 , 6 ) Constraint ( X_T_3 ) [ t == 0 ] == identity ( 6 , 6 ) Constraint ( B_k ) [ t == 0 ] == < B_1 , B_2 , B_3 > Constraint ( X_J ) [ t == 0 ] == < X_J_1 , X_J_2 > Constraint ( X_J ) [ t == t ] == < X_J_1 , X_J_2 > Constraint ( X_T ) [ t == 0 ] == < X_T_1 , X_T_2 , X_T_3 > }
	solution { solutionExpr T_geom : Seq( matrix ( real , 4 , 4 ) ) order 4 group 0 method Visualisation Input B_k : Seq( matrix ( real , 4 , 4 ) ) Input T_offset : Seq( matrix ( real , 4 , 4 ) ) Input B_1 : matrix ( real , 4 , 4 ) Input T_offset_1 : matrix ( real , 4 , 4 ) Input B_2 : matrix ( real , 4 , 4 ) Input T_offset_2 : matrix ( real , 4 , 4 ) Input B_3 : matrix ( real , 4 , 4 ) Input T_offset_3 : matrix ( real , 4 , 4 ) Input n : real Constraint ( n ) [ t == 0 ] == 3 Constraint ( n ) [ t == 0 ] == 3 Constraint ( T_geom_1 ) [ t == 0 ] == zeroMat ( 4 , 4 ) Constraint ( T_geom_2 ) [ t == 0 ] == zeroMat ( 4 , 4 ) Constraint ( T_geom_3 ) [ t == 0 ] == zeroMat ( 4 , 4 ) Constraint ( T_geom_1 ) [ t == t ] == B_1 * T_offset_1 Constraint ( T_geom_2 ) [ t == t ] == B_2 * T_offset_2 Constraint ( T_geom_3 ) [ t == t ] == B_3 * T_offset_3 Constraint ( T_geom ) [ t == t ] == < T_geom_1 , T_geom_2 , T_geom_3 > }
	solution { solutionExpr L_k_geom : Seq( Geom ) order 5 group 0 method Visual Input B_1 : matrix ( real , 4 , 4 ) Input B_2 : matrix ( real , 4 , 4 ) Input B_3 : matrix ( real , 4 , 4 ) Input L1_geom : Geom Input L2_geom : Geom Input L3_geom : Geom Input B_k : Seq( matrix ( real , 4 , 4 ) ) Input T_geom : Seq( matrix ( real , 4 , 4 ) ) Input T_offset : Seq( matrix ( real , 4 , 4 ) ) Input T_geom_1 : matrix ( real , 4 , 4 ) Input T_offset_1 : matrix ( real , 4 , 4 ) Input T_geom_2 : matrix ( real , 4 , 4 ) Input T_offset_2 : matrix ( real , 4 , 4 ) Input T_geom_3 : matrix ( real , 4 , 4 ) Input T_offset_3 : matrix ( real , 4 , 4 ) Input X_J_k : Seq( matrix ( real , 6 , 6 ) ) Input theta : vector ( real , 2 ) Input H_1 : matrix ( real , 1 , 6 ) Input H_2 : matrix ( real , 1 , 6 ) Input X_J_1 : matrix ( real , 6 , 6 ) Input X_J_2 : matrix ( real , 6 , 6 ) Input n : real Input H : matrix ( real , 2 , 18 ) Constraint ( n ) [ t == 0 ] == 3 Constraint ( n ) [ t == 0 ] == 3 Constraint ( B_1 ) [ t == 0 ] == [| 1.0 , 0.0 , 0.0 , 0.0 ; 0.0 , 1.0 , 0.0 , 0.0 ; - 0.0 , 0.0 , 1.0 , 0.023 ; 0 , 0 , 0 , 1 |] Constraint ( B_2 ) [ t == 0 ] == [| 1.0 , 0.0 , 0.0 , 0.0 ; 0.0 , 1.0 , 0.0 , 0.0 ; - 0.0 , 0.0 , 1.0 , 0.023 ; 0 , 0 , 0 , 1 |] Constraint ( B_3 ) [ t == 0 ] == [| 1.0 , 0.0 , 0.0 , 0.0 ; 0.0 , 1.0 , 0.0 , 0.0 ; - 0.0 , 0.0 , 1.0 , 0.01 ; 0 , 0 , 0 , 1 |] Constraint ( B_k ) [ t == 0 ] == < B_1 , B_2 , B_3 > Constraint ( T_offset_1 ) [ t == 0 ] == [| 1.0 , 0.0 , 0.0 , 0.0 ; 0.0 , 1.0 , 0.0 , 0.0 ; 0.0 , 0.0 , 1.0 , 0.023 ; 0 , 0 , 0 , 1 |] Constraint ( T_offset_2 ) [ t == 0 ] == [| 1.0 , 0.0 , 0.0 , 0.0 ; 0.0 , 1.0 , 0.0 , 0.0 ; 0.0 , 0.0 , 1.0 , 0.023 ; 0 , 0 , 0 , 1 |] Constraint ( T_offset_3 ) [ t == 0 ] == [| 1.0 , 0.0 , 0.0 , 0.0 ; 0.0 , 1.0 , 0.0 , 0.0 ; 0.0 , 0.0 , 1.0 , 0.01 ; 0 , 0 , 0 , 1 |] Constraint ( T_geom_1 ) [ t == t ] == B_1 * T_offset_1 Constraint ( T_geom_2 ) [ t == t ] == B_2 * T_offset_2 Constraint ( T_geom_3 ) [ t == t ] == B_3 * T_offset_3 Constraint ( T_geom ) [ t == t ] == < T_geom_1 , T_geom_2 , T_geom_3 > Constraint ( T_offset ) [ t == 0 ] == < T_offset_1 , T_offset_2 , T_offset_3 > Constraint ( X_J_k ) [ t == 0 ] == < X_J_1 , X_J_2 > Constraint ( X_J_k ) [ t == t ] == < X_J_1 , X_J_2 > Constraint ( H_1 ) [ t == 0 ] == [| 0 , 0 , 1 , 0 , 0 , 0 |] Constraint ( H_2 ) [ t == 0 ] == [| 1 , 0 , 0 , 0 , 0 , 0 |] Constraint ( submatrix ( H ) ( 0 , 0 , 1 , 6 ) ) [ t == 0 ] == H_1 Constraint ( submatrix ( H ) ( 1 , 6 , 1 , 6 ) ) [ t == 0 ] == H_2 Constraint ( theta ) [ t == 0 ] == zeroVec ( 2 ) Constraint ( X_J_1 ) [ t == 0 ] == [| 1.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 ; 0.0 , 1.0 , 0.0 , 0.0 , 0.0 , 0.0 ; 0.0 , 0.0 , 1.0 , 0.0 , 0.0 , 0.0 ; 0.0 , 0.0 , 0.0 , 1.0 , 0.0 , 0.0 ; 0.0 , 0.0 , 0.0 , 0.0 , 1.0 , 0.0 ; 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 1.0 |] Constraint ( X_J_1 ) [ t == t ] == zeroMat ( 6 , 6 ) Constraint ( X_J_2 ) [ t == 0 ] == [| 1.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 ; 0.0 , 1.0 , 0.0 , 0.0 , 0.0 , 0.0 ; 0.0 , 0.0 , 1.0 , 0.0 , 0.0 , 0.0 ; 0.0 , 0.0 , 0.0 , 1.0 , 0.0 , 0.0 ; 0.0 , 0.0 , 0.0 , 0.0 , 1.0 , 0.0 ; 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 1.0 |] Constraint ( X_J_2 ) [ t == t ] == zeroMat ( 6 , 6 ) }
}
record LaserScan {
	angle_min : real
	angle_max : real
	angle_increment : real
	time_increment : real
	scan_time : real
	range_min : real
	range_max : real
	ranges : Seq( real )
	intensities : Seq( real ) } record Geom { geomType : string geomVal : vector ( real ) meshUri : string meshScale : vector ( real ) } sensor Lidar {
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
sensor IMU {
	input angularRateAV : real
	input angularRateLV : real
	output currentLV : real
	output currentAV : real
}
function ind ( z_t : real , lower : real , upper : real ) : real { precondition lower <= upper
	postcondition result == if z_t >= lower /\ z_t <= upper then 1 else 0 end } function Identity ( size : int ) : matrix ( real , 6 , 6 ) { } function zeroMat ( r : int , c : int ) : matrix ( real , 0 , 0 ) { } function zeroVec ( n : int ) : vector ( real , 0 ) { } function Phi ( m : int , n : int , B_k : Seq( matrix ( real , 4 , 4 ) ) ) : matrix ( real , 6 , 6 ) { }