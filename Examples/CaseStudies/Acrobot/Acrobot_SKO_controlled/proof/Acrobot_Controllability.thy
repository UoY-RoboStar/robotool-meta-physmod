 section \<open> Proof_solution Physics Equations \<close> 
theory Acrobot_Controllability
  imports
    "Hybrid-Verification.Hybrid_Verification"
    "HOL-Decision_Procs.Commutative_Ring"
begin

consts Phi :: "nat \<Rightarrow> nat \<Rightarrow> (real mat[4, 4]) list \<Rightarrow> real mat[3, 3]"

dataspace proof_solution_system = 
  variables
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
    B_ctrl :: "real mat[2, 1]"
    u :: "real ^1"
    theta' :: "real ^2"
    theta'' :: "real ^2"
    M_mass_inv :: "real mat[2, 2]"


context proof_solution_system
begin

(* === BEGIN auto-generated from Acrobot_SKO_controlled.pm via T3/T4/T5 pipeline === *)

definition n_init where "n_init \<equiv> (N = 2)\<^sup>e"
definition b_k_init where "b_k_init \<equiv> (B_k = [B_1, B_2, B_3])\<^sup>e"
definition x_j_init where "x_j_init \<equiv> (X_J = [X_J_1, X_J_2])\<^sup>e"
definition x_t_init where "x_t_init \<equiv> (X_T = [X_T_1, X_T_2, X_T_3])\<^sup>e"
definition m_init where "m_init \<equiv> (M = \<^bold>[[1.33,0.0,0.0,0.0,1.0,0.0,0,0,0,0,0,0,0,0,0,0,0,0], [0.0,1.0,0.0,-1.0,0.0,0.0,0,0,0,0,0,0,0,0,0,0,0,0], [0.0,0.0,0.0,0.0,0.0,0.0,0,0,0,0,0,0,0,0,0,0,0,0], [0.0,-1.0,0.0,1.0,0.0,0.0,0,0,0,0,0,0,0,0,0,0,0,0], [1.0,0.0,0.0,0.0,1.0,0.0,0,0,0,0,0,0,0,0,0,0,0,0], [0.0,0.0,0.0,0.0,0.0,1.0,0,0,0,0,0,0,0,0,0,0,0,0], [0,0,0,0,0,0,0.333,0.0,0.0,0.0,0.5,0.0,0,0,0,0,0,0], [0,0,0,0,0,0,0.0,0.25,0.0,-0.5,0.0,0.0,0,0,0,0,0,0], [0,0,0,0,0,0,0.0,0.0,0.0,0.0,0.0,0.0,0,0,0,0,0,0], [0,0,0,0,0,0,0.0,-0.5,0.0,1.0,0.0,0.0,0,0,0,0,0,0], [0,0,0,0,0,0,0.5,0.0,0.0,0.0,1.0,0.0,0,0,0,0,0,0], [0,0,0,0,0,0,0.0,0.0,0.0,0.0,0.0,1.0,0,0,0,0,0,0], [0,0,0,0,0,0,0,0,0,0,0,0,0.0,0.0,0.0,0.0,0.0,0.0], [0,0,0,0,0,0,0,0,0,0,0,0,0.0,0.0,0.0,0.0,0.0,0.0], [0,0,0,0,0,0,0,0,0,0,0,0,0.0,0.0,0.0,0.0,0.0,0.0], [0,0,0,0,0,0,0,0,0,0,0,0,0.0,0.0,0.0,0.0,0.0,0.0], [0,0,0,0,0,0,0,0,0,0,0,0,0.0,0.0,0.0,0.0,0.0,0.0], [0,0,0,0,0,0,0,0,0,0,0,0,0.0,0.0,0.0,0.0,0.0,0.0]\<^bold>])\<^sup>e"
definition h_init where "h_init \<equiv> (H = \<^bold>[[1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0], [0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0]\<^bold>])\<^sup>e"
definition b_1_init where "b_1_init \<equiv> (B_1 = \<^bold>[[1.0,0.0,0.0,0.0], [0.0,1.0,0.0,0.15], [0.0,0.0,1.0,0.0], [0,0,0,1]\<^bold>])\<^sup>e"
definition x_t_1_init where "x_t_1_init \<equiv> (X_T_1 = \<^bold>[[1,0,0,0,0,0], [0,1,0,0,0,0], [0,0,1,0,0,0], [0,-1.0,0,1,0,0], [1.0,0,0,0,1,0], [0,0,0,0,0,1]\<^bold>])\<^sup>e"
definition b_2_init where "b_2_init \<equiv> (B_2 = \<^bold>[[1.0,0.0,0.0,0.0], [0.0,1.0,0.0,0.0], [0.0,0.0,1.0,0.0], [0,0,0,1]\<^bold>])\<^sup>e"
definition x_t_2_init where "x_t_2_init \<equiv> (X_T_2 = \<^bold>[[1,0,0,0,0,0], [0,1,0,0,0,0], [0,0,1,0,0,0], [0,0,0,1,0,0], [0,0,0,0,1,0], [0,0,0,0,0,1]\<^bold>])\<^sup>e"
definition b_3_init where "b_3_init \<equiv> (B_3 = \<^bold>[[1.0,0.0,0.0,0.0], [0.0,1.0,0.0,0.0], [0.0,0.0,1.0,0.0], [0,0,0,1]\<^bold>])\<^sup>e"
definition x_t_3_init where "x_t_3_init \<equiv> (X_T_3 = \<^bold>[[1,0,0,0,0,0], [0,1,0,0,0,0], [0,0,1,0,0,0], [0,0,0,1,0,0], [0,0,0,0,1,0], [0,0,0,0,0,1]\<^bold>])\<^sup>e"
definition b_ctrl_init where "b_ctrl_init \<equiv> (B_ctrl = \<^bold>[[1.0], [0.0]\<^bold>])\<^sup>e"


definition submatrix_phi_0_0_3_3_eq where "submatrix_phi_0_0_3_3_eq \<equiv> (\<^bold>[[phi$0$0,phi$0$1,phi$0$2],
  [phi$1$0,phi$1$1,phi$1$2],
  [phi$2$0,phi$2$1,phi$2$2]\<^bold>] = \<^bold>[[1,0,0],
  [0,1,0],
  [0,0,1]\<^bold>])\<^sup>e"
definition submatrix_phi_0_3_3_3_eq where "submatrix_phi_0_3_3_3_eq \<equiv> (\<^bold>[[phi$0$3,phi$0$4,phi$0$5],
  [phi$1$3,phi$1$4,phi$1$5],
  [phi$2$3,phi$2$4,phi$2$5]\<^bold>] = \<^bold>[[0,0,0],
  [0,0,0],
  [0,0,0]\<^bold>])\<^sup>e"
definition submatrix_phi_0_6_3_3_eq where "submatrix_phi_0_6_3_3_eq \<equiv> (\<^bold>[[phi$0$6,phi$0$7,phi$0$8],
  [phi$1$6,phi$1$7,phi$1$8],
  [phi$2$6,phi$2$7,phi$2$8]\<^bold>] = \<^bold>[[0,0,0],
  [0,0,0],
  [0,0,0]\<^bold>])\<^sup>e"
definition submatrix_phi_3_3_3_3_eq where "submatrix_phi_3_3_3_3_eq \<equiv> (\<^bold>[[phi$3$3,phi$3$4,phi$3$5],
  [phi$4$3,phi$4$4,phi$4$5],
  [phi$5$3,phi$5$4,phi$5$5]\<^bold>] = \<^bold>[[1,0,0],
  [0,1,0],
  [0,0,1]\<^bold>])\<^sup>e"
definition submatrix_phi_3_6_3_3_eq where "submatrix_phi_3_6_3_3_eq \<equiv> (\<^bold>[[phi$3$6,phi$3$7,phi$3$8],
  [phi$4$6,phi$4$7,phi$4$8],
  [phi$5$6,phi$5$7,phi$5$8]\<^bold>] = \<^bold>[[0,0,0],
  [0,0,0],
  [0,0,0]\<^bold>])\<^sup>e"
definition submatrix_phi_3_0_3_3_eq where "submatrix_phi_3_0_3_3_eq \<equiv> (\<^bold>[[phi$3$0,phi$3$1,phi$3$2],
  [phi$4$0,phi$4$1,phi$4$2],
  [phi$5$0,phi$5$1,phi$5$2]\<^bold>] = Phi 2 1 B_k)\<^sup>e"
definition submatrix_phi_6_6_3_3_eq where "submatrix_phi_6_6_3_3_eq \<equiv> (\<^bold>[[phi$6$6,phi$6$7,phi$6$8],
  [phi$7$6,phi$7$7,phi$7$8],
  [phi$8$6,phi$8$7,phi$8$8]\<^bold>] = \<^bold>[[1,0,0],
  [0,1,0],
  [0,0,1]\<^bold>])\<^sup>e"
definition submatrix_phi_6_0_3_3_eq where "submatrix_phi_6_0_3_3_eq \<equiv> (\<^bold>[[phi$6$0,phi$6$1,phi$6$2],
  [phi$7$0,phi$7$1,phi$7$2],
  [phi$8$0,phi$8$1,phi$8$2]\<^bold>] = Phi 3 1 B_k)\<^sup>e"
definition submatrix_phi_6_3_3_3_eq where "submatrix_phi_6_3_3_3_eq \<equiv> (\<^bold>[[phi$6$3,phi$6$4,phi$6$5],
  [phi$7$3,phi$7$4,phi$7$5],
  [phi$8$3,phi$8$4,phi$8$5]\<^bold>] = Phi 3 2 B_k)\<^sup>e"

definition b_k_eq where "b_k_eq \<equiv> (B_k = [B_1, B_2, B_3])\<^sup>e"
definition x_t_eq where "x_t_eq \<equiv> (X_T = [X_T_1, X_T_2, X_T_3])\<^sup>e"
definition x_j_eq where "x_j_eq \<equiv> (X_J = [X_J_1, X_J_2])\<^sup>e"
definition v_eq where "v_eq \<equiv> (V = transpose phi ** transpose H *v theta')\<^sup>e"
definition alpha_eq where "alpha_eq \<equiv> (alpha = transpose phi ** transpose H *v theta' + a)\<^sup>e"
definition f_eq where "f_eq \<equiv> (f = phi ** M *v alpha + b)\<^sup>e"
definition tau_dynamics_eq where "tau_dynamics_eq \<equiv> (tau = M_mass *v theta'' + C)\<^sup>e"
definition m_mass_eq where "m_mass_eq \<equiv> (M_mass = H ** phi ** M ** transpose phi ** transpose H)\<^sup>e"
definition c_eq where "c_eq \<equiv> (C = H *v (M ** transpose phi *v a + b))\<^sup>e"
definition b_1_eq where "b_1_eq \<equiv> (B_1 = B_3 ** T_3_2 ** T_2_1)\<^sup>e"
definition b_2_eq where "b_2_eq \<equiv> (B_2 = B_3 ** T_3_2)\<^sup>e"
definition n_eq where "n_eq \<equiv> (N = r_v1 + r_v2)\<^sup>e"
definition tau_ctrl_eq where "tau_ctrl_eq \<equiv> (tau = B_ctrl *v u)\<^sup>e"
definition M_mass_inv_eq where "M_mass_inv_eq \<equiv> (M_mass ** M_mass_inv = \<^bold>[[1,0],[0,1]\<^bold>])\<^sup>e"
definition x_j_1_eq where "x_j_1_eq \<equiv> (X_J_1 = \<^bold>[[1,0,0,0,0,0],
  [0,cos(theta$0),-sin(theta$0),0,0,0],
  [0,sin(theta$0),cos(theta$0),0,0,0],
  [0,0,0,1,0,0],
  [0,0,0,0,cos(theta$0),-sin(theta$0)],
  [0,0,0,0,sin(theta$0),cos(theta$0)]\<^bold>])\<^sup>e"
definition x_j_2_eq where "x_j_2_eq \<equiv> (X_J_2 = \<^bold>[[1,0,0,0,0,0],
  [0,cos(theta$1),-sin(theta$1),0,0,0],
  [0,sin(theta$1),cos(theta$1),0,0,0],
  [0,0,0,1,0,0],
  [0,0,0,0,cos(theta$1),-sin(theta$1)],
  [0,0,0,0,sin(theta$1),cos(theta$1)]\<^bold>])\<^sup>e"

(* === END auto-generated === *)

(* Plant ODE: theta'' = M_mass_inv * (B_ctrl * u - C).
   Derived from the generated equation tau_dynamics_eq (M_mass * theta'' + C = tau)
   and tau_ctrl_eq (tau = B_ctrl * u), solved for theta''. *)
definition Plant where
  "Plant \<equiv> { theta` = theta', theta'` = M_mass_inv *v ((B_ctrl *v u) - C) }"


definition n_dof :: "(real ^'n::finite \<Longrightarrow> 'st) \<Rightarrow> nat" where
  "n_dof (_::real ^'n \<Longrightarrow> 'st) \<equiv> CARD('n)"

definition m_inputs :: "(real mat['n::finite,'m::finite] \<Longrightarrow> 'st) \<Rightarrow> nat" where
  "m_inputs (_::real mat['n,'m] \<Longrightarrow> 'st) \<equiv> CARD('m)"

definition is_underactuated :: "nat \<Rightarrow> nat \<Rightarrow> bool" where
  "is_underactuated n m \<equiv> m < n"

theorem acrobot_is_underactuated:
  shows "is_underactuated (CARD(2)) (CARD(1))"
  unfolding is_underactuated_def
  by simp


lemma B_ctrl_underactuated:
  shows "m_inputs B_ctrl < n_dof theta"
  unfolding n_dof_def m_inputs_def by simp


lemma state_dim_is_4: "2 * n_dof theta = (4::nat)"
  unfolding n_dof_def by simp


definition degree_of_underactuation :: "nat \<Rightarrow> nat \<Rightarrow> nat" where
  "degree_of_underactuation n m \<equiv> n - m"

theorem acrobot_underactuation_degree:
  shows "degree_of_underactuation (n_dof theta) (m_inputs B_ctrl) = 1"
  unfolding degree_of_underactuation_def n_dof_def m_inputs_def
  by simp

(* A_lin: 4x4 linearized state matrix for the second-order system
   x = [theta, theta']^T. Parameterised by the 2x2 stiffness matrix
   K = M_mass_inv * (d(gravity)/d(theta)) evaluated at an equilibrium.
   Upper-right identity: theta' = d(theta)/dt.
   Lower-left K block: linearized acceleration from position. *)
definition A_lin :: "real mat[2,2] \<Rightarrow> real mat[4,4]" where
  "A_lin K \<equiv> \<^bold>[[0,0,1,0],
    [0,0,0,1],
    [K$0$0, K$0$1, 0, 0],
    [K$1$0, K$1$1, 0, 0]\<^bold>]"

(* B_lin: 4x1 linearized input matrix. Parameterised by L = M_mass_inv * B_ctrl.
   Zeros in rows 0-1: control does not directly affect position.
   Rows 2-3: control effect on acceleration via inverse mass matrix. *)
definition B_lin :: "real mat[2,1] \<Rightarrow> real mat[4,1]" where
  "B_lin L \<equiv> \<^bold>[[0],
    [0],
    [L$0$0],
    [L$1$0]\<^bold>]"

(* B_lin_from_B_ctrl: constructs the 4x1 linearized B from the 2x2 inverse
   mass matrix and the 2x1 control input matrix: L = M_inv * B_ctrl. *)
definition B_lin_from_B_ctrl :: "real mat[2,2] \<Rightarrow> real mat[2,1] \<Rightarrow> real mat[4,1]" where
  "B_lin_from_B_ctrl M_inv B \<equiv> B_lin (M_inv ** B)"

(* Controllability matrix C = [B | AB | A^2B | A^3B] for a 4-state, 1-input system.
   Full rank (det != 0) means the system is controllable (Kalman rank condition). *)
definition controllability_matrix_4x1 ::
  "real mat[4,4] \<Rightarrow> real mat[4,1] \<Rightarrow> real mat[4,4]" where
  "controllability_matrix_4x1 A B \<equiv>
    (let AB = A ** B in
     let A2B = A ** AB in
     let A3B = A ** A2B in
       \<^bold>[[B$0$0,  AB$0$0,  A2B$0$0,  A3B$0$0],
         [B$1$0,  AB$1$0,  A2B$1$0,  A3B$1$0],
         [B$2$0,  AB$2$0,  A2B$2$0,  A3B$2$0],
         [B$3$0,  AB$3$0,  A2B$3$0,  A3B$3$0]\<^bold>])"

(* Controllability: det of the 4x4 Kalman controllability matrix is non-zero. *)
definition is_controllable :: "real mat[4,4] \<Rightarrow> real mat[4,1] \<Rightarrow> bool" where
  "is_controllable A B \<equiv> det (controllability_matrix_4x1 A B) \<noteq> 0"

lemma det_block_diag_repeat_2x2:
  fixes m00 m01 m10 m11 :: real
  shows "det (\<^bold>[[m00,m01,0,0],
    [m10,m11,0,0],
    [0,0,m00,m01],
    [0,0,m10,m11]\<^bold>] :: real mat[4,4]) = (m00 * m11 - m01 * m10)\<^sup>2"
proof -
  let ?A = "(\<^bold>[[m00,m01,0,0],
    [m10,m11,0,0],
    [0,0,m00,m01],
    [0,0,m10,m11]\<^bold>] :: real mat[4,4])"
  let ?U = "UNIV :: 4 set"
  let ?PU = "{p. p permutes ?U}"
  let ?t01 = "Transposition.transpose (0::4) (1::4)"
  let ?t23 = "Transposition.transpose (2::4) (3::4)"
  let ?S = "{id, ?t01, ?t23, ?t01 \<circ> ?t23}"
  let ?pp = "\<lambda>p. of_int (sign p) * prod (\<lambda>i. ?A $ i $ p i) ?U"
  have four_eq_zero: "((4::4) = 0)" by simp

  have finU: "finite ?U" by simp
  have finPU: "finite ?PU"
    using finite_permutations[OF finU] .

  have S_subset: "?S \<subseteq> ?PU"
    by (simp add: permutes_compose permutes_swap_id)

  have pp0: "\<forall>p\<in>?PU - ?S. ?pp p = 0"
  proof
    fix p
    assume p_notS: "p \<in> ?PU - ?S"
    then have pU: "p permutes ?U" by simp

    have "prod (\<lambda>i. ?A $ i $ p i) ?U = 0"
    proof (rule ccontr)
      assume prod_ne0: "prod (\<lambda>i. ?A $ i $ p i) ?U \<noteq> 0"
      from prod_ne0 finU have nz: "\<forall>i\<in>?U. ?A $ i $ p i \<noteq> 0"
        using prod_zero_iff by blast

      have nz0: "?A $ (0::4) $ p (0::4) \<noteq> 0"
        using nz[rule_format, of "0::4"] by simp
      have nz1: "?A $ (1::4) $ p (1::4) \<noteq> 0"
        using nz[rule_format, of "1::4"] by simp
      have nz2: "?A $ (2::4) $ p (2::4) \<noteq> 0"
        using nz[rule_format, of "2::4"] by simp
      have nz3: "?A $ (3::4) $ p (3::4) \<noteq> 0"
        using nz[rule_format, of "3::4"] by simp

      (* Rows 0,1 have zeros in columns 2,3 *)
      have p0_ne2: "p (0::4) \<noteq> 2"
      proof
        assume h: "p (0::4) = 2"
        from nz0 show False by (simp add: h)
      qed
      have p0_ne3: "p (0::4) \<noteq> 3"
      proof
        assume h: "p (0::4) = 3"
        from nz0 show False by (simp add: h)
      qed

      have p1_ne2: "p (1::4) \<noteq> 2"
      proof
        assume h: "p (1::4) = 2"
        from nz1 show False by (simp add: h)
      qed
      have p1_ne3: "p (1::4) \<noteq> 3"
      proof
        assume h: "p (1::4) = 3"
        from nz1 show False by (simp add: h)
      qed

      have p0_in: "p (0::4) = 0 \<or> p (0::4) = 1"
      proof -
        have p0_cases:
          "p (0::4) = 0 \<or> p (0::4) = 1 \<or> p (0::4) = 2 \<or> p (0::4) = 3"
          using exhaust_4[of "p (0::4)"]
        using four_eq_zero by argo
        from p0_cases show ?thesis
        proof (elim disjE)
          assume h0: "p (0::4) = 0"
          show ?thesis by (rule disjI1, fact h0)
        next
          assume h1: "p (0::4) = 1"
          show ?thesis by (rule disjI2, fact h1)
        next
          assume h2: "p (0::4) = 2"
          have False using p0_ne2 h2 by (rule notE)
          thus ?thesis by (rule FalseE)
        next
          assume h3: "p (0::4) = 3"
          have False using p0_ne3 h3 by (rule notE)
          thus ?thesis by (rule FalseE)
        qed
      qed

      have p1_in: "p (1::4) = 0 \<or> p (1::4) = 1"
      proof -
        have p1_cases:
          "p (1::4) = 0 \<or> p (1::4) = 1 \<or> p (1::4) = 2 \<or> p (1::4) = 3"
          using exhaust_4[of "p (1::4)"]
        using four_eq_zero by presburger
        from p1_cases show ?thesis
        proof (elim disjE)
          assume h0: "p (1::4) = 0"
          show ?thesis by (rule disjI1, fact h0)
        next
          assume h1: "p (1::4) = 1"
          show ?thesis by (rule disjI2, fact h1)
        next
          assume h2: "p (1::4) = 2"
          have False using p1_ne2 h2 by (rule notE)
          thus ?thesis by (rule FalseE)
        next
          assume h3: "p (1::4) = 3"
          have False using p1_ne3 h3 by (rule notE)
          thus ?thesis by (rule FalseE)
        qed
      qed

      (* Rows 2,3 have zeros in columns 0,1 *)
      have p2_ne0: "p (2::4) \<noteq> 0"
      proof
        assume h: "p (2::4) = 0"
        from nz2 show False by (simp add: h)
      qed
      have p2_ne1: "p (2::4) \<noteq> 1"
      proof
        assume h: "p (2::4) = 1"
        from nz2 show False by (simp add: h)
      qed
      have p3_ne0: "p (3::4) \<noteq> 0"
      proof
        assume h: "p (3::4) = 0"
        from nz3 show False by (simp add: h)
      qed
      have p3_ne1: "p (3::4) \<noteq> 1"
      proof
        assume h: "p (3::4) = 1"
        from nz3 show False by (simp add: h)
      qed

      have p2_in: "p (2::4) = 2 \<or> p (2::4) = 3"
      proof -
        have p2_cases:
          "p (2::4) = 0 \<or> p (2::4) = 1 \<or> p (2::4) = 2 \<or> p (2::4) = 3"
          using exhaust_4[of "p (2::4)"]
        using four_eq_zero by argo
        from p2_cases show ?thesis
        proof (elim disjE)
          assume h0: "p (2::4) = 0"
          have False using p2_ne0 h0 by (rule notE)
          thus ?thesis by (rule FalseE)
        next
          assume h1: "p (2::4) = 1"
          have False using p2_ne1 h1 by (rule notE)
          thus ?thesis by (rule FalseE)
        next
          assume h2: "p (2::4) = 2"
          show ?thesis by (rule disjI1, fact h2)
        next
          assume h3: "p (2::4) = 3"
          show ?thesis by (rule disjI2, fact h3)
        qed
      qed

      have p3_in: "p (3::4) = 2 \<or> p (3::4) = 3"
      proof -
        have p3_cases:
          "p (3::4) = 0 \<or> p (3::4) = 1 \<or> p (3::4) = 2 \<or> p (3::4) = 3"
          using exhaust_4[of "p (3::4)"]
        using four_eq_zero by presburger
        from p3_cases show ?thesis
        proof (elim disjE)
          assume h0: "p (3::4) = 0"
          have False using p3_ne0 h0 by (rule notE)
          thus ?thesis by (rule FalseE)
        next
          assume h1: "p (3::4) = 1"
          have False using p3_ne1 h1 by (rule notE)
          thus ?thesis by (rule FalseE)
        next
          assume h2: "p (3::4) = 2"
          show ?thesis by (rule disjI1, fact h2)
        next
          assume h3: "p (3::4) = 3"
          show ?thesis by (rule disjI2, fact h3)
        qed
      qed

      have inj: "inj_on p ?U"
        using pU by (simp add: permutes_inj_on)

      have p01_neq: "p (0::4) \<noteq> p (1::4)"
      proof
        assume h: "p (0::4) = p (1::4)"
        have "0 = (1::4)"
          using inj_onD[OF inj, of "0::4" "1::4"] h by simp
        thus False by simp
      qed

      have p23_neq: "p (2::4) \<noteq> p (3::4)"
      proof
        assume h: "p (2::4) = p (3::4)"
        have "2 = (3::4)"
          using inj_onD[OF inj, of "2::4" "3::4"] h by simp
        thus False by simp
      qed

      have p01_cases:
        "(p (0::4) = 0 \<and> p (1::4) = 1) \<or> (p (0::4) = 1 \<and> p (1::4) = 0)"
      proof -
        from p0_in show ?thesis
        proof (elim disjE)
          assume p0_0: "p (0::4) = 0"
          from p1_in show ?thesis
          proof (elim disjE)
            assume p1_0: "p (1::4) = 0"
            have h: "p (0::4) = p (1::4)" using p0_0 p1_0 by simp
            have False using p01_neq h by (rule notE)
            thus ?thesis by (rule FalseE)
          next
            assume p1_1: "p (1::4) = 1"
            show ?thesis by (rule disjI1, intro conjI, fact p0_0, fact p1_1)
          qed
        next
          assume p0_1: "p (0::4) = 1"
          from p1_in show ?thesis
          proof (elim disjE)
            assume p1_0: "p (1::4) = 0"
            show ?thesis by (rule disjI2, intro conjI, fact p0_1, fact p1_0)
          next
            assume p1_1: "p (1::4) = 1"
            have h: "p (0::4) = p (1::4)" using p0_1 p1_1 by simp
            have False using p01_neq h by (rule notE)
            thus ?thesis by (rule FalseE)
          qed
        qed
      qed

      have p23_cases:
        "(p (2::4) = 2 \<and> p (3::4) = 3) \<or> (p (2::4) = 3 \<and> p (3::4) = 2)"
      proof -
        from p2_in show ?thesis
        proof (elim disjE)
          assume p2_2: "p (2::4) = 2"
          from p3_in show ?thesis
          proof (elim disjE)
            assume p3_2: "p (3::4) = 2"
            have h: "p (2::4) = p (3::4)" using p2_2 p3_2 by simp
            have False using p23_neq h by (rule notE)
            thus ?thesis by (rule FalseE)
          next
            assume p3_3: "p (3::4) = 3"
            show ?thesis by (rule disjI1, intro conjI, fact p2_2, fact p3_3)
          qed
        next
          assume p2_3: "p (2::4) = 3"
          from p3_in show ?thesis
          proof (elim disjE)
            assume p3_2: "p (3::4) = 2"
            show ?thesis by (rule disjI2, intro conjI, fact p2_3, fact p3_2)
          next
            assume p3_3: "p (3::4) = 3"
            have h: "p (2::4) = p (3::4)" using p2_3 p3_3 by simp
            have False using p23_neq h by (rule notE)
            thus ?thesis by (rule FalseE)
          qed
        qed
      qed

      have p_inS: "p \<in> ?S"
      proof -
        from p01_cases show ?thesis
        proof (elim disjE)
          assume a01: "p (0::4) = 0 \<and> p (1::4) = 1"
          then have p0: "p (0::4) = 0" and p1: "p (1::4) = 1" by simp_all
          from p23_cases show ?thesis
          proof (elim disjE)
          assume a23: "p (2::4) = 2 \<and> p (3::4) = 3"
          then have p2: "p (2::4) = 2" and p3: "p (3::4) = 3" by simp_all
            have pid: "p = id"
            proof (rule ext)
              fix x :: 4
              have xc: "x = 0 \<or> x = 1 \<or> x = 2 \<or> x = 3"
                using exhaust_4[of x]
              using four_eq_zero by blast
              from xc show "p x = id x"
              proof (elim disjE)
                assume x0: "x = 0"
                show ?thesis
                by (simp add: p0 x0)
              next
                assume x1: "x = 1"
                show ?thesis by (simp add: p1 x1)
              next
                assume x2: "x = 2"
                show ?thesis by (simp add: p2 x2)
              next
                assume x3: "x = 3"
                show ?thesis by (simp add: p3 x3)
              qed
            qed
            thus ?thesis by simp
          next
            assume a23: "p (2::4) = 3 \<and> p (3::4) = 2"
            then have p2: "p (2::4) = 3" and p3: "p (3::4) = 2" by simp_all
            have pt23: "p = ?t23"
            proof (rule ext)
              fix x :: 4
              have xc: "x = 0 \<or> x = 1 \<or> x = 2 \<or> x = 3"
                using exhaust_4[of x] 
              using four_eq_zero by blast
              from xc show "p x = ?t23 x"
              proof (elim disjE)
                assume x0: "x = 0"
                show ?thesis 
                by (simp add: p0 x0)
              next
                assume x1: "x = 1"
                show ?thesis by (simp add: p1 x1)
              next
                assume x2: "x = 2"
                show ?thesis by (simp add: p2 x2)
              next
                assume x3: "x = 3"
                show ?thesis by (simp add: p3 x3)
              qed
            qed
            thus ?thesis by simp
          qed
        next
          assume a01: "p (0::4) = 1 \<and> p (1::4) = 0"
          then have p0: "p (0::4) = 1" and p1: "p (1::4) = 0" by simp_all
          from p23_cases show ?thesis
          proof (elim disjE)
            assume a23: "p (2::4) = 2 \<and> p (3::4) = 3"
            then have p2: "p (2::4) = 2" and p3: "p (3::4) = 3" by simp_all
            have pt01: "p = ?t01"
            proof (rule ext)
              fix x :: 4
              have xc: "x = 0 \<or> x = 1 \<or> x = 2 \<or> x = 3"
                using exhaust_4[of x]
              using four_eq_zero by blast
              from xc show "p x = ?t01 x"
              proof (elim disjE)
                assume x0: "x = 0"
                show ?thesis by (simp add: p0 x0)
              next
                assume x1: "x = 1"
                show ?thesis by (simp add: p1 x1)
              next
                assume x2: "x = 2"
                show ?thesis by (simp add: p2 x2)
              next
                assume x3: "x = 3"
                show ?thesis by (simp add: p3 x3)
              qed
            qed
            thus ?thesis by simp
          next
            assume a23: "p (2::4) = 3 \<and> p (3::4) = 2"
            then have p2: "p (2::4) = 3" and p3: "p (3::4) = 2" by simp_all
            have pt0123: "p = ?t01 \<circ> ?t23"
            proof (rule ext)
              fix x :: 4
              have xc: "x = 0 \<or> x = 1 \<or> x = 2 \<or> x = 3"
                using exhaust_4[of x]
              using four_eq_zero by blast
              from xc show "p x = (?t01 \<circ> ?t23) x"
              proof (elim disjE)
                assume x0: "x = 0"
                show ?thesis
                  by (simp add: p0 x0)
              next
                assume x1: "x = 1"
                show ?thesis
                  by (simp add: p1 x1)
              next
                assume x2: "x = 2"
                show ?thesis
                  by (simp add: p2 x2) 
              next
                assume x3: "x = 3"
                show ?thesis
                  by (simp add: p3 x3)
              qed
            qed
            thus ?thesis by simp
          qed
        qed
      qed

      from p_notS p_inS show False by simp
    qed

    thus "?pp p = 0" by simp
  qed


  have det_eq_S: "det ?A = (\<Sum>p\<in>?S. ?pp p)"
  proof -
    have det_eq_perm: "det ?A = (\<Sum>p | p permutes ?U. ?pp p)"
      unfolding det_def by simp
    have perm_eq_pu: "(\<Sum>p | p permutes ?U. ?pp p) = (\<Sum>p\<in>?PU. ?pp p)"
      by simp

    have finS: "finite ?S" by simp
    have finDiff: "finite (?PU - ?S)" using finPU by simp
    have disj: "?S \<inter> (?PU - ?S) = {}"
      by blast
    have PU_split: "?PU = ?S \<union> (?PU - ?S)"
      using S_subset by blast

    have sumDiff0: "(\<Sum>p\<in>?PU - ?S. ?pp p) = 0"
    proof -
      have sum0: "(\<Sum>p\<in>?PU - ?S. ?pp p) = (\<Sum>p\<in>?PU - ?S. 0)"
      proof (rule sum.cong)
        show "?PU - ?S = ?PU - ?S" by simp
        fix p
        assume hp: "p \<in> ?PU - ?S"
        thus "?pp p = 0" using pp0 by blast
      qed
      have sum1: "(\<Sum>p\<in>?PU - ?S. 0) = 0"
        by simp
      from sum0 sum1 show ?thesis by simp
    qed

    have pu_eq_s: "(\<Sum>p\<in>?PU. ?pp p) = (\<Sum>p\<in>?S. ?pp p)"
    proof -
      have step1:
        "(\<Sum>p\<in>?PU. ?pp p) = (\<Sum>p\<in>?S \<union> (?PU - ?S). ?pp p)"
      using PU_split by presburger
      have step2:
        "(\<Sum>p\<in>?S \<union> (?PU - ?S). ?pp p) =
          (\<Sum>p\<in>?S. ?pp p) + (\<Sum>p\<in>?PU - ?S. ?pp p)"
        by (rule sum.union_disjoint[OF finS finDiff disj])
      have step3:
        "(\<Sum>p\<in>?S. ?pp p) + (\<Sum>p\<in>?PU - ?S. ?pp p) =
          (\<Sum>p\<in>?S. ?pp p)"
      using sumDiff0 by linarith
      from step1 step2 step3 show ?thesis by simp
    qed

    from det_eq_perm perm_eq_pu pu_eq_s show ?thesis by simp
  qed

  have sum_eq: "(\<Sum>p\<in>?S. ?pp p) = (m00 * m11 - m01 * m10)\<^sup>2"
proof -
  let ?t0123 = "?t01 \<circ> ?t23"
  have id_ne_t01: "id \<noteq> ?t01"
  proof
    assume h: "id = ?t01"
    from h have "id (0::4) = ?t01 (0::4)" by simp
    thus False by (simp add: Transposition.transpose_def)
  qed
  have id_ne_t23: "id \<noteq> ?t23"
  proof
    assume h: "id = ?t23"
    from h have "id (2::4) = ?t23 (2::4)" by simp
    thus False by (simp add: Transposition.transpose_def)
  qed
  have id_ne_t0123: "id \<noteq> ?t0123"
  proof
    assume h: "id = ?t0123"
    from h have "id (0::4) = ?t0123 (0::4)" by simp
    thus False by (simp add: Transposition.transpose_def)
  qed

  have t01_ne_t23: "?t01 \<noteq> ?t23"
  proof
    assume h: "?t01 = ?t23"
    from h have "?t01 (0::4) = ?t23 (0::4)" by simp
    thus False by (simp add: Transposition.transpose_def)
  qed
  have t01_ne_t0123: "?t01 \<noteq> ?t0123"
  proof
    assume h: "?t01 = ?t0123"
    from h have "?t01 (2::4) = ?t0123 (2::4)" by simp
    thus False by (simp add: Transposition.transpose_def)
  qed
  have t23_ne_t0123: "?t23 \<noteq> ?t0123"
  proof
    assume h: "?t23 = ?t0123"
    from h have "?t23 (0::4) = ?t0123 (0::4)" by simp
    thus False by (simp add: Transposition.transpose_def)
  qed

  have sumS:
    "(\<Sum>p\<in>?S. ?pp p) = ?pp id + ?pp ?t01 + ?pp ?t23 + ?pp ?t0123"
  proof -
    have S_def: "?S = insert id (insert ?t01 (insert ?t23 { ?t0123 }))"
      by simp
    have id_notin: "id \<notin> insert ?t01 (insert ?t23 { ?t0123 })"
      by (simp add: id_ne_t01 id_ne_t23 id_ne_t0123)
    have t01_notin: "?t01 \<notin> insert ?t23 { ?t0123 }"
      by (simp add: t01_ne_t23 t01_ne_t0123)
    have t23_notin: "?t23 \<notin> { ?t0123 }"
      by (simp add: t23_ne_t0123)

    have sum0:
      "(\<Sum>p\<in>?S. ?pp p) =
        ?pp id + (\<Sum>p\<in>insert ?t01 (insert ?t23 { ?t0123 }). ?pp p)"
    by (meson finite id_notin sum.insert)
    have sum1:
      "(\<Sum>p\<in>insert ?t01 (insert ?t23 { ?t0123 }). ?pp p) =
        ?pp ?t01 + (\<Sum>p\<in>insert ?t23 { ?t0123 }. ?pp p)"
    by (meson finite sum.insert t01_notin)
    have sum2:
      "(\<Sum>p\<in>insert ?t23 { ?t0123 }. ?pp p) =
        ?pp ?t23 + (\<Sum>p\<in>{ ?t0123 }. ?pp p)"
        by (meson finite sum.insert t23_notin)

    have sum3: "(\<Sum>p\<in>{ ?t0123 }. ?pp p) = ?pp ?t0123"
      by simp

    from sum0 sum1 sum2 sum3 show ?thesis by simp
  qed
  have pp_id: "?pp id = (m00*m11) * (m00*m11)"
    by (simp add: UNIV_4 four_eq_zero sign_id)

  have pp_t01: "?pp ?t01 = - (m01*m10*m00*m11)"
    by (simp add: UNIV_4 four_eq_zero sign_swap_id Transposition.transpose_def)

  have pp_t23: "?pp ?t23 = - (m00*m11*m01*m10)"
    by (simp add: UNIV_4 four_eq_zero sign_swap_id Transposition.transpose_def)

  have pp_t0123: "?pp ?t0123 = (m01*m10) * (m01*m10)"
    by (simp add: UNIV_4 four_eq_zero sign_compose sign_swap_id sign_id
                  Transposition.transpose_def comp_apply)

  have poly:
    "(\<Sum>p\<in>?S. ?pp p) =
       (m00*m11) * (m00*m11)
     - (m01*m10*m00*m11)
     - (m00*m11*m01*m10)
     + (m01*m10) * (m01*m10)"
  proof -
    have poly0:
      "(\<Sum>p\<in>?S. ?pp p) = ?pp id + ?pp ?t01 + ?pp ?t23 + ?pp ?t0123"
      by (rule sumS)
    have poly1:
      "?pp id + ?pp ?t01 + ?pp ?t23 + ?pp ?t0123 =
        (m00*m11) * (m00*m11)
      - (m01*m10*m00*m11)
      - (m00*m11*m01*m10)
      + (m01*m10) * (m01*m10)"
      by (subst pp_id, subst pp_t01, subst pp_t23, subst pp_t0123, ring)
    from poly0 poly1 show ?thesis by simp
  qed

  (* Now it's pure algebra: let the ring procedure finish it. *)
  show ?thesis
    using poly
    by (simp add: power2_eq_square; ring)
qed
  show ?thesis
    using det_eq_S sum_eq by simp
qed


lemma det_controllability_matrix_second_order:
  fixes K :: "real mat[2,2]" and L :: "real mat[2,1]"
  shows "det (controllability_matrix_4x1 (A_lin K) (B_lin L)) =
    - (det (\<^bold>[[L$0$0, (K ** L)$0$0],
      [L$1$0, (K ** L)$1$0]\<^bold>] :: real mat[2,2]))\<^sup>2"
proof -
  let ?l1 = "L$0$0"
  let ?l2 = "L$1$0"
  let ?s1 = "(K ** L)$0$0"
  let ?s2 = "(K ** L)$1$0"
  have four_eq_zero: "((4::4) = 0)" by simp
  have one_eq_zero1: "((1::1) = 0)"
  proof -
    have "(0::1) \<in> (UNIV :: 1 set)" by simp
    then have "(0::1) \<in> ({1} :: 1 set)" by simp
    then have "(0::1) = (1::1)" by simp
    then show ?thesis by (rule sym)
  qed

  have AB:
    "A_lin K ** B_lin L =
      (\<^bold>[[?l1],
        [?l2],
        [0],
        [0]\<^bold>] :: real mat[4,1])"
  proof -
    show ?thesis
      apply (vector matrix_matrix_mult_def A_lin_def B_lin_def sum_4)
      apply (intro allI)
      subgoal for i
        using exhaust_4[of i]
        by (elim disjE; simp add: matrix_matrix_mult_def A_lin_def B_lin_def sum_4 four_eq_zero one_eq_zero1)
      done
  qed

  have two_eq_zero: "((2::2) = 0)" by simp
  have s1_alt: "?s1 = K$0$0 * ?l1 + K$0$1 * ?l2"
    by (simp add: matrix_matrix_mult_def sum_2 two_eq_zero algebra_simps)
  have s2_alt: "?s2 = K$1$0 * ?l1 + K$1$1 * ?l2"
    by (simp add: matrix_matrix_mult_def sum_2 two_eq_zero algebra_simps)

  have A2B:
    "A_lin K ** (A_lin K ** B_lin L) =
      (\<^bold>[[0],
        [0],
        [?s1],
        [?s2]\<^bold>] :: real mat[4,1])"
  proof -
    show ?thesis
      apply (vector AB matrix_matrix_mult_def A_lin_def sum_4)
      apply (intro allI)
      subgoal for i
        using exhaust_4[of i]
        by (elim disjE; simp add:
          AB B_lin_def matrix_matrix_mult_def A_lin_def sum_4 sum_2 two_eq_zero algebra_simps
          four_eq_zero one_eq_zero1)
      done
  qed

  have A3B:
    "A_lin K ** (A_lin K ** (A_lin K ** B_lin L)) =
      (\<^bold>[[?s1],
        [?s2],
        [0],
        [0]\<^bold>] :: real mat[4,1])"
  proof -
    have "A_lin K ** (A_lin K ** (A_lin K ** B_lin L)) =
      A_lin K ** (\<^bold>[[0],
        [0],
        [?s1],
        [?s2]\<^bold>] :: real mat[4,1])"
      by (simp add: A2B)
    also have "\<dots> =
      (\<^bold>[[?s1],
        [?s2],
        [0],
        [0]\<^bold>] :: real mat[4,1])"
      apply (vector matrix_matrix_mult_def A_lin_def sum_4)
      apply (intro allI)
      subgoal for i
        using exhaust_4[of i]
        by (elim disjE; simp add: matrix_matrix_mult_def A_lin_def sum_4 four_eq_zero one_eq_zero1)
      done
    finally show ?thesis .
  qed

  have A2B_from_AB:
    "A_lin K ** (\<^bold>[[?l1],
      [?l2],
      [0],
      [0]\<^bold>] :: real mat[4,1]) =
      (\<^bold>[[0],
        [0],
        [?s1],
        [?s2]\<^bold>] :: real mat[4,1])"
  proof -
    have "A_lin K ** (\<^bold>[[?l1], [?l2], [0], [0]\<^bold>] :: real mat[4,1]) =
      A_lin K ** (A_lin K ** B_lin L)"
      by (simp add: AB[symmetric])
    also have "\<dots> =
      (\<^bold>[[0],
        [0],
        [?s1],
        [?s2]\<^bold>] :: real mat[4,1])"
      by (simp add: A2B)
    finally show ?thesis .
  qed

  have A3B_from_AB:
    "A_lin K ** (A_lin K ** (\<^bold>[[?l1],
      [?l2],
      [0],
      [0]\<^bold>] :: real mat[4,1])) =
      (\<^bold>[[?s1],
        [?s2],
        [0],
        [0]\<^bold>] :: real mat[4,1])"
  proof -
    have "A_lin K ** (A_lin K ** (\<^bold>[[?l1], [?l2], [0], [0]\<^bold>] :: real mat[4,1])) =
      A_lin K ** (A_lin K ** (A_lin K ** B_lin L))"
      by (simp add: AB[symmetric])
    also have "\<dots> =
      (\<^bold>[[?s1],
        [?s2],
        [0],
        [0]\<^bold>] :: real mat[4,1])"
      by (simp add: A3B)
    finally show ?thesis .
  qed

  have A3B_from_A2B:
    "A_lin K ** (\<^bold>[[0],
      [0],
      [?s1],
      [?s2]\<^bold>] :: real mat[4,1]) =
      (\<^bold>[[?s1],
        [?s2],
        [0],
        [0]\<^bold>] :: real mat[4,1])"
  proof -
    have "A_lin K ** (\<^bold>[[0], [0], [?s1], [?s2]\<^bold>] :: real mat[4,1]) =
      A_lin K ** (A_lin K ** (A_lin K ** B_lin L))"
      by (simp add: A2B[symmetric])
    also have "\<dots> =
      (\<^bold>[[?s1],
        [?s2],
        [0],
        [0]\<^bold>] :: real mat[4,1])"
      by (simp add: A3B)
    finally show ?thesis .
  qed

  have B0: "B_lin L$0$0 = 0"
    by (simp add: B_lin_def four_eq_zero one_eq_zero1)
  have B1: "B_lin L$1$0 = 0"
    by (simp add: B_lin_def four_eq_zero one_eq_zero1)
  have B2: "B_lin L$2$0 = ?l1"
    by (simp add: B_lin_def four_eq_zero one_eq_zero1)
  have B3: "B_lin L$3$0 = ?l2"
    by (simp add: B_lin_def four_eq_zero one_eq_zero1)

  have ctrl_form:
    "controllability_matrix_4x1 (A_lin K) (B_lin L) =
      (\<^bold>[[0, ?l1, 0, ?s1],
        [0, ?l2, 0, ?s2],
        [?l1, 0, ?s1, 0],
        [?l2, 0, ?s2, 0]\<^bold>] :: real mat[4,4])"
  proof -
    show ?thesis
      by (simp add:
        controllability_matrix_4x1_def Let_def AB A2B_from_AB A3B_from_A2B B0 B1 B2 B3)
  qed

  let ?C = "(\<^bold>[[0, ?l1, 0, ?s1],
    [0, ?l2, 0, ?s2],
    [?l1, 0, ?s1, 0],
    [?l2, 0, ?s2, 0]\<^bold>] :: real mat[4,4])"

  let ?p = "Transposition.transpose (0::4) (2::4) \<circ>
            (Transposition.transpose (0::4) (3::4) \<circ>
             Transposition.transpose (0::4) (1::4))"

  have p_perm: "?p permutes (UNIV :: 4 set)"
    by (intro permutes_compose permutes_swap_id; simp)

  have p_sign: "sign ?p = -1"
  proof -
    let ?t02 = "Transposition.transpose (0::4) (2::4)"
    let ?t03 = "Transposition.transpose (0::4) (3::4)"
    let ?t01 = "Transposition.transpose (0::4) (1::4)"

    have perm02: "permutation ?t02"
    proof (rule permutes_imp_permutation[of "UNIV :: 4 set"])
      show "finite (UNIV :: 4 set)" by simp
      show "?t02 permutes (UNIV :: 4 set)"
        by (intro permutes_swap_id; simp)
    qed
    have perm03: "permutation ?t03"
    proof (rule permutes_imp_permutation[of "UNIV :: 4 set"])
      show "finite (UNIV :: 4 set)" by simp
      show "?t03 permutes (UNIV :: 4 set)"
        by (intro permutes_swap_id; simp)
    qed
    have perm01: "permutation ?t01"
    proof (rule permutes_imp_permutation[of "UNIV :: 4 set"])
      show "finite (UNIV :: 4 set)" by simp
      show "?t01 permutes (UNIV :: 4 set)"
        by (intro permutes_swap_id; simp)
    qed
    have perm0301: "permutation (?t03 \<circ> ?t01)"
      by (rule permutation_compose[OF perm03 perm01])

	    have sign_p: "sign ?p = sign ?t02 * (sign ?t03 * sign ?t01)"
	    proof -
	      have s1: "sign ?p = sign ?t02 * sign (?t03 \<circ> ?t01)"
	        by (rule sign_compose[OF perm02 perm0301])
	      have s2: "sign (?t03 \<circ> ?t01) = sign ?t03 * sign ?t01"
	        by (rule sign_compose[OF perm03 perm01])
	      from s1 show ?thesis
	        by (simp add: s2 algebra_simps)
	    qed
    show ?thesis
      using sign_p by (simp add: sign_swap_id algebra_simps)
  qed

  have det_perm: "det (\<chi> i j. ?C$i$?p j :: real^4^4) = of_int (sign ?p) * det ?C"
    using det_permute_columns[OF p_perm, of ?C] by simp

  have permuted_is_block_diag:
    "(\<chi> i j. ?C$i$?p j :: real^4^4) =
      (\<^bold>[[?l1, ?s1, 0, 0],
        [?l2, ?s2, 0, 0],
        [0, 0, ?l1, ?s1],
        [0, 0, ?l2, ?s2]\<^bold>] :: real mat[4,4])"
    by (vector fun_eq_iff UNIV_4 Transposition.transpose_def)

  have det_C:
    "det ?C =
      - (det (\<^bold>[[?l1, ?s1],
        [?l2, ?s2]\<^bold>] :: real mat[2,2]))\<^sup>2"
  proof -
    have detC: "det ?C = - det (\<chi> i j. ?C$i$?p j :: real^4^4)"
      by (subst det_perm, simp add: p_sign)
    have det2: "det (\<^bold>[[?l1, ?s1],
      [?l2, ?s2]\<^bold>] :: real mat[2,2]) = ?l1 * ?s2 - ?s1 * ?l2"
      by (simp add: det_2 two_eq_zero algebra_simps)

    have "det ?C = - det (\<chi> i j. ?C$i$?p j :: real^4^4)"
      by (fact detC)
    also have "\<dots> =
      - det (\<^bold>[[?l1, ?s1, 0, 0],
        [?l2, ?s2, 0, 0],
        [0, 0, ?l1, ?s1],
        [0, 0, ?l2, ?s2]\<^bold>] :: real mat[4,4])"
      by (subst permuted_is_block_diag, simp)
    also have "\<dots> =
      - (?l1 * ?s2 - ?s1 * ?l2)\<^sup>2"
      by (simp add: det_block_diag_repeat_2x2)
    also have "\<dots> =
      - (det (\<^bold>[[?l1, ?s1],
        [?l2, ?s2]\<^bold>] :: real mat[2,2]))\<^sup>2"
      by (subst det2, simp)
    finally show ?thesis .
  qed
  show ?thesis
    by (simp add: ctrl_form det_C)
qed

lemma is_controllable_second_order_iff:
  fixes K :: "real mat[2,2]" and L :: "real mat[2,1]"
  shows "is_controllable (A_lin K) (B_lin L) \<longleftrightarrow>
    det (\<^bold>[[L$0$0, (K ** L)$0$0],
      [L$1$0, (K ** L)$1$0]\<^bold>] :: real mat[2,2]) \<noteq> 0"
  unfolding is_controllable_def
  by (simp add: det_controllability_matrix_second_order)



(* kalman2: reduced 2x2 Kalman matrix [L | K*L] for second-order systems.
   The 4x4 controllability check reduces to det(kalman2) != 0 because
   the A_lin/B_lin structure causes the 4x4 determinant to factor as
   -(det(kalman2))^2 (proved in det_controllability_matrix_second_order). *)
definition kalman2 :: "real mat[2,2] \<Rightarrow> real mat[2,1] \<Rightarrow> real mat[2,2]" where
  "kalman2 K L \<equiv> \<^bold>[[L$0$0, (K ** L)$0$0],
    [L$1$0, (K ** L)$1$0]\<^bold>]"

lemma is_controllable_second_order_iff_kalman2:
  fixes K :: "real mat[2,2]" and L :: "real mat[2,1]"
  shows "is_controllable (A_lin K) (B_lin L) \<longleftrightarrow> det (kalman2 K L) \<noteq> 0"
  unfolding kalman2_def
  by (rule is_controllable_second_order_iff)
end


(* Equilibrium configurations of the acrobot (joint angles).
   Upward: shoulder at pi (link 1 pointing up), elbow at 0 (link 2 aligned).
   Downward: both joints at 0 (both links hanging down). *)
definition upward_equilibrium :: "real ^2" where
  "upward_equilibrium \<equiv> vec_of_list [pi, 0]"

definition downward_equilibrium :: "real ^2" where
  "downward_equilibrium \<equiv> vec_of_list [0, 0]"

context proof_solution_system
begin

subsection \<open>Upright equilibrium: numeric controllability check\<close>

(* B_ctrl_upright: control input matrix from the p-model (ControlledMotor on
   elbow joint). Same as b_ctrl_init but as a pure value outside the dataspace.
   [1,0]^T: actuator applies torque to elbow (joint 1), not shoulder (joint 0). *)
definition B_ctrl_upright :: "real mat[2,1]" where
  "B_ctrl_upright \<equiv> \<^bold>[[1], [0]\<^bold>]"

(* M_mass_inv_upright: inverse of the 2x2 joint-space mass matrix M_mass
   evaluated at the upright equilibrium (theta = (pi, 0), theta' = 0).
   M_mass = H * phi * M * phi^T * H^T from the generated equations (m_mass_eq),
   with physical parameters: m1=1kg, m2=1kg, l1=1m, l2=2m, lc1=0.5m, lc2=1m,
   Iyy1=0.083, Iyy2=0.333. Exact rationals from inverting M_mass at equilibrium:
   e.g. 2000/333 = 1/(m1*lc1^2 + Iyy1 + ...) after numerically computed analytic inversion. *)
definition M_mass_inv_upright :: "real mat[2,2]" where
  "M_mass_inv_upright \<equiv> \<^bold>[[2000/333, -1000/333],
    [-1000/333, 1333000/776889]\<^bold>]"

(* K_upright: linearized gravity-stiffness matrix at the upright equilibrium.
   K = M_mass_inv * d(g(theta))/d(theta) evaluated at theta = (pi, 0).
   The gravity terms involve m*g*lc*cos(theta), so their derivatives at
   theta=pi give the entries. These rationals arise from the product of
   M_mass_inv_upright with the gravity Jacobian using g=9.81. *)
definition K_upright :: "real mat[2,2]" where
  "K_upright \<equiv> \<^bold>[[1090/37, -545/37],
    [-1090000/86321, 1089455/86321]\<^bold>]"

(* L_upright: linearized input vector L = M_mass_inv * B_ctrl at upright
   equilibrium. This is the effective control authority in acceleration space. *)
definition L_upright :: "real mat[2,1]" where
  "L_upright \<equiv> M_mass_inv_upright ** B_ctrl_upright"

lemma L_upright_00:
  shows "L_upright$0$0 = 2000/333"
proof -
  have two_eq_zero: "((2::2) = 0)" by simp

  have "L_upright$0$0 =
        (\<Sum>k\<in>(UNIV::2 set). M_mass_inv_upright$0$k * B_ctrl_upright$k$0)"
    unfolding L_upright_def
    by (simp add: matrix_matrix_mult_def)

  also have "... =
        M_mass_inv_upright$0$0 * B_ctrl_upright$0$0 +
        M_mass_inv_upright$0$1 * B_ctrl_upright$1$0"
    by (simp add: sum_2 two_eq_zero)

  also have "... = 2000/333"
    by (simp add: M_mass_inv_upright_def B_ctrl_upright_def two_eq_zero)

  finally show ?thesis .
qed

lemma L_upright_10:
  shows "L_upright$1$0 = -1000/333"
proof -
  have two_eq_zero: "((2::2) = 0)" by simp
  show ?thesis
    unfolding L_upright_def M_mass_inv_upright_def B_ctrl_upright_def
    by (simp add: matrix_matrix_mult_def sum_2 two_eq_zero algebra_simps)
qed

lemma K_upright_L_upright_00:
  shows "(K_upright ** L_upright)$0$0 = 2725000/12321"
proof -
  have two_eq_zero: "((2::2) = 0)" by simp
  show ?thesis
    by (simp add:
      matrix_matrix_mult_def sum_2 two_eq_zero algebra_simps
      K_upright_def L_upright_00 L_upright_10)
qed

lemma K_upright_L_upright_10:
  shows "(K_upright ** L_upright)$1$0 = -3269455000/28744893"
proof -
  have two_eq_zero: "((2::2) = 0)" by simp
  show ?thesis
    by (simp add:
      matrix_matrix_mult_def sum_2 two_eq_zero algebra_simps
      K_upright_def L_upright_00 L_upright_10)
qed

lemma det_kalman2_upright:
  shows "det (kalman2 K_upright L_upright) = (-545000000) / 28744893"
proof -
  have L00: "L_upright$0$0 = 2000/333"
    by (simp add: L_upright_00)
  have L10: "L_upright$1$0 = -1000/333"
    by (simp add: L_upright_10)
  have KL00: "(K_upright ** L_upright)$0$0 = 2725000/12321"
    by (simp add: K_upright_L_upright_00)
  have KL10: "(K_upright ** L_upright)$1$0 = -3269455000/28744893"
    by (simp add: K_upright_L_upright_10)
  have two_eq_zero: "((2::2) = 0)" by simp

  have det_eq:
    "det (kalman2 K_upright L_upright) =
      (2000/333) * (-3269455000/28744893) - (2725000/12321) * (-1000/333)"
    by (simp add: kalman2_def det_2 L00 L10 KL00 KL10 two_eq_zero algebra_simps)

  have det_val:
    "(2000/333) * (-3269455000/28744893) - (2725000/12321) * (-1000/333) =
      ((-545000000) / 28744893 :: real)"
  proof -
    (* Clear denominators manually (no field_simp / norm_num required). *)
    let ?D = "(333::real) * 12321 * 28744893"
    have Dnz: "?D \<noteq> 0" by simp

    have t1:
      "?D * ((2000/333) * (-3269455000/28744893)) =
        12321 * 2000 * (-3269455000)"
      by (simp add: algebra_simps)

    have t2:
      "?D * ((2725000/12321) * (-1000/333)) =
        28744893 * 2725000 * (-1000)"
      by (simp add: algebra_simps)

    have t3:
      "?D * ((-545000000) / 28744893) =
        333 * 12321 * (-545000000)"
      by (simp add: algebra_simps)

    have num:
      "(12321::real) * 2000 * (-3269455000) - 28744893 * 2725000 * (-1000) =
        333 * 12321 * (-545000000)"
      by ring

    have eqD:
      "?D * ((2000/333) * (-3269455000/28744893) - (2725000/12321) * (-1000/333)) =
        ?D * ((-545000000) / 28744893)"
      using t1 t2 t3 num
      by (simp add: algebra_simps)

    have diff_eq:
      "?D * (((2000/333) * (-3269455000/28744893) - (2725000/12321) * (-1000/333))
              - (-545000000) / 28744893) = (0::real)"
      using eqD by (simp add: algebra_simps)

    have "((2000/333) * (-3269455000/28744893) - (2725000/12321) * (-1000/333))
              - (-545000000::real) / 28744893 = 0"
    proof -
      from diff_eq Dnz show ?thesis
        by (metis mult_eq_0_iff)
    qed

    thus ?thesis by simp
  qed

  from det_eq det_val show ?thesis
    by (simp only: det_eq det_val)
qed


lemma acrobot_upright_controllable:
  shows "is_controllable (A_lin K_upright)
    (B_lin_from_B_ctrl M_mass_inv_upright B_ctrl_upright)"
proof -
  have "det (kalman2 K_upright L_upright) \<noteq> 0"
    by (simp add: det_kalman2_upright)
  thus ?thesis
    unfolding B_lin_from_B_ctrl_def L_upright_def
    by (simp add: is_controllable_second_order_iff_kalman2)
qed

theorem acrobot_controllability_upward:
  fixes s :: 'st
  assumes "theta<s> = upward_equilibrium"
  assumes "theta'<s> = 0"
  assumes m_inv_upright: "M_mass_inv<s> = M_mass_inv_upright"
  assumes b_ctrl_upright: "B_ctrl<s> = B_ctrl_upright"
  shows "is_controllable (A_lin K_upright) (B_lin_from_B_ctrl (M_mass_inv<s>) (B_ctrl<s>))"
proof -
  show ?thesis
    using acrobot_upright_controllable
    by (simp add: m_inv_upright b_ctrl_upright)
qed

end

end