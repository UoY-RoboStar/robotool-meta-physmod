// FEATHERSTONE.xtend - Source-code generation templates for Featherstone spatial-vector dynamics
//
// Implements (explicitly, with unfolded intermediate matrices):
//   - RNEA Bias forces (Featherstone/RBDA Table 5.1 with qdd=0)
//   - CRBA mass matrix (RBDA Table 6.2)
//   - ABA forward dynamics (RBDA Table 7.1)
//   - Explicit LDLT inversion (for CRBA-based forward dynamics)
//   - Euler integration
//
// Indexing / numbering convention (Featherstone / RBDA "regular numbering"):
//   - Base-to-tip numbering: base link is 0, then 1..N moving links outwards.
//   - In serial chains, parent(i) = i-1 (with parent(0)=base).
//   - q, XT, I, jtype sequences are ordered BASE -> TIP (i = 0..N-1 corresponds to link number i+1).
//

package circus.robocalc.robosim.physmod.libs.sourceCodeGen.formulation

import circus.robocalc.robosim.physmod.slnRef.slnRef.SlnRef

import static circus.robocalc.robosim.physmod.libs.sourceCodeGen.formulation.SKO.getInitalValue
import static circus.robocalc.robosim.physmod.libs.sourceCodeGen.libUtils.libUtils.*

class FEATHERSTONE {

    private static def String zeroInitialiser(String simplifiedType) {
        if (simplifiedType === null) {
            return "0"
        }
        if (simplifiedType.startsWith("vec(") && simplifiedType.endsWith(")")) {
            val size = simplifiedType.substring(4, simplifiedType.length - 1).trim
            return "zeroVec(" + size + ")"
        }
        if (simplifiedType.startsWith("mat(") && simplifiedType.endsWith(")")) {
            val inner = simplifiedType.substring(4, simplifiedType.length - 1)
            val parts = inner.split(",")
            if (parts.size >= 2) {
                val rows = parts.get(0).trim
                val cols = parts.get(1).trim
                return "zeroMat(" + rows + ", " + cols + ")"
            }
        }
        if (simplifiedType.startsWith("seq(")) {
            return "seq()"
        }
        return "0"
    }

    private static def String inputName(SlnRef solution, int index) {
        if (solution === null || solution.inputs === null || solution.inputs.size <= index) {
            throw new IllegalStateException("Missing expected input at index " + index)
        }
        val name = solution.inputs.get(index).value?.name
        if (name === null || name.trim.length == 0) {
            throw new IllegalStateException("Missing input name at index " + index)
        }
        return name
    }

    private static def int parseCount(String value, int fallback) {
        if (value === null) {
            return fallback
        }
        try {
            return Integer.parseInt(value.trim)
        } catch (Exception e) {
            return fallback
        }
    }

    private static val String IDENTITY_6_LITERAL =
        "[1.0,0.0,0.0,0.0,0.0,0.0; " +
        "0.0,1.0,0.0,0.0,0.0,0.0; " +
        "0.0,0.0,1.0,0.0,0.0,0.0; " +
        "0.0,0.0,0.0,1.0,0.0,0.0; " +
        "0.0,0.0,0.0,0.0,1.0,0.0; " +
        "0.0,0.0,0.0,0.0,0.0,1.0]"

    private static def String repeatSeq(String element, int count) {
        if (count <= 0) {
            return "seq()"
        }
        val parts = new java.util.ArrayList<String>()
        for (i : 0 ..< count) {
            parts.add(element)
        }
        return "seq(" + parts.join(", ") + ")"
    }

    private static def String featherstoneInputs(SlnRef solution, String xtName, String iName, String jtypeName, String nStr) {
        val count = parseCount(nStr, 0)
        var inputs = ""
        for (input : solution.inputs) {
            val isExpr = solution.expression !== null && input.value.name == solution.expression.name
            if (!isExpr) {
                val rawType = if (input.value?.type === null) "" else input.value.type.trim
                val isSeqType = rawType.startsWith("Seq(") || rawType.startsWith("seq(")
                var initVal = if (isSeqType)
                    getInitalValue(input.value.name, solution)
                else
                    getInitalValue(input.value.name, input.value.type, solution)

                if (isSeqType && (initVal === null || initVal.trim == "seq()")) {
                    if (input.value.name == xtName) {
                        initVal = repeatSeq(IDENTITY_6_LITERAL, count)
                    } else if (input.value.name == iName) {
                        initVal = repeatSeq(IDENTITY_6_LITERAL, count)
                    } else if (input.value.name == jtypeName) {
                        initVal = repeatSeq("1", count)
                    }
                }

                inputs += input.value.name + " : " + simplifyType(input.value.type)
                if (initVal !== null && initVal.trim != "seq()") {
                    inputs += " = " + initVal
                }
                inputs += ";" + "\n"
            }
        }
        return inputs
    }

    // RNEA bias forces
    static class RNEABias {

