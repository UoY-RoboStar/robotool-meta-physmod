package Joint_Relation

// Tests the 'relation' property on Joint

pmodel Joint_Relation {
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
			def { }
			flexibly connected to L1
			relation 1
		}
	}
}
