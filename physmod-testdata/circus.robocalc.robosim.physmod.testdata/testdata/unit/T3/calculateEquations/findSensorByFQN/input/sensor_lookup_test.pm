import physmod::math::*

pmodel TestSensorLookup {
	local link Link1 {
		pose { x=0.0 y=0.0 z=0.0 roll=0.0 pitch=0.0 yaw=0.0 }
		def { }
		local sensor Sensor1 {
			def {
				input SignalIn : real
				output MeasurementOut : real
				equation SignalIn == MeasurementOut
			}
			pose { x=0.0 y=0.0 z=0.0 roll=0.0 pitch=0.0 yaw=0.0 }
		}
		local sensor Sensor2 {
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
				const H : vector ( real , 6 ) = (| 0 , 0 , 1 , 0 , 0 , 0 |)
			}
			flexibly connected to Link2
		}
	}
	local link Link2 {
		pose { x=0.0 y=0.0 z=1.0 roll=0.0 pitch=0.0 yaw=0.0 }
		def { }
		local sensor Link2Sensor {
			def {
				input SignalIn : real
				output MeasurementOut : real
				equation SignalIn == MeasurementOut
			}
			pose { x=0.0 y=0.0 z=0.0 roll=0.0 pitch=0.0 yaw=0.0 }
		}
	}
}