        static def String asSolution(SlnRef solution){

            val outExp = solution.expression
            val outName = outExp.name
            val outType = simplifyType(outExp.type)

            val qName = inputName(solution, 0)
            val dqName = inputName(solution, 1)
            val XTName = inputName(solution, 2)
            val IName = inputName(solution, 3)
            val jtypeName = inputName(solution, 4)

            // Sizes & constants
            val NStr = getInitalValue("N","int",solution)
            val gravityVal = getInitalValue("gravity","float",solution)
            val inputs = featherstoneInputs(solution, XTName, IName, jtypeName, NStr)

            return '''
Solution temp{
    state{
        N: int = «NStr»;
        gravity: float = «gravityVal»;

        «outName» : «outType» = «zeroInitialiser(outType)»;
        «inputs»
    }
    functions{
        function identity(n: int) : mat() {}
        function transpose(m: mat()) : mat() {}
        function skewSymmetric(p: vec(3)) : mat(3,3) {
            skewSymmetric[0,0] == 0 /\
            skewSymmetric[0,1] == -p[2] /\
            skewSymmetric[0,2] == p[1] /\
            skewSymmetric[1,0] == p[2] /\
            skewSymmetric[1,1] == 0 /\
            skewSymmetric[1,2] == -p[0] /\
            skewSymmetric[2,0] == -p[1] /\
            skewSymmetric[2,1] == p[0] /\
            skewSymmetric[2,2] == 0
        }

        function sin(x: float) : float {}
        function cos(x: float) : float {}

        function zeroVec(n: int) : vec() {}
        function zeroMat(n: int, m: int) : mat() {}
        function zeroVecSeq(length: int, n: int) : seq(vec()) {}
        function zeroMatSeq(length: int, n: int, m: int) : seq(mat()) {}
    }
    computation{
        // RBDA Table 5.1 (body coordinates) with qdd = 0 to obtain C(q,qd)

        Xup : seq(mat(6,6)) = zeroMatSeq(N,6,6);
        S   : seq(vec(6))   = zeroVecSeq(N,6);
        v   : seq(vec(6))   = zeroVecSeq(N,6);
        a   : seq(vec(6))   = zeroVecSeq(N,6);
        f   : seq(vec(6))   = zeroVecSeq(N,6);

        // Base conditions (fixed base):
        // v_base = 0, a_base = +g (matches SKO_gravity convention: gravity vector is [0,0,-g])
        v_base : vec(6) = zeroVec(6);
        a_base : vec(6) = zeroVec(6);
        // Linear acceleration component (vz) holds +g for downward gravity (world z up)
        a_base[5] = gravity;

        // --- Pass 1: outward (base -> tip) ------------------------------------------
        // Regular numbering (base -> tip): outward traversal is i = 0 .. N-1.
        for(i: int in range(0,N,1)){
            // ---- jcalc(jtype[i], q[i], qd[i]) (expanded) ---------------------------
            jt : int = jtype[i];
            axisSign : float = 1.0;
            if (jt < 0) { axisSign = -1.0; }
            jtAbs : int = jt;
            if (jt < 0) { jtAbs = -jt; }

            qi : float = q[i];
            qdi: float = d_q[i];

            // Signed joint displacement for negative-axis joints
            qEff : float = axisSign * qi;

            Si  : vec(6) = zeroVec(6);
            XJ  : mat(6,6) = identity(6);

            if (jtAbs == 1){ // Rx
                Si = [ axisSign,0,0, 0,0,0 ];
                c: float = cos(qEff);
                s: float = sin(qEff);
                XJ = [ 1,0,0, 0,0,0;
                       0,c,s, 0,0,0;
                       0,-s,c,0,0,0;
                       0,0,0, 1,0,0;
                       0,0,0, 0,c,s;
                       0,0,0, 0,-s,c ];
            }
            if (jtAbs == 2){ // Ry
                Si = [ 0,axisSign,0, 0,0,0 ];
                c: float = cos(qEff);
                s: float = sin(qEff);
                XJ = [ c,0,-s, 0,0,0;
                       0,1,0,  0,0,0;
                       s,0,c,  0,0,0;
                       0,0,0,  c,0,-s;
                       0,0,0,  0,1,0;
                       0,0,0,  s,0,c ];
            }
            if (jtAbs == 3){ // Rz
                Si = [ 0,0,axisSign, 0,0,0 ];
                c: float = cos(qEff);
                s: float = sin(qEff);
                XJ = [ c,s,0,  0,0,0;
                       -s,c,0, 0,0,0;
                       0,0,1,  0,0,0;
                       0,0,0,  c,s,0;
                       0,0,0, -s,c,0;
                       0,0,0,  0,0,1 ];
            }
            if (jtAbs == 4){ // Px
                Si = [ 0,0,0, axisSign,0,0 ];
                d: float = qEff;
                XJ = [ 1,0,0, 0,0,0;
                       0,1,0, 0,0,0;
                       0,0,1, 0,0,0;
                       0,0,0, 1,0,0;
                       0,0,d, 0,1,0;
                       0,-d,0,0,0,1 ];
            }
            if (jtAbs == 5){ // Py
                Si = [ 0,0,0, 0,axisSign,0 ];
                d: float = qEff;
                XJ = [ 1,0,0, 0,0,0;
                       0,1,0, 0,0,0;
                       0,0,1, 0,0,0;
                       0,0,-d,1,0,0;
                       0,0,0, 0,1,0;
                       d,0,0, 0,0,1 ];
            }
            if (jtAbs == 6){ // Pz
                Si = [ 0,0,0, 0,0,axisSign ];
                d: float = qEff;
                XJ = [ 1,0,0, 0,0,0;
                       0,1,0, 0,0,0;
                       0,0,1, 0,0,0;
                       0,d,0, 1,0,0;
                       -d,0,0,0,1,0;
                       0,0,0, 0,0,1 ];
            }

            S[i] = Si;

            // vJ = S*qd, cJ = 0 for these standard joints
            vJ : vec(6) = Si * qdi;

            // Xup = XJ * XT
            Xup[i] = XJ * XT[i];

            // Parent velocity/acceleration (serial-chain parent(i)=i-1; base is outside arrays)
            if (i == 0){
                // parent is base
                v[i] = Xup[i] * v_base + vJ;
            } else {
                // parent is i-1
                v[i] = Xup[i] * v[i-1] + vJ;
            }

            // crm(v) matrix (spatial cross product for motion vectors)
            w : vec(3) = subvector(v[i])(0,3);
            vl: vec(3) = subvector(v[i])(3,3);
            wx: mat(3,3) = skewSymmetric(w);
            vx: mat(3,3) = skewSymmetric(vl);

            crm_v : mat(6,6) = zeroMat(6,6);
            submatrix(crm_v)(0,0,3,3) = wx;
            submatrix(crm_v)(3,0,3,3) = vx;
            submatrix(crm_v)(3,3,3,3) = wx;

            // a = Xup*a_parent + cJ + v × vJ   (qdd=0)
            if (i == 0){
                a[i] = Xup[i] * a_base + (crm_v * vJ);
            } else {
                a[i] = Xup[i] * a[i-1] + (crm_v * vJ);
            }

            // crf(v) matrix (spatial cross product for force vectors)
            crf_v : mat(6,6) = zeroMat(6,6);
            submatrix(crf_v)(0,0,3,3) = wx;
            submatrix(crf_v)(0,3,3,3) = vx;
            submatrix(crf_v)(3,3,3,3) = wx;

            // f = I*a + v ×* (I*v)
            Iv : vec(6) = I[i] * v[i];
            f[i] = I[i] * a[i] + (crf_v * Iv);
        }

        // --- Pass 2: inward (tip -> base) --------------------------------------------
        tauBias : vec(«NStr») = zeroVec(N);

        for(i: int in range(N-1,-1,-1)){
            tauBias[i] = transpose(S[i]) * f[i];

            // accumulate to parent (serial chain: parent(i)=i-1)
            if (i > 0){
                f[i-1] = f[i-1] + transpose(Xup[i]) * f[i];
            }
        }

        «outName» = tauBias;
    }
}'''
        }

    }

    // CRBA mass matrix
    static class CRBA {

        static def String asSolution(SlnRef solution){

            val outExp = solution.expression
            val outName = outExp.name
            val outType = simplifyType(outExp.type)

            val qName = inputName(solution, 0)
            val XTName = inputName(solution, 1)
            val IName = inputName(solution, 2)
            val jtypeName = inputName(solution, 3)

            val NStr = getInitalValue("N","int",solution)
            val inputs = featherstoneInputs(solution, XTName, IName, jtypeName, NStr)

            return '''
Solution temp{
    state{
        N: int = «NStr»;
        «outName» : «outType» = «zeroInitialiser(outType)»;
        «inputs»
    }
    functions{
        function identity(n: int) : mat() {}
        function transpose(m: mat()) : mat() {}
        function zeroVec(n: int) : vec() {}
        function zeroMat(n: int, m: int) : mat() {}
        function zeroMatSeq(length: int, n: int, m: int) : seq(mat()) {}
        function zeroVecSeq(length: int, n: int) : seq(vec()) {}
        function sin(x: float) : float {}
        function cos(x: float) : float {}
    }
    computation{
        // RBDA Table 6.2 (Composite-Rigid-Body Algorithm) to compute joint-space inertia matrix H(q)

        Xup : seq(mat(6,6)) = zeroMatSeq(N,6,6);
        S   : seq(vec(6))   = zeroVecSeq(N,6);

        // Composite inertias Ic (I^c in the book)
        Ic  : seq(mat(6,6)) = zeroMatSeq(N,6,6);

        // --- Pass 1: compute Xup and initialise Ic (base -> tip) ---------------------
        for(i: int in range(0,N,1)){
            jt : int = jtype[i];
            axisSign : float = 1.0;
            if (jt < 0) { axisSign = -1.0; }
            jtAbs : int = jt;
            if (jt < 0) { jtAbs = -jt; }

            qi : float = q[i];
            qEff : float = axisSign * qi;

            Si : vec(6) = zeroVec(6);
            XJ : mat(6,6) = identity(6);

            if (jtAbs == 1){ // Rx
                Si = [ axisSign,0,0, 0,0,0 ];
                c: float = cos(qEff);
                s: float = sin(qEff);
                XJ = [ 1,0,0, 0,0,0;
                       0,c,s, 0,0,0;
                       0,-s,c,0,0,0;
                       0,0,0, 1,0,0;
                       0,0,0, 0,c,s;
                       0,0,0, 0,-s,c ];
            }
            if (jtAbs == 2){ // Ry
                Si = [ 0,axisSign,0, 0,0,0 ];
                c: float = cos(qEff);
                s: float = sin(qEff);
                XJ = [ c,0,-s, 0,0,0;
                       0,1,0,  0,0,0;
                       s,0,c,  0,0,0;
                       0,0,0,  c,0,-s;
                       0,0,0,  0,1,0;
                       0,0,0,  s,0,c ];
            }
            if (jtAbs == 3){ // Rz
                Si = [ 0,0,axisSign, 0,0,0 ];
                c: float = cos(qEff);
                s: float = sin(qEff);
                XJ = [ c,s,0,  0,0,0;
                       -s,c,0, 0,0,0;
                       0,0,1,  0,0,0;
                       0,0,0,  c,s,0;
                       0,0,0, -s,c,0;
                       0,0,0,  0,0,1 ];
            }
            if (jtAbs == 4){ // Px
                Si = [ 0,0,0, axisSign,0,0 ];
                d: float = qEff;
                XJ = [ 1,0,0, 0,0,0;
                       0,1,0, 0,0,0;
                       0,0,1, 0,0,0;
                       0,0,0, 1,0,0;
                       0,0,d, 0,1,0;
                       0,-d,0,0,0,1 ];
            }
            if (jtAbs == 5){ // Py
                Si = [ 0,0,0, 0,axisSign,0 ];
                d: float = qEff;
                XJ = [ 1,0,0, 0,0,0;
                       0,1,0, 0,0,0;
                       0,0,1, 0,0,0;
                       0,0,-d,1,0,0;
                       0,0,0, 0,1,0;
                       d,0,0, 0,0,1 ];
            }
            if (jtAbs == 6){ // Pz
                Si = [ 0,0,0, 0,0,axisSign ];
                d: float = qEff;
                XJ = [ 1,0,0, 0,0,0;
                       0,1,0, 0,0,0;
                       0,0,1, 0,0,0;
                       0,d,0, 1,0,0;
                       -d,0,0,0,1,0;
                       0,0,0, 0,0,1 ];
            }

            S[i] = Si;
            Xup[i] = XJ * XT[i];
            Ic[i] = I[i];
        }

        // --- Pass 2: inward recursion (tip -> base) to accumulate Ic and fill H ----------------
        H : mat(«NStr»,«NStr») = zeroMat(N,N);

        // i runs from tip to base
        for(i: int in range(N-1,-1,-1)){
            // F = Ic[i] * S[i]
            F : vec(6) = Ic[i] * S[i];

            // diagonal
            H[i][i] = transpose(S[i]) * F;

            // off-diagonal terms along ancestor chain (serial chain: ancestors are i-1, i-2, ...)
            j : int = i;
            while (j > 0){
                // propagate force to parent
                F = transpose(Xup[j]) * F;
                j = j - 1;
                H[i][j] = transpose(S[j]) * F;
                H[j][i] = H[i][j];
            }

            // accumulate composite inertia to parent
            if (i > 0){
                Ic[i-1] = Ic[i-1] + transpose(Xup[i]) * Ic[i] * Xup[i];
            }
        }

        «outName» = H;
    }
}'''
        }

    }

