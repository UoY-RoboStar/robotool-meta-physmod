import physmod::joints::Revolute import physmod::sensors::IR import physmod::actuators::SpeedControlMotor import physmod::actuators::LinearSpeedControlMotor import physmod::sensors::Camera import physmod::math::* pmodel SimpleArm {	
	local link BaseLink {
		def {
		}
		jref ElbowJoint = Revolute_x {
			flexibly connected to IntermediateLink

			aref ElbowJointMotor = TorqueControlMotor
		annotation Revolute {
				axis = Axis {
					xyz = (| 1 , 0 , 0 |)
					dynamics = Dynamics {
						damping = 0
						_friction = 0
						spring_reference = 0
						spring_stiffness = 0
					}
					limit = Limit {
						lower = - 1.5707964
						upper = 1.5707964
						velocity = 5
					}
				}
			}

			pose {
				x = 
				
				0
				y = 0
				z = 0.25
				roll = 0.0
				pitch = 0.0
				yaw = 0.0
			}
		}
		pose {
			x = 
			
			
			0
			y = 0
			z = 0.25
			roll = 0
			pitch = 0
			yaw = 0
		}
	local body BaseLink {
			def {
				box ( length = 1 , width = 1 , height = 0.5 )

				inertial information {
					mass 
					
					
				100
					inertia matrix { ixx 10.417 ixy 0 ixz 0 iyy 16.667 iyz 0 izz 10.417 }
					pose {
						x = 0
						y = 0
						z = 0
						roll = 0.0
						pitch = 0.0
						yaw = 0.0
					}
				}
			}
			pose {
				x = 
				
				0
				y = 0
				z = 0
				roll = 0.0
				pitch = 0.0
				yaw = 0.0
			}
		}
	sref ObjectBeamSensor = BeamModelSensor {
		pose {
				x = 0
				y = 0.5
				z = - 0.25
				roll = 0.0
				pitch = 0.0
				yaw = 0.0
			}
		}
		sref GoalBeamSensor = BeamModelSensor {
		pose {
				x = 0
				y = - 0.5
				z = - 0.25
				roll = 0.0
				pitch = 0.0
				yaw = 0.0
			}
		}
	}
	local link IntermediateLink {
		def {
		}
		jref WristJoint = Revolute_z {
			flexibly connected to Gripper

			aref WristJointMotor = TorqueControlMotor
			annotation Revolute {
				axis = Axis {
					xyz = (| 0 , 0 , 1 |)
					dynamics = Dynamics {
						damping = 0
						_friction = 0
						spring_reference = 0
						spring_stiffness = 0
					}
					limit = Limit {
						lower = - 6.2831855
						upper = 6.2831855
						velocity = 5
					}
				}
			}

			pose {
				x = 
				
				0
				y = 0
				z = 2.0
				roll = 0.0
				pitch = 0.0
				yaw = 0.0
			}
		}
	local body IntermediateLink {
			def {
				cylinder ( radius =  0.25 , length = 4 )

				inertial information {
					mass 1
					inertia matrix { ixx 1.349 ixy 0 ixz 0 iyy 1.349 iyz 0 izz 0.0313 }
					pose {
						x = 0
						y = 0
						z = 0
						roll = 0
						pitch = 0
						yaw = 0
					}
				}
			}
			pose {
				x = 
				
				0
				y = 0
				z = 0
				roll = 0
				pitch = 0.0
				yaw = 0.0
			}
		}
		pose {
			x = 
			
			
			0
			y = 0
			z = 2.5
			roll = 0
			pitch = 0.0
			yaw = 0.0
		}
	}
	local link Gripper {
		def {
		}
		jref left_slider = Prismatic_x {
			flexibly connected to left_finger
			annotation Prismatic {
				axis = Axis {
					xyz = (| 1 , 0 , 0 |)
					limit = Limit {
						effort=0
					}
				}
			}
		pose {
				x = 0.25
				y = 0
				z = 0.25
				roll = 0
				pitch = 0
				yaw = 0
			}
		aref left_sliderMotor = TorqueControlMotor
		}
		jref right_slider = Prismatic_x {
			flexibly connected to right_finger
			annotation Prismatic {
				axis = Axis {
					xyz = (| 1 , 0 , 0 |)
					limit = Limit {
						effort=0
					}
				}
			}
		pose {
				x = 0.25
				y = 0
				z = 0.25
				roll = 0
				pitch = 0
				yaw = 0
			}
		aref right_sliderMotor = TorqueControlMotor
		}
	local body Gripper {
			def {
				box ( length =  0.5 , width = 0.5 , height = 0.5 )
			inertial information {
					mass 0.5
					inertia matrix { ixx 0.0208 ixy 0 ixz 0 iyy 0.0208 iyz 0 izz 0.0208 }
					pose {
						x = 0
						y = 0
						z = 0
						roll = 0
						pitch = 0
						yaw = 0
					}
				}
			}
			pose {
				x = 
				0
				y = 0
				z = 0
				roll = 0
				pitch = 0.0
				yaw = 0.0
			}
		}
	}
	local link left_finger {
		def {
		}
		local body left_finger {
			def {
				inertial information {
					mass 0.01
					inertia matrix { ixx 0.000283 ixy 0 ixz 0 iyy 0.0000752 iyz 0 izz 0.00209 }
					pose {
						x = 0
						y = 0
						z = 0
						roll = 0
						pitch = 0
						yaw = 0
					}
				}
				box ( length =  0.015 , width = 0.5 , height = 0.3 )
			}
			pose {
				x = 0
				y = 0
				z = 0
				roll = 0
				pitch = 0
				yaw = 0
			}
		}
	pose {
			x = - 0.25
			y = 0
			z = 5.15
			roll = 0
			pitch = 0
			yaw = 0
		}
	}
	local link right_finger {
		def {
		}
	local body right_finger {
			def {
				inertial information {
					mass 0.01
					inertia matrix { ixx 0.000283 ixy 0 ixz 0 iyy 0.0000752 iyz 0 izz 0.00209 }
					pose {
						x = 0
						y = 0
						z = 0
						roll = 0
						pitch = 0
						yaw = 0
					}
				}
				box ( length =  0.015 , width = 0.5 , height = 0.3 )
			}
			pose {
				x = 
				0
				y = 0
				z = 0
				roll = 0
				pitch = 0
				yaw = 0
			}
		}
	pose {
			x = 0.25
			y = 0
			z = 5.15
			roll = 0.0
			pitch = 0.0
			yaw = 0.0
		}
	}
}

