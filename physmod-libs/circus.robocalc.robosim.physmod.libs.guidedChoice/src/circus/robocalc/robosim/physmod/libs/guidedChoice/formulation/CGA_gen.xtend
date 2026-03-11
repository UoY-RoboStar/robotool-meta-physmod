package circus.robocalc.robosim.physmod.libs.guidedChoice.formulation

import org.eclipse.emf.common.util.EList
import org.eclipse.emf.common.util.BasicEList
import java.util.regex.Pattern
import circus.robocalc.robosim.physmod.libs.guidedChoice.solutionLib.SolutionRef
import circus.robocalc.robosim.physmod.libs.guidedChoice.solutionLib.Local


 // CGA guided-choice library

 
class CGA_gen {

    static class GeneralisedPosition_method1 {
        static def EList<SolutionRef> asReference(SolutionRef solution) {
            val dof = requireThetaDof(solution)
            val n = requireBodyCount(solution, dof)
            val dtVal = tryGetInitialValue("dt", solution)

            val theta = solution.expression
            val d_theta = createLocal("d_theta", "vector(real," + dof + ")")
            val dd_theta = createLocal("dd_theta", "vector(real," + dof + ")")

            val motor_k = createLocal("motor_k", "seq(vector(real,8))")
            val motor_T = createLocal("motor_T", "seq(vector(real,8))")
            val B_k = createLocal("B_k", "seq(matrix(real,4,4))")

            val axis_rot = createLocal("axis_rot", "seq(vector(real,3))")
            val axis_lin = createLocal("axis_lin", "seq(vector(real,3))")
            val joint_type = createLocal("joint_type", "seq(int)")

            val mass_k = createLocal("mass_k", "seq(real)")
            val com_k = createLocal("com_k", "seq(vector(real,3))")
            val inertia_k = createLocal("inertia_k", "seq(matrix(real,3,3))")

            val tau = createLocal("tau", "vector(real," + dof + ")")
            val damping = createLocal("damping", "matrix(real," + dof + "," + dof + ")")
            val gravity = createLocal("gravity", "real")

            val baseConstraints = new BasicEList<String>()
            baseConstraints.add("(n)[t==0]==" + n)
            baseConstraints.add("(N)[t==0]==" + dof)
            if (dtVal !== null) {
                baseConstraints.add("(dt)[t==0]==" + dtVal)
            }

            val fk = new SolutionRef()
            fk.expression = motor_k
            fk.method = "ForwardKinematics"
            fk.inputs = new BasicEList<Local>()
            fk.inputs.add(copyLocal(theta))
            fk.inputs.add(motor_T)
            fk.inputs.add(axis_rot)
            fk.inputs.add(axis_lin)
            fk.inputs.add(joint_type)
            fk.constraints = new BasicEList<String>()
            fk.constraints.addAll(baseConstraints)
            fk.group = solution.group
            fk.order = 1
            fk.iterations = 1

            val aba = new SolutionRef()
            aba.expression = dd_theta
            aba.method = "ABAForwardDynamics"
            aba.inputs = new BasicEList<Local>()
            aba.inputs.add(copyLocal(theta))
            aba.inputs.add(d_theta)
            aba.inputs.add(tau)
            aba.inputs.add(damping)
            aba.inputs.add(gravity)
            aba.inputs.add(B_k)
            aba.inputs.add(axis_rot)
            aba.inputs.add(axis_lin)
            aba.inputs.add(joint_type)
            aba.inputs.add(mass_k)
            aba.inputs.add(com_k)
            aba.inputs.add(inertia_k)
            aba.constraints = new BasicEList<String>()
            aba.constraints.addAll(baseConstraints)
            aba.group = solution.group
            aba.order = 2
            aba.iterations = 1

            val dThetaSolution = new SolutionRef()
            dThetaSolution.expression = d_theta
            dThetaSolution.method = "Euler"
            dThetaSolution.inputs = new BasicEList<Local>()
            dThetaSolution.inputs.add(dd_theta)
            dThetaSolution.constraints = new BasicEList<String>()
            dThetaSolution.constraints.addAll(baseConstraints)
            val dThetaInit = getConstraintForVariable(solution, d_theta.name)
            if (dThetaInit !== null) {
                dThetaSolution.constraints.add(dThetaInit)
            }
            dThetaSolution.group = solution.group
            dThetaSolution.order = 3
            dThetaSolution.iterations = 1

            val thetaSolution = new SolutionRef()
            thetaSolution.expression = copyLocal(theta)
            thetaSolution.method = "Euler"
            thetaSolution.inputs = new BasicEList<Local>()
            thetaSolution.inputs.add(d_theta)
            thetaSolution.constraints = new BasicEList<String>()
            thetaSolution.constraints.addAll(baseConstraints)
            val thetaInit = getConstraintForVariable(solution, theta.name)
            if (thetaInit !== null) {
                thetaSolution.constraints.add(thetaInit)
            }
            thetaSolution.group = solution.group
            thetaSolution.order = 4
            thetaSolution.iterations = 1

            val results = new BasicEList<SolutionRef>()
            results.add(fk)
            results.add(aba)
            results.add(dThetaSolution)
            results.add(thetaSolution)
            return results
        }
    }

    static class ForwardKinematics {
        static def SolutionRef asReference(SolutionRef solution) {
            solution.method = "ForwardKinematics"
            return solution
        }
    }

    static class InverseDynamicsRNEA {
        static def SolutionRef asReference(SolutionRef solution) {
            solution.method = "InverseDynamicsRNEA"
            return solution
        }
    }

    static class ABAForwardDynamics {
        static def SolutionRef asReference(SolutionRef solution) {
            solution.method = "ABAForwardDynamics"
            return solution
        }
    }

    static class Euler {
        static def SolutionRef asReference(SolutionRef solution) {
            solution.method = "Euler"
            return solution
        }
    }

    private static def int requireThetaDof(SolutionRef solution) {
        if (solution === null || solution.expression === null || solution.expression.type === null) {
            throw new IllegalStateException("Theta expression type is missing; expected vector(real,N).")
        }
        val dof = LibUtils.getVectorSize(solution.expression.type)
        if (dof <= 0) {
            throw new IllegalStateException("Invalid theta vector size: " + solution.expression.type)
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