    // LDLT inversion (symmetric positive definite)
    static class LDLTAlgorithm {

        static def String asSolution(SlnRef solution){

            val outExp = solution.expression
            val outName = outExp.name
            val outType = simplifyType(outExp.type)

            val inputs = getInputs(solution)
            val MName = inputName(solution, 0)

            val NStr = getInitalValue("N","int",solution)

            return '''
Solution temp{
    state{
        N: int = «NStr»;
        «outName» : «outType» = «zeroInitialiser(outType)»;
        «inputs»
    }
    functions{
        function zeroVec(n: int) : vec() {}
        function zeroMat(n: int, m: int) : mat() {}
    }
    computation{
        // Explicit LDLT factorisation + inversion for symmetric PD matrices.
        // Produces inv(M) (used by CRBA-based forward dynamics).
        //
        // Factorisation:
        //   M = L * D * L^T, with L unit-lower-triangular and D diagonal.

        M : mat(«NStr»,«NStr») = «MName»;

        L : mat(«NStr»,«NStr») = zeroMat(N,N);
        D : vec(«NStr»)   = zeroVec(N);

        // Build L and D
        for(i: int in range(0,N,1)){
            L[i][i] = 1.0;

            for(j: int in range(0,i,1)){
                sum : float = M[i][j];
                for(k: int in range(0,j,1)){
                    sum = sum - L[i][k] * D[k] * L[j][k];
                }
                L[i][j] = sum / D[j];
            }

            di : float = M[i][i];
            for(k: int in range(0,i,1)){
                di = di - L[i][k] * L[i][k] * D[k];
            }
            D[i] = di;
        }

        // Invert using solves for each column of I
        Minv : mat(«NStr»,«NStr») = zeroMat(N,N);

        for(c: int in range(0,N,1)){
            // Solve L*y = e_c
            y : vec(«NStr») = zeroVec(N);
            for(i: int in range(0,N,1)){
                rhs : float = 0.0;
                if (i == c) { rhs = 1.0; }

                sum : float = rhs;
                for(k: int in range(0,i,1)){
                    sum = sum - L[i][k] * y[k];
                }
                y[i] = sum; // L[i,i]=1
            }

            // Solve D*z = y
            z : vec(«NStr») = zeroVec(N);
            for(i: int in range(0,N,1)){
                z[i] = y[i] / D[i];
            }

            // Solve L^T*x = z
            x : vec(«NStr») = zeroVec(N);
            for(i: int in range(N-1,-1,-1)){
                sum : float = z[i];
                for(k: int in range(i+1,N,1)){
                    sum = sum - L[k][i] * x[k];
                }
                x[i] = sum; // diag of L^T is 1
            }

            // Set column c
            for(i: int in range(0,N,1)){
                Minv[i][c] = x[i];
            }
        }

        «outName» = Minv;
    }
}'''
        }

    }

