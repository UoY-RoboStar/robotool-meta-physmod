pmodel pm1 {
    InOut theta: vector(real,2)
    InOut X_J: Seq(matrix(real,6,6))
    InOut X_J_1: matrix(real,6,6)
    InOut X_J_2: matrix(real,6,6)
    // Individual X_J_i algebraic constraints (rotation matrices)
    Constraint (X_J_1)[t==t] == [|cos(theta[0]),-sin(theta[0]),0,0,0,0;sin(theta[0]),cos(theta[0]),0,0,0,0;0,0,1,0,0,0;0,0,0,cos(theta[0]),-sin(theta[0]),0;0,0,0,sin(theta[0]),cos(theta[0]),0;0,0,0,0,0,1|]
    Constraint (X_J_2)[t==t] == [|1,0,0,0,0,0;0,cos(theta[1]),-sin(theta[1]),0,0,0;0,sin(theta[1]),cos(theta[1]),0,0,0;0,0,0,1,0,0;0,0,0,0,cos(theta[1]),-sin(theta[1]);0,0,0,0,sin(theta[1]),cos(theta[1])|]
    // Sequence aggregate algebraic constraint
    Constraint (X_J)[t==t] == <X_J_1, X_J_2>
    // Initial conditions
    Constraint (X_J_1)[t==0] == zeroMat(6,6)
    Constraint (X_J_2)[t==0] == zeroMat(6,6)
    Constraint (X_J)[t==0] == <X_J_1, X_J_2>
    Constraint (theta)[t==0] == zeroVec(2)
}
