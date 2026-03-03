package Body_Relation

// Tests the 'relation' property on Body

pmodel Body_Relation {
	local link L1 {
		def { }
		local body B1 {
			def { box(length=0.1, width=0.1, height=0.1) }
			relation 1
		}
	}
}
