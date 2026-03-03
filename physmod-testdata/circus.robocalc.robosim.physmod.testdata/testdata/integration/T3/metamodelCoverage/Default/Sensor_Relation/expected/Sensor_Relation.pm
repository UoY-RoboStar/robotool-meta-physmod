package Sensor_Relation

// Tests the 'relation' property on Sensor

sensor TrivialSensor {
	input SignalIn : real
	output MeasurementOut : real
	equation SignalIn == MeasurementOut
}

pmodel Sensor_Relation {
	local link L1 {
		def { }
		local body B1 {
			def { box(length=0.1, width=0.1, height=0.1) }
		}
		local sensor S1 {
			def {
				input SignalIn : real
				output MeasurementOut : real
				equation SignalIn == MeasurementOut
			}
		}
	}
}
