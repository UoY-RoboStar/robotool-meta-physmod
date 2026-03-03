package DynamicDevice_Locals

// Tests the 'locals' property of DynamicDevice

sensor SensorWithLocals {
	input SignalIn : real
	output MeasurementOut : real
	local LocalState : real
	equation LocalState == SignalIn * 2
	equation MeasurementOut == LocalState
}

pmodel DynamicDevice_Locals {
	local link L1 {
		def { }
		local body B1 {
			def { box(length=0.1, width=0.1, height=0.1) }
		}
		sref S1 = SensorWithLocals { }
	}
}
