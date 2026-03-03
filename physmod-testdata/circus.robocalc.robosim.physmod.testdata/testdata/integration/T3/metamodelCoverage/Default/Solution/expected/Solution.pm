package Solution

// Tests the Solution metamodel component

pmodel Solution {
	local link L1 {
		def { }
		local body B1 {
			def { box(length=0.1, width=0.1, height=0.1) }
		}
	}

	solution {
		solutionExpr phi : real
		order 1
		group 0
		method Eval
		Input theta : real
		Input omega : real
	}
}
