import  physmod::SKO::joints::* 
import  physmod::math::* 
	pmodel SimpleArmSerial {
	local link BaseLink {
		def {
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