import physmod::joints::Revolute import physmod::sensors::IR import physmod::actuators::SpeedControlMotor import physmod::actuators::LinearSpeedControlMotor import physmod::sensors::Camera import physmod::math::* pmodel SimpleArm {	
	local link BaseLink {
		def {
		}
		jref ElbowJoint = Revolute_x {
			flexibly connected to IntermediateLink

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
		aref ElbowMotor = TrivialMotor {
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
	sref BaseSensor = TrivialSensor {
			pose {
				x = 0
				y = - 0.5
				z = - 0.25
				roll = 0
				pitch = 0
				yaw = 0
			}
		}
	}
	local link IntermediateLink {
		def {
		}
		jref WristJoint = Revolute_z {
			flexibly connected to Gripper

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
		aref WristMotor = TrivialMotor {
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
	pose {
			x = 0
			y = 0
			z = 4.75
			roll = 0
			pitch = 0
			yaw = 0
		}
	}
}

joint Revolute_x{
 local H: matrix(real,6,1),q: real, theta: matrix(real,3,3)
 const Axis: vector(real,3) = (|1,0,0|), AxisMatrix: matrix(real,3,3) = [|0, -Axis[3],Axis[2];Axis[3],0,-Axis[1];-Axis[2],Axis[1],0|], I: matrix(real,3,3) = [|1, 0, 0; 0, 1, 0; 0,0,1|]
 equation theta == I + sin(q)*AxisMatrix + (1-cos(q))*AxisMatrix cat 2
 equation H == (|1,0,0,0,0,0|)
}

joint Revolute_z{
 local H: matrix(real,6,1),q: real, theta: matrix(real,3,3)
 const Axis: vector(real,3) = (|1,0,0|), AxisMatrix: matrix(real,3,3) = [|0, -Axis[3],Axis[2];Axis[3],0,-Axis[1];-Axis[2],Axis[1],0|], I: matrix(real,3,3) = [|1, 0, 0; 0, 1, 0; 0,0,1|]
 equation theta == I + sin(q)*AxisMatrix + (1-cos(q))*AxisMatrix cat 2
 equation H == (|0,0,1,0,0,0|)
}
sensor TrivialSensor {
	input SignalIn: real
	output MeasurementOut: real
	equation SignalIn == MeasurementOut
}
actuator TrivialMotor {
	input TorqueIn: real
	output TorqueOut: real
	equation TorqueIn == TorqueOut
}


function BeamModel(d: real): real{}
function ind(z_t: real, lower: real, upper:real): real {
   precondition lower <= upper
   postcondition result == if z_t >= lower /\ z_t <= upper then 1 else 0 end
}