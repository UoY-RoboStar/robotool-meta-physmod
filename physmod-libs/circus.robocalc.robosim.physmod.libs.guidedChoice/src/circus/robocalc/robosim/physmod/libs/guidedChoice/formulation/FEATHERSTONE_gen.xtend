package circus.robocalc.robosim.physmod.libs.guidedChoice.formulation

import org.eclipse.emf.common.util.EList
import org.eclipse.emf.common.util.BasicEList
import java.util.regex.Pattern
import circus.robocalc.robosim.physmod.libs.guidedChoice.solutionLib.SolutionRef
import circus.robocalc.robosim.physmod.libs.guidedChoice.solutionLib.Local

class FEATHERSTONE_gen {

    static class GeneralisedPosition_method1 {
        static def EList<SolutionRef> asReference(SolutionRef solution) {
            val dof = requireQDof(solution)
            val n = requireBodyCount(solution, dof)

            val dtVal = tryGetInitialValue("dt", solution)
            val gravityVal = tryGetInitialValue("gravity", solution)

            val q = solution.expression
            val d_q = createLocal("d_" + q.name, "vector(real," + dof + ")")
            val dd_q = createLocal("dd_" + q.name, "vector(real," + dof + ")")

            val tau = createLocal("tau", "vector(real," + dof + ")")
            val damping = createLocal("damping", "matrix(real," + dof + "," + dof + ")")

            val XT = createLocal("XT", "seq(matrix(real,6,6))")
            val I = createLocal("I", "seq(matrix(real,6,6))")
            val jtype = createLocal("jtype", "seq(int)")

            val C = createLocal("C", "vector(real," + dof + ")")
            val H = createLocal("H", "matrix(real," + dof + "," + dof + ")")
            val H_inv = createLocal("H_inv", "matrix(real," + dof + "," + dof + ")")

            val baseConstraints = new BasicEList<String>()
            baseConstraints.add("(n)[t==0]==" + n)
            baseConstraints.add("(N)[t==0]==" + dof)
            if (dtVal !== null) {
                baseConstraints.add("(dt)[t==0]==" + dtVal)
            }
            if (gravityVal !== null) {
                baseConstraints.add("(gravity)[t==0]==" + gravityVal)
            }

            val bias = new SolutionRef()
            bias.expression = C
            bias.method = "RNEABias"
            bias.inputs = new BasicEList<Local>()
            bias.inputs.add(copyLocal(q))
            bias.inputs.add(d_q)
            bias.inputs.add(XT)
            bias.inputs.add(I)
            bias.inputs.add(jtype)
            bias.constraints = new BasicEList<String>()
            bias.constraints.addAll(baseConstraints)
            bias.group = solution.group
            bias.order = 1
            bias.iterations = 1

            val crba = new SolutionRef()
            crba.expression = H
            crba.method = "CRBA"
            crba.inputs = new BasicEList<Local>()
            crba.inputs.add(copyLocal(q))
            crba.inputs.add(XT)
            crba.inputs.add(I)
            crba.inputs.add(jtype)
            crba.constraints = new BasicEList<String>()
            crba.constraints.addAll(baseConstraints)
            crba.group = solution.group
            crba.order = 2
            crba.iterations = 1

            val ldlt = new SolutionRef()
            ldlt.expression = H_inv
            ldlt.method = "LDLTAlgorithm"
            ldlt.inputs = new BasicEList<Local>()
            ldlt.inputs.add(H)
            ldlt.constraints = new BasicEList<String>()
            ldlt.constraints.addAll(baseConstraints)
            ldlt.group = solution.group
            ldlt.order = 3
            ldlt.iterations = 1

            val fd = new SolutionRef()
            fd.expression = dd_q
            fd.method = "ForwardDynamics"
            fd.inputs = new BasicEList<Local>()
            fd.inputs.add(tau)
            fd.inputs.add(C)
            fd.inputs.add(damping)
            fd.inputs.add(d_q)
            fd.inputs.add(H_inv)
            fd.constraints = new BasicEList<String>()
            fd.constraints.addAll(baseConstraints)
            fd.group = solution.group
            fd.order = 4
            fd.iterations = 1

            val dQSolution = new SolutionRef()
            dQSolution.expression = d_q
            dQSolution.method = "Euler"
            dQSolution.inputs = new BasicEList<Local>()
            dQSolution.inputs.add(dd_q)
            dQSolution.constraints = new BasicEList<String>()
            dQSolution.constraints.addAll(baseConstraints)
            val dQInit = getConstraintForVariable(solution, d_q.name)
            if (dQInit !== null) {
                dQSolution.constraints.add(dQInit)
            }
            dQSolution.group = solution.group
            dQSolution.order = 5
            dQSolution.iterations = 1

            val qSolution = new SolutionRef()
            qSolution.expression = copyLocal(q)
            qSolution.method = "Euler"
            qSolution.inputs = new BasicEList<Local>()
            qSolution.inputs.add(d_q)
            qSolution.constraints = new BasicEList<String>()
            qSolution.constraints.addAll(baseConstraints)
            val qInit = getConstraintForVariable(solution, q.name)
            if (qInit !== null) {
                qSolution.constraints.add(qInit)
            }
            qSolution.group = solution.group
            qSolution.order = 6
            qSolution.iterations = 1

            val results = new BasicEList<SolutionRef>()
            results.add(bias)
            results.add(crba)
            results.add(ldlt)
            results.add(fd)
            results.add(dQSolution)
            results.add(qSolution)
            return results
        }
    }

