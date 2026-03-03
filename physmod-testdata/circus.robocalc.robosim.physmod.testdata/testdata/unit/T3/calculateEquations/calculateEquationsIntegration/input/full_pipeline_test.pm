import physmod::math::*

pmodel TestFullPipeline {
	local link BaseLink {
		pose { x=0.0 y=0.0 z=0.0 roll=0.0 pitch=0.0 yaw=0.0 }
		def { }
		local body BaseBody {
			def {
				inertial information {
					mass 1.0
					inertia matrix { ixx 0.1 ixy 0.0 ixz 0.0 iyy 0.1 iyz 0.0 izz 0.1 }
					pose { x=0.0 y=0.0 z=0.0 roll=0.0 pitch=0.0 yaw=0.0 }
				}
				box ( length=0.2, width=0.2, height=0.2 )
			}
			pose { x=0.0 y=0.0 z=0.0 roll=0.0 pitch=0.0 yaw=0.0 }
		}
		local sensor BaseSensor {
			def {
				input SignalIn : real
				output MeasurementOut : real
				equation SignalIn == MeasurementOut
			}
			pose { x=0.0 y=0.0 z=0.0 roll=0.0 pitch=0.0 yaw=0.0 }
		}
		local joint Joint1 {
			pose { x=0.0 y=0.0 z=0.0 roll=0.0 pitch=0.0 yaw=0.0 }
			def {
				const H : vector ( real , 6 ) = [| 0 , 0 , 1 , 0 , 0 , 0 |]
				InOut theta : real
				InOut XJ : matrix ( real , 6 , 6 )
				equation XJ == [| cos ( theta ) , sin ( theta ) , 0 , 0 , 0 , 0 ;
								 - sin ( theta ) , cos ( theta ) , 0 , 0 , 0 , 0 ;
								 0 , 0 , 1 , 0 , 0 , 0 ;
								 0 , 0 , 0 , cos ( theta ) , sin ( theta ) , 0 ;
								 0 , 0 , 0 , - sin ( theta ) , cos ( theta ) , 0 ;
								 0 , 0 , 0 , 0 , 0 , 1 |]
			}
			flexibly connected to Link1
		}
	}
	local link Link1 {
		pose { x=0.0 y=0.0 z=1.0 roll=0.0 pitch=0.0 yaw=0.0 }
		def { }
		local body Link1Body {
			def {
				inertial information {
					mass 1.0
					inertia matrix { ixx 0.083 ixy 0.0 ixz 0.0 iyy 0.083 iyz 0.0 izz 0.001 }
					pose { x=0.0 y=0.0 z=0.0 roll=0.0 pitch=0.0 yaw=0.0 }
				}
				cylinder ( radius=0.05, length=1.0 )
			}
			pose { x=0.0 y=0.0 z=0.0 roll=0.0 pitch=0.0 yaw=0.0 }
		}
		local actuator Link1Motor {
			def {
				input TorqueIn : real
				output TorqueOut : real
				equation TorqueIn == TorqueOut
			}
			pose { x=0.0 y=0.0 z=0.0 roll=0.0 pitch=0.0 yaw=0.0 }
		}
		local joint Joint2 {
			pose { x=0.0 y=0.0 z=0.0 roll=0.0 pitch=0.0 yaw=0.0 }
			def {
				const H : vector ( real , 6 ) = [| 0 , 0 , 1 , 0 , 0 , 0 |]
				InOut theta : real
				InOut XJ : matrix ( real , 6 , 6 )
				equation XJ == [| cos ( theta ) , sin ( theta ) , 0 , 0 , 0 , 0 ;
								 - sin ( theta ) , cos ( theta ) , 0 , 0 , 0 , 0 ;
								 0 , 0 , 1 , 0 , 0 , 0 ;
								 0 , 0 , 0 , cos ( theta ) , sin ( theta ) , 0 ;
								 0 , 0 , 0 , - sin ( theta ) , cos ( theta ) , 0 ;
								 0 , 0 , 0 , 0 , 0 , 1 |]
			}
			flexibly connected to Link2
		}
	}
	local link Link2 {
		pose { x=0.0 y=0.0 z=2.0 roll=0.0 pitch=0.0 yaw=0.0 }
		def { }
		local body Link2Body {
			def {
				inertial information {
					mass 0.5
					inertia matrix { ixx 0.04 ixy 0.0 ixz 0.0 iyy 0.04 iyz 0.0 izz 0.001 }
					pose { x=0.0 y=0.0 z=0.0 roll=0.0 pitch=0.0 yaw=0.0 }
				}
				cylinder ( radius=0.05, length=0.5 )
			}
			pose { x=0.0 y=0.0 z=0.0 roll=0.0 pitch=0.0 yaw=0.0 }
		}
	}
}
