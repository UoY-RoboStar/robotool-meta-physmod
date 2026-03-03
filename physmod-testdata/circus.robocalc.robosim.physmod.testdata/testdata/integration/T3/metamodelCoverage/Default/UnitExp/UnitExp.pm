package UnitExp

// Tests the UnitExp metamodel component
// Syntax: expression unit

primitive unit metre
primitive unit second

pmodel UnitExp {
	local distance : real
	local time_val : real

	equation distance == 1.0 metre
	equation time_val == 2.0 second

	local link L1 {
		def { }
		local body B1 {
			def { box(length=0.1, width=0.1, height=0.1) }
		}
	}
}
