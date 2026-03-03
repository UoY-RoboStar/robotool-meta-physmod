map AcrobotMapping dmodel AcrobotSwingUpLQRModule to pmodel AcrobotControlled {

	// Map the d-model torque command into the controlled motor input.
	// ControlledMotor enforces: TorqueOut == B_ctrl * ControlIn.
	operation ApplyTorque {
		equation AcrobotControlled::Link1::ElbowJoint::ElbowMotor.ControlIn == tau 
	}

	// -------------------------------------------------------------------------
	// Combined sensor event (single event with all 4 sensor values)
	// -------------------------------------------------------------------------
	// This pattern avoids codegen issues with multiple input events per cycle.
	// The d-model receives all sensor values in a single AcrobotSensorState record.
	//
	// SKO tip-to-base convention: theta(1) = shoulder (base), theta(0) = elbow (tip).
	// No mapping swap is required - the d-model receives raw physical sensor values.

	input event sensorUpdate?su {
		equation su.shoulderAngle == AcrobotControlled::BaseLink::ShoulderJoint::ShoulderEncoder.AngleOut
		equation su.shoulderVelocity == AcrobotControlled::BaseLink::ShoulderJoint::ShoulderEncoder.VelocityOut
		equation su.elbowAngle == AcrobotControlled::Link1::ElbowJoint::ElbowEncoder.AngleOut
		equation su.elbowVelocity == AcrobotControlled::Link1::ElbowJoint::ElbowEncoder.VelocityOut 
	}
}
