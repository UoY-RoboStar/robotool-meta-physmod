package Link_Relation

// Tests the 'relation' property on Link

pmodel Link_Relation {
	local link L1 {
		def { }
		relation 1
		local body B1 {
			def { box(length=0.1, width=0.1, height=0.1) }
		}
	}
}
