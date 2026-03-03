package AnnotationInstantiation

// Tests AnnotationInstantiation metamodel components
// Including AnnotationValueInstantiation and AnnotationTemplateInstantiation

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
		local joint J1 {
			def {
				annotation JointAnnotation {
					stiffness = 100.0
					damping = 0.5
				}
				input position : real
				output torque : real
				equation torque == position
			}
			flexibly connected to L1
		}
	}
}
