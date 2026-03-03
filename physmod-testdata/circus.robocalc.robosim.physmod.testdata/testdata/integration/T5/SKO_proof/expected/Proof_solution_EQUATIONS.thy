section \<open> Proof_solution Physics Equations \<close>

theory Proof_solution_EQUATIONS
  imports "Hybrid-Verification.Hybrid_Verification"
begin

text \<open> Geometry datatype for link visualization \<close>
record Geom =
  geomType :: string
  geomVal :: "real list"

dataspace proof_solution_system =
  variables
    proof_var :: int
    N :: real
    B_k :: "(real mat[4, 4]) list"
    X_J :: "(real mat[6, 6]) list"
    X_T :: "(real mat[6, 6]) list"
    V :: "real ^18"
    f :: "real ^18"
    a :: "real ^18"
    b :: "real ^18"
    alpha :: "real ^18"
    phi :: "real mat[18, 18]"
    M :: "real mat[18, 18]"
    theta :: "real ^2"
    tau :: "real ^2"
    C :: "real ^2"
    H :: "real mat[2, 18]"
    M_mass :: "real mat[2, 2]"
    H_1 :: "real mat[1, 6]"
    H_2 :: "real mat[1, 6]"
    B_1 :: "real mat[4, 4]"
    X_T_1 :: "real mat[6, 6]"
    M_1 :: "real mat[6, 6]"
    r_v1 :: real
    T_2_1 :: "real mat[4, 4]"
    B_2 :: "real mat[4, 4]"
    X_T_2 :: "real mat[6, 6]"
    M_2 :: "real mat[6, 6]"
    r_v2 :: real
    T_3_2 :: "real mat[4, 4]"
    B_3 :: "real mat[4, 4]"
    X_T_3 :: "real mat[6, 6]"
    M_3 :: "real mat[6, 6]"
    X_J_1 :: "real mat[6, 6]"
    X_J_2 :: "real mat[6, 6]"
    n :: int
    d_theta :: "real ^2"
    dd_theta :: "real ^2"
    M_inv :: "real mat[2, 2]"
    dt :: real
    sensor_outputs :: real
    T_geom :: "(real mat[4, 4]) list"
    T_offset :: "(real mat[4, 4]) list"
    T_offset_1 :: "real mat[4, 4]"
    T_offset_2 :: "real mat[4, 4]"
    T_offset_3 :: "real mat[4, 4]"
    geom_31 :: "Geom"
    geom_21 :: "Geom"
    geom_11 :: "Geom"
    T_geom_1 :: "real mat[4, 4]"
    T_geom_2 :: "real mat[4, 4]"
    T_geom_3 :: "real mat[4, 4]"
    BaseLink_BaseSensor_SignalIn :: real
    BaseLink_BaseSensor_MeasurementOut :: real
    BaseLink_ElbowActuator_TorqueIn :: real
    BaseLink_ElbowActuator_TorqueOut :: real
    IntermediateLink_WristActuator_TorqueIn :: real
    IntermediateLink_WristActuator_TorqueOut :: real
    theta' :: "real ^2"
    theta'' :: "real ^2"
  

context proof_solution_system
begin

definition n_init where "n_init \<equiv> (N = 2)\<^sup>e"
definition b_k_init where "b_k_init \<equiv> (B_k = [B_1, B_2, B_3])\<^sup>e"
definition x_j_init where "x_j_init \<equiv> (X_J = [X_J_1, X_J_2])\<^sup>e"
definition x_t_init where "x_t_init \<equiv> (X_T = [X_T_1, X_T_2, X_T_3])\<^sup>e"
definition h_init where "h_init \<equiv> (H = \<^bold>[[0], [,], [0], [,], [1], [,], [0], [,], [0], [,], [0]\<^bold>])\<^sup>e"
definition b_1_init where "b_1_init \<equiv> (B_1 = \<^bold>[[1.0,0.0,0.0,0.0], [0.0,1.0,0.0,0.0], [0.0,0.0,1.0,4.75], [0,0,0,1]\<^bold>])\<^sup>e"
definition x_t_1_init where "x_t_1_init \<equiv> (X_T_1 = \<^bold>[[1,0,0,0,0,0], [0,1,0,0,0,0], [0,0,1,0,0,0], [0,-4.0,0.0,1,0,0], [4.0,0,0.0,0,1,0], [0.0,0.0,0,0,0,1]\<^bold>])\<^sup>e"
definition m_1_init where "m_1_init \<equiv> (M_1 = \<^bold>[[0.052050002,0.0,0.0,0.0,-0.125,0.0], [0.0,0.052050002,0.0,0.125,0.0,0.0], [0.0,0.0,0.0208,0.0,0.0,0.0], [0.0,0.125,0.0,0.5,0.0,0.0], [-0.125,0.0,0.0,0.0,0.5,0.0], [0.0,0.0,0.0,0.0,0.0,0.5]\<^bold>])\<^sup>e"
definition b_2_init where "b_2_init \<equiv> (B_2 = \<^bold>[[1.0,0.0,0.0,0.0], [0.0,1.0,0.0,0.0], [0.0,0.0,1.0,2.5], [0,0,0,1]\<^bold>])\<^sup>e"
definition x_t_2_init where "x_t_2_init \<equiv> (X_T_2 = \<^bold>[[1,0,0,0,0,0], [0,1,0,0,0,0], [0,0,1,0,0,0], [0,-0.5,0.0,1,0,0], [0.5,0,0.0,0,1,0], [0.0,0.0,0,0,0,1]\<^bold>])\<^sup>e"
definition m_2_init where "m_2_init \<equiv> (M_2 = \<^bold>[[5.349,0.0,0.0,0.0,-2.0,0.0], [0.0,5.349,0.0,2.0,0.0,0.0], [0.0,0.0,0.0313,0.0,0.0,0.0], [0.0,2.0,0.0,1.0,0.0,0.0], [-2.0,0.0,0.0,0.0,1.0,0.0], [0.0,0.0,0.0,0.0,0.0,1.0]\<^bold>])\<^sup>e"
definition b_3_init where "b_3_init \<equiv> (B_3 = \<^bold>[[1.0,0.0,0.0,0.0], [0.0,1.0,0.0,0.0], [0.0,0.0,1.0,0.25], [0,0,0,1]\<^bold>])\<^sup>e"
definition x_t_3_init where "x_t_3_init \<equiv> (X_T_3 = \<^bold>[[1,0,0,0,0,0], [0,1,0,0,0,0], [0,0,1,0,0,0], [0,0,0,1,0,0], [0,0,0,0,1,0], [0,0,0,0,0,1]\<^bold>])\<^sup>e"
definition m_3_init where "m_3_init \<equiv> (M_3 = \<^bold>[[16.667,0.0,0.0,0.0,-25.0,0.0], [0.0,22.917,0.0,25.0,0.0,0.0], [0.0,0.0,10.417,0.0,0.0,0.0], [0.0,25.0,0.0,100.0,0.0,0.0], [-25.0,0.0,0.0,0.0,100.0,0.0], [0.0,0.0,0.0,0.0,0.0,100.0]\<^bold>])\<^sup>e"
definition n_init_2 where "n_init_2 \<equiv> (n = 3)\<^sup>e"
definition dt_init where "dt_init \<equiv> (dt = 0.01)\<^sup>e"
definition geom_31_init where "geom_31_init \<equiv> (geom_31 = Geom { geomType = \\"box\\", geomVal = [1.0 , 1.0 , 0.5], meshUri = \\"\\", meshScale = [1.0] })\<^sup>e"
definition geom_21_init where "geom_21_init \<equiv> (geom_21 = Geom { geomType = \\"cylinder\\", geomVal = [0.25 , 4.0], meshUri = \\"\\", meshScale = [1.0] })\<^sup>e"
definition geom_11_init where "geom_11_init \<equiv> (geom_11 = Geom { geomType = \\"box\\", geomVal = [0.5 , 0.5 , 0.5], meshUri = \\"\\", meshScale = [1.0] })\<^sup>e"
definition t_geom_1_init where "t_geom_1_init \<equiv> (T_geom_1 = \<^bold>[[1.0,0.0,0.0,0.0], [0.0,1.0,0.0,0.0], [0.0,0.0,1.0,4.75], [0,0,0,1]\<^bold>])\<^sup>e"
definition t_geom_2_init where "t_geom_2_init \<equiv> (T_geom_2 = \<^bold>[[1.0,0.0,0.0,0.0], [0.0,1.0,0.0,0.0], [0.0,0.0,1.0,2.5], [0,0,0,1]\<^bold>])\<^sup>e"
definition t_geom_3_init where "t_geom_3_init \<equiv> (T_geom_3 = \<^bold>[[1.0,0.0,0.0,0.0], [0.0,1.0,0.0,0.0], [0.0,0.0,1.0,0.25], [0,0,0,1]\<^bold>])\<^sup>e"

text \<open> System algebraic constraints \<close>

definition b_k_eq where "b_k_eq \<equiv> (B_k = [B_1, B_2, B_3])\<^sup>e"
definition x_t_eq where "x_t_eq \<equiv> (X_T = [X_T_1, X_T_2, X_T_3])\<^sup>e"
definition x_j_eq where "x_j_eq \<equiv> (X_J = [X_J_1, X_J_2])\<^sup>e"
definition v_eq where "v_eq \<equiv> (V = transpose phi ** transpose H *v theta')\<^sup>e"
definition alpha_eq where "alpha_eq \<equiv> (alpha = transpose phi ** transpose H *v theta' + a)\<^sup>e"
definition f_eq where "f_eq \<equiv> (f = phi * M *v alpha + b)\<^sup>e"
definition tau_eq where "tau_eq \<equiv> (tau = M_mass *v theta'' + C)\<^sup>e"
definition m_mass_eq where "m_mass_eq \<equiv> (M_mass = H *v phi ** M ** transpose phi ** transpose H)\<^sup>e"
definition c_eq where "c_eq \<equiv> (C = H *v (M ** transpose phi *v a + b))\<^sup>e"
definition b_1_eq where "b_1_eq \<equiv> (B_1 = B_3 ** T_3_2 ** T_2_1)\<^sup>e"
definition b_2_eq where "b_2_eq \<equiv> (B_2 = B_3 ** T_3_2)\<^sup>e"
definition n_eq where "n_eq \<equiv> (N = r_v1 + r_v2)\<^sup>e"
definition x_j_1_eq where "x_j_1_eq \<equiv> (X_J_1 = \<^bold>[[((0)),-((0)),0,0,0,0],
  [((0)),((0)),0,0,0,0],
  [0,0,1,0,0,0],
  [0,0,0,((0)),-((0)),0],
  [0,0,0,((0)),((0)),0],
  [0,0,0,0,0,1]\<^bold>])\<^sup>e"
definition x_j_2_eq where "x_j_2_eq \<equiv> (X_J_2 = \<^bold>[[1,0,0,0,0,0],
  [0,((1)),-((1)),0,0,0],
  [0,((1)),((1)),0,0,0],
  [0,0,0,1,0,0],
  [0,0,0,0,((1)),-((1))],
  [0,0,0,0,((1)),((1))]\<^bold>])\<^sup>e"
definition baselink_basesensor_signalin_eq where "baselink_basesensor_signalin_eq \<equiv> (BaseLink_BaseSensor_SignalIn = BaseLink_BaseSensor_MeasurementOut)\<^sup>e"
definition baselink_elbowactuator_torquein_eq where "baselink_elbowactuator_torquein_eq \<equiv> (BaseLink_ElbowActuator_TorqueIn = BaseLink_ElbowActuator_TorqueOut)\<^sup>e"
definition intermediatelink_wristactuator_torquein_eq where "intermediatelink_wristactuator_torquein_eq \<equiv> (IntermediateLink_WristActuator_TorqueIn = IntermediateLink_WristActuator_TorqueOut)\<^sup>e"
definition t_geom_1_eq where "t_geom_1_eq \<equiv> (T_geom_1 = B_1 ** T_offset_1)\<^sup>e"
definition t_geom_2_eq where "t_geom_2_eq \<equiv> (T_geom_2 = B_2 ** T_offset_2)\<^sup>e"
definition t_geom_3_eq where "t_geom_3_eq \<equiv> (T_geom_3 = B_3 ** T_offset_3)\<^sup>e"
definition t_geom_eq where "t_geom_eq \<equiv> (T_geom = [T_geom_1, T_geom_2, T_geom_3])\<^sup>e"
definition x_j_1_eq_2 where "x_j_1_eq_2 \<equiv> (X_J_1 = \<^bold>[[((0)),-((0)),0,0,0,0],
  [((0)),((0)),0,0,0,0],
  [0,0,1,0,0,0],
  [0,0,0,((0)),-((0)),0],
  [0,0,0,((0)),((0)),0],
  [0,0,0,0,0,1]\<^bold>])\<^sup>e"
definition x_j_2_eq_2 where "x_j_2_eq_2 \<equiv> (X_J_2 = \<^bold>[[1,0,0,0,0,0],
  [0,((1)),-((1)),0,0,0],
  [0,((1)),((1)),0,0,0],
  [0,0,0,1,0,0],
  [0,0,0,0,((1)),-((1))],
  [0,0,0,0,((1)),((1))]\<^bold>])\<^sup>e"
definition x_j_eq_2 where "x_j_eq_2 \<equiv> (X_J = [X_J_1, X_J_2])\<^sup>e"
definition baselink_basesensor_signalin_eq_2 where "baselink_basesensor_signalin_eq_2 \<equiv> (BaseLink_BaseSensor_SignalIn = BaseLink_BaseSensor_MeasurementOut)\<^sup>e"
definition t_geom_1_eq_2 where "t_geom_1_eq_2 \<equiv> (T_geom_1 = B_1 ** T_offset_1)\<^sup>e"
definition t_geom_2_eq_2 where "t_geom_2_eq_2 \<equiv> (T_geom_2 = B_2 ** T_offset_2)\<^sup>e"
definition t_geom_3_eq_2 where "t_geom_3_eq_2 \<equiv> (T_geom_3 = B_3 ** T_offset_3)\<^sup>e"
definition t_geom_eq_2 where "t_geom_eq_2 \<equiv> (T_geom = [T_geom_1, T_geom_2, T_geom_3])\<^sup>e"

end

end
