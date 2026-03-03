import physmod::joints::Revolute import physmod::sensors::IR import physmod::actuators::SpeedControlMotor import physmod::actuators::LinearSpeedControlMotor import physmod::sensors::Camera import physmod::math::* pmodel FourBarPlanarLinkage {
	local link Link1 {
		def {
			local number : real = 0
		}
		local body Link1 {
			def {
				inertial information {
					mass 20.0
					inertia matrix { ixx 26.6667 ixy 0.0 ixz 0.0 iyy 26.6667 iyz 0.0 izz 3.2 }
					pose {
						x = 0
						y = 0
						z = 0
						roll = 0.0
						pitch = 0.0
						yaw = 0.0
					}
				}
				cylinder ( radius = 0.25 , length = 4 )
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
		jref Link1Joint = Revolute_x {
			annotation Revolute {
				axis = Axis {
					xyz = (| 0 , 1 , 0 |)
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
			flexibly connected to Link2
			pose {
				x = 
				
				
				
				0
				y = 0
				z = 0
				roll = 0.0
				pitch = 0.0
				yaw = 0.0
			}
			local number : real = 3
		}
		pose {
			x = 
			
			
			
			0
			y = 0
			z = 2.0
			roll = 0
			pitch = 0
			yaw = 0
		}
	}
	local link Link2 {
		def {
			local number : real = 3
		}
		local body Link2 {
			def {
				inertial information {
					mass 20.0
					inertia matrix { ixx 26.6667 ixy 0.0 ixz 0.0 iyy 26.6667 iyz 0.0 izz 3.2 }
					pose {
						x = 0
						y = 0
						z = 0
						roll = 0
						pitch = 0
						yaw = 0
					}
				}
				cylinder ( radius =  0.25 , length = 4 )
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
		jref Link2Joint = Revolute_z {
			annotation Revolute {
				axis = Axis {
					xyz = (| 0 , 1 , 0 |)
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
			flexibly connected to Link3
			pose {
				x = 
				
				
				0
				y = 0
				z = 2.0
				roll = 0.0
				pitch = 0.0
				yaw = 0.0
			}
			local number : real = 2
		}
		pose {
			x = 
			
			
			
			
			0
			y = 2
			z = 4
			roll = 1.57
			pitch = 0.0
			yaw = 0.0
		}
	}
	local link Link3 {
		def {
			local number : real = 2
			local test : real = 1
			inertial information {
				mass 20.0
				inertia matrix { ixx 26.6667 ixy 0.0 ixz 0.0 iyy 26.6667 iyz 0.0 izz 3.2 }
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
		local body Link3 {
			def {
				cylinder ( radius = 0.25 , length = 4 )
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
		jref Link3Joint = Revolute_x {
			annotation Revolute {
				axis = Axis {
					xyz = (| 0 , 1 , 0 |)
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
			flexibly connected to Link4
			local number : real = 1
		}
		pose {
			x = 
				0
			y = 4
			z = 2
			roll = 0
			pitch = 0
			yaw = 0
		}
	}
	local link Link4 {
		def {
			local number : real = 1
		}
		local body Link4 {
			def {
				inertial information {
					mass 20.0
					inertia matrix { ixx 26.6667 ixy 0.0 ixz 0.0 iyy 26.6667 iyz 0.0 izz 3.2 }
					pose {
						x = 0
						y = 0
						z = 0
						roll = 0
						pitch = 0
						yaw = 0
					}
				}
				cylinder ( radius =  0.24 , length = 4 )
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
		jref Link4Joint = Revolute_x {
			annotation Revolute {
				axis = Axis {
					xyz = (| 0 , 1 , 0 |)
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
			flexibly connected to Link1
		}
		pose {
			x = 
			0
			y = 2
			z = 0
			roll = 1.57
			pitch = 0
			yaw = 0
		}
	}
	local number : real = 0
}
actuator TorqueControlMotor {
	input TorqueIn : real
	output TorqueOut : real
	equation TorqueIn == TorqueOut
}
joint Revolute_x {
	local H : matrix ( real , 6 , 1 ) , X_CF : matrix ( real , 3 , 4 ) , V_CF : real , A_CF : real , N : real , v : real , q : real , q_C : matrix ( real , 3 , 3 )
	const Axis : vector ( real , 3 ) = (| 0 , 1 , 0 |) , AxisMatrix : matrix ( real , 3 , 3 ) = [| 0 , - Axis [ 3 ] , Axis [ 2 ] ; Axis [ 3 ] , 0 , - Axis [ 1 ] ; - Axis [ 2 ] , Axis [ 1 ] , 0 |] , v_initial : real = 0 , q_initial : real = 0 , I : matrix ( real , 3 , 3 ) = [| 1 , 0 , 0 ; 0 , 1 , 0 ; 0 , 0 , 1 |]
	equation q_C == I + sin ( q ) * AxisMatrix + ( 1 - cos ( q ) ) * AxisMatrix cat 2
	equation N == 1.0
	equation H == (| 0 , 1 , 0 , 0 , 0 , 0 |)
	equation X_CF == [| cos ( q ) , 0 , sin ( q ) ; 0 , 1 , 0 ; - sin ( q ) , 0 , cos ( q ) ; 0 , 0 , 0 |]
	equation V_CF == H * v
	equation A_CF == H * derivative ( v )
	equation derivative ( q ) == N * v
// equation tau(q) == M(q)*derivative(q) + C(q, derivative(q)) + f
}
joint Revolute_z {
	local H : matrix ( real , 6 , 1 ) , X_FM : matrix ( real , 3 , 4 ) , V_FM : real , A_FM : real , N : real , v : real , q : real
	equation N == 1.0
	equation H == (| 0 , 1 , 0 , 0 , 0 , 0 |)
	equation X_FM == [| cos ( q ) , 0 , sin ( q ) ; 0 , 1 , 0 ; - sin ( q ) , 0 , cos ( q ) ; 0 , 0 , 0 |]
	equation V_FM == H * v
	equation A_FM == H * derivative ( v )
	equation derivative ( q ) == N * v
}
joint Prismatic_x {
	input v : real , q : real
	local H : matrix ( real , 6 , 1 ) , X_FM : matrix ( real , 3 , 4 ) , V_FM : real , A_FM : real , N : real
	equation N == 1.0
	equation H == (| 0 , 0 , 0 , 1 , 0 , 0 |)
	equation X_FM == [| 1 , 0 , 0 ; 0 , 1 , 0 ; 0 , 0 , 1 ; q , 0 , 0 |]
	equation V_FM == H * v
	equation A_FM == H * derivative ( v )
	equation derivative ( q ) == N * v
}
