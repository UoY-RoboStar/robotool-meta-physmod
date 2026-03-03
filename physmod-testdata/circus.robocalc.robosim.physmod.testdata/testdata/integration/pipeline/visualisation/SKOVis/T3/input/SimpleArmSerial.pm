import  physmod::math::*
	pmodel SimpleArmSerial {
	// Top-level variables for visualization
	InOut N: real = 2
	InOut B_k: Seq(matrix(real,4,4))
	InOut XJ_k: Seq(matrix(real,6,6))
	InOut theta: vector(real,2)
	InOut B_1: matrix(real,4,4)
	InOut B_2: matrix(real,4,4)
	InOut B_3: matrix(real,4,4)
	InOut XJ_1: matrix(real,6,6)
	InOut XJ_2: matrix(real,6,6)
	InOut L1_geom: Geom
	InOut L2_geom: Geom
	InOut L3_geom: Geom
	InOut Lk_geom: Seq(Geom)
	InOut H_1: vector(real,6)
	InOut H_2: vector(real,6)
	InOut H: matrix(real,2,18)

	// Geometric constraints (based on body definitions)
	Constraint (L1_geom.geomType)[t==0] == "box"
	Constraint (L1_geom.geomVal)[t==0] == [|0.5,0.5,0.5|]
	Constraint (L2_geom.geomType)[t==0] == "cylinder"
	Constraint (L2_geom.geomVal)[t==0] == [|0.25,4.0|]
	Constraint (L3_geom.geomType)[t==0] == "box"
	Constraint (L3_geom.geomVal)[t==0] == [|1.0,1.0,0.5|]
	Constraint (Lk_geom)[t==0] == <L1_geom, L2_geom, L3_geom>

	// Frame and joint constraints
	Constraint (B_k)[t==0] == <B_1, B_2, B_3>
	Constraint (XJ_k)[t==0] == <XJ_1, XJ_2>

	local link BaseLink {
		def {
		InOut L3_geom: Geom
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
				const H : matrix ( real , 1 , 6 ) = [| 1 , 0 , 0 , 0 , 0 , 0 |]
				InOut theta : real
				InOut XJ : matrix ( real , 6 , 6 )
				equation XJ == [| 1 , 0 , 0 , 0 , 0 , 0 ; 0 , cos ( theta ) , - sin ( theta ) , 0 , 0 , 0 ; 0 , sin ( theta ) , cos ( theta ) , 0 , 0 , 0 ; 0 , 0 , 0 , 1 , 0 , 0 ; 0 , 0 , 0 , 0 , cos ( theta ) , - sin ( theta ) ; 0 , 0 , 0 , 0 , sin ( theta ) , cos ( theta ) |]
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
	}
	local link IntermediateLink {
		def {
		InOut L2_geom: Geom
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
				const  H : matrix ( real , 1 , 6 ) = [| 0 , 0 , 1 , 0 , 0 , 0 |]
				InOut theta : real
				InOut XJ : matrix ( real , 6 , 6 )
				equation XJ == [| cos ( theta ) , - sin ( theta ) , 0 , 0 , 0 , 0 ; sin ( theta ) , cos ( theta ) , 0 , 0 , 0 , 0 ; 0 , 0 , 1 , 0 , 0 , 0 ; 0 , 0 , 0 , cos ( theta ) , - sin ( theta ) , 0 ; 0 , 0 , 0 , sin ( theta ) , cos ( theta ) , 0 ; 0 , 0 , 0 , 0 , 0 , 1 |]
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
	}
	local link Gripper {
		def {
		InOut L1_geom: Geom
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
	}
}
sensor TrivialSensor {
	input SignalIn : real
	output MeasurementOut : real
	equation SignalIn == MeasurementOut
}
actuator TrivialMotor {
	input TorqueIn : real
	output TorqueOut : real
	equation TorqueIn == TorqueOut
}
