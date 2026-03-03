package Annotation

// Tests the AnnotationTemplate metamodel component

annotation template SimpleAnnotation {
}

annotation template AnnotationWithParameter {
	param1 : real
}

pmodel Annotation {
	local link L1 {
		def { }
		local body B1 {
			def { box(length=0.1, width=0.1, height=0.1) }
		}
	}
}
