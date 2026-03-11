package circus.robocalc.robosim.physmod.libs.sourceCodeGen.formulation

import circus.robocalc.robosim.physmod.slnRef.slnRef.SlnRef
import static circus.robocalc.robosim.physmod.libs.sourceCodeGen.libUtils.libUtils.*
import static circus.robocalc.robosim.physmod.libs.sourceCodeGen.formulation.SKO.getInitalValue

/**
 * CGA source-code generator library.
 *
 * Kinematics use motor-based forward kinematics (rotors and translators).
 * Dynamics use articulated-body (ABA) and RNEA-style recursion with explicit
 * computation blocks. Twists and wrenches are 6D spatial vectors; all frame
 * transforms derive from the motor chain (B_k).
 */
class CGA {

    private static def void appendStateVar(StringBuilder sb, java.util.Set<String> declared, String name, String type, String initVal) {
        if (name === null || name.trim.length == 0) {
            return
        }
        if (!declared.add(name)) {
            return
        }
        var normalizedInit = initVal
        if (normalizedInit !== null && normalizedInit.startsWith("seq(")) {
            normalizedInit = normalizeSeqLiteral(normalizedInit)
        }
        sb.append(name + " : " + simplifyType(type))
        if (normalizedInit !== null && normalizedInit != "seq()") {
            sb.append(" = " + normalizedInit)
        }
        sb.append(";\n")
    }

    private static def String normalizeSeqLiteral(String value) {
        if (value === null) {
            return null
        }
        var result = value
        result = result.replace("[|", "[")
        result = result.replace("|]", "]")
        result = result.replace("(|", "[")
        result = result.replace("|)", "]")
        return result
    }

    private static def int parseIntLiteral(String value) {
        if (value === null) {
            return -1
        }
        val trimmed = value.trim
        if (trimmed.matches("\\d+")) {
            return Integer.parseInt(trimmed)
        }
        return -1
    }

    private static def int countSeqElements(String value) {
        if (value === null) {
            return -1
        }
        val trimmed = value.trim
        if (!trimmed.startsWith("seq(") || !trimmed.endsWith(")")) {
            return -1
        }
        val inner = trimmed.substring(4, trimmed.length - 1).trim
        if (inner.length == 0) {
            return 0
        }
        var depthParen = 0
        var depthBracket = 0
        var depthBrace = 0
        var count = 1
        for (i : 0 ..< inner.length) {
            val ch = inner.charAt(i)
            switch (ch) {
                case '(' : depthParen++
                case ')' : depthParen--
                case '[' : depthBracket++
                case ']' : depthBracket--
                case '{' : depthBrace++
                case '}' : depthBrace--
                case ',' : {
                    if (depthParen == 0 && depthBracket == 0 && depthBrace == 0) {
                        count++
                    }
                }
                default : {}
            }
        }
        return count
    }

    private static def String repeatSeqLiteral(String element, int count) {
        if (count <= 0) {
            return "seq()"
        }
        val sb = new StringBuilder
        sb.append("seq(")
        for (i : 0 ..< count) {
            sb.append(element)
            if (i < count - 1) {
                sb.append(", ")
            }
        }
        sb.append(")")
        return sb.toString
    }

    private static def String ensureMotorSeqInit(String initVal, int count) {
        if (initVal !== null && initVal != "seq()") {
            return initVal
        }
        if (count <= 0) {
            return initVal
        }
        return repeatSeqLiteral("motorIdentity()", count)
    }

    private static def String getInputInitialValue(SlnRef solution, String name) {
        val input = solution.inputs.findFirst[i | i.value?.name == name]
        if (input !== null) {
            return getInitalValue(name, input.value.type, solution)
        }
        if (solution.expression !== null && solution.expression.name == name) {
            return getInitalValue(name, solution.expression.type, solution)
        }
        return null
    }

    // Motor-based forward kinematics (explicit rotor/translator construction)
    static class ForwardKinematics {

