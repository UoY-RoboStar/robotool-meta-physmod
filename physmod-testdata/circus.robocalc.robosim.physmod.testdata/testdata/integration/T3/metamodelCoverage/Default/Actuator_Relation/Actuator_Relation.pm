package Actuator_Relation

// Tests the 'relation' property on Actuator

actuator TrivialMotor {
	input TorqueIn : real
	output TorqueOut : real
	equation TorqueIn == TorqueOut
}

pmodel Actuator_Relation {
	local link L1 {
		def { }
		local body B1 {
			def { box(length=0.1, width=0.1, height=0.1) }
		}
		aref A1 = TrivialMotor {
			relation 1 == 1
		}
	}
}
