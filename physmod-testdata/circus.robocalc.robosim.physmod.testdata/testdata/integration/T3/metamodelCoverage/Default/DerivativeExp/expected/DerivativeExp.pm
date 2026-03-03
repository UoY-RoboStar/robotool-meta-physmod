package DerivativeExp

// Tests the DerivativeExp metamodel component
// Syntax: derivative(expression)

pmodel DerivativeExp {
	local theta : real
	local omega : real

	equation omega == derivative(theta)

	local link L1 {
		def { }
		local body B1 {
			def { box(length=0.1, width=0.1, height=0.1) }
		}
	}
}