        static def String asSolution(SlnRef solution) {
            val nStr = getInitalValue("n", "int", solution)
            val NStr = getInitalValue("N", "int", solution)
            val exprName = solution.expression.name
            val exprType = solution.expression.type

            var exprInit = getInitalValue(exprName, exprType, solution)
            var motorJointInit = getInitalValue("motor_joint", "Seq(vector(real,8))", solution)

            val nVal = parseIntLiteral(nStr)
            val NVal = parseIntLiteral(NStr)
            val motorTInit = getInputInitialValue(solution, "motor_T")
            val axisRotInit = getInputInitialValue(solution, "axis_rot")
            val jointTypeInit = getInputInitialValue(solution, "joint_type")
            val bKInit = getInitalValue("B_k", "Seq(matrix(real,4,4))", solution)

            var motorKCount = nVal
            if (motorKCount <= 0) {
                motorKCount = countSeqElements(motorTInit)
            }
            if (motorKCount <= 0) {
                motorKCount = countSeqElements(bKInit)
            }
            if (motorKCount <= 0) {
                val axisCount = countSeqElements(axisRotInit)
                if (axisCount > 0) {
                    motorKCount = axisCount + 1
                }
            }

            var motorJointCount = NVal
            if (motorJointCount <= 0) {
                motorJointCount = countSeqElements(axisRotInit)
            }
            if (motorJointCount <= 0) {
                motorJointCount = countSeqElements(jointTypeInit)
            }

            if (exprName == "motor_k") {
                exprInit = ensureMotorSeqInit(exprInit, motorKCount)
            }
            motorJointInit = ensureMotorSeqInit(motorJointInit, motorJointCount)

            val stateDecls = new StringBuilder
            val declared = new java.util.LinkedHashSet<String>()

            appendStateVar(stateDecls, declared, exprName, exprType, exprInit)
            appendStateVar(stateDecls, declared, "B_k", "Seq(matrix(real,4,4))", getInitalValue("B_k", "Seq(matrix(real,4,4))", solution))
            appendStateVar(stateDecls, declared, "motor_joint", "Seq(vector(real,8))", motorJointInit)
            appendStateVar(stateDecls, declared, "n", "int", nStr)
            appendStateVar(stateDecls, declared, "N", "int", NStr)

            for (input : solution.inputs) {
                val name = input.value?.name
                if (name !== null && name != exprName) {
                    appendStateVar(stateDecls, declared, name, input.value.type, getInitalValue(name, input.value.type, solution))
                }
            }

            '''
            Solution temp {
                state{
                    «stateDecls.toString»
                }
                functions{
                    function motorIdentity(): vec(8) { }
                    function motorProduct(m1: vec(8), m2: vec(8)): vec(8) { }
                    function motorReverse(m: vec(8)): vec(8) { }
                    function motorToMatrix(m: vec(8)): mat(4,4) { }
                    function identity(n: int): mat() { }

                    function sin(x: float): float { }
                    function cos(x: float): float { }
                }
                computation{
                    // Step 1: Base link (index N) uses its fixed motor (allows base offset)
                    motor_k[N] = motor_T[N];
                    B_k[N] = motorToMatrix(motor_k[N]);

                    // Step 2: Build joint motors + absolute link motors from base (inboard) to tip (outboard)
                    //
                    // Conventions:
                    //   - motor_T[k] : fixed frame motor from parent(link k+2) to child(link k+1)
                    //   - motor_joint[k] = motor_T[k] * jointMotor(theta[k])
                    //   - motor_k[k] = motor_k[k+1] * motor_joint[k]
                    //
                    // joint_type[k]:
                    //   0 = revolute  (Rotor about axis_rot[k])
                    //   1 = prismatic (Translator along axis_lin[k])
                    for (k: int in range(N-1, -1, -1)) {

                        if (joint_type[k] == 0) {
                            // --- Revolute joint motor: Rotor(axis_rot, theta) ---
                            // axis_rot stores rotor-generator coefficients in basis [e12,e13,e23]
                            half_angle : float = 0.5 * theta[k];
                            // Rotor(q) = cos(q/2) + sin(q/2) * axis_rot
                            s : float = sin(half_angle);

                            rotor : vec(8) = motorIdentity();
                            rotor[0] = cos(half_angle);
                            rotor[1] = s * axis_rot[k][0]; // e12
                            rotor[2] = s * axis_rot[k][1]; // e13
                            rotor[3] = s * axis_rot[k][2]; // e23
                            // rotor[4..7] remain 0

                            motor_joint[k] = motorProduct(motor_T[k], rotor);

                        } else {
                            // --- Prismatic joint motor: Translator(axis_lin * theta) ---
                            t : vec(3) = axis_lin[k] * theta[k];

                            translator : vec(8) = motorIdentity();
                            translator[0] = 1.0;
                            translator[4] = -0.5 * t[0];
                            translator[5] = -0.5 * t[1];
                            translator[6] = -0.5 * t[2];
                            translator[7] = 0.0;

                            motor_joint[k] = motorProduct(motor_T[k], translator);
                        }

                        // absolute motor + matrix form
                        motor_k[k] = motorProduct(motor_k[k+1], motor_joint[k]);
                        B_k[k] = motorToMatrix(motor_k[k]);
                    }
                }
            }
            '''
        }

    }

    // Inverse dynamics (RNEA)
    static class InverseDynamicsRNEA {

        static def String asSolution(SlnRef solution) {
            val NStr = getInitalValue("N", "int", solution)
            val NInt = Integer.parseInt(NStr)
            val exprName = solution.expression.name
            val exprType = solution.expression.type

            val stateDecls = new StringBuilder
            val declared = new java.util.LinkedHashSet<String>()

            appendStateVar(stateDecls, declared, exprName, exprType, getInitalValue(exprName, exprType, solution))
            appendStateVar(stateDecls, declared, "N", "int", NStr)
            for (input : solution.inputs) {
                val name = input.value?.name
                if (name !== null && name != exprName) {
                    appendStateVar(stateDecls, declared, name, input.value.type, getInitalValue(name, input.value.type, solution))
                }
            }

            '''
            Solution temp {
                state{
                    «stateDecls.toString»
                }

                functions{
                    // --- core linear algebra helpers (explicit / traceable) ---
                    function skewSymmetric(v: vec(3)): mat(3,3) {
                        skewSymmetric[0,0] == 0 /\
                        skewSymmetric[0,1] == -v[2] /\
                        skewSymmetric[0,2] == v[1] /\
                        skewSymmetric[1,0] == v[2] /\
                        skewSymmetric[1,1] == 0 /\
                        skewSymmetric[1,2] == -v[0] /\
                        skewSymmetric[2,0] == -v[1] /\
                        skewSymmetric[2,1] == v[0] /\
                        skewSymmetric[2,2] == 0
                    }

                    function zeroMat(rows: int, cols: int): mat() {
                        for (i: int in range(0, rows, 1)) {
                            for (j: int in range(0, cols, 1)) {
                                zeroMat[i,j] == 0
                            }
                        }
                    }
                    function zeroVec(size: int): vec() {
                        for (i: int in range(0, size, 1)) {
                            zeroVec[i] == 0
                        }
                    }

                    // Motion cross operator crm(v) = [ω× 0; v× ω×]
                    function spatialCrossMotion(v: vec(6)): mat(6,6) {
                        // ω× block
                        for (i: int in range(0, 3, 1)) {
                            for (j: int in range(0, 3, 1)) {
                                spatialCrossMotion[i,j] == skewSymmetric(subvector(v)(0, 3))[i,j]
                            }
                        } /\
                        // 0 block
                        for (i: int in range(0, 3, 1)) {
                            for (j: int in range(3, 6, 1)) {
                                spatialCrossMotion[i,j] == 0
                            }
                        } /\
                        // v× block
                        for (i: int in range(3, 6, 1)) {
                            for (j: int in range(0, 3, 1)) {
                                spatialCrossMotion[i,j] == skewSymmetric(subvector(v)(3, 3))[i - 3, j]
                            }
                        } /\
                        // ω× block (bottom-right)
                        for (i: int in range(3, 6, 1)) {
                            for (j: int in range(3, 6, 1)) {
                                spatialCrossMotion[i,j] == skewSymmetric(subvector(v)(0, 3))[i - 3, j - 3]
                            }
                        }
                    }

                    // Force cross operator crf(v) = [ω× v×; 0 ω×]
                    function spatialCrossForce(v: vec(6)): mat(6,6) {
                        // ω× block (top-left)
                        for (i: int in range(0, 3, 1)) {
                            for (j: int in range(0, 3, 1)) {
                                spatialCrossForce[i,j] == skewSymmetric(subvector(v)(0, 3))[i,j]
                            }
                        } /\
                        // v× block (top-right)
                        for (i: int in range(0, 3, 1)) {
                            for (j: int in range(3, 6, 1)) {
                                spatialCrossForce[i,j] == skewSymmetric(subvector(v)(3, 3))[i, j - 3]
                            }
                        } /\
                        // 0 block (bottom-left)
                        for (i: int in range(3, 6, 1)) {
                            for (j: int in range(0, 3, 1)) {
                                spatialCrossForce[i,j] == 0
                            }
                        } /\
                        // ω× block (bottom-right)
                        for (i: int in range(3, 6, 1)) {
                            for (j: int in range(3, 6, 1)) {
                                spatialCrossForce[i,j] == skewSymmetric(subvector(v)(0, 3))[i - 3, j - 3]
                            }
                        }
                    }

                    // These are treated as built-ins by the toolchain/runtime
                    function transpose(m: mat()): mat() { }
                    function identity(n: int): mat() { }
                }

                computation{
                    // Step 1: Build per-link Xup (motion transform), S (joint motion axis), and spatial inertia I
                    Xup : seq(mat(6,6)) = seq(«FOR i : 0 ..< NInt»zeroMat(6,6)«IF i < NInt-1»,«ENDIF»«ENDFOR»);
                    S   : seq(vec(6))   = seq(«FOR i : 0 ..< NInt»zeroVec(6)«IF i < NInt-1»,«ENDIF»«ENDFOR»);
                    I   : seq(mat(6,6)) = seq(«FOR i : 0 ..< NInt»zeroMat(6,6)«IF i < NInt-1»,«ENDIF»«ENDFOR»);

                    for (i: int in range(0, N, 1)) {

                        // ---- Xup[i]: from parent (i+1) to child (i) ----
                        R_p : mat(3,3) = submatrix(B_k[i+1])(0,0,3,3);
                        p_p : vec(3)   = submatrix(B_k[i+1])(0,3,3,1);
                        R_c : mat(3,3) = submatrix(B_k[i])(0,0,3,3);
                        p_c : vec(3)   = submatrix(B_k[i])(0,3,3,1);

                        R_pc : mat(3,3) = transpose(R_p) * R_c;
                        p_pc : vec(3)   = transpose(R_p) * (p_c - p_p);

                        E : mat(3,3) = transpose(R_pc); // rotation parent->child

                        X : mat(6,6) = zeroMat(6,6);
                        submatrix(X)(0,0,3,3) = E;
                        submatrix(X)(3,3,3,3) = E;
                        submatrix(X)(3,0,3,3) = -E * skewSymmetric(p_pc);

                        Xup[i] = X;

                        // ---- S[i]: joint motion axis (no exposed H API) ----
                        S_i : vec(6) = zeroVec(6);

                        if (joint_type[i] == 0) {
                            // revolute: ω = (axis_x, axis_y, axis_z), v = 0
                            // axis_rot stores (e12,e13,e23) = (z, y, x)
                            S_i[0] = axis_rot[i][2];
                            S_i[1] = axis_rot[i][1];
                            S_i[2] = axis_rot[i][0];
                        } else {
                            // prismatic: ω = 0, v = axis_lin
                            S_i[3] = axis_lin[i][0];
                            S_i[4] = axis_lin[i][1];
                            S_i[5] = axis_lin[i][2];
                        }

                        S[i] = S_i;

                        // ---- I[i]: spatial inertia at link frame origin ----
                        m  : float = mass_k[i];
                        com_i : vec(3) = com_k[i];
                        Ic : mat(3,3) = inertia_k[i];
                        Cx : mat(3,3) = skewSymmetric(com_i);

                        I11 : mat(3,3) = Ic + m * Cx * transpose(Cx);
                        I12 : mat(3,3) = m * Cx;
                        I21 : mat(3,3) = transpose(I12);
                        I22 : mat(3,3) = m * identity(3);

                        Ii : mat(6,6) = zeroMat(6,6);
                        submatrix(Ii)(0,0,3,3) = I11;
                        submatrix(Ii)(0,3,3,3) = I12;
                        submatrix(Ii)(3,0,3,3) = I21;
                        submatrix(Ii)(3,3,3,3) = I22;

                        I[i] = Ii;
                    }

                    // Step 2: Damping torque (explicit)
                    tau_d : vec(«NStr») = damping * d_theta;

                    // Step 3: RNEA forward pass (base -> tip): v, a, f
                    v : seq(vec(6)) = seq(«FOR i : 0 ..< NInt»zeroVec(6)«IF i < NInt-1»,«ENDIF»«ENDFOR»);
                    a : seq(vec(6)) = seq(«FOR i : 0 ..< NInt»zeroVec(6)«IF i < NInt-1»,«ENDIF»«ENDFOR»);
                    f : seq(vec(6)) = seq(«FOR i : 0 ..< NInt»zeroVec(6)«IF i < NInt-1»,«ENDIF»«ENDFOR»);

                    // Gravity as pseudo base acceleration (linear Z component)
                    a_base : vec(6) = zeroVec(6);
                    a_base[5] = gravity;

                    for (i: int in range(N-1, -1, -1)) {
                        vJ : vec(6) = S[i] * d_theta[i];

                        if (i == N-1) {
                            v[i] = vJ;
                            a[i] = Xup[i] * a_base + spatialCrossMotion(v[i]) * vJ + S[i] * dd_theta[i];
                        } else {
                            v[i] = Xup[i] * v[i+1] + vJ;
                            a[i] = Xup[i] * a[i+1] + spatialCrossMotion(v[i]) * vJ + S[i] * dd_theta[i];
                        }

                        f[i] = I[i] * a[i] + spatialCrossForce(v[i]) * (I[i] * v[i]);
                    }

                    // Step 4: RNEA backward pass (tip -> base): accumulate forces + extract joint torques
                    for (i: int in range(0, N, 1)) {
                        tau[i] = transpose(S[i]) * f[i] + tau_d[i];

                        if (i < N-1) {
                            f[i+1] = f[i+1] + transpose(Xup[i]) * f[i];
                        }
                    }
                }
            }
            '''
        }

    }

    // Forward dynamics (ABA)
    static class ABAForwardDynamics {

        static def String asSolution(SlnRef solution) {
            val NStr = getInitalValue("N", "int", solution)
            val NInt = Integer.parseInt(NStr)
            val exprName = solution.expression.name
            val exprType = solution.expression.type

            val stateDecls = new StringBuilder
            val declared = new java.util.LinkedHashSet<String>()

            appendStateVar(stateDecls, declared, exprName, exprType, getInitalValue(exprName, exprType, solution))
            appendStateVar(stateDecls, declared, "N", "int", NStr)
            for (input : solution.inputs) {
                val name = input.value?.name
                if (name !== null && name != exprName) {
                    appendStateVar(stateDecls, declared, name, input.value.type, getInitalValue(name, input.value.type, solution))
                }
            }

            '''
            Solution temp {
                state{
                    «stateDecls.toString»
                }

                functions{
                    function skewSymmetric(v: vec(3)): mat(3,3) {
                        skewSymmetric[0,0] == 0 /\
                        skewSymmetric[0,1] == -v[2] /\
                        skewSymmetric[0,2] == v[1] /\
                        skewSymmetric[1,0] == v[2] /\
                        skewSymmetric[1,1] == 0 /\
                        skewSymmetric[1,2] == -v[0] /\
                        skewSymmetric[2,0] == -v[1] /\
                        skewSymmetric[2,1] == v[0] /\
                        skewSymmetric[2,2] == 0
                    }

                    function zeroMat(rows: int, cols: int): mat() {
                        for (i: int in range(0, rows, 1)) {
                            for (j: int in range(0, cols, 1)) {
                                zeroMat[i,j] == 0
                            }
                        }
                    }
                    function zeroVec(size: int): vec() {
                        for (i: int in range(0, size, 1)) {
                            zeroVec[i] == 0
                        }
                    }

                    function spatialCrossMotion(v: vec(6)): mat(6,6) {
                        for (i: int in range(0, 3, 1)) {
                            for (j: int in range(0, 3, 1)) {
                                spatialCrossMotion[i,j] == skewSymmetric(subvector(v)(0, 3))[i,j]
                            }
                        } /\
                        for (i: int in range(0, 3, 1)) {
                            for (j: int in range(3, 6, 1)) {
                                spatialCrossMotion[i,j] == 0
                            }
                        } /\
                        for (i: int in range(3, 6, 1)) {
                            for (j: int in range(0, 3, 1)) {
                                spatialCrossMotion[i,j] == skewSymmetric(subvector(v)(3, 3))[i - 3, j]
                            }
                        } /\
                        for (i: int in range(3, 6, 1)) {
                            for (j: int in range(3, 6, 1)) {
                                spatialCrossMotion[i,j] == skewSymmetric(subvector(v)(0, 3))[i - 3, j - 3]
                            }
                        }
                    }

                    function spatialCrossForce(v: vec(6)): mat(6,6) {
                        for (i: int in range(0, 3, 1)) {
                            for (j: int in range(0, 3, 1)) {
                                spatialCrossForce[i,j] == skewSymmetric(subvector(v)(0, 3))[i,j]
                            }
                        } /\
                        for (i: int in range(0, 3, 1)) {
                            for (j: int in range(3, 6, 1)) {
                                spatialCrossForce[i,j] == skewSymmetric(subvector(v)(3, 3))[i, j - 3]
                            }
                        } /\
                        for (i: int in range(3, 6, 1)) {
                            for (j: int in range(0, 3, 1)) {
                                spatialCrossForce[i,j] == 0
                            }
                        } /\
                        for (i: int in range(3, 6, 1)) {
                            for (j: int in range(3, 6, 1)) {
                                spatialCrossForce[i,j] == skewSymmetric(subvector(v)(0, 3))[i - 3, j - 3]
                            }
                        }
                    }

                    function transpose(m: mat()): mat() { }
                    function identity(n: int): mat() { }
                }

                computation{
                    // Step 1: Build per-link Xup, S, and spatial inertia I
                    Xup : seq(mat(6,6)) = seq(«FOR i : 0 ..< NInt»zeroMat(6,6)«IF i < NInt-1»,«ENDIF»«ENDFOR»);
                    S   : seq(vec(6))   = seq(«FOR i : 0 ..< NInt»zeroVec(6)«IF i < NInt-1»,«ENDIF»«ENDFOR»);
                    I   : seq(mat(6,6)) = seq(«FOR i : 0 ..< NInt»zeroMat(6,6)«IF i < NInt-1»,«ENDIF»«ENDFOR»);

                    for (i: int in range(0, N, 1)) {

                        // Xup (parent i+1 -> child i)
                        R_p : mat(3,3) = submatrix(B_k[i+1])(0,0,3,3);
                        p_p : vec(3)   = submatrix(B_k[i+1])(0,3,3,1);
                        R_c : mat(3,3) = submatrix(B_k[i])(0,0,3,3);
                        p_c : vec(3)   = submatrix(B_k[i])(0,3,3,1);

                        R_pc : mat(3,3) = transpose(R_p) * R_c;
                        p_pc : vec(3)   = transpose(R_p) * (p_c - p_p);

                        E : mat(3,3) = transpose(R_pc);

                        X : mat(6,6) = zeroMat(6,6);
                        submatrix(X)(0,0,3,3) = E;
                        submatrix(X)(3,3,3,3) = E;
                        submatrix(X)(3,0,3,3) = -E * skewSymmetric(p_pc);

                        Xup[i] = X;

                        // S (joint motion axis)
                        S_i : vec(6) = zeroVec(6);

                        if (joint_type[i] == 0) {
                            S_i[0] = axis_rot[i][2];
                            S_i[1] = axis_rot[i][1];
                            S_i[2] = axis_rot[i][0];
                        } else {
                            S_i[3] = axis_lin[i][0];
                            S_i[4] = axis_lin[i][1];
                            S_i[5] = axis_lin[i][2];
                        }

                        S[i] = S_i;

                        // Spatial inertia
                        m  : float = mass_k[i];
                        com_i : vec(3) = com_k[i];
                        Ic : mat(3,3) = inertia_k[i];
                        Cx : mat(3,3) = skewSymmetric(com_i);

                        I11 : mat(3,3) = Ic + m * Cx * transpose(Cx);
                        I12 : mat(3,3) = m * Cx;
                        I21 : mat(3,3) = transpose(I12);
                        I22 : mat(3,3) = m * identity(3);

                        Ii : mat(6,6) = zeroMat(6,6);
                        submatrix(Ii)(0,0,3,3) = I11;
                        submatrix(Ii)(0,3,3,3) = I12;
                        submatrix(Ii)(3,0,3,3) = I21;
                        submatrix(Ii)(3,3,3,3) = I22;

                        I[i] = Ii;
                    }

                    // Step 2: Damping torque
                    tau_d : vec(«NStr») = damping * d_theta;

                    // Step 3: ABA forward pass (velocities + bias terms)
                    v  : seq(vec(6)) = seq(«FOR i : 0 ..< NInt»zeroVec(6)«IF i < NInt-1»,«ENDIF»«ENDFOR»);
                    bias_c  : seq(vec(6)) = seq(«FOR i : 0 ..< NInt»zeroVec(6)«IF i < NInt-1»,«ENDIF»«ENDFOR»);

                    IA : seq(mat(6,6)) = I;
                    pA : seq(vec(6))   = seq(«FOR i : 0 ..< NInt»zeroVec(6)«IF i < NInt-1»,«ENDIF»«ENDFOR»);

                    for (i: int in range(N-1, -1, -1)) {
                        vJ : vec(6) = S[i] * d_theta[i];

                        if (i == N-1) {
                            v[i] = vJ;
                        } else {
                            v[i] = Xup[i] * v[i+1] + vJ;
                        }

                        bias_c[i]  = spatialCrossMotion(v[i]) * vJ;
                        pA[i] = spatialCrossForce(v[i]) * (I[i] * v[i]);
                    }

                    // Step 4: ABA backward pass (articulated inertia propagation)
                    U  : seq(vec(6)) = seq(«FOR i : 0 ..< NInt»zeroVec(6)«IF i < NInt-1»,«ENDIF»«ENDFOR»);
                    d  : vec(«NStr») = zeroVec(N);
                    u  : vec(«NStr») = zeroVec(N);

                    Ia : seq(mat(6,6)) = seq(«FOR i : 0 ..< NInt»zeroMat(6,6)«IF i < NInt-1»,«ENDIF»«ENDFOR»);
                    pa : seq(vec(6))   = seq(«FOR i : 0 ..< NInt»zeroVec(6)«IF i < NInt-1»,«ENDIF»«ENDFOR»);

                    for (i: int in range(0, N, 1)) {
                        U[i] = IA[i] * S[i];
                        d[i] = transpose(S[i]) * U[i];
                        u[i] = tau[i] - transpose(S[i]) * pA[i] - tau_d[i];

                        Ia[i] = IA[i] - (U[i] * (1.0 / d[i])) * transpose(U[i]);
                        pa[i] = pA[i] + Ia[i] * bias_c[i] + U[i] * (u[i] / d[i]);

                        if (i < N-1) {
                            IA[i+1] = IA[i+1] + transpose(Xup[i]) * Ia[i] * Xup[i];
                            pA[i+1] = pA[i+1] + transpose(Xup[i]) * pa[i];
                        }
                    }

                    // Step 5: ABA forward pass (accelerations)
                    a_base : vec(6) = zeroVec(6);
                    a_base[5] = gravity;

                    a : seq(vec(6)) = seq(«FOR i : 0 ..< NInt»zeroVec(6)«IF i < NInt-1»,«ENDIF»«ENDFOR»);

                    for (i: int in range(N-1, -1, -1)) {
                        if (i == N-1) {
                a[i] = Xup[i] * a_base + bias_c[i];
            } else {
                a[i] = Xup[i] * a[i+1] + bias_c[i];
            }

                        dd_theta[i] = (u[i] - transpose(U[i]) * a[i]) / d[i];
                        a[i] = a[i] + S[i] * dd_theta[i];
                    }
                }
            }
            '''
        }

    }

    // Euler integration
    static class Euler{
        static def String asSolution(SlnRef solution) {
            val expressionName = solution.expression.name
            val derivativeName = if (expressionName.startsWith("d_")) {
                "dd_" + expressionName.substring(2)
            } else {
                "d_" + expressionName
            }

            '''
            Solution temp {
                state{ «expressionName» : «simplifyType(solution.expression.type)» = «getInitalValue(expressionName,solution.expression.type, solution)»;
                       «getInputs(solution)»
                }
                computation{
                    «expressionName» = «expressionName» + dt * «derivativeName»;
                }
            }
            '''
        }

    }
}
