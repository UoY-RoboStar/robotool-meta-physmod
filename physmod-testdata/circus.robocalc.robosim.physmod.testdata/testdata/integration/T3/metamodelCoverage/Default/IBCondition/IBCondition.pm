package IBCondition

// Tests the IBCondition (Initial/Boundary Condition) metamodel component
// IBCondition syntax: (expression)[variable == value]

pmodel IBCondition {
	local theta : real

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
		Input omega : real
		Constraint (theta) [t == 0] == 1.0
	}
}
