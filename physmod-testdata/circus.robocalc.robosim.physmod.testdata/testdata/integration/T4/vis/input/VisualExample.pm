import  physmod::math::* 
        pmodel SimpleArmSerial {
        InOut N: real = 2
	InOut B_k: Seq(matrix(real,4,4))
	InOut XJ_k: Seq(matrix(real,6,6))
	InOut theta: vector(real,2)
	InOut H: matrix(real,2,18)
	InOut H_1: matrix(real,1,6)
	InOut H_2: matrix(real,1,6)
	InOut XJ_1: matrix(real,6,6)
	InOut XJ_2: matrix(real,6,6)
	InOut B_1: matrix(real,4,4)
	InOut B_2: matrix(real,4,4)
	InOut B_3: matrix(real,4,4)
	InOut L1_geom: Geom
	InOut L2_geom: Geom
	InOut L3_geom: Geom
	InOut Lk_geom: Seq(Geom)
	
	// Geometric constraints (following SKO pattern)
	Constraint (L1_geom.geomType)[t==0] == "box"
	Constraint (L1_geom.geomVal)[t==0] == [|0.5,0.5,0.5|]
	Constraint (L2_geom.geomType)[t==0] == "cylinder"
	Constraint (L2_geom.geomVal)[t==0] == [|0.25,4.0|]
	Constraint (L3_geom.geomType)[t==0] == "box"
	Constraint (L3_geom.geomVal)[t==0] == [|1.0,1.0,0.5|]
	Constraint (Lk_geom)[t==0] == <L1_geom, L2_geom, L3_geom>
	
	// XJ constraints (should be resolved from joint definitions)
	equation XJ_k == < XJ_1 , XJ_2 >
	Constraint ( XJ_1 ) [ t == 0 ] == [| 1.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 ; 0.0 , 1.0 , 0.0 , 0.0 , 0.0 , 0.0 ; 0.0 , 0.0 , 1.0 , 0.0 , 0.0 , 0.0 ; 0.0 , 0.0 , 0.0 , 1.0 , 0.0 , 0.0 ; 0.0 , 0.0 , 0.0 , 0.0 , 1.0 , 0.0 ; 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 1.0 |]
	Constraint ( XJ_2 ) [ t == 0 ] == [| 1.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 ; 0.0 , 1.0 , 0.0 , 0.0 , 0.0 , 0.0 ; 0.0 , 0.0 , 1.0 , 0.0 , 0.0 , 0.0 ; 0.0 , 0.0 , 0.0 , 1.0 , 0.0 , 0.0 ; 0.0 , 0.0 , 0.0 , 0.0 , 1.0 , 0.0 ; 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 1.0 |]
	
	        solution{
                solutionExpr B_k: Seq(matrix(real,4,4))
                order 1
                group 1
                method Visual
        }
	
	local link BaseLink {
		def {
		InOut L3_geom : Geom InOut M_3 : matrix ( real , 6 , 6 ) = [| 10.417 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 ; 0.0 , 16.667 , 0.0 , 0.0 , 0.0 , 0.0 ; 0.0 , 0.0 , 10.417 , 0.0 , 0.0 , 0.0 ; 0.0 , 0.0 , 0.0 , 100.0 , 0.0 , 0.0 ; 0.0 , 0.0 , 0.0 , 0.0 , 100.0 , 0.0 ; 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 100.0 |] InOut a_3 : vector ( real , 6 ) InOut b_3 : vector ( real , 6 ) InOut V_3 : vector ( real , 6 ) InOut alpha_3 : vector ( real , 6 ) InOut f_3 : vector ( real , 6 ) InOut B_3 : matrix ( real , 4 , 4 ) InOut m : real = 100.0 InOut I : matrix ( real , 3 , 3 ) = [| 10.417 , 0.0 , 0.0 ; 0.0 , 16.667 , 0.0 ; 0.0 , 0.0 , 10.417 |] InOut identity : matrix ( real , 3 , 3 ) = [| 1.0 , 0.0 , 0.0 ; 0.0 , 1.0 , 0.0 ; 0.0 , 0.0 , 1.0 |] InOut _f_2 : vector ( real , 6 ) InOut phi_3_2 : matrix ( real , 6 , 6 ) InOut tau_3 : vector ( real , 1 ) local number : real = 3 local poseVec : vector ( real , 6 ) = [| 0.0 , 0.0 , 0.25 , 0.0 , 0.0 , 0.0 |] equation f_3 == phi_3_2 * _f_2 + M_3 * alpha_3 + b_3 equation V_3 == 0 equation alpha_3 == a_3 Constraint ( B_3 ) [ t == 0 ] == [| 1.000000 , 0.000000 , 0.000000 , 0.000000 ; 0.000000 , 1.000000 , 0.000000 , 0.000000 ; - 0.000000 , 0.000000 , 1.000000 , 0.250000 ; 0 , 0 , 0 , 1 |]
		}
		local body BaseLink {
			def {
				inertial information {
					mass 100.0
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
				x = 0.0
				y = 0.0
				z = 0.0
				roll = 0.0
				pitch = 0.0
				yaw = 0.0
			}
		}
		sref BaseSensor = TrivialSensor {
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
				const H : vector ( real , 6 ) , theta_2 : real , XJ : matrix ( real , 6 , 6 )
			InOut B_2 : matrix ( real , 4 , 4 ) InOut B_3 : matrix ( real , 4 , 4 ) InOut _B_3 : matrix ( real , 4 , 4 ) InOut T_3_2 : matrix ( real , 4 , 4 ) InOut V_3 : vector ( real , 6 ) InOut _V_3 : vector ( real , 6 ) InOut alpha_3 : vector ( real , 6 ) InOut _alpha_3 : vector ( real , 6 ) InOut f_2 : vector ( real , 6 ) InOut r_v2 : real = 1 InOut theta_2 : real InOut phi_3_2 : matrix ( real , 6 , 6 ) local number : real = 2 local poseVec : vector ( real , 6 ) = [| 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 |] const H2 : vector ( real , 6 ) = (| 1 , 0 , 0 , 0 , 0 , 0 |) equation H == H2 equation XJ == [| 1 , 0 , 0 , 0 , 0 , 0 ; 0 , cos ( theta_2 ) , - sin ( theta_2 ) , 0 , 0 , 0 ; 0 , sin ( theta_2 ) , cos ( theta_2 ) , 0 , 0 , 0 ; 0 , 0 , 0 , 1 , 0 , 0 ; 0 , 0 , 0 , 0 , cos ( theta_2 ) , - sin ( theta_2 ) ; 0 , 0 , 0 , 0 , sin ( theta_2 ) , cos ( theta_2 ) |] equation _B_3 == B_3 equation _V_3 == V_3 equation _alpha_3 == alpha_3 equation _f_2 == f_2 Constraint ( XJ ) [ t == 0 ] == [| 1.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 ; 0.0 , 1.0 , 0.0 , 0.0 , 0.0 , 0.0 ; 0.0 , 0.0 , 1.0 , 0.0 , 0.0 , 0.0 ; 0.0 , 0.0 , 0.0 , 1.0 , 0.0 , 0.0 ; 0.0 , 0.0 , 0.0 , 0.0 , 1.0 , 0.0 ; 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 1.0 |] }
			flexibly connected to IntermediateLink
			pose {
				x = 0.0
				y = 0.0
				z = 0.0
				roll = 0.0
				pitch = 0.0
				yaw = 0.0
			}
		aref ElbowActuator = TrivialMotor {
				pose {
					x = 0.0
					y = 0.0
					z = 0.0
					roll = 0.0
					pitch = 0.0
					yaw = 0.0
				}
			}
		relation B_3 == ElbowJoint . B_3 /\ V_3 == ElbowJoint . V_3 /\ alpha_3 == ElbowJoint . alpha_3 /\ XJ_2 == ElbowJoint . XJ }
		pose {
				x = 
				
				0.0
				y = 0.0
				z = 0.25
				roll = 0.0
				pitch = 0.0
				yaw = 0.0
			}
	relation B_3 == BaseLink . B_3 /\ V [ 2 ] == BaseLink . V_3 /\ a [ 2 ] == BaseLink . a_3 /\ b [ 2 ] == BaseLink . b_3 /\ alpha [ 2 ] == BaseLink . alpha_3 /\ submatrix ( M ) ( 12 , 12 , 6 , 6 ) == BaseLink . M_3 /\ tau [ 2 ] == BaseLink . tau_3 }
	local link IntermediateLink {
		def {
		input test_2 : vector ( real , 1 ) InOut L2_geom : Geom InOut M_2 : matrix ( real , 6 , 6 ) = [| 1.349 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 ; 0.0 , 1.349 , 0.0 , 0.0 , 0.0 , 0.0 ; 0.0 , 0.0 , 0.0313 , 0.0 , 0.0 , 0.0 ; 0.0 , 0.0 , 0.0 , 1.0 , 0.0 , 0.0 ; 0.0 , 0.0 , 0.0 , 0.0 , 1.0 , 0.0 ; 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 1.0 |] InOut a_2 : vector ( real , 6 ) InOut b_2 : vector ( real , 6 ) InOut V_2 : vector ( real , 6 ) InOut alpha_2 : vector ( real , 6 ) InOut f_2 : vector ( real , 6 ) InOut B_2 : matrix ( real , 4 , 4 ) InOut m : real = 1.0 InOut I : matrix ( real , 3 , 3 ) = [| 1.349 , 0.0 , 0.0 ; 0.0 , 1.349 , 0.0 ; 0.0 , 0.0 , 0.0313 |] InOut identity : matrix ( real , 3 , 3 ) = [| 1.0 , 0.0 , 0.0 ; 0.0 , 1.0 , 0.0 ; 0.0 , 0.0 , 1.0 |] InOut theta_2 : real InOut phi_3_2 : matrix ( real , 6 , 6 ) InOut _V_3 : vector ( real , 6 ) InOut _alpha_3 : vector ( real , 6 ) InOut _B_3 : matrix ( real , 4 , 4 ) InOut T_3_2 : matrix ( real , 4 , 4 ) InOut _f_1 : vector ( real , 6 ) InOut phi_2_1 : matrix ( real , 6 , 6 ) InOut H_2 : vector ( real , 6 ) = (| 1 , 0 , 0 , 0 , 0 , 0 |) InOut r_v2 : real = 1 InOut tau_2 : vector ( real , 1 ) local number : real = 2 local poseVec : vector ( real , 6 ) = [| 0.0 , 0.0 , 2.5 , 0.0 , 0.0 , 0.0 |] equation V_2 == adj ( phi_3_2 ) * _V_3 + adj ( H_2 ) + derivative ( theta_2 ) equation alpha_2 == adj ( phi_3_2 ) * _alpha_3 + adj ( H_2 ) * derivative ( theta_2 ) + a_2 equation tau_2 == H_2 * f_2 equation B_2 == _B_3 * T_3_2 equation f_2 == phi_2_1 * _f_1 + M_2 * alpha_2 + b_2 Constraint ( B_2 ) [ t == 0 ] == [| 1.000000 , 0.000000 , 0.000000 , 0.000000 ; 0.000000 , 1.000000 , 0.000000 , 0.000000 ; - 0.000000 , 0.000000 , 1.000000 , 2.500000 ; 0 , 0 , 0 , 1 |] Constraint ( theta_2 ) [ t == 0 ] == 0
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
				const  H : vector ( real , 6 ) , theta_1 : real , XJ : matrix ( real , 6 , 6 )
			InOut B_1 : matrix ( real , 4 , 4 ) InOut B_2 : matrix ( real , 4 , 4 ) InOut _B_2 : matrix ( real , 4 , 4 ) InOut T_2_1 : matrix ( real , 4 , 4 ) InOut V_2 : vector ( real , 6 ) InOut _V_2 : vector ( real , 6 ) InOut alpha_2 : vector ( real , 6 ) InOut _alpha_2 : vector ( real , 6 ) InOut f_1 : vector ( real , 6 ) InOut r_v1 : real = 1 InOut theta_1 : real InOut phi_2_1 : matrix ( real , 6 , 6 ) local number : real = 1 local poseVec : vector ( real , 6 ) = [| 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 |] const H1 : vector ( real , 6 ) = (| 0 , 0 , 1 , 0 , 0 , 0 |) equation H == H1 equation XJ == [| cos ( theta_1 ) , - sin ( theta_1 ) , 0 , 0 , 0 , 0 ; sin ( theta_1 ) , cos ( theta_1 ) , 0 , 0 , 0 , 0 ; 0 , 0 , 1 , 0 , 0 , 0 ; 0 , 0 , 0 , cos ( theta_1 ) , - sin ( theta_1 ) , 0 ; 0 , 0 , 0 , sin ( theta_1 ) , cos ( theta_1 ) , 0 ; 0 , 0 , 0 , 0 , 0 , 1 |] equation _B_2 == B_2 equation _V_2 == V_2 equation _alpha_2 == alpha_2 equation _f_1 == f_1 Constraint ( XJ ) [ t == 0 ] == [| 1.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 ; 0.0 , 1.0 , 0.0 , 0.0 , 0.0 , 0.0 ; 0.0 , 0.0 , 1.0 , 0.0 , 0.0 , 0.0 ; 0.0 , 0.0 , 0.0 , 1.0 , 0.0 , 0.0 ; 0.0 , 0.0 , 0.0 , 0.0 , 1.0 , 0.0 ; 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 1.0 |] }
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
		aref WristActuator = TrivialMotor {
				pose {
					x = 0.0
					y = 0.0
					z = 0.0
					roll = 0.0
					pitch = 0.0
					yaw = 0.0
				}
			}
		relation B_2 == IntermediateLink . WristJoint . B_2 /\ V_2 == IntermediateLink . WristJoint . V_2 /\ alpha_2 == IntermediateLink . WristJoint . alpha_2 /\ XJ_1 == IntermediateLink . WristJoint . XJ }
		pose {
			x = 
			
			
			0.0
			y = 0.0
			z = 2.5
			roll = 0.0
			pitch = 0.0
			yaw = 0.0
		}
	relation H_2 == IntermediateLink.H2 /\  B_2 == IntermediateLink . B_2 /\ V [ 1 ] == IntermediateLink . V_2 /\ a [ 1 ] == IntermediateLink . a_2 /\ b [ 1 ] == IntermediateLink . b_2 /\ alpha [ 1 ] == IntermediateLink . alpha_2 /\ submatrix ( M ) ( 6 , 6 , 6 , 6 ) == IntermediateLink . M_2 /\ tau [ 1 ] == IntermediateLink . tau_2
	relation_flexi B_2 == IntermediateLink . B_2 /\ f_2 == IntermediateLink . f_2 /\ theta_2 == IntermediateLink . theta_2 /\ T_3_2 == IntermediateLink . T_3_2 /\ phi_3_2 == IntermediateLink . phi_3_2 /\ _V_3 == IntermediateLink . _V_3 /\ theta [ 1 ] == IntermediateLink . theta_2 }
	local link Gripper {
		def {
		input test_1 : vector ( real , 1 ) InOut L1_geom : Geom InOut M_1 : matrix ( real , 6 , 6 ) = [| 0.0208 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 ; 0.0 , 0.0208 , 0.0 , 0.0 , 0.0 , 0.0 ; 0.0 , 0.0 , 0.0208 , 0.0 , 0.0 , 0.0 ; 0.0 , 0.0 , 0.0 , 0.5 , 0.0 , 0.0 ; 0.0 , 0.0 , 0.0 , 0.0 , 0.5 , 0.0 ; 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.5 |] InOut a_1 : vector ( real , 6 ) InOut b_1 : vector ( real , 6 ) InOut V_1 : vector ( real , 6 ) InOut alpha_1 : vector ( real , 6 ) InOut f_1 : vector ( real , 6 ) InOut B_1 : matrix ( real , 4 , 4 ) InOut m : real = 0.5 InOut I : matrix ( real , 3 , 3 ) = [| 0.0208 , 0.0 , 0.0 ; 0.0 , 0.0208 , 0.0 ; 0.0 , 0.0 , 0.0208 |] InOut identity : matrix ( real , 3 , 3 ) = [| 1.0 , 0.0 , 0.0 ; 0.0 , 1.0 , 0.0 ; 0.0 , 0.0 , 1.0 |] InOut theta_1 : real InOut phi_2_1 : matrix ( real , 6 , 6 ) InOut _V_2 : vector ( real , 6 ) InOut _alpha_2 : vector ( real , 6 ) InOut _B_2 : matrix ( real , 4 , 4 ) InOut T_2_1 : matrix ( real , 4 , 4 ) InOut H_1 : vector ( real , 6 ) = (| 0 , 0 , 1 , 0 , 0 , 0 |) InOut r_v1 : real = 1 InOut tau_1 : vector ( real , 1 ) local number : real = 1 local poseVec : vector ( real , 6 ) = [| 0.0 , 0.0 , 4.75 , 0.0 , 0.0 , 0.0 |] equation V_1 == adj ( phi_2_1 ) * _V_2 + adj ( H_1 ) + derivative ( theta_1 ) equation alpha_1 == adj ( phi_2_1 ) * _alpha_2 + adj ( H_1 ) * derivative ( theta_1 ) + a_1 equation tau_1 == H_1 * f_1 equation B_1 == _B_2 * T_2_1 equation f_1 == M_1 * alpha_1 + b_1 Constraint ( B_1 ) [ t == 0 ] == [| 1.000000 , 0.000000 , 0.000000 , 0.000000 ; 0.000000 , 1.000000 , 0.000000 , 0.000000 ; - 0.000000 , 0.000000 , 1.000000 , 4.750000 ; 0 , 0 , 0 , 1 |] Constraint ( theta_1 ) [ t == 0 ] == 0
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
	relation H_1 == Gripper.H_1 /\ B_1 == Gripper . B_1 /\ V [ 0 ] == Gripper . V_1 /\ a [ 0 ] == Gripper . a_1 /\ b [ 0 ] == Gripper . b_1 /\ alpha [ 0 ] == Gripper . alpha_1 /\ submatrix ( M ) ( 0 , 0 , 6 , 6 ) == Gripper . M_1 /\ tau [ 0 ] == Gripper . tau_1
	relation_flexi B_1 == Gripper . B_1 /\ f_1 == Gripper . f_1 /\ theta_1 == Gripper . theta_1 /\ T_2_1 == Gripper . T_2_1 /\ phi_2_1 == Gripper . phi_2_1 /\ _V_2 == Gripper . _V_2 /\ theta [ 0 ] == Gripper . theta_1
}

const n : int = 3 
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
InOut M_1 : matrix ( real , 6 , 6 ) 
InOut r_v1 : real = 1 
InOut T_2_1 : matrix ( real , 4 , 4 ) 
InOut B_2 : matrix ( real , 4 , 4 ) 
InOut M_2 : matrix ( real , 6 , 6 ) 
InOut r_v2 : real = 1 
InOut T_3_2 : matrix ( real , 4 , 4 ) 
InOut B_3 : matrix ( real , 4 , 4 ) 
InOut M_3 : matrix ( real , 6 , 6 ) 

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
equation XJ_k == < XJ_1 , XJ_2 > 
equation V == adj ( phi ) * adj ( H ) * derivative ( theta ) 
equation alpha == adj ( phi ) * adj ( H ) * derivative ( theta ) + a 
equation f == phi * ( M * alpha + b ) 
equation tau == M_mass * derivative ( derivative ( theta ) ) + C 
equation M_mass == H * phi * M * adj ( phi ) * adj ( H ) 
equation C == H * phi ( M * adj ( phi ) * a + b ) 
equation B_2 == B_3 * T_3_2 
equation B_1 == B_3 * T_3_2 * T_2_1 
equation N == r_v1 + r_v2 

Constraint submatrix ( M ) ( 0 , 0 , 6 , 6 ) [ t == 0 ] == M_1 
Constraint submatrix ( M ) ( 6 , 6 , 6 , 6 ) [ t == 0 ] == M_2 
Constraint submatrix ( M ) ( 12 , 12 , 6 , 6 ) [ t == 0 ] == M_3 


Constraint ( XJ_1 ) [ t == 0 ] == [| 1.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 ; 0.0 , 1.0 , 0.0 , 0.0 , 0.0 , 0.0 ; 0.0 , 0.0 , 1.0 , 0.0 , 0.0 , 0.0 ; 0.0 , 0.0 , 0.0 , 1.0 , 0.0 , 0.0 ; 0.0 , 0.0 , 0.0 , 0.0 , 1.0 , 0.0 ; 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 1.0 |]
Constraint ( XJ_2 ) [ t == 0 ] == [| 1.0 , 0.0 , 0.0 , 0.0 , 0.0 , 0.0 ; 0.0 , 1.0 , 0.0 , 0.0 , 0.0 , 0.0 ; 0.0 , 0.0 , 1.0 , 0.0 , 0.0 , 0.0 ; 0.0 , 0.0 , 0.0 , 1.0 , 0.0 , 0.0 ; 0.0 , 0.0 , 0.0 , 0.0 , 1.0 , 0.0 ; 0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 1.0 |]
Constraint ( theta ) [ t == 0 ] == zeroVec(2)
Constraint ( B_1 ) [ t == 0 ] == [| 1.0 , 0.0 , 0.0 , 0.0 ; 0.0 , 1.0 , 0.0 , 0.0 ; 0.0 , 0.0 , 1.0 , 4.75 ; 0 , 0 , 0 , 1 |]
Constraint ( B_2 ) [ t == 0 ] == [| 1.0 , 0.0 , 0.0 , 0.0 ; 0.0 , 1.0 , 0.0 , 0.0 ; 0.0 , 0.0 , 1.0 , 2.5 ; 0 , 0 , 0 , 1 |]
Constraint ( B_3 ) [ t == 0 ] == [| 1.0 , 0.0 , 0.0 , 0.0 ; 0.0 , 1.0 , 0.0 , 0.0 ; 0.0 , 0.0 , 1.0 , 0.25 ; 0 , 0 , 0 , 1 |]
Constraint ( H_1 ) [ t == 0 ] == [| 0 , 0 , 1 , 0 , 0 , 0 |]
Constraint (submatrix(H)(0,0,1,6)) [t==0] == H_1
Constraint ( H_2 ) [ t == 0 ] == [| 1 , 0 , 0 , 0 , 0 , 0 |]
Constraint (submatrix(H)(1,6,1,6)) [t==0] == H_2



}

sensor TrivialSensor {
	input SignalIn : real
	output MeasurementOut : real
	equation SignalIn == MeasurementOut
}


record Geom { 
    geomType : string 
    geomVal : vector ( real ) 
}

actuator TrivialMotor {
	input TorqueIn : real
	output TorqueOut : real
	equation TorqueIn == TorqueOut
}

function identity ( size : real ) : matrix ( real , 3 , 3 ) { } 
function zeroes ( size : real ) : matrix ( real , 3 , 3 ) { } 
function Phi ( m : real , n : real , B_k : Seq( matrix ( real , 4 , 4 ) ) ) : matrix ( real , 6 , 6 ) { } 
function zeroVec ( a : real ) : vector ( real , 1 ) { } 
function zeroMat ( a : real , b : real ) : matrix ( real , 0 , 0 ) { } 
function getFramePosition ( k : real , B_n : Seq( matrix ( real , 4 , 4 ) ) ) : vector ( real , 3 ) { } 

const T : int

record Geom{
 	geomType: string
 	geomVal: vector(real)
}
