package DynamicDevice_Constraints

// Tests the 'constraints' property of DynamicDevice

sensor SensorWithConstraints {
	input SignalIn : real
	output MeasurementOut : real
	equation SignalIn == MeasurementOut
	Constraint SignalIn >= 0
	Constraint MeasurementOut <= 100
}

pmodel DynamicDevice_Constraints {
	local link L1 {
		def { }
		local body B1 {
			def { box(length=0.1, width=0.1, height=0.1) }
		}
		sref S1 = SensorWithConstraints { }
	}
}