    static class GeneralisedPosition_method2 {
        static def EList<SolutionRef> asReference(SolutionRef solution) {
            val dof = requireQDof(solution)
            val n = requireBodyCount(solution, dof)

            val dtVal = tryGetInitialValue("dt", solution)
            val gravityVal = tryGetInitialValue("gravity", solution)

            val q = solution.expression
            val d_q = createLocal("d_" + q.name, "vector(real," + dof + ")")
            val dd_q = createLocal("dd_" + q.name, "vector(real," + dof + ")")

            val tau = createLocal("tau", "vector(real," + dof + ")")
            val damping = createLocal("damping", "matrix(real," + dof + "," + dof + ")")

            val XT = createLocal("XT", "seq(matrix(real,6,6))")
            val I = createLocal("I", "seq(matrix(real,6,6))")
            val jtype = createLocal("jtype", "seq(int)")

            val baseConstraints = new BasicEList<String>()
            baseConstraints.add("(n)[t==0]==" + n)
            baseConstraints.add("(N)[t==0]==" + dof)
            if (dtVal !== null) {
                baseConstraints.add("(dt)[t==0]==" + dtVal)
            }
            if (gravityVal !== null) {
                baseConstraints.add("(gravity)[t==0]==" + gravityVal)
            }

            val aba = new SolutionRef()
            aba.expression = dd_q
            aba.method = "ABAForwardDynamics"
            aba.inputs = new BasicEList<Local>()
            aba.inputs.add(copyLocal(q))
            aba.inputs.add(d_q)
            aba.inputs.add(tau)
            aba.inputs.add(damping)
            aba.inputs.add(XT)
            aba.inputs.add(I)
            aba.inputs.add(jtype)
            aba.constraints = new BasicEList<String>()
            aba.constraints.addAll(baseConstraints)
            aba.group = solution.group
            aba.order = 1
            aba.iterations = 1

            val dQSolution = new SolutionRef()
            dQSolution.expression = d_q
            dQSolution.method = "Euler"
            dQSolution.inputs = new BasicEList<Local>()
            dQSolution.inputs.add(dd_q)
            dQSolution.constraints = new BasicEList<String>()
            dQSolution.constraints.addAll(baseConstraints)
            val dQInit = getConstraintForVariable(solution, d_q.name)
            if (dQInit !== null) {
                dQSolution.constraints.add(dQInit)
            }
            dQSolution.group = solution.group
            dQSolution.order = 2
            dQSolution.iterations = 1

            val qSolution = new SolutionRef()
            qSolution.expression = copyLocal(q)
            qSolution.method = "Euler"
            qSolution.inputs = new BasicEList<Local>()
            qSolution.inputs.add(d_q)
            qSolution.constraints = new BasicEList<String>()
            qSolution.constraints.addAll(baseConstraints)
            val qInit = getConstraintForVariable(solution, q.name)
            if (qInit !== null) {
                qSolution.constraints.add(qInit)
            }
            qSolution.group = solution.group
            qSolution.order = 3
            qSolution.iterations = 1

            val results = new BasicEList<SolutionRef>()
            results.add(aba)
            results.add(dQSolution)
            results.add(qSolution)
            return results
        }
    }

    private static def int requireQDof(SolutionRef solution) {
        if (solution === null || solution.expression === null || solution.expression.type === null) {
            throw new IllegalStateException("Generalised position expression type is missing; expected vector(real,N).")
        }
        val dof = LibUtils.getVectorSize(solution.expression.type)
        if (dof <= 0) {
            throw new IllegalStateException("Invalid generalised position vector size: " + solution.expression.type)
        }
        return dof
    }

    private static def int requireBodyCount(SolutionRef solution, int dof) {
        val nStr = tryGetInitialValue("n", solution)
        return if (nStr !== null) Integer.parseInt(nStr) else dof + 1
    }

    private static def String tryGetInitialValue(String name, SolutionRef solution) {
        try {
            return LibUtils.getInitalValue(name, solution)
        } catch (Exception e) {
            return null
        }
    }

    private static def String getConstraintForVariable(SolutionRef solution, String varName) {
        if (solution.constraints === null) return null
        val pat = Pattern.compile("\\(\\s*" + Pattern.quote(varName) + "\\s*\\)\\s*\\[\\s*t\\s*==\\s*0\\s*\\]\\s*==.*")
        for (c : solution.constraints) {
            if (pat.matcher(c).matches) {
                return c
            }
        }
        return null
    }

    private static def Local createLocal(String name, String type) {
        val local = new Local()
        local.name = name
        local.type = type
        return local
    }

    private static def Local copyLocal(Local source) {
        val local = new Local()
        local.name = source.name
        local.type = source.type
        return local
    }
}
