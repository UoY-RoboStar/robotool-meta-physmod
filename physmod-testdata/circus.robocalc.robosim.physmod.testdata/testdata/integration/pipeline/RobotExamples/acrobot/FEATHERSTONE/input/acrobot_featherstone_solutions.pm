solution{
    solutionExpr q: vector(real,2)
    order 1
    group 1
    method GeneralisedPosition_method2
    Constraint (n)[t==0] == 3
    Constraint (N)[t==0] == 2
    Constraint (dt)[t==0] == 0.01
    Constraint (gravity)[t==0] == 9.81
    Constraint (q)[t==0] == (|1.0,1.0|)
    Constraint (d_q)[t==0] == zeroVec(2)
    Constraint (tau)[t==0] == zeroVec(2)
    Constraint (damping)[t==0] == [|0.1,0.0;0.0,0.1|]
}
solution{
    solutionExpr T_geom: Seq(matrix(real,4,4))
    order 10
    group 1
    method Visual
    Input B_1: matrix(real,4,4)
    Input B_2: matrix(real,4,4)
    Input B_3: matrix(real,4,4)
    Input B_k: Seq(matrix(real,4,4))
    Input L1_geom: Geom
    Input L2_geom: Geom
    Input L3_geom: Geom
    Input T_geom: Seq(matrix(real,4,4))
    Input T_offset: Seq(matrix(real,4,4))
    Input T_geom_1: matrix(real,4,4)
    Input T_geom_2: matrix(real,4,4)
    Input T_geom_3: matrix(real,4,4)
    Input T_offset_1: matrix(real,4,4)
    Input T_offset_2: matrix(real,4,4)
    Input T_offset_3: matrix(real,4,4)
    Constraint (B_1)[t==0] == [|1.0,0.0,0.0,0.0; 0.0,1.0,0.0,0.15; 0.0,0.0,1.0,0.0; 0,0,0,1|]
    Constraint (B_2)[t==0] == [|1.0,0.0,0.0,0.0; 0.0,1.0,0.0,0.0; 0.0,0.0,1.0,0.0; 0,0,0,1|]
    Constraint (B_3)[t==0] == [|1.0,0.0,0.0,0.0; 0.0,1.0,0.0,0.0; 0.0,0.0,1.0,0.0; 0,0,0,1|]
    Constraint (B_k)[t==0] == <B_1, B_2, B_3>
    Constraint (T_geom_1)[t==0] == [|1.0,0.0,0.0,0.0; 0.0,1.0,0.0,0.0; 0.0,0.0,1.0,-0.4; 0,0,0,1|]
    Constraint (T_geom_2)[t==0] == [|1.0,0.0,0.0,0.0; 0.0,1.0,0.0,0.0; 0.0,0.0,1.0,-2.15; 0,0,0,1|]
    Constraint (T_geom_3)[t==0] == [|1.0,0.0,0.0,0.0; 0.0,1.0,0.0,0.0; 0.0,0.0,1.0,-0.1; 0,0,0,1|]
    Constraint (T_offset_1)[t==0] == [|1.0,0.0,0.0,0.0; 0.0,1.0,0.0,0.0; 0.0,0.0,1.0,-1.05; 0,0,0,1|]
    Constraint (T_offset_2)[t==0] == [|1.0,0.0,0.0,0.0; 0.0,1.0,0.0,0.0; 0.0,0.0,1.0,-0.55; 0,0,0,1|]
    Constraint (T_offset_3)[t==0] == [|1.0,0.0,0.0,0.0; 0.0,1.0,0.0,0.0; 0.0,0.0,1.0,-0.1; 0,0,0,1|]
    Constraint (T_geom)[t==0] == <T_geom_1, T_geom_2, T_geom_3>
    Constraint (T_offset)[t==0] == <T_offset_1, T_offset_2, T_offset_3>
    Constraint (L1_geom.geomType)[t==0] == "cylinder"
    Constraint (L1_geom.geomVal)[t==0] == [| 0.05 , 1.0 |]
    Constraint (L2_geom.geomType)[t==0] == "cylinder"
    Constraint (L2_geom.geomVal)[t==0] == [| 0.05 , 2.0 |]
    Constraint (L3_geom.geomType)[t==0] == "box"
    Constraint (L3_geom.geomVal)[t==0] == [| 0.2 , 0.2 , 0.2 |]
}
