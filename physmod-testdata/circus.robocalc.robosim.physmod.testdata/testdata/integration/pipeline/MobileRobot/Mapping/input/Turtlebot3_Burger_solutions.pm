solution {
	solutionExpr u : vector(real,2)
	order 0
	group 0
	method PlatformMapping
}

solution {
	solutionExpr tau : vector(real,2)
	order 1
	group 0
	method ControlledActuator
	Input B_ctrl : matrix(real,2,2)
	Input u : vector(real,2)
}

solution {
	solutionExpr theta : vector(real,2)
	order 2
	group 0
	method GeneralisedPosition_method1_gravity_damping
	Constraint (theta) [t == 0] == [|0.0; 0.0|]
	Constraint (d_theta) [t == 0] == [|0.0; 0.0|]
	Constraint (dt) [t == 0] == 0.01
}

solution {
	solutionExpr B_k : Seq(matrix(real,4,4))
	order 3
	group 0
	method Eval
}

solution {
	solutionExpr T_geom : Seq(matrix(real,4,4))
	order 4
	group 0
	method Visualisation
}

solution {
	solutionExpr L_k_geom : Seq(Geom)
	order 5
	group 0
	method Visual
}
