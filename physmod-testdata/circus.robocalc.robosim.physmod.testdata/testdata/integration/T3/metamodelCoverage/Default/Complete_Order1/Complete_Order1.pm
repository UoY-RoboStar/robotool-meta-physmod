package Complete_Order1

// Comprehensive test exercising all metamodel components up to order 1.
// Testing every pairwise combination is combinatorially infeasible;
// instead, we test individual components plus this comprehensive model
// with all components present simultaneously.

// Library definitions demonstrating DynamicDevice properties
sensor CompleteSensor {
	input SignalIn : real
	output MeasurementOut : real
	InOut State : real
	local LocalVar : real
	const GAIN : real = 1.0
	equation LocalVar == SignalIn * GAIN
	equation MeasurementOut == LocalVar
	Constraint SignalIn >= 0
}

actuator CompleteActuator {
	input TorqueIn : real
	output TorqueOut : real
	InOut MotorState : real
	local InternalVar : real
	const EFFICIENCY : real = 0.95
	equation InternalVar == TorqueIn * EFFICIENCY
	equation TorqueOut == InternalVar
	Constraint TorqueIn <= 100
}

joint CompleteJoint {
	input PositionCmd : real
	output Position : real
	const LIMIT : real
	equation Position == PositionCmd
}

link CompleteLink {
	inertial information {
		mass 1.0
		inertia matrix { ixx 0.1 ixy 0 ixz 0 iyy 0.1 iyz 0 izz 0.1 }
	}
}

body CompleteBody {
	box(length=0.1, width=0.1, height=0.1)
	inertial information {
		mass 0.5
		inertia matrix { ixx 0.01 ixy 0 ixz 0 iyy 0.01 iyz 0 izz 0.01 }
	}
}

// Base module for Part instantiation
pmodel BaseModule {
	local link BaseLink {
		def { }
		local body BaseBody {
			def { sphere(radius=0.05) }
		}
	}
}

// Main comprehensive model
pmodel Complete_Order1 {
	// PModel-level DynamicDevice properties
	input ModelInput : real
	output ModelOutput : real
	InOut ModelState : real
	local ModelLocal : real
	const MODEL_CONST : real = 42.0
	equation ModelLocal == ModelInput + MODEL_CONST
	equation ModelOutput == ModelLocal
	Constraint ModelInput >= -100

	// Solution block with IBCondition
	solution {
		solutionExpr phi : real
		order 1
		group 0
		method Eval
		Input theta : real
		Constraint (ModelLocal) [t == 0] == 0.0
	}

	// Part with Instantiation
	part P1 = BaseModule {
		pose { x = 1.0 y = 0 z = 0 roll = 0 pitch = 0 yaw = 0 }
		link BaseLink fixed to L1
	}

	// LocalLink with relation
	local link L1 {
		pose { x = 0 y = 0 z = 0 roll = 0 pitch = 0 yaw = 0 }
		def { }
		relation 1

		// LocalBody with Box geometry
		local body LB1 {
			pose { x = 0 y = 0 z = 0.1 roll = 0 pitch = 0 yaw = 0 }
			def { box(length=0.2, width=0.2, height=0.2) }
			relation 1
		}

		// ReferenceBody (note: ReferenceBody doesn't support relation property)
		bref RB1 = CompleteBody {
			pose { x = 0.3 y = 0 z = 0.1 roll = 0 pitch = 0 yaw = 0 }
		}

		// LocalSensor with Index
		local sensor LS1 {
			index i : [0,2)
			pose { x = i*0.1 y = 0 z = 0.2 roll = 0 pitch = 0 yaw = 0 }
			def {
				input S_In : real
				output S_Out : real
				equation S_In == S_Out
			}
			relation i == i
		}

		// ReferenceSensor
		sref RS1 = CompleteSensor {
			pose { x = 0.5 y = 0 z = 0.2 roll = 0 pitch = 0 yaw = 0 }
			1 == 1
		}

		// LocalActuator
		local actuator LA1 {
			pose { x = 0 y = 0.1 z = 0 roll = 0 pitch = 0 yaw = 0 }
			def {
				input A_In : real
				output A_Out : real
				equation A_In == A_Out
			}
			relation 1 == 1
		}

		// ReferenceActuator
		aref RA1 = CompleteActuator {
			pose { x = 0 y = 0.2 z = 0 roll = 0 pitch = 0 yaw = 0 }
			relation 1 == 1
		}
	}

	// ReferenceLink with Index (note: ReferenceLink doesn't support relation_flexi)
	lref L2 = CompleteLink {
		index j : [0,1)
		pose { x = 0.5+j*0.2 y = 0 z = 0 roll = 0 pitch = 0 yaw = 0 }

		// Body with Sphere geometry
		local body LB2 {
			def { sphere(radius=0.05) }
		}

		// LocalJoint with relation and FlexibleConnection
		local joint LJ1 {
			def { }
			flexibly connected to L1
			relation 6

			// Sensor on joint
			local sensor JS1 {
				def {
					input JS_In : real
					output JS_Out : real
					equation JS_In == JS_Out
				}
			}

			// Actuator on joint
			local actuator JA1 {
				def {
					input JA_In : real
					output JA_Out : real
					equation JA_In == JA_Out
				}
			}
		}
	}

	// Third link for demonstrating more connections
	local link L3 {
		pose { x = 1.0 y = 0 z = 0 roll = 0 pitch = 0 yaw = 0 }
		def { }

		// Body with Cylinder geometry
		local body LB3 {
			def { cylinder(radius=0.03, length=0.1) }
		}

		// Body with Mesh geometry
		local body LB4 {
			def { mesh { shape "cube.dae" scaling 0.01 } }
		}

		// ReferenceJoint with Instantiation
		jref RJ1 = CompleteJoint {
			flexibly connected to L2
			instantiation LIMIT = 3.14159
			relation 7
		}

		// FixedConnection
		fixed to L1
	}
}
