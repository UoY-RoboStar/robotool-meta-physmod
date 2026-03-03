package Index

// Tests the Index metamodel component
// Index provides a way to create multiple instances of elements

pmodel Index {
	local link L1 {
		index i : [0,3)
		def { }
		local body B1 {
			def { box(length=0.1, width=0.1, height=0.1) }
		}
	}
}
