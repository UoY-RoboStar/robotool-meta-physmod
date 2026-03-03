package DynamicDevice_Outputs

// Tests the 'outputs' property of DynamicDevice

sensor SensorWithOutputs {
	input SignalIn : real
	output MeasurementOut : real
	output SecondaryOut : real
	equation SignalIn == MeasurementOut
	equation SecondaryOut == MeasurementOut * 2
}

pmodel DynamicDevice_Outputs {
	local link L1 {
		def { }
		local body B1 {
			def { box(length=0.1, width=0.1, height=0.1) }
		}
		local sensor S1 {
			def {
				input SignalIn : real
				output MeasurementOut : real
				output SecondaryOut : real
				equation SignalIn == MeasurementOut
				equation SecondaryOut == MeasurementOut * 2
			}
		}
	}
}
