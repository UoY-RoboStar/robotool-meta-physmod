package IntegralExp

// Tests the IntegralExp metamodel component
// Syntax: integral(expression) or integral(expression, lower, upper)

pmodel IntegralExp {
	local theta : real
	local position : real

	equation position == integral(theta)

	local link L1 {
		def { }
		local body B1 {
			def { box(length=0.1, width=0.1, height=0.1) }
		}
	}
}