sensor BeamModelSensor{
	input trueDistance : real, measuredDistance: real, z_hit: real, z_short: real, z_max: real, z_rand: real, sigma_hit: real, lambda_short: real
	output measurement : real
	local p_hit: real, p_short: real, p_rand: real, p_max: real, eta1: real, eta2: real, N: real
	const PI: real, e: real
	equation N == 1/(sqrt(2*PI*sigma_hit^2))*e^{-(0.5/sigma_hit^2)*(measuredDistance - trueDistance)^2}
	equation eta1 == (integral(N))^-1
	equation eta2 == 1/(1- e^{-lambda_short*trueDistance})
	equation p_hit == ind(measuredDistance, 0, z_max)*eta1*N
	equation p_short == ind(measuredDistance, 0, trueDistance)*eta2*lambda_short*e^{-lambda_short*measuredDistance}
	equation p_max == ind(measuredDistance, z_max, z_max)
	equation p_rand == ind(measuredDistance, 0, z_max)*1/z_max
	
	equation measurement == BeamModel(measuredDistance)
	
}

joint Revolute_x{
 local H_CF: matrix(real,6,1), X_CF: matrix(real,3,4), V_CF: real, A_CF: real, N: real, v: real, theta: real, q_C: matrix(real,3,3)
 const Axis: vector(real,3) = (|1,0,0|), AxisMatrix: matrix(real,3,3) = [|0, -Axis[3],Axis[2];Axis[3],0,-Axis[1];-Axis[2],Axis[1],0|], v_initial:real = 0 , q_initial: real = 0, I: matrix(real,3,3) = [|1, 0, 0; 0, 1, 0; 0,0,1|]
 equation q_C == I + sin(theta)*AxisMatrix + (1-cos(theta))*AxisMatrix cat 2
 equation N == 1.0
 equation H_CF == (|1,0,0,0,0,0|)
 equation X_CF ==[|1,0,0;0,cos(theta),sin(theta);0,-sin(theta),cos(theta);0,0,0|]
 equation V_CF == H_CF * v
 equation A_CF == H_CF * derivative(v)
 equation derivative(theta) == N * v 
 //equation tau(q) == M(q)*derivative(q) + C(q, derivative(q)) + f
}

joint Revolute_z{
 local H_FM: matrix(real,6,1), X_FM: matrix(real,3,4), V_FM: real, A_FM: real, N: real, v: real, q: real  
 equation N == 1.0
 equation H_FM == (|0,0,1,0,0,0|)
 equation X_FM ==[|cos(q),sin(q),0;-sin(q),cos(q),0;0,0,1;0,0,0|]
 equation V_FM == H_FM * v
 equation A_FM == H_FM * derivative(v)
 equation derivative(q) == N * v 
 
}


actuator TorqueControlMotor {
	input TorqueIn : real
	output TorqueOut : real
	equation TorqueIn == TorqueOut
}
joint Prismatic_x {
 input v: real, q: real
 local H_FM: matrix(real,6,1), X_FM: matrix(real,3,4), V_FM: real, A_FM: real, N: real  
 equation N == 1.0
 equation H_FM == (|0,0,0,1,0,0|)
 equation X_FM ==[|1,0,0;0,1,0;0,0,1;q,0,0|]
 equation V_FM == H_FM * v
 equation A_FM == H_FM * derivative(v)
 equation derivative(q) == N * v 
}


function BeamModel(d: real): real{}
function ind(z_t: real, lower: real, upper:real): real {
   precondition lower <= upper
   postcondition result == if z_t >= lower /\ z_t <= upper then 1 else 0 end
}