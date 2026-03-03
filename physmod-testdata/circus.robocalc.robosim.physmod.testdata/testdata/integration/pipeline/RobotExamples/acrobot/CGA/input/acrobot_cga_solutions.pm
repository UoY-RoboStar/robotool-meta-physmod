solution{
    solutionExpr motor_k: Seq(vector(real,8))
    order 1
    group 1
    method ForwardKinematics
    Input theta: vector(real,2)
    Input motor_T: Seq(vector(real,8))
    Input axis_rot: Seq(vector(real,3))
    Input axis_lin: Seq(vector(real,3))
    Input joint_type: Seq(int)
    Input n: int
    Input N: int
    Constraint (n)[t==0] == 3
    Constraint (N)[t==0] == 2
    Constraint (theta)[t==0] == (|1.0,1.0|)
    Constraint (motor_T)[t==0] == <[|1.0,0.0,0.0,0.0,0.0,0.0,0.5,0.0|], [|1.0,0.0,0.0,0.0,0.0,0.0,1.0,0.0|], [|1.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0|]>
    Constraint (axis_rot)[t==0] == <[|0.0,1.0,0.0|], [|0.0,1.0,0.0|]>
    Constraint (axis_lin)[t==0] == <[|0.0,0.0,0.0|], [|0.0,0.0,0.0|]>
    Constraint (joint_type)[t==0] == <0,0>
}
solution{
    solutionExpr dd_theta: vector(real,2)
    order 2
    group 1
    method ABAForwardDynamics
    Input theta: vector(real,2)
    Input d_theta: vector(real,2)
    Input tau: vector(real,2)
    Input damping: matrix(real,2,2)
    Input gravity: real
    Input B_k: Seq(matrix(real,4,4))
    Input axis_rot: Seq(vector(real,3))
    Input axis_lin: Seq(vector(real,3))
    Input joint_type: Seq(int)
    Input mass_k: Seq(real)
    Input com_k: Seq(vector(real,3))
    Input inertia_k: Seq(matrix(real,3,3))
    Input N: int
    Constraint (N)[t==0] == 2
    Constraint (theta)[t==0] == (|1.0,1.0|)
    Constraint (d_theta)[t==0] == (|0.0,0.0|)
    Constraint (tau)[t==0] == (|0.0,0.0|)
    Constraint (damping)[t==0] == [|0.0,0.0;0.0,0.0|]
    Constraint (gravity)[t==0] == 9.81
    Constraint (axis_rot)[t==0] == <[|0.0,1.0,0.0|], [|0.0,1.0,0.0|]>
    Constraint (axis_lin)[t==0] == <[|0.0,0.0,0.0|], [|0.0,0.0,0.0|]>
    Constraint (joint_type)[t==0] == <0,0>
    Constraint (mass_k)[t==0] == <1.0,1.0>
    Constraint (com_k)[t==0] == <[|0.0,0.0,0.0|], [|0.0,0.0,0.0|]>
    Constraint (inertia_k)[t==0] == <[|0.083,0.0,0.0;0.0,0.083,0.0;0.0,0.0,0.001|], [|0.333,0.0,0.0;0.0,0.333,0.0;0.0,0.0,0.001|]>
    Constraint (B_1)[t==0] == [|1.0,0.0,0.0,0.0; 0.0,1.0,0.0,0.0; 0.0,0.0,1.0,0.0; 0.0,0.0,0.0,1.0|]
    Constraint (B_2)[t==0] == [|1.0,0.0,0.0,0.0; 0.0,1.0,0.0,0.0; 0.0,0.0,1.0,0.0; 0.0,0.0,0.0,1.0|]
    Constraint (B_3)[t==0] == [|1.0,0.0,0.0,0.0; 0.0,1.0,0.0,0.0; 0.0,0.0,1.0,0.0; 0.0,0.0,0.0,1.0|]
    Constraint (B_k)[t==0] == <B_1, B_2, B_3>
    Constraint (dd_theta)[t==0] == zeroVec(2)
}
solution{
    solutionExpr d_theta: vector(real,2)
    order 3
    group 1
    method Euler
    Input dd_theta: vector(real,2)
    Input dt: real
    Constraint (dd_theta)[t==0] == zeroVec(2)
    Constraint (dt)[t==0] == 0.01
    Constraint (d_theta)[t==0] == (|0.0,0.0|)
}
solution{
    solutionExpr theta: vector(real,2)
    order 4
    group 1
    method Euler
    Input d_theta: vector(real,2)
    Input dt: real
    Constraint (d_theta)[t==0] == (|0.0,0.0|)
    Constraint (dt)[t==0] == 0.01
    Constraint (theta)[t==0] == (|1.0,1.0|)
}
solution{
    solutionExpr B_k: Seq(matrix(real,4,4))
    order 5
    group 1
    method Visual
    Input B_k: Seq(matrix(real,4,4))
    Input theta: vector(real,2)
    Input l: vector(real,2)
    Input lc: vector(real,2)
    Input n: int
    Input L1_geom: Geom
    Input L2_geom: Geom
    Input L3_geom: Geom
    Input B_1: matrix(real,4,4)
    Input B_2: matrix(real,4,4)
    Input B_3: matrix(real,4,4)
    Constraint (n)[t==0] == 3
    Constraint (theta)[t==0] == (|1.0,1.0|)
    Constraint (l)[t==0] == (|1.0,2.0|)
    Constraint (lc)[t==0] == (|0.5,1.0|)
    Constraint (B_1)[t==0] == [|1.0,0.0,0.0,0.0; 0.0,1.0,0.0,0.0; 0.0,0.0,1.0,0.0; 0.0,0.0,0.0,1.0|]
    Constraint (B_2)[t==0] == [|1.0,0.0,0.0,0.0; 0.0,1.0,0.0,0.0; 0.0,0.0,1.0,0.0; 0.0,0.0,0.0,1.0|]
    Constraint (B_3)[t==0] == [|1.0,0.0,0.0,0.0; 0.0,1.0,0.0,0.0; 0.0,0.0,1.0,0.0; 0.0,0.0,0.0,1.0|]
    Constraint (B_k)[t==0] == <B_1, B_2, B_3>
    Constraint (L1_geom.geomType)[t==0] == "cylinder"
    Constraint (L1_geom.geomVal)[t==0] == [|0.05, 1.0|]
    Constraint (L2_geom.geomType)[t==0] == "cylinder"
    Constraint (L2_geom.geomVal)[t==0] == [|0.05, 2.0|]
    Constraint (L3_geom.geomType)[t==0] == "sphere"
    Constraint (L3_geom.geomVal)[t==0] == [|0.08|]
}
