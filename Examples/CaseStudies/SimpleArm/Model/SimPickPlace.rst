

interface detectGoalI {
	event detectGoal : boolean
}

interface PickPlaceI {
	PrePick ( )
PrePlace ( )
	Return ( )
}

interface detectObjectI {
	event detectObject : boolean
}

controller PickPlaceC {
	requires PickPlaceI uses detectObjectI uses detectGoalI sref stm_ref0 = PickPlaceS

	connection PickPlaceC on detectObject to stm_ref0 on detectObject

	connection PickPlaceC on detectGoal to stm_ref0 on detectGoal
	cycleDef cycle == 1
}

stm PickPlaceS {
	clock C

	input context { uses detectObjectI uses detectGoalI }
	output context { requires PickPlaceI }
	cycleDef cycle == 1
initial i0
	state Finding_Object {
	}

	state Finding_Goal {
	}

	state PrePicking {
	}

	state PrePlacing {
	}

	state Returning {
	}

	transition t1 {
		from i0
		to Finding_Object
	}
	transition t2 {
		from Finding_Object
		to Finding_Object
		condition 
	
	
		not $ detectObject
		action 
	exec
	}
	transition t7 {
		from Finding_Goal
		to PrePlacing
		condition 
		
		
		$ detectGoal
		action # C ; PickPlaceI::PrePlace ( )
	}
	transition t5 {
		from PrePicking
		to PrePicking
		condition since ( C ) <= 2
		action 
	
	
	exec
	}
transition t6 {
		from Finding_Object
		to PrePicking
		condition 
		$ detectObject
		action # C ; PickPlaceI::PrePick ( )
	}
	transition t10 {
		from PrePlacing
		to PrePlacing
		condition since ( C ) <= 3
		action 
	
	exec
	}
	transition t14 {
		from Returning
		to Returning
		condition since ( C ) <= 2
		action 
	exec
	}
	transition t18 {
		from PrePicking
		to Finding_Goal
		condition since ( C ) > 2
	}
transition t3 {
		from Returning
		to Finding_Object
		condition since ( C ) > 2
	}
transition t0 {
		from Finding_Goal
		to Finding_Goal
		condition not $ detectGoal
		action exec
	}
	transition t9 {
		from PrePlacing
		to Returning
		condition since ( C ) > 3
		action # C ; PickPlaceI::Return ( )
	}
}

module PickPlace {
	robotic platform SimpleArm {
		uses detectObjectI uses detectGoalI provides PickPlaceI }

	cref ctrl_ref0 = PickPlaceC
	cycleDef cycle == 1

	connection SimpleArm on detectObject to ctrl_ref0 on detectObject ( _async )

	connection SimpleArm on detectGoal to ctrl_ref0 on detectGoal ( _async )
}

