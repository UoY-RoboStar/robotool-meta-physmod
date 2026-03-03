package DynamicDevice_Inputs

// Tests the 'inputs' property of DynamicDevice

sensor SensorWithInputs {
	input SignalIn : real
	output MeasurementOut : real
	equation SignalIn == MeasurementOut
}

pmodel DynamicDevice_Inputs {
	local link L1 {
		def { }
		local body B1 {
			def { box(length=0.1, width=0.1, height=0.1) }
		}
		sref S1 = SensorWithInputs { }
	}
}
