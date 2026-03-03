package DynamicDevice_InOuts

// Tests the 'InOuts' property of DynamicDevice

sensor SensorWithInOuts {
	input SignalIn : real
	output MeasurementOut : real
	InOut State : real
	equation SignalIn == MeasurementOut
}

pmodel DynamicDevice_InOuts {
	local link L1 {
		def { }
		local body B1 {
			def { box(length=0.1, width=0.1, height=0.1) }
		}
		local sensor S1 {
			def {
				input SignalIn : real
				output MeasurementOut : real
				InOut State : real
				equation SignalIn == MeasurementOut
			}
		}
	}
}
