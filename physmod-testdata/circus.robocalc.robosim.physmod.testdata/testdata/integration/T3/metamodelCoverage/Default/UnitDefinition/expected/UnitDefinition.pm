package UnitDefinition

// Tests the UnitDefinition metamodel components
// Includes primitive units and derived units

primitive unit metre
primitive unit second
primitive unit kilogram

pmodel UnitDefinition {
	local link L1 {
		def { }
		local body B1 {
			def { box(length=0.1, width=0.1, height=0.1) }
		}
	}
}
derived unit newton {
	base kilogram * metre / second^2
	factor 1.0
}
