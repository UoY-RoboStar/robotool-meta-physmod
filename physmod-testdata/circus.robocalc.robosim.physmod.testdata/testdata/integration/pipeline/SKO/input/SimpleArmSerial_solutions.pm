
	solution{
		solutionExpr theta: vector(real,2)
		order 1
		group 1
		method GeneralisedPosition_method1
	}

	solution{
		solutionExpr B_k: Seq(matrix(real,4,4))
		order 2
		group 1
		method Eval
	}

	solution{
		solutionExpr B_k: Seq(matrix(real,4,4))
		order 10
		group 1
		method Visual
		Input L1_geom: Geom
		Input L2_geom: Geom
		Input L3_geom: Geom
	}
