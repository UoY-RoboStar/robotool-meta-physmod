package Link_RelationFlexi

// Tests the 'relation_flexi' property on Link

pmodel Link_RelationFlexi {
	local link L1 {
		def { }
		relation_flexi 2
		local body B1 {
			def { box(length=0.1, width=0.1, height=0.1) }
		}
	}
}
