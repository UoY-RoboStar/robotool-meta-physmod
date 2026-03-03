package Instantiation

// Tests the Instantiation class for constant value assignment

joint RevoluteJoint {
	const LIMIT : real
}

pmodel Instantiation {
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
		jref J1 = RevoluteJoint {
			flexibly connected to L1
			instantiation LIMIT = 1.57
		}
	}
}
