solution{
	solutionExpr u: vector(real,1)
	order 0
	group 0
	method PlatformMapping
}

solution{
	solutionExpr B_k: Seq(matrix(real,4,4))
	order 1
	group 0
	method ForwardKinematics
	Input n: int
	Input theta: vector(real,2)
	Input X_J: Seq(matrix(real,6,6))
	Input X_J_1: matrix(real,6,6)
	Input X_J_2: matrix(real,6,6)
	Input X_T: Seq(matrix(real,6,6))
	Input X_T_1: matrix(real,6,6)
	Input X_T_2: matrix(real,6,6)
	Input X_T_3: matrix(real,6,6)
	Input B_1: matrix(real,4,4)
	Input B_2: matrix(real,4,4)
	Input B_3: matrix(real,4,4)
	Constraint (n) [t == 0] == 3
	Constraint (theta) [t == 0] == [|-0.1; 0.1|]
	Constraint (B_k) [t == 0] == <B_1, B_2, B_3>
	Constraint (B_1) [t == 0] == [|1,0,0,0; 0,1,0,0.15; 0,0,1,0; 0,0,0,1|]
	Constraint (B_2) [t == 0] == [|1,0,0,0; 0,1,0,0; 0,0,1,0; 0,0,0,1|]
	Constraint (B_3) [t == 0] == [|1,0,0,0; 0,1,0,0; 0,0,1,0; 0,0,0,1|]
	Constraint (X_J) [t == 0] == <X_J_1, X_J_2>
	Constraint (X_J_1) [t == 0] == zeroMat(6,6)
	Constraint (X_J_2) [t == 0] == zeroMat(6,6)
	Constraint (X_J_1) [t == t] == [|1,0,0,0,0,0; 0,cos(theta(0)),-sin(theta(0)),0,0,0; 0,sin(theta(0)),cos(theta(0)),0,0,0; 0,0,0,1,0,0; 0,0,0,0,cos(theta(0)),-sin(theta(0)); 0,0,0,0,sin(theta(0)),cos(theta(0))|]
	Constraint (X_J_2) [t == t] == [|1,0,0,0,0,0; 0,cos(theta(1)),-sin(theta(1)),0,0,0; 0,sin(theta(1)),cos(theta(1)),0,0,0; 0,0,0,1,0,0; 0,0,0,0,cos(theta(1)),-sin(theta(1)); 0,0,0,0,sin(theta(1)),cos(theta(1))|]
	Constraint (X_T) [t == 0] == <X_T_1, X_T_2, X_T_3>
	Constraint (X_T_1) [t == 0] == [|1,0,0,0,0,0; 0,1,0,0,0,0; 0,0,1,0,0,0; 0,-1,0,1,0,0; 1,0,0,0,1,0; 0,0,0,0,0,1|]
	Constraint (X_T_2) [t == 0] == identity(6,6)
	Constraint (X_T_3) [t == 0] == identity(6,6)
}

solution{
	solutionExpr tau: vector(real,2)
	order 2
	group 0
	method ControlledActuator
	Input B_ctrl: matrix(real,2,1)
	Constraint (B_ctrl) [t == 0] == [|1.0; 0.0|]
}

solution{
	solutionExpr theta: vector(real,2)
	order 3
	group 0
	method GeneralisedPosition_method1_gravity_damping
	Input M: matrix(real,18,18)
	Input T_offset_1: matrix(real,4,4)
	Input T_offset_2: matrix(real,4,4)
	Input T_offset_3: matrix(real,4,4)
	Constraint (theta) [t == 0] == [|-0.1; 0.1|]
	Constraint (d_theta) [t == 0] == [|0.02; 0.0|]
	Constraint (dt) [t == 0] == 0.005
	Constraint (submatrix(M)(0,0,6,6)) [t == 0] == [|1.33,0,0,0,1,0; 0,1,0,-1,0,0; 0,0,0,0,0,0; 0,-1,0,1,0,0; 1,0,0,0,1,0; 0,0,0,0,0,1|]
	Constraint (submatrix(M)(6,6,6,6)) [t == 0] == [|0.333,0,0,0,0.5,0; 0,0.25,0,-0.5,0,0; 0,0,0,0,0,0; 0,-0.5,0,1,0,0; 0.5,0,0,0,1,0; 0,0,0,0,0,1|]
	Constraint (submatrix(M)(12,12,6,6)) [t == 0] == zeroMat(6,6)
	Constraint (T_offset_1) [t == 0] == [|1,0,0,0; 0,1,0,0; 0,0,1,-1.05; 0,0,0,1|]
	Constraint (T_offset_2) [t == 0] == [|1,0,0,0; 0,1,0,0; 0,0,1,-0.55; 0,0,0,1|]
	Constraint (T_offset_3) [t == 0] == [|1,0,0,0; 0,1,0,0; 0,0,1,-0.1; 0,0,0,1|]
}

solution{
	solutionExpr T_geom: Seq(matrix(real,4,4))
	order 8
	group 0
	method Visualisation
}

solution{
	solutionExpr L_k_geom: Seq(Geom)
	order 9
	group 0
	method Visual
	Input L1_geom: Geom
	Input L2_geom: Geom
	Input L3_geom: Geom
}

solution{
	solutionExpr ShoulderEncoderAngle: real
	order 10
	group 0
	method JointEncoderAngle
}

solution{
	solutionExpr ShoulderEncoderVelocity: real
	order 11
	group 0
	method JointEncoderVelocity
}

solution{
	solutionExpr ElbowEncoderAngle: real
	order 12
	group 0
	method JointEncoderAngle
}

solution{
	solutionExpr ElbowEncoderVelocity: real
	order 13
	group 0
	method JointEncoderVelocity
}
