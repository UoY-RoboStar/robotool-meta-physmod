package ReferenceActuatorTest

actuator TrivialMotor {
	input TorqueIn : real
	output TorqueOut : real
	equation TorqueIn == TorqueOut
}

pmodel ReferenceActuatorTest {
	local link L1 {
		def {
		}
		local body B1 {
			def {
				box(length=0.1, width=0.1, height=0.1)
			}
		}
		aref Motor1 = TrivialMotor {
		}
	}
}
