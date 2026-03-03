package Fragment

// Tests the Fragment metamodel component
// Fragments are reusable collections of links, joints, sensors, and actuators

sensor TrivialSensor {
	input SignalIn : real
	output MeasurementOut : real
	equation SignalIn == MeasurementOut
}

pmodel Fragment {
	local link L1 {
		def { }
		local body B1 {
			def { box(length=0.1, width=0.1, height=0.1) }
		}
	}
}
actuator TrivialActuator {
	input TorqueIn : real
	output TorqueOut : real
	equation TorqueIn == TorqueOut
}

fragment TestFragment {
	local link FragLink {
		def { }
		local body FragBody {
			def { box(length=0.1, width=0.1, height=0.1) }
		}
	}
	sref FragSensor = TrivialSensor { 1 == 1 }
	aref FragActuator = TrivialActuator { relation 1 == 1 }
}