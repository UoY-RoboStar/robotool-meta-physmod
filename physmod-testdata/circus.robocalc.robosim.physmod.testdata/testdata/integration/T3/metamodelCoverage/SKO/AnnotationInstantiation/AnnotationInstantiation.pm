package AnnotationInstantiation

// Tests AnnotationInstantiation metamodel components
// Including AnnotationValueInstantiation and AnnotationTemplateInstantiation

import physmod::math::*

annotation template JointAnnotation {
	stiffness : real
	damping : real
}

annotation template NestedTemplate {
	gain : real
}

annotation template CompositeAnnotation {
	nested : template NestedTemplate
	scale : real
}

joint AnnotatedJoint {
	const H : vector ( real , 6 ) = [| 1 , 0 , 0 , 0 , 0 , 0 |]
	InOut theta : real
	InOut XJ : matrix ( real , 6 , 6 )
	equation XJ == [|
		1 , 0 , 0 , 0 , 0 , 0 ;
		0 , cos ( theta ) , - sin ( theta ) , 0 , 0 , 0 ;
		0 , sin ( theta ) , cos ( theta ) , 0 , 0 , 0 ;
		0 , 0 , 0 , 1 , 0 , 0 ;
		0 , 0 , 0 , 0 , cos ( theta ) , - sin ( theta ) ;
		0 , 0 , 0 , 0 , sin ( theta ) , cos ( theta )
	|]
	annotation JointAnnotation {
		stiffness = 100.0
		damping = 0.5
	}
	input position : real
	output torque : real
	equation torque == position
}

pmodel AnnotationInstantiation {
	local link L1 {
		def { }
		local body B1 {
			def { box(length=0.1, width=0.1, height=0.1) }
		}
	}
	local link L2 {
		def { }
		local body B2 {
			def { box(length=0.1, width=0.1, height=0.1) }
		}
		jref J1 = AnnotatedJoint {
			flexibly connected to L1
		}
	}
}
