map OA_1SM dmodel OA_1SM::mobileOA_M to pmodel Turtlebot3_Burger {
	// Map desired linear/angular velocities into left/right wheel control inputs.
	// Wheel speed: w = (v +/- w * WHEEL_BASE/2) / WHEEL_RADIUS.
	operation move{
		equation Turtlebot3_Burger::BaseLink::LeftWheelJoint::LeftMotor.ControlIn ==
			(lv - av * 0.160 / 2) / 0.033
		equation Turtlebot3_Burger::BaseLink::RightWheelJoint::RightMotor.ControlIn ==
			(lv + av * 0.160 / 2) / 0.033
	}

	input event closestDistance?closest_distance {
		equation closest_distance == Turtlebot3_Burger::BaseLink::TBLidar.closestDistance 
	}

	input event closestAngle?closest_angle {
		equation closest_angle == Turtlebot3_Burger::BaseLink::TBLidar.closestAngle 
	}
}
