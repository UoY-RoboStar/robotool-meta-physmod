package Instantiation

// Tests the Instantiation class for constant value assignment

import physmod::math::*

joint RevoluteJoint {
	const H : vector ( real , 6 ) = [| 1 , 0 , 0 , 0 , 0 , 0 |]
	const LIMIT : real
	InOut q : real
	InOut XJ : matrix ( real , 6 , 6 )
	equation XJ == [|
		1 , 0 , 0 , 0 , 0 , 0 ;
		0 , cos ( q ) , - sin ( q ) , 0 , 0 , 0 ;
		0 , sin ( q ) , cos ( q ) , 0 , 0 , 0 ;
		0 , 0 , 0 , 1 , 0 , 0 ;
		0 , 0 , 0 , 0 , cos ( q ) , - sin ( q ) ;
		0 , 0 , 0 , 0 , sin ( q ) , cos ( q )
	|]
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