    // Forward dynamics via mass-matrix inverse
    static class ForwardDynamics {

        static def String asSolution(SlnRef solution){

            val outExp = solution.expression
            val outName = outExp.name
            val outType = simplifyType(outExp.type)

            val inputs = getInputs(solution)
            val tauName = inputName(solution, 0)
            val CName = inputName(solution, 1)
            val dampingName = inputName(solution, 2)
            val dqName = inputName(solution, 3)
            val HinvName = inputName(solution, 4)

            val NStr = getInitalValue("N","int",solution)

            return '''
Solution temp{
    state{
        N: int = «NStr»;
        «outName» : «outType» = «zeroInitialiser(outType)»;
        «inputs»
    }
    functions{
        function zeroVec(n: int) : vec() {}
    }
    computation{
        // ddq = inv(H) * (tau - C - damping*qd)
        rhs : vec(«NStr») = zeroVec(N);
        rhs = tau - C - damping * d_q;

        «outName» = H_inv * rhs;
    }
}'''
        }

    }

    // ABA forward dynamics
    static class ABAForwardDynamics {

        static def String asSolution(SlnRef solution){

            val outExp = solution.expression
            val outName = outExp.name
            val outType = simplifyType(outExp.type)

            val qName = inputName(solution, 0)
            val dqName = inputName(solution, 1)
            val tauName = inputName(solution, 2)
            val dampingName = inputName(solution, 3)
            val XTName = inputName(solution, 4)
            val IName = inputName(solution, 5)
            val jtypeName = inputName(solution, 6)

            val NStr = getInitalValue("N","int",solution)
            val gravityVal = getInitalValue("gravity","float",solution)
            val inputs = featherstoneInputs(solution, XTName, IName, jtypeName, NStr)

            return '''
Solution temp{
    state{
        N: int = «NStr»;
        gravity: float = «gravityVal»;

        «outName» : «outType» = «zeroInitialiser(outType)»;
        «inputs»
    }
    functions{
        function identity(n: int) : mat() {}
        function transpose(m: mat()) : mat() {}
        function skewSymmetric(p: vec(3)) : mat(3,3) {
            skewSymmetric[0,0] == 0 /\
            skewSymmetric[0,1] == -p[2] /\
            skewSymmetric[0,2] == p[1] /\
            skewSymmetric[1,0] == p[2] /\
            skewSymmetric[1,1] == 0 /\
            skewSymmetric[1,2] == -p[0] /\
            skewSymmetric[2,0] == -p[1] /\
            skewSymmetric[2,1] == p[0] /\
            skewSymmetric[2,2] == 0
        }

        function sin(x: float) : float {}
        function cos(x: float) : float {}

        function zeroVec(n: int) : vec() {}
        function zeroMat(n: int, m: int) : mat() {}
        function zeroVecSeq(length: int, n: int) : seq(vec()) {}
        function zeroMatSeq(length: int, n: int, m: int) : seq(mat()) {}
    }
    computation{
        // RBDA Table 7.1 (Articulated-Body Algorithm) for forward dynamics.
        // Uses tau_eff = tau - damping*qd.

        tau_eff : vec(«NStr») = tau - damping * d_q;

        Xup : seq(mat(6,6)) = zeroMatSeq(N,6,6);
        S   : seq(vec(6))   = zeroVecSeq(N,6);
        v   : seq(vec(6))   = zeroVecSeq(N,6);
        c   : seq(vec(6))   = zeroVecSeq(N,6);

        IA  : seq(mat(6,6)) = zeroMatSeq(N,6,6);
        pA  : seq(vec(6))   = zeroVecSeq(N,6);

        U   : seq(vec(6))   = zeroVecSeq(N,6);
        d   : vec(«NStr»)        = zeroVec(N);
        u   : vec(«NStr»)        = zeroVec(N);

        a   : seq(vec(6))   = zeroVecSeq(N,6);
        qdd : vec(«NStr»)        = zeroVec(N);

        // Base conditions
        v_base : vec(6) = zeroVec(6);
        a_base : vec(6) = zeroVec(6);
        a_base[5] = gravity;

        // --- Pass 1: outward (base -> tip) ------------------------------------------
        for(i: int in range(0,N,1)){
            // jcalc expanded
            jt : int = jtype[i];
            axisSign : float = 1.0;
            if (jt < 0) { axisSign = -1.0; }
            jtAbs : int = jt;
            if (jt < 0) { jtAbs = -jt; }

            qi : float = q[i];
            qdi: float = d_q[i];
            qEff : float = axisSign * qi;

            Si : vec(6) = zeroVec(6);
            XJ : mat(6,6) = identity(6);

            if (jtAbs == 1){ // Rx
                Si = [ axisSign,0,0, 0,0,0 ];
                cR: float = cos(qEff);
                sR: float = sin(qEff);
                XJ = [ 1,0,0, 0,0,0;
                       0,cR,sR, 0,0,0;
                       0,-sR,cR,0,0,0;
                       0,0,0, 1,0,0;
                       0,0,0, 0,cR,sR;
                       0,0,0, 0,-sR,cR ];
            }
            if (jtAbs == 2){ // Ry
                Si = [ 0,axisSign,0, 0,0,0 ];
                cR: float = cos(qEff);
                sR: float = sin(qEff);
                XJ = [ cR,0,-sR, 0,0,0;
                       0,1,0,   0,0,0;
                       sR,0,cR,  0,0,0;
                       0,0,0,   cR,0,-sR;
                       0,0,0,   0,1,0;
                       0,0,0,   sR,0,cR ];
            }
            if (jtAbs == 3){ // Rz
                Si = [ 0,0,axisSign, 0,0,0 ];
                cR: float = cos(qEff);
                sR: float = sin(qEff);
                XJ = [ cR,sR,0,  0,0,0;
                       -sR,cR,0, 0,0,0;
                       0,0,1,    0,0,0;
                       0,0,0,   cR,sR,0;
                       0,0,0,  -sR,cR,0;
                       0,0,0,   0,0,1 ];
            }
            if (jtAbs == 4){ // Px
                Si = [ 0,0,0, axisSign,0,0 ];
                dP: float = qEff;
                XJ = [ 1,0,0, 0,0,0;
                       0,1,0, 0,0,0;
                       0,0,1, 0,0,0;
                       0,0,0, 1,0,0;
                       0,0,dP,0,1,0;
                       0,-dP,0,0,0,1 ];
            }
            if (jtAbs == 5){ // Py
                Si = [ 0,0,0, 0,axisSign,0 ];
                dP: float = qEff;
                XJ = [ 1,0,0, 0,0,0;
                       0,1,0, 0,0,0;
                       0,0,1, 0,0,0;
                       0,0,-dP,1,0,0;
                       0,0,0, 0,1,0;
                       dP,0,0, 0,0,1 ];
            }
            if (jtAbs == 6){ // Pz
                Si = [ 0,0,0, 0,0,axisSign ];
                dP: float = qEff;
                XJ = [ 1,0,0, 0,0,0;
                       0,1,0, 0,0,0;
                       0,0,1, 0,0,0;
                       0,dP,0, 1,0,0;
                       -dP,0,0,0,1,0;
                       0,0,0, 0,0,1 ];
            }

            S[i] = Si;
            Xup[i] = XJ * XT[i];

            // vJ = S*qd, cJ=0
            vJ : vec(6) = Si * qdi;

            // velocity recursion (serial-chain parent(i)=i-1; base is outside arrays)
            if (i == 0){
                v[i] = Xup[i] * v_base + vJ;
            } else {
                v[i] = Xup[i] * v[i-1] + vJ;
            }

            // crm(v) for c(i) = v×vJ + cJ
            w : vec(3) = subvector(v[i])(0,3);
            vl: vec(3) = subvector(v[i])(3,3);
            wx: mat(3,3) = skewSymmetric(w);
            vx: mat(3,3) = skewSymmetric(vl);

            crm_v : mat(6,6) = zeroMat(6,6);
            submatrix(crm_v)(0,0,3,3) = wx;
            submatrix(crm_v)(3,0,3,3) = vx;
            submatrix(crm_v)(3,3,3,3) = wx;

            c[i] = crm_v * vJ; // + cJ (zero)

            // initialise articulated-body inertia and bias force
            IA[i] = I[i];

            // pA = v ×* (I*v)
            crf_v : mat(6,6) = zeroMat(6,6);
            submatrix(crf_v)(0,0,3,3) = wx;
            submatrix(crf_v)(0,3,3,3) = vx;
            submatrix(crf_v)(3,3,3,3) = wx;

            Iv : vec(6) = I[i] * v[i];
            pA[i] = crf_v * Iv;
        }

        // --- Pass 2: inward (tip -> base) -------------------------------------------
        for(i: int in range(N-1,-1,-1)){
            U[i] = IA[i] * S[i];
            d[i] = transpose(S[i]) * U[i];
            u[i] = tau_eff[i] - transpose(S[i]) * pA[i];

            if (i > 0){
                Ia : mat(6,6) = IA[i] - (U[i] * transpose(U[i])) / d[i];
                IA[i-1] = IA[i-1] + transpose(Xup[i]) * Ia * Xup[i];

                // RBDA Table 7.1: use articulated inertia Ia (not the raw IA) for the bias force propagation term
                pa : vec(6) = pA[i] + Ia * c[i] + U[i] * (u[i] / d[i]);
                pA[i-1] = pA[i-1] + transpose(Xup[i]) * pa;
            }
        }

        // --- Pass 3: outward (base -> tip) ------------------------------------------
        for(i: int in range(0,N,1)){
            if (i == 0){
                a[i] = Xup[i] * a_base + c[i];
            } else {
                a[i] = Xup[i] * a[i-1] + c[i];
            }

            qdd[i] = (u[i] - transpose(U[i]) * a[i]) / d[i];
            a[i] = a[i] + S[i] * qdd[i];
        }

        «outName» = qdd;
    }
}'''
        }

    }

    // Euler integration
    static class Euler {

        static def String asSolution(SlnRef solution){

            val outExp = solution.expression
            val outName = outExp.name
            val outType = simplifyType(outExp.type)

            val inputs = getInputs(solution)

            // Determine the name of the derivative variable that corresponds to outName
            val derivativeName = if (outName.startsWith("d_")) "dd_" + outName.substring(2) else "d_" + outName

            return '''
Solution temp{
    state{
        «outName» : «outType» = «zeroInitialiser(outType)»;
        «inputs»
    }
    functions{
        function zeroVec(n: int) : vec() {}
    }
    computation{
        // Explicit Euler integration:
        //   x_{k+1} = x_k + dt * xdot_k
        «outName» = «outName» + dt * «derivativeName»;
    }
}'''
        }

    }
}
