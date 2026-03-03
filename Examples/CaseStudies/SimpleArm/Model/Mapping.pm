map M dmodel PickPlace to pmodel SimpleArm {
	operation PrePick{
		equation SimpleArm::BaseLink::ElbowJoint::ElbowJointMotor.TorqueIn == -ind(t,0,1)* t cat 10* (34683 + 80634 * t - 102817 * t cat 2)/2500 + ind(t,1,2)*t cat 10 * (34683 + 80634 * t - 102817 * t cat 2)/2500
	}
	operation PrePlace{
		const Pi: real
		equation SimpleArm::BaseLink::ElbowJoint::ElbowJointMotor.TorqueIn ==  ind(t,0,1)* t cat 10 (34683 + 80634 * t - 102817 * t cat 2)/2500 + ind(t,1,2)*Pi/4 -ind(t,2,3)*t cat 10 (34683 + 80634 * t - 102817 * t cat 2)/2500
	}
	
	operation Return{
		equation SimpleArm::BaseLink::ElbowJoint::ElbowJointMotor.TorqueIn == -ind(t,0,1)*(t cat 10 (34683 + 80634 * t - 102817 * t cat 2))/2500 + ind(t,1,2)*(t cat 10 * (34683 + 80634 * t - 102817 * t cat 2))/2500
	} 
	input event detectObject?object{ 
		predicate object == SimpleArm::BaseLink::ObjectBeamSensor.measurement < 4.75111	/\ 	SimpleArm::BaseLink::ObjectBeamSensor.measurement>4.79
		}
		
	input event detectGoal?goal {
		predicate goal == SimpleArm::BaseLink::GoalBeamSensor.measurement < 4.75111	/\ 	SimpleArm::BaseLink::GoalBeamSensor.measurement>4.79
		
	}

}
function ind(time:real, lower: real, upper:real): real {
   precondition lower <= upper
   postcondition result == if time >= lower /\ time <= upper then 1 else 0 end
}