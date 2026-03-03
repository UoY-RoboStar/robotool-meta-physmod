package Sensor_Relation

// Tests the 'relation' property on Sensor

sensor TrivialSensor {
	input SignalIn : real
	output MeasurementOut : real
	equation SignalIn == MeasurementOut
}

pmodel Sensor_Relation {
	local link L1 {
		pose { x=0.0 y=0.0 z=0.0 roll=0.0 pitch=0.0 yaw=0.0 }
		def {
			inertial information {
				mass 0.0
				inertia matrix { ixx 0.0 ixy 0.0 ixz 0.0 iyy 0.0 iyz 0.0 izz 0.0 }
			}
		}
		local body B1 {
			def { box(length=0.1, width=0.1, height=0.1) }
		}
		sref S1 = TrivialSensor {
			1 == 1
		}
	}
}
