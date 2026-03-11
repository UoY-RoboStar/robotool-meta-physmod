package circus.robocalc.robosim.physmod.libs.guidedChoice.formulation

import org.eclipse.emf.common.util.EList
import org.eclipse.emf.common.util.BasicEList
import java.util.regex.Pattern
import java.io.StringReader
import java.util.ArrayList
import javax.script.ScriptEngineManager
import java.util.List
import circus.robocalc.robosim.physmod.libs.guidedChoice.solutionLib.SolutionRef
import circus.robocalc.robosim.physmod.libs.guidedChoice.solutionLib.Local
import circus.robocalc.robosim.physmod.slnRef.slnRef.SlnRef
import circus.robocalc.robosim.physmod.slnDF.slnDF.SlnDFFactory

// This class contains methods associated with the SKO formulation
class SKO_gen{
	static boolean DEBUG_SOLUTION_LOGGING = Boolean.getBoolean("physmod.debug.solutionLogging")
	//@params takes in constraint and returns a list of solutions
	static def int requireThetaDof(SolutionRef solution) {
		if (solution === null || solution.expression === null || solution.expression.type === null) {
			throw new IllegalStateException("Theta expression type is missing; expected vector(real,N).")
		}
		val dof = getVectorSize(solution.expression.type)
		if (dof <= 0) {
			throw new IllegalStateException("Invalid theta vector size: " + solution.expression.type)
		}
		return dof
	}

	static def int requireBodyCount(SolutionRef solution) {
		val nStr = getInitalValue("n", solution)
		if (nStr === null) {
			throw new IllegalStateException("Missing initial condition for n in solution constraints.")
		}
		return Integer.parseInt(nStr)
	}

	static def void ensureNConstraint(SolutionRef solution, int n) {
		if (solution.constraints === null) {
			solution.constraints = new BasicEList<String>
		}
		val constraint = "(n)[t == 0] == " + n
		if (solution.constraints.findFirst[c | c.replaceAll("\\s+", "") == constraint.replaceAll("\\s+", "")] === null) {
			solution.constraints.add(constraint)
		}
	}
	static class GeneralisedPosition_method1{
		static def EList<SolutionRef> asReference(SolutionRef solution){
		 // 1) TODO Check that solution valid iff constraints provided are given
 		var factory = SlnDFFactory.eINSTANCE;
		val dof = requireThetaDof(solution)
		val n = requireBodyCount(solution)

		 // 2) Return the solution
		 // Note: tau is expected to be provided by user as an INPUT to this method
		 // (e.g., via Mapping::PlatformMapping or Actuator::ControlledActuator)

		 var solution_phi = new SolutionRef()
		 solution_phi.expression = new Local()
		 solution_phi.expression.name = "phi"
		 solution_phi.expression.type = "matrix(real," + 6 * n + "," + 6 * n + ")"
		 ensureNConstraint(solution_phi, n)
		 solution_phi = Eval.asReference(solution_phi);
		 solution_phi.group = solution.group
		 solution_phi.order = 2
		 solution_phi.iterations = 1

		 var solution_C = new SolutionRef()
		 solution_C.expression = new Local()
		 solution_C.expression.name = "C"
		 solution_C.expression.type = "vector(real," + dof + ")"
		 ensureNConstraint(solution_C, n)
		 solution_C = NewtonEulerInverseDynamics.asReference(solution_C);
		 solution_C.group = solution.group
		 solution_C.order = 3
		 solution_C.iterations = 1

		 var solution_M = new SolutionRef()
		 solution_M.expression = new Local()
		 solution_M.expression.name = "M_mass"
		 solution_M.expression.type = "matrix(real," + dof + "," + dof + ")"
		 ensureNConstraint(solution_M, n)
		 solution_M = CompositeBodyAlgorithm.asReference(solution_M);
		 solution_M.group = solution.group
		 solution_M.order = 4
		 solution_M.iterations = 1

		 var solution_M_inv = new SolutionRef()
		 solution_M_inv.expression = new Local()
		 solution_M_inv.expression.name = "M_inv"
		 solution_M_inv.expression.type = "matrix(real," + dof + "," + dof + ")"
		 ensureNConstraint(solution_M_inv, n)
		 solution_M_inv = CholeskyAlgorithm.asReference(solution_M_inv);
		 solution_M.group = solution.group
		 solution_M_inv.order = 5
		 solution_M_inv.iterations = 1

		 var solution_theta_dd = new SolutionRef()
		 solution_theta_dd.expression = new Local()
		 solution_theta_dd.expression.name = "dd_theta"
		 solution_theta_dd.expression.type = "vector(real," + dof + ")"
		 ensureNConstraint(solution_theta_dd, n)
		 solution_theta_dd = DirectForwardDynamics.asReference(solution_theta_dd);
		 solution_theta_dd.group = solution.group
		 solution_theta_dd.order = 6
		 solution_theta_dd.iterations = 1

		 var solution_theta_d = new SolutionRef()
		 solution_theta_d.expression = new Local()
		 solution_theta_d.expression.name = "d_theta"
		 solution_theta_d.expression.type = "vector(real," + dof + ")"
		 ensureNConstraint(solution_theta_d, n)
		 solution_theta_d = Euler.asReference(solution_theta_d);
		 solution_theta_d.group = solution.group
		 solution_theta_d.order = 7
		 solution_theta_d.iterations = 1

		 var solution_theta = new SolutionRef()
		 solution_theta.expression = new Local()
		 solution_theta.expression.name = "theta"
		 solution_theta.expression.type = "vector(real," + dof + ")"
		 // Copy theta constraints from original solution (e.g., initial conditions from solution block)
		 if (DEBUG_SOLUTION_LOGGING) {
		 System.out.println("[SKO_gen] GeneralisedPosition_method1: original solution.constraints count = " + (if (solution.constraints !== null) solution.constraints.size else "null"))
		 }
		 if (solution.constraints !== null) {
		     for (c : solution.constraints) {
		         if (DEBUG_SOLUTION_LOGGING) {
		         System.out.println("[SKO_gen] Original constraint: " + c)
		         }
		     }
		     solution_theta.constraints = new BasicEList<String>
		     for (c : solution.constraints) {
		         if (c.contains("(theta)") && c.contains("t") && (c.contains("0") || c.contains("t"))) {
		             solution_theta.constraints.add(c)
		             if (DEBUG_SOLUTION_LOGGING) {
		             System.out.println("[SKO_gen] Copied theta constraint: " + c)
		             }
		         }
		     }
		 }
		 ensureNConstraint(solution_theta, n)
		 solution_theta = Euler.asReference(solution_theta);
		 solution_theta.group = solution.group
		 solution_theta.order = 8
		 solution_theta.iterations = 1

		// Combine solutions into an EList
		// Note: Bk is NOT added here - it's unfolded separately by the T4 generator
		// Note: tau is NOT added here - it's expected to be provided by user as an input
		var solutions = new BasicEList<SolutionRef>();
		solutions.add(solution_phi);
		solutions.add(solution_C);
		solutions.add(solution_M);
		solutions.add(solution_M_inv);
		solutions.add(solution_theta_dd);
		solutions.add(solution_theta_d);
		solutions.add(solution_theta);

    			return solutions;
		} 	
		
		static def EList<SolutionRef> computeError(SolutionRef solution){

		}
	}

	static class GeneralisedPosition_method1_closedChain{
		static def EList<SolutionRef> asReference(SolutionRef solution){
		 // Closed-chain analog of GeneralisedPosition_method1
 		var factory = SlnDFFactory.eINSTANCE;
		val dof = requireThetaDof(solution)
		val n = requireBodyCount(solution)

		// Try to infer nLoop from constraints: (nLoop)[t==0]==k  => nc = 6*k
		var nLoopValue = -1
		val nLoopPattern = Pattern.compile("\\(\\s*nLoop\\s*\\)\\s*\\[\\s*t\\s*==\\s*0\\s*\\]\\s*==\\s*(\\d+)")
		if (solution.constraints !== null) {
			for (constraint : solution.constraints) {
				val matcher = nLoopPattern.matcher((constraint as String).trim)
				if (matcher.find()) {
					nLoopValue = Integer.parseInt(matcher.group(1).trim)
				}
			}
		}
		val nc = if (nLoopValue > 0) 6 * nLoopValue else -1

		// Note: tau is expected to be provided by user as an INPUT to this method
		// (e.g., via Mapping::PlatformMapping or Actuator::ControlledActuator)

		var solution_phi = new SolutionRef()
		solution_phi.expression = new Local()
		solution_phi.expression.name = "phi"
		solution_phi.expression.type = "matrix(real," + 6 * n + "," + 6 * n + ")"
		ensureNConstraint(solution_phi, n)
		solution_phi = Eval.asReference(solution_phi);
		solution_phi.group = solution.group
		solution_phi.order = 2
		solution_phi.iterations = 1

		var solution_C = new SolutionRef()
		solution_C.expression = new Local()
		solution_C.expression.name = "C"
		solution_C.expression.type = "vector(real," + dof + ")"
		ensureNConstraint(solution_C, n)
		solution_C = NewtonEulerInverseDynamics.asReference(solution_C);
		solution_C.group = solution.group
		solution_C.order = 3
		solution_C.iterations = 1

		var solution_M = new SolutionRef()
		solution_M.expression = new Local()
		solution_M.expression.name = "M_mass"
		solution_M.expression.type = "matrix(real," + dof + "," + dof + ")"
		ensureNConstraint(solution_M, n)
		solution_M = CompositeBodyAlgorithm.asReference(solution_M);
		solution_M.group = solution.group
		solution_M.order = 4
		solution_M.iterations = 1

		var solution_M_inv = new SolutionRef()
		solution_M_inv.expression = new Local()
		solution_M_inv.expression.name = "M_inv"
		solution_M_inv.expression.type = "matrix(real," + dof + "," + dof + ")"
		ensureNConstraint(solution_M_inv, n)
		solution_M_inv = CholeskyAlgorithm.asReference(solution_M_inv);
		solution_M.group = solution.group
		solution_M_inv.order = 5
		solution_M_inv.iterations = 1

		var solution_G_c = new SolutionRef()
		solution_G_c.expression = new Local()
		solution_G_c.expression.name = "G_c"
		solution_G_c.expression.type = if (nc > 0) "matrix(real," + nc + "," + dof + ")" else "Null"
		ensureNConstraint(solution_G_c, n)
		solution_G_c = ConstraintJacobian.asReference(solution_G_c);
		solution_G_c.group = solution.group
		solution_G_c.order = 6
		solution_G_c.iterations = 1

		var solution_theta_dd = new SolutionRef()
		solution_theta_dd.expression = new Local()
		solution_theta_dd.expression.name = "dd_theta"
		solution_theta_dd.expression.type = "vector(real," + dof + ")"
		ensureNConstraint(solution_theta_dd, n)
		solution_theta_dd = ConstrainedForwardDynamics.asReference(solution_theta_dd);
		solution_theta_dd.group = solution.group
		solution_theta_dd.order = 7
		solution_theta_dd.iterations = 1

		var solution_theta_d = new SolutionRef()
		solution_theta_d.expression = new Local()
		solution_theta_d.expression.name = "d_theta"
		solution_theta_d.expression.type = "vector(real," + dof + ")"
		ensureNConstraint(solution_theta_d, n)
		solution_theta_d = Euler.asReference(solution_theta_d);
		solution_theta_d.group = solution.group
		solution_theta_d.order = 8
		solution_theta_d.iterations = 1

		var solution_theta = new SolutionRef()
		solution_theta.expression = new Local()
		solution_theta.expression.name = "theta"
		solution_theta.expression.type = "vector(real," + dof + ")"
		// Copy theta constraints from original solution (e.g., initial conditions from solution block)
		if (DEBUG_SOLUTION_LOGGING) {
		System.out.println("[SKO_gen] GeneralisedPosition_method1_closedChain: original solution.constraints count = " + (if (solution.constraints !== null) solution.constraints.size else "null"))
		}
		if (solution.constraints !== null) {
		    for (c : solution.constraints) {
		        if (DEBUG_SOLUTION_LOGGING) {
		        System.out.println("[SKO_gen] Original constraint: " + c)
		        }
		    }
		    solution_theta.constraints = new BasicEList<String>
		    for (c : solution.constraints) {
		        if (c.contains("(theta)") && c.contains("t") && (c.contains("0") || c.contains("t"))) {
		            solution_theta.constraints.add(c)
		            if (DEBUG_SOLUTION_LOGGING) {
		            System.out.println("[SKO_gen] Copied theta constraint: " + c)
		            }
		        }
		    }
		}
		ensureNConstraint(solution_theta, n)
		solution_theta = Euler.asReference(solution_theta);
		solution_theta.group = solution.group
		solution_theta.order = 9
		solution_theta.iterations = 1

		// 9b) g_pos (loop position residuals) - order 10
		var solution_g_pos = new SolutionRef()
		solution_g_pos.expression = new Local()
		solution_g_pos.expression.name = "g_pos"
		solution_g_pos.expression.type = if (nLoopValue > 0) "vector(real," + (3 * nLoopValue) + ")" else "Null"
		if (solution.constraints !== null) {
			solution_g_pos.constraints = new BasicEList<String>
			for (c : solution.constraints) {
				if (c.contains("B_sel") || c.contains("Q_c") || c.contains("(nLoop)")) {
					solution_g_pos.constraints.add(c)
				}
			}
		}
		ensureNConstraint(solution_g_pos, n)
		solution_g_pos = SKO_closed_gen.LoopPositionResidualsClosedChain.asReference(solution_g_pos)
		solution_g_pos.group = solution.group
		solution_g_pos.order = 10
		solution_g_pos.iterations = 1

		var solution_theta_proj = new SolutionRef()
		solution_theta_proj.expression = new Local()
		solution_theta_proj.expression.name = "theta"
		solution_theta_proj.expression.type = "vector(real," + dof + ")"
		// Carry forward X_J/X_T constraints so projection can recompute kinematics if needed.
		if (solution.constraints !== null) {
			solution_theta_proj.constraints = new BasicEList<String>
			for (c : solution.constraints) {
				if (c.contains("X_J") || c.contains("X_T") || c.contains("(n)")) {
					solution_theta_proj.constraints.add(c)
				}
			}
		}
		ensureNConstraint(solution_theta_proj, n)
		solution_theta_proj = SKO_closed_gen.ConstraintProjectionClosedChain.asReference(solution_theta_proj)
		solution_theta_proj.group = solution.group
		solution_theta_proj.order = 11
		solution_theta_proj.iterations = 1

		// Combine solutions into an EList
		var solutions = new BasicEList<SolutionRef>();
		solutions.add(solution_phi);
		solutions.add(solution_C);
		solutions.add(solution_M);
		solutions.add(solution_M_inv);
		solutions.add(solution_G_c);
		solutions.add(solution_theta_dd);
		solutions.add(solution_theta_d);
		solutions.add(solution_theta);
		solutions.add(solution_g_pos);
		solutions.add(solution_theta_proj);

    			return solutions;
		}

		static def EList<SolutionRef> computeError(SolutionRef solution){

		}
	}

	static class GeneralisedPosition_method1_closedChain_gravity_damping{
		static def EList<SolutionRef> asReference(SolutionRef solution){
		 // Closed-chain analog of GeneralisedPosition_method1_gravity_damping
		 var factory = SlnDFFactory.eINSTANCE;
		val dof = requireThetaDof(solution)
		val n = requireBodyCount(solution)

		// Try to infer nLoop from constraints: (nLoop)[t==0]==k  => nc = 6*k
		var nLoopValue = -1
		val nLoopPattern = Pattern.compile("\\(\\s*nLoop\\s*\\)\\s*\\[\\s*t\\s*==\\s*0\\s*\\]\\s*==\\s*(\\d+)")
		if (solution.constraints !== null) {
			for (constraint : solution.constraints) {
				val matcher = nLoopPattern.matcher((constraint as String).trim)
				if (matcher.find()) {
					nLoopValue = Integer.parseInt(matcher.group(1).trim)
				}
			}
		}
		val nc = if (nLoopValue > 0) 6 * nLoopValue else -1

		// Note: tau is expected to be provided by user as an INPUT to this method
		// (e.g., via Mapping::PlatformMapping or Actuator::ControlledActuator)

		// 1) phi (Eval) - order 2
		var solution_phi = new SolutionRef()
		solution_phi.expression = new Local()
		solution_phi.expression.name = "phi"
		solution_phi.expression.type = "matrix(real," + 6 * n + "," + 6 * n + ")"
		ensureNConstraint(solution_phi, n)
		solution_phi = Eval.asReference(solution_phi);
		solution_phi.group = solution.group
		solution_phi.order = 2
		solution_phi.iterations = 1

		// 2) C (NewtonEulerInverseDynamics_gravity) - order 3
		var solution_C = new SolutionRef()
		solution_C.expression = new Local()
		solution_C.expression.name = "C"
		solution_C.expression.type = "vector(real," + dof + ")"
		ensureNConstraint(solution_C, n)
		solution_C = NewtonEulerInverseDynamics_gravity.asReference(solution_C);
		solution_C.group = solution.group
		solution_C.order = 3
		solution_C.iterations = 1

		// 3) M_mass (CompositeBodyAlgorithm) - order 4
		var solution_M = new SolutionRef()
		solution_M.expression = new Local()
		solution_M.expression.name = "M_mass"
		solution_M.expression.type = "matrix(real," + dof + "," + dof + ")"
		ensureNConstraint(solution_M, n)
		solution_M = CompositeBodyAlgorithm.asReference(solution_M);
		solution_M.group = solution.group
		solution_M.order = 4
		solution_M.iterations = 1

		// 4) M_inv (CholeskyAlgorithm) - order 5
		var solution_M_inv = new SolutionRef()
		solution_M_inv.expression = new Local()
		solution_M_inv.expression.name = "M_inv"
		solution_M_inv.expression.type = "matrix(real," + dof + "," + dof + ")"
		ensureNConstraint(solution_M_inv, n)
		solution_M_inv = CholeskyAlgorithm.asReference(solution_M_inv);
		solution_M_inv.group = solution.group
		solution_M_inv.order = 5
		solution_M_inv.iterations = 1

		// 5) tau_d (ViscousDamping) - order 6
		var solution_tau_d = new SolutionRef()
		solution_tau_d.expression = new Local()
		solution_tau_d.expression.name = "tau_d"
		solution_tau_d.expression.type = "vector(real," + dof + ")"
		ensureNConstraint(solution_tau_d, n)
		solution_tau_d = ViscousDamping.asReference(solution_tau_d);
		solution_tau_d.group = solution.group
		solution_tau_d.order = 6
		solution_tau_d.iterations = 1

		// 6) G_c (ConstraintJacobian) - order 7
		var solution_G_c = new SolutionRef()
		solution_G_c.expression = new Local()
		solution_G_c.expression.name = "G_c"
		solution_G_c.expression.type = if (nc > 0) "matrix(real," + nc + "," + dof + ")" else "Null"
		ensureNConstraint(solution_G_c, n)
		solution_G_c = ConstraintJacobian.asReference(solution_G_c);
		solution_G_c.group = solution.group
		solution_G_c.order = 7
		solution_G_c.iterations = 1

		// 7) dd_theta (ConstrainedForwardDynamics) - order 8
		var solution_theta_dd = new SolutionRef()
		solution_theta_dd.expression = new Local()
		solution_theta_dd.expression.name = "dd_theta"
		solution_theta_dd.expression.type = "vector(real," + dof + ")"
		ensureNConstraint(solution_theta_dd, n)
		solution_theta_dd = ConstrainedForwardDynamics.asReference(solution_theta_dd);
		solution_theta_dd.group = solution.group
		solution_theta_dd.order = 8
		solution_theta_dd.iterations = 1

		// 8) d_theta (Euler) - order 9
		var solution_theta_d = new SolutionRef()
		solution_theta_d.expression = new Local()
		solution_theta_d.expression.name = "d_theta"
		solution_theta_d.expression.type = "vector(real," + dof + ")"
		ensureNConstraint(solution_theta_d, n)
		// Copy d_theta and dt constraints from original solution before Euler.asReference adds defaults
		if (solution.constraints !== null) {
			solution_theta_d.constraints = new BasicEList<String>
			for (c : solution.constraints) {
				if (c.contains("(d_theta)") || c.contains("(dt)") || c.contains("(dd_theta)")) {
					solution_theta_d.constraints.add(c)
				}
			}
		}
		solution_theta_d = Euler.asReference(solution_theta_d);
		solution_theta_d.group = solution.group
		solution_theta_d.order = 9
		solution_theta_d.iterations = 1

		// 9) theta (Euler) - order 10
		var solution_theta = new SolutionRef()
		solution_theta.expression = new Local()
		solution_theta.expression.name = "theta"
		solution_theta.expression.type = "vector(real," + dof + ")"
		// Copy theta and dt constraints from original solution before Euler.asReference adds defaults
		if (solution.constraints !== null) {
			if (DEBUG_SOLUTION_LOGGING) {
			System.out.println("[SKO_gen DEBUG] Original solution has " + solution.constraints.size + " constraints:")
			}
			for (c : solution.constraints) {
				if (DEBUG_SOLUTION_LOGGING) {
				System.out.println("[SKO_gen DEBUG]   '" + c + "'")
				}
			}
			solution_theta.constraints = new BasicEList<String>
			for (c : solution.constraints) {
				if (c.contains("(theta)") || c.contains("(dt)") || c.contains("(d_theta)")) {
					if (DEBUG_SOLUTION_LOGGING) {
					System.out.println("[SKO_gen DEBUG] Copying constraint: '" + c + "'")
					}
					solution_theta.constraints.add(c)
			}
			}
			if (DEBUG_SOLUTION_LOGGING) {
			System.out.println("[SKO_gen DEBUG] Copied " + solution_theta.constraints.size + " constraints to solution_theta")
			}
		}
		ensureNConstraint(solution_theta, n)
		solution_theta = Euler.asReference(solution_theta);
		solution_theta.group = solution.group
		solution_theta.order = 10
		solution_theta.iterations = 1

		// 9b) g_pos (loop position residuals) - order 11
		var solution_g_pos = new SolutionRef()
		solution_g_pos.expression = new Local()
		solution_g_pos.expression.name = "g_pos"
		solution_g_pos.expression.type = if (nLoopValue > 0) "vector(real," + (3 * nLoopValue) + ")" else "Null"
		if (solution.constraints !== null) {
			solution_g_pos.constraints = new BasicEList<String>
			for (c : solution.constraints) {
				if (c.contains("B_sel") || c.contains("Q_c") || c.contains("(nLoop)")) {
					solution_g_pos.constraints.add(c)
				}
			}
		}
		ensureNConstraint(solution_g_pos, n)
		solution_g_pos = SKO_closed_gen.LoopPositionResidualsClosedChain.asReference(solution_g_pos)
		solution_g_pos.group = solution.group
		solution_g_pos.order = 11
		solution_g_pos.iterations = 1

		// 10) theta projection (ConstraintProjection) - order 12
		var solution_theta_proj = new SolutionRef()
		solution_theta_proj.expression = new Local()
		solution_theta_proj.expression.name = "theta"
		solution_theta_proj.expression.type = "vector(real," + dof + ")"
		// Carry forward X_J/X_T constraints so projection can recompute kinematics if needed.
		if (solution.constraints !== null) {
			solution_theta_proj.constraints = new BasicEList<String>
			for (c : solution.constraints) {
				if (c.contains("X_J") || c.contains("X_T") || c.contains("(n)")) {
					solution_theta_proj.constraints.add(c)
				}
			}
		}
		ensureNConstraint(solution_theta_proj, n)
		solution_theta_proj = SKO_closed_gen.ConstraintProjectionClosedChain.asReference(solution_theta_proj)
		solution_theta_proj.group = solution.group
		solution_theta_proj.order = 12
		solution_theta_proj.iterations = 1

		// Combine solutions into an EList
		var solutions = new BasicEList<SolutionRef>();
		solutions.add(solution_phi);
		solutions.add(solution_C);
		solutions.add(solution_M);
		solutions.add(solution_M_inv);
		solutions.add(solution_tau_d);
		solutions.add(solution_G_c);
		solutions.add(solution_theta_dd);
		solutions.add(solution_theta_d);
		solutions.add(solution_theta);
		solutions.add(solution_g_pos);
		solutions.add(solution_theta_proj);

    			return solutions;
		}

		static def EList<SolutionRef> computeError(SolutionRef solution){

		}
	}

	static class GeneralisedPosition_method1_gravity_damping{
		static def EList<SolutionRef> asReference(SolutionRef solution){
		 // Similar to GeneralisedPosition_method1 but with gravity and damping
		 var factory = SlnDFFactory.eINSTANCE;
		 val dof = requireThetaDof(solution)
		 val n = requireBodyCount(solution)

		 // Note: tau is expected to be provided by user as an INPUT to this method
		 // (e.g., via Mapping::PlatformMapping or Actuator::ControlledActuator)

		 // 1) phi (Eval) - order 2
		 var solution_phi = new SolutionRef()
		 solution_phi.expression = new Local()
		 solution_phi.expression.name = "phi"
		 solution_phi.expression.type = "matrix(real," + 6 * n + "," + 6 * n + ")"
		 ensureNConstraint(solution_phi, n)
		 solution_phi = Eval.asReference(solution_phi);
		 solution_phi.group = solution.group
		 solution_phi.order = 2
		 solution_phi.iterations = 1

		 // 3) C (NewtonEulerInverseDynamics_gravity) - order 3
		 var solution_C = new SolutionRef()
		 solution_C.expression = new Local()
		 solution_C.expression.name = "C"
		 solution_C.expression.type = "vector(real," + dof + ")"
		 ensureNConstraint(solution_C, n)
		 solution_C = NewtonEulerInverseDynamics_gravity.asReference(solution_C);
		 solution_C.group = solution.group
		 solution_C.order = 3
		 solution_C.iterations = 1

		 // 4) M_mass (CompositeBodyAlgorithm) - order 4
		 var solution_M = new SolutionRef()
		 solution_M.expression = new Local()
		 solution_M.expression.name = "M_mass"
		 solution_M.expression.type = "matrix(real," + dof + "," + dof + ")"
		 ensureNConstraint(solution_M, n)
		 solution_M = CompositeBodyAlgorithm.asReference(solution_M);
		 solution_M.group = solution.group
		 solution_M.order = 4
		 solution_M.iterations = 1

		 // 5) M_inv (CholeskyAlgorithm) - order 5
		 var solution_M_inv = new SolutionRef()
		 solution_M_inv.expression = new Local()
		 solution_M_inv.expression.name = "M_inv"
		 solution_M_inv.expression.type = "matrix(real," + dof + "," + dof + ")"
		 ensureNConstraint(solution_M_inv, n)
		 solution_M_inv = CholeskyAlgorithm.asReference(solution_M_inv);
		 solution_M_inv.group = solution.group
		 solution_M_inv.order = 5
		 solution_M_inv.iterations = 1

		 // 6) tau_d (ViscousDamping) - order 6
		 var solution_tau_d = new SolutionRef()
		 solution_tau_d.expression = new Local()
		 solution_tau_d.expression.name = "tau_d"
		 solution_tau_d.expression.type = "vector(real," + dof + ")"
		 ensureNConstraint(solution_tau_d, n)
		 solution_tau_d = ViscousDamping.asReference(solution_tau_d);
		 solution_tau_d.group = solution.group
		 solution_tau_d.order = 6
		 solution_tau_d.iterations = 1

		 // 7) dd_theta (DirectForwardDynamics) - order 7
		 var solution_theta_dd = new SolutionRef()
		 solution_theta_dd.expression = new Local()
		 solution_theta_dd.expression.name = "dd_theta"
		 solution_theta_dd.expression.type = "vector(real," + dof + ")"
		 ensureNConstraint(solution_theta_dd, n)
		 solution_theta_dd = DirectForwardDynamics.asReference(solution_theta_dd);
		 solution_theta_dd.group = solution.group
		 solution_theta_dd.order = 7
		 solution_theta_dd.iterations = 1

		 // 8) d_theta (Euler) - order 8
		 var solution_theta_d = new SolutionRef()
		 solution_theta_d.expression = new Local()
		 solution_theta_d.expression.name = "d_theta"
		 solution_theta_d.expression.type = "vector(real," + dof + ")"
		 ensureNConstraint(solution_theta_d, n)
		 // Copy d_theta and dt constraints from original solution before Euler.asReference adds defaults
		 if (solution.constraints !== null) {
		 	solution_theta_d.constraints = new BasicEList<String>
		 	for (c : solution.constraints) {
		 		if (c.contains("(d_theta)") || c.contains("(dt)") || c.contains("(dd_theta)")) {
		 			solution_theta_d.constraints.add(c)
		 		}
		 	}
		 }
		 solution_theta_d = Euler.asReference(solution_theta_d);
		 solution_theta_d.group = solution.group
		 solution_theta_d.order = 8
		 solution_theta_d.iterations = 1

		 // 9) theta (Euler) - order 9
		 var solution_theta = new SolutionRef()
		 solution_theta.expression = new Local()
		 solution_theta.expression.name = "theta"
		 solution_theta.expression.type = "vector(real," + dof + ")"
		 // Copy theta and dt constraints from original solution before Euler.asReference adds defaults
		 if (solution.constraints !== null) {
		 	if (DEBUG_SOLUTION_LOGGING) {
		 	System.out.println("[SKO_gen DEBUG] Original solution has " + solution.constraints.size + " constraints:")
		 	}
		 	for (c : solution.constraints) {
		 		if (DEBUG_SOLUTION_LOGGING) {
		 		System.out.println("[SKO_gen DEBUG]   '" + c + "'")
		 		}
		 	}
		 	solution_theta.constraints = new BasicEList<String>
		 	for (c : solution.constraints) {
		 		if (c.contains("(theta)") || c.contains("(dt)") || c.contains("(d_theta)")) {
		 			if (DEBUG_SOLUTION_LOGGING) {
		 			System.out.println("[SKO_gen DEBUG] Copying constraint: '" + c + "'")
		 			}
		 			solution_theta.constraints.add(c)
		 	}
		 	}
		 	if (DEBUG_SOLUTION_LOGGING) {
		 	System.out.println("[SKO_gen DEBUG] Copied " + solution_theta.constraints.size + " constraints to solution_theta")
		 	}
		 }
		 ensureNConstraint(solution_theta, n)
		 solution_theta = Euler.asReference(solution_theta);
		 solution_theta.group = solution.group
		 solution_theta.order = 9
		 solution_theta.iterations = 1

		// Combine solutions into an EList
		// Note: tau is NOT added here - it's expected to be provided by user as an input
		var solutions = new BasicEList<SolutionRef>();
		solutions.add(solution_phi);
		solutions.add(solution_C);
		solutions.add(solution_M);
		solutions.add(solution_M_inv);
		solutions.add(solution_tau_d);
		solutions.add(solution_theta_dd);
		solutions.add(solution_theta_d);
		solutions.add(solution_theta);

    			return solutions;
		}
	}

// NOTE: PlatformMapping and WorldMapping have been moved to Mapping_gen.xtend
// as they are formulation-agnostic interface mapping methods.

//static class PlatformMapping2 {
//    // Cache DSL resources.
//    private static val injector = new SlnDFStandaloneSetup().createInjectorAndDoEMFRegistration()
//    private static val parser = injector.getInstance(IParser)
//    private static val serializer = injector.getInstance(ISerializer)
//    
//   
//    
//    static def SolutionRef asReference(SolutionRef solution) {
//        // Set the method field.
//        solution.method = "PlatformMapping"
//        
//        // Check the solution expression (solutionExpr) for "tau".
//        switch solution.expression.name {
//            case "tau": {
//            	 // Parse the expected constraint once.
//			    val expectedConstraintString = "Constraint (tau)[t == 0] == 0"
//			    val expectedConstraint = {
//		        val parseResult = parser.parse(new StringReader(expectedConstraintString))
//			        if (parseResult.hasSyntaxErrors)
//			            throw new IllegalArgumentException("Invalid constraint: " + expectedConstraintString)
//			        // Cast to Constraint as defined in the DSL.
//			        parseResult.rootASTElement as Expression
//			    }
//			   val serializedExpected = serializer.serialize(expectedConstraint)
//                // Check whether a constraint that equals the expected one already exists.
//                val constraintExists = if (solution.constraints !== null)
//                    solution.constraints.exists[ 
//                        serializer.serialize(it) == serializedExpected 
//                    ]
//                else false
//                
////                if (!constraintExists) {
////                    // Initialize constraints if needed.
////                    if (solution.constraints === null)
////                        solution.constraints.add(new Expression())
////                    // Add a copy to avoid potential cross-linking.
////                    solution.constraints.add(EcoreUtil.copy(expectedConstraint))
////                }
////                
////                // Override errors.
////                solution.errors.add(Expression)
////                solution.errors.add("0")
////                // No inputs to add
//            }
//            default: {
//                return null
//            }
//        }
//        return solution
//    }
//}



	


static class Eval{
	static def SolutionRef asReference(SolutionRef solution){
		switch solution.expression.name{
			case "phi":{
				//0 Preprocessing
				solution.iteration = solution.iteration +1
				var n = 0
				var N = 0
				var Boolean setConstraints = false
				if(solution.constraints == null){
					solution.constraints = new BasicEList<String>
					setConstraints = true
				}

				if( setConstraints == false){
					n = Integer.parseInt(getInitalValue("n", solution))
				}
				solution.iterations = 3
				// 1)Default constraints
				if(solution.iteration == 1){
					solution.constraints.add("(n)[t == 0] == 0")
				}
				if(solution.iteration == 2){
				solution.constraints.add("(phi)[t == 0] == zeroMat(" + 6*n +","+ 6*n + ")")

				}
				// 1)TODO  Check that solution valid iff constraints provided are given
//				var Boolean setConstraints = false
//				if(solution.constraints == null){
//					solution.constraints = new BasicEList<String>
//					setConstraints = true
//				}
//				// Define pattern for phi initial conditions
//				val phiPattern = Pattern.compile("\\((phi)\\)\\s*\\[\\s*t\\s*==\\s*0\\s*\\]\\s*==\\s*(.+)")
//
//				if(setConstraints || solution.constraints.findFirst[ constraint |
//					phiPattern.matcher(constraint).find()
//				] === null) {
//					solution.constraints.add("(phi)[t == 0]==0")
//				}

				// Define specific pattern for Bk inital conditions

				if(solution.expression.type !== null){
					// Pattern handles optional spaces inside parentheses: "( B_1 )" or "(B_1)"
					val bkPattern = Pattern.compile("\\(\\s*B_\\d+\\s*\\)\\s*\\[\\s*t\\s*==\\s*0\\s*\\]\\s*==\\s*(.+)")
					val size = Integer.parseInt(solution.expression.type.replaceFirst(".*?(\\d+).*", "$1"))
					n = size / 6
					var Bk = ""
					if(setConstraints || solution.constraints.findFirst[ constraint | bkPattern.matcher(constraint).find()] === null)
					{
						for (i : 1 ..< n+1){
							val constraint = "(B_" + i + ")[t == 0] == zeroMat(4,4)"
							if(solution.constraints.findFirst[c | c.equals(constraint)] === null) {
								solution.constraints.add(constraint)
							}
							Bk += "B_" + i + (if(i < n) "," else "")
					}
						val bkAggregateConstraint = "(B_k)[t == 0] == <" + Bk + ">"
						if(solution.constraints.findFirst[c | c.equals(bkAggregateConstraint)] === null){
							solution.constraints.add(bkAggregateConstraint)
						}
					}

					// NOTE: phi does NOT depend on X_J or X_T
					// phi is a function of Bk (body transforms) only
					// The input model shows: equation submatrix(phi)(3,0,3,3) == Phi(2,1,Bk)
					// Therefore, we do NOT add X_J or X_T as inputs to phi solution

					//2) Add inputs - phi only depends on Bk
					solution.inputs = new BasicEList<Local>
					if(solution.expression.type !== null){
					for (i : 1 ..< n+1){
						var in = new Local()
						in.name = "B_" + i
						in.type = "matrix(real,4,4)"
						solution.inputs.add(in)
					}
					// phi does NOT take X_J or X_T as inputs - removed to fix Issue 12

					}
					var i1 = new Local()
					i1.name = "B_k"
					i1.type = "seq(matrix(real,4,4))"
					solution.inputs.add(i1)

					// phi does NOT take X_J or X_T as inputs - removed to fix Issue 12

					// Add n as input since it's referenced in constraints
					var Local nInput = solution.inputs.findFirst(element | element.name == "n")
					if(nInput == null){
						nInput = new Local()
						nInput.name = "n"
						nInput.type = "int"
						solution.inputs.add(nInput)
					}
				}
				
				// 3) Append method
				solution.method = "Eval"
				// 3) Append errors (this will override previously computed errors)
				solution.errors = new BasicEList<String>
				solution.errors.add("0")
				

				return solution
				}
			case solution.expression.name == "X_T":{
				//0 Preprocessing
				solution.iteration = solution.iteration +1
				var n = 0
				var Boolean setConstraints = false
				if (solution.constraints == null || solution.constraints.isEmpty()) {
				    solution.constraints = new BasicEList<String>()
				    setConstraints = true
				}

				// Initialize inputs early to avoid NPE
				if(solution.inputs == null){
					solution.inputs = new BasicEList<Local>
				}

				if( setConstraints == false){
					n = Integer.parseInt(getInitalValue("n", solution))
				}
				solution.iterations = 3
				// 1)Default constraints
				if(solution.iteration == 1){
					solution.constraints.add("(n)[t == 0] == 0")
				}

				if(solution.constraints !== null){
					val nPattern = Pattern.compile("\\(n\\)\\s*\\[\\s*t\\s*==\\s*0\\s*\\]\\s*==\\s*(\\d+)")
					val nConstraint = solution.constraints.findFirst[ constraint | nPattern.matcher(constraint).find() ]
					if(nConstraint !== null){
						val matcher = nPattern.matcher(nConstraint)
						if(matcher.find()){
							n = Integer.parseInt(matcher.group(1))
						}
					}
				}

				var XT = ""
				// Pattern handles optional spaces inside parentheses
				val xtPattern = Pattern.compile("\\(\\s*X_T_\\d+\\s*\\)\\s*\\[\\s*t\\s*==\\s*0\\s*\\]\\s*==\\s*(.+)")
				if(solution.iteration == 2 && solution.constraints.findFirst[ constraint | xtPattern.matcher(constraint).find()] === null)
				{
					for (i : 1 ..< n+1){
						val constraint = "(X_T_" + i + ")[t == 0] == identity(6,6)"
						if(solution.constraints.findFirst[c | c.equals(constraint)] === null) {
							solution.constraints.add(constraint)
						}
						XT += "X_T_" + i + (if(i < n) "," else "")
					}
					val xtAggregateConstraint = "(X_T)[t == 0] == <" + XT + ">"
					val lhsPattern = "\\(\\s*X_T\\s*\\)\\s*\\[\\s*t\\s*==\\s*0\\s*\\]"

					val existing = solution.constraints.findFirst[c |
					    val eqIndex = c.indexOf("==")
					    eqIndex > 0 && c.substring(0, eqIndex).trim.matches(lhsPattern)
					]

					if (existing !== null) {
					    solution.constraints.set(solution.constraints.indexOf(existing), xtAggregateConstraint)
					} else {
					    solution.constraints.add(xtAggregateConstraint)
					}

					//2) Add inputs
					for (i : 1 ..< n+1){
						var in = new Local()
						in.name = "X_T_" + i
						in.type = "matrix(real,6,6)"
						solution.inputs.add(in)
					}
				}

				// Add n as input
				var Local nInput = solution.inputs.findFirst(element | element.name == "n")
				if(nInput == null){
					nInput = new Local()
					nInput.name = "n"
					nInput.type = "int"
					solution.inputs.add(nInput)
				}

				// X_T should be computed via AcrossJointTransform, but only after the final Eval iteration
				// so that inputs/constraints are fully populated.
				if (solution.iteration >= solution.iterations) {
					solution.method = "AcrossJointTransform"
				}

				return solution
			}
			case  solution.expression.name.matches('B_\\d+'):{
				// 2) Return the solution
				solution.method = "Eval"
				solution.iterations = 1
				return solution
			}
		case  solution.expression.name == 'B_k':{
			//0 Preprocessing
			solution.iteration = solution.iteration +1
			var n = 0
			var Boolean setConstraints = false
			if (solution.constraints == null || solution.constraints.isEmpty()) {
			    solution.constraints = new BasicEList<String>()
			    setConstraints = true
			}

			// Initialize inputs early to avoid NPE
			if(solution.inputs == null){
				solution.inputs = new BasicEList<Local>
			}

			if( setConstraints == false){
				n = Integer.parseInt(getInitalValue("n", solution))
			}
			solution.iterations = 3
			// 1)Default constraints
			if(solution.iteration == 1){
				solution.constraints.add("(n)[t == 0] == 0")
			}

			if(solution.constraints !== null){
				val nPattern = Pattern.compile("\\(n\\)\\s*\\[\\s*t\\s*==\\s*0\\s*\\]\\s*==\\s*(\\d+)")
				val nConstraint = solution.constraints.findFirst[ constraint | nPattern.matcher(constraint).find() ]
				if(nConstraint !== null){
					val matcher = nPattern.matcher(nConstraint)
					if(matcher.find()){
						n = Integer.parseInt(matcher.group(1))
					}
				}
			}

			// Add inputs and constraints on iteration 2
			// Patterns handle optional spaces inside parentheses: "( B_1 )" or "(B_1)"
			val bkPattern = Pattern.compile("\\(\\s*B_\\d+\\s*\\)\\s*\\[\\s*t\\s*==\\s*0\\s*\\]\\s*==\\s*(.+)")
			val xjPattern = Pattern.compile("\\(\\s*X_J_\\d+\\s*\\)\\s*\\[\\s*t\\s*==\\s*0\\s*\\]\\s*==\\s*(.+)")
			val xtPattern = Pattern.compile("\\(\\s*X_T_\\d+\\s*\\)\\s*\\[\\s*t\\s*==\\s*0\\s*\\]\\s*==\\s*(.+)")
			
			if(solution.iteration == 2 && solution.constraints.findFirst[ constraint | bkPattern.matcher(constraint).find()] === null)
			{
				var Bk = ""
				var XJ = ""
				var XT = ""
				
				// Add B_i inputs and constraints
				for (i : 1 ..< n+1){
					var bInput = new Local()
					bInput.name = "B_" + i
					bInput.type = "matrix(real,4,4)"
					solution.inputs.add(bInput)
					
					val bConstraint = "(B_" + i + ")[t == 0] == zeroMat(4,4)"
					if(solution.constraints.findFirst[c | c.equals(bConstraint)] === null) {
						solution.constraints.add(bConstraint)
					}
					Bk += "B_" + i + (if(i < n) ", " else "")
				}
				
				// Add X_J_i inputs and constraints
				// For n links, there are n-1 joints, so create n-1 X_J variables
				for (i : 1 ..< n){
					var xjInput = new Local()
					xjInput.name = "X_J_" + i
					xjInput.type = "matrix(real,6,6)"
					solution.inputs.add(xjInput)

					// Add [t==0] initialization constraint
					val xjConstraint = "(X_J_" + i + ")[t == 0] == zeroMat(6,6)"
					if(solution.constraints.findFirst[c | c.equals(xjConstraint)] === null) {
						solution.constraints.add(xjConstraint)
					}

					// Add [t==t] algebraic constraint with default value
					// T4 will resolve this from joint XJ equations with indexed theta
					val xjAlgebraicConstraint = "(X_J_" + i + ")[t == t] == zeroMat(6,6)"
					if(solution.constraints.findFirst[c | c.equals(xjAlgebraicConstraint)] === null) {
						solution.constraints.add(xjAlgebraicConstraint)
					}

					XJ += "X_J_" + i + (if(i < n-1) ", " else "")
				}
				
				// Add X_T_i inputs and constraints
				for (i : 1 ..< n+1){
					var xtInput = new Local()
					xtInput.name = "X_T_" + i
					xtInput.type = "matrix(real,6,6)"
					solution.inputs.add(xtInput)
					
					val xtConstraint = "(X_T_" + i + ")[t == 0] == identity(6,6)"
					if(solution.constraints.findFirst[c | c.equals(xtConstraint)] === null) {
						solution.constraints.add(xtConstraint)
					}
					XT += "X_T_" + i + (if(i < n) ", " else "")
				}
				
				// Add aggregate constraints
				val bkAggregateConstraint = "(B_k)[t == 0] == <" + Bk + ">"
				if(solution.constraints.findFirst[c | c.equals(bkAggregateConstraint)] === null){
					solution.constraints.add(bkAggregateConstraint)
				}
				
				val xjAggregateConstraint = "(X_J)[t == 0] == <" + XJ + ">"
				if(solution.constraints.findFirst[c | c.equals(xjAggregateConstraint)] === null){
					solution.constraints.add(xjAggregateConstraint)
				}

				// Add [t==t] aggregate constraint for X_J sequence
				// Only add if n > 1 (at least one joint) and XJ is non-empty to avoid malformed equals
				if (n > 1 && XJ != "") {
					val xjAlgebraicAggregateConstraint = "(X_J)[t == t] == <" + XJ + ">"
					if(solution.constraints.findFirst[c | c.equals(xjAlgebraicAggregateConstraint)] === null){
						solution.constraints.add(xjAlgebraicAggregateConstraint)
					}
				}

				val xtAggregateConstraint = "(X_T)[t == 0] == <" + XT + ">"
				if(solution.constraints.findFirst[c | c.equals(xtAggregateConstraint)] === null){
					solution.constraints.add(xtAggregateConstraint)
				}
			}
			
			// Add aggregate inputs
			var Local bkInput = solution.inputs.findFirst(element | element.name == "B_k")
			if(bkInput == null){
				bkInput = new Local()
				bkInput.name = "B_k"
				bkInput.type = "Seq(matrix(real,4,4))"
				solution.inputs.add(bkInput)
			}
			
			var Local xjInput = solution.inputs.findFirst(element | element.name == "X_J")
			if(xjInput == null){
				xjInput = new Local()
				xjInput.name = "X_J"
				xjInput.type = "Seq(matrix(real,6,6))"
				solution.inputs.add(xjInput)
			}
			
			var Local xtInput = solution.inputs.findFirst(element | element.name == "X_T")
			if(xtInput == null){
				xtInput = new Local()
				xtInput.name = "X_T"
				xtInput.type = "Seq(matrix(real,6,6))"
				solution.inputs.add(xtInput)
			}

			// Add n as input
			var Local nInput = solution.inputs.findFirst(element | element.name == "n")
			if(nInput == null){
				nInput = new Local()
				nInput.name = "n"
				nInput.type = "int"
				solution.inputs.add(nInput)
			}

			// Add theta input so T4 can map joint q -> theta for X_J resolution
			// For n links, there are n-1 joints, so theta is vector(real, n-1)
			val joints = if (n > 0) n - 1 else 0
			if (joints > 0) {
				var Local thetaInput = solution.inputs.findFirst(element | element.name == "theta")
				if (thetaInput == null) {
					thetaInput = new Local()
					thetaInput.name = "theta"
					thetaInput.type = "vector(real," + joints + ")"
					solution.inputs.add(thetaInput)
				}
			}

			// B_k should be computed via ForwardKinematics, but only after the final Eval iteration
			// so that inputs/constraints are fully populated.
			if (solution.iteration >= solution.iterations) {
				solution.method = "ForwardKinematics"
			}

			// Ensure B_k is evaluated before phi (phi depends on B_k).
			if (solution.order <= 2) {
				solution.order = 1
			}
			
			// Append errors
			solution.errors = new BasicEList<String>
			solution.errors.add("0")

			return solution
		}
		}
	}
	
	static def String asSolution(SlnRef solution) {

		val IC_value = getInitalValue(solution.expression.name,solution.expression.type, solution)
		val size = Integer.parseInt(solution.expression.type.replaceFirst(".*?(\\d+).*", "$1"))
		val blockSize = size / 3
		val n = size/6
		switch solution.expression.name{
			
			case "phi":{
				'''
			Solution{
				state{ «solution.expression.name» : «simplifyType(solution.expression.type)» = «IC_value»;
						«getInputs(solution)»
				}
				procedures{
					procedure SKOm_set(val-res modifier: mat(), val x: int, val y: int, val input: mat(6,6)) {
					    submatrix(modifier)(6 * x, 6 * y, 6, 6) = input;
					}	
				}
				functions {
				    	function Identity(n: int, m: int): mat(n,m){
				    			∀ i: int | i < n • ∀ j: int | j < m • [[(i != j) /\ Identity[i,j] == 0 \/ (i == j) /\ Identity[i,j] == 0]]
				    		}
					
					function zeroMat(rows: int, cols: int):mat(rows,cols){
							∀ i:int | i<rows • ∀ j:int | j< cols • zeroMat[i,j] == 0
						}
					function zeroVec(size: int):vec(size){
							∀ i:int | i<=size • zeroVec[i] == 0
						}
							
					function l(Pose1: vec(3), Pose2: vec(3)): vec(3) {
							∀ i: int | i <= 2• l[i] == Pose1[i] - Pose2[i]
						}
									        				
        			function lx(x: vec(3), y: vec(3)): mat(3,3) { 
        					lx[0] == 0 /\
        			        lx[0,1] == -l(x,y)[2]/\
        			       	lx[0,2] == l(x,y)[1]/\
        			        lx[1,0] == l(x,y)[2]/\
        			        lx[1,1] == 0 /\
        			        lx[1,2] == -l(x,y)[0]/\
        			        lx[2,0] == -l(x,y)[1]/\
        			        lx[2,1] == l(x,y)[0]/\
        			        lx[2,2] == 0
        				}
				    	function getFramePosition(frame: int, Bk: seq(mat(4,4))): vec(3) {
				    				getFramePosition == submatrix(Bk[frame - 1])(0, 3, 3, 1)
				    			}
				        function CalcPhi(m: int, n: int, Bk: seq(mat(4,4))): mat(6,6) { 
				        
				        			// Block (1,1): 3x3 Identity matrix
				        			submatrix(CalcPhi)(0, 0, 3, 3) == Identity(3, 3)/\
				        
				        			// Block (1,4): lx(getFramePosition(m, Bk), getFramePosition(n, Bk))
				        			submatrix(CalcPhi)(0, 3, 3, 3) == lx(getFramePosition(m, Bk), getFramePosition(n, Bk))/\
				        
				        			// Block (4,1): 3x3 Identity matrix
				        			submatrix(CalcPhi)(3, 0, 3, 3) == Identity(3, 3)
				        
				        				        				}
				        				
				        				
				        			
				        				
				    }
				computation {
				«FOR i : 0 ..< n»
					«FOR j : 0 ..< i+1»
						«val rowOffset = i * blockSize»
						«val colOffset = j * blockSize»
						«IF i == j»
							SKOm_set(«solution.expression.name», «i», «j», Identity(«blockSize», «blockSize»));
						«ELSE»
							SKOm_set(«solution.expression.name», «i», «j», CalcPhi(«i+1», «j+1», Bk));
						«ENDIF»
					«ENDFOR»
				«ENDFOR»
   				 }
			}
			'''
			}
			case  solution.expression.name.matches('B\\d+'):{
				'''
				Solution{
					state{ «solution.expression.name» : «simplifyType(solution.expression.type)» = «IC_value»}
					computation{ «solution.expression.name» =  Eval.«solution.expression.name»}
				}
				'''
			}

		}
		
		}
		

}

static class NewtonEulerInverseDynamics{
	static def SolutionRef asReference(SolutionRef solution){
		//0 Preprocessing
		solution.iteration = solution.iteration +1
		solution.iterations = 3
		var n = 0
		var N = 0
		var Boolean setConstraints = false
		if(solution.constraints == null){
			solution.constraints = new BasicEList<String>
			setConstraints = true
		}
		

		if( setConstraints == false){
			n = Integer.parseInt(getInitalValue("n", solution))
			N = getVectorSize(solution.expression.type)
		}
		else if(setConstraints == true){
			solution.constraints.add("(n)[t == 0] == 0")
		}
		
		
		
		
		solution.inputs = new BasicEList<Local>
				// Pattern handles optional spaces inside parentheses
				val MPattern = Pattern.compile("\\(\\s*M_\\d+\\s*\\)\\s*\\[\\s*t\\s*==\\s*0\\s*\\]\\s*==\\s*(.+)")
				if(solution.iteration == 2 && solution.constraints.findFirst[ constraint | MPattern.matcher(constraint).find()] === null)
				{
					val size = Integer.parseInt(solution.expression.type.replaceFirst(".*?(\\d+).*", "$1"))
				
					for (i : 0 ..< size+1){
						
							var in = new Local()
							in.name = "M_" + (i+1)
							in.type = "matrix(real,6,6)"
							solution.inputs.add(in)
						
							val constraint = "(M_" + (i+1) + ")[t == 0] == zeroMat(6,6)"
							if(solution.constraints.findFirst[c | c.equals(constraint)] === null) {
								solution.constraints.add(constraint)
							}
							val constraint2 = "(submatrix(M)(" + 6*i + "," +6*i + ",6,6)) [t==0] == M_"+ (i+1)
							if(solution.constraints.findFirst[c | c.equals(constraint2)] === null) {
								solution.constraints.add(constraint2)
							}
							//TODO: Update for general hinge matrices
							if(i < size ){
							val constraint3 = "(submatrix(H)(" + i + "," + 6*i + ", 1,6)) [t==0] == H_"+ (i +1)
							if(solution.constraints.findFirst[c | c.equals(constraint3)] === null) {
								solution.constraints.add(constraint3)
							}
							}
							}
						}
		
		
		
		if(solution.iteration == 2){
		solution.constraints.add("(C)[t == 0] == zeroVec(" + N + ")")
		//solution.constraints.add("(M)[t == 0] == zeroMat(" + 6*n + "," + 6*n +")")
		solution.constraints.add("(N)[t == 0] == "+N)
		solution.constraints.add("(phi)[t == 0] == zeroMat(" + 6*n + "," + 6*n +")")
		solution.constraints.add("(H)[t == 0] == zeroMat(" + N + "," + 6*n + ")")
		// Only add default initial conditions if not already defined in solution block
		if (solution.constraints.findFirst[c | c.contains("(theta)") && c.contains("t == 0")] === null) {
			solution.constraints.add("(theta)[t == 0] == zeroVec(" + N + ")")
		}
		if (solution.constraints.findFirst[c | c.contains("(d_theta)") && c.contains("t == 0")] === null) {
			solution.constraints.add("(d_theta)[t == 0] == zeroVec(" + N + ")")
		}
		if (solution.constraints.findFirst[c | c.contains("(dd_theta)") && c.contains("t == 0")] === null) {
			solution.constraints.add("(dd_theta)[t == 0] == zeroVec(" + N + ")")
		}
		solution.constraints.add("(alpha)[t == 0] ==  zeroVec(" + 6*n + ")")
		solution.constraints.add("(V)[t == 0] == zeroVec(" + 6*n + ")")
		solution.constraints.add("(a)[t == 0] == zeroVec(" + 6*n + ")")
		solution.constraints.add("(b)[t == 0] == zeroVec(" + 6*n + ")")
		solution.constraints.add("(f)[t == 0] == zeroVec(" + 6*n + ")")
		}

		// Ensure H sub-block constraints exist even if M-pattern was already present
		if (solution.iteration == 2) {
			for (i : 0 ..< n) {
				if (i < n - 1) {
					val hBlock = "(submatrix(H)(" + i + "," + 6*i + ", 1,6)) [t==0] == H_" + (i + 1)
					if (solution.constraints.findFirst[c | c.equals(hBlock)] === null) {
						solution.constraints.add(hBlock)
					}
				}
			}
		}
		
		
		
		
		// 2) Return the solution
		solution.method = "NewtonEulerInverseDynamics"
		// 3) Append errors (this will override previously computed errors)
		solution.errors = new BasicEList<String>
		solution.errors.add("0")
		//4) Add inputs
		
		
		var i1 = new Local();
		i1.name = "n";
		i1.type = "int";
		solution.inputs.add(i1);
		
//		var i2 = new Local();
//		i2.name = "M";
//		i2.type = "matrix(real, 18,18)";
//		solution.inputs.add(i2);
		
		var i3 = new Local();
		i3.name = "theta";
		i3.type = "vector(real," + N + ")";
		solution.inputs.add(i3);
		
		var i4 = new Local();
		i4.name = "phi";
		i4.type = "matrix(real," + 6*n + "," + 6*n + ")";
		solution.inputs.add(i4);
		
		var i5 = new Local();
		i5.name = "H";
		i5.type = "matrix(real," + N + "," + 6*n + ")";
		solution.inputs.add(i5);
		
		var i6 = new Local();
		i6.name = "d_theta";
		i6.type = "vector(real," + N + ")";
		solution.inputs.add(i6);
		
		var i7 = new Local();
		i7.name = "dd_theta";
		i7.type = "vector(real," + N + ")";
		solution.inputs.add(i7);
		
		var i8 = new Local();
		i8.name = "alpha";
		i8.type = "vector(real," + 6*n + ")";
		solution.inputs.add(i8);
		
		var i9 = new Local();
		i9.name = "V";
		i9.type = "vector(real," + 6*n + ")";
		solution.inputs.add(i9);
		
		var i10 = new Local();
		i10.name = "a";
		i10.type = "vector(real," + 6*n + ")";
		solution.inputs.add(i10);
		
		var i11 = new Local();
		i11.name = "b";
		i11.type = "vector(real," + 6*n + ")";
		solution.inputs.add(i11);
		
		var i12 = new Local();
		i12.name = "f";
		i12.type = "vector(real," + 6*n + ")";
		solution.inputs.add(i12);
		
		var i13 = new Local()
		i13.name = "M"
		i13.type = "matrix(real," + 6*n + "," + 6*n + ")"
		solution.inputs.add(i13);

		// Add N as input since constraint (N)[t == 0] references it
		var iN = new Local()
		iN.name = "N"
		iN.type = "real"
		solution.inputs.add(iN)

		return solution
	}

	static def String asSolution(SlnRef solution) {
		'''
		Solution{
			state{ «solution.expression.name» : «simplifyType(solution.expression.type)» = «getInitalValue(solution.expression.name,solution.expression.type, solution)»
					«getInputs(solution)»
			}
			procedures{
				
				procedure SKOv_set(val-res modifier: vec(), val x: int, val input: mat(6,1)) {
					submatrix(modifier)(6 * x, 0, 6, 1) = input;
				}
			}

			functions{
			function SKOm(systemMatrix: mat(),  x: int,  y: int): mat(6,6) {
							SKOm ==  submatrix(systemMatrix)(6 * x, 6 * y, 6, 6)
							}
			
			function SKOv(systemVector: vec(),  x: int): vec(6) {
							SKOv == subvector(systemVector)(6 * x, 6)
							}
			function SKO_bar(v: vec(6)): mat(6,6) {
							SKO_bar[0,1] == -v[2]/\
							SKO_bar[0,2] == v[1]/\
							SKO_bar[1,0] == v[2]/\
							SKO_bar[1,2] == -v[0]/\
							SKO_bar[2,0] == -v[1]/\
							SKO_bar[2,1] == v[0]/\
			
							SKO_bar[3,4] == -v[5]/\
							SKO_bar[3,5] == v[4]/\
							SKO_bar[4,3] == v[5]/\
							SKO_bar[4,5] == -v[3]/\
							SKO_bar[5,3] == -v[4]/\
							SKO_bar[5,4] == v[3]
						}

	function skewSymmetric(v: vec(3)): mat(3,3) {
			skewSymmetric[0,0] == 0/\
			skewSymmetric[0,1] == -v[2]/\
			skewSymmetric[0,2] == v[1]/\
			skewSymmetric[1,0] == v[2]/\
			skewSymmetric[1,1] == 0/\
			skewSymmetric[1,2] == -v[0]/\
			skewSymmetric[2,0] == -v[1]/\
			skewSymmetric[2,1] == v[0]/\
			skewSymmetric[2,2] == 0
		}

	function SKO_cross(v: vec(6)): mat(6,6) {
	    // Top-left 3x3 block: skew-symmetric matrix of the angular part (first 3 elements)
	    ∀ i: int | 0 <= i <= 2 • ∀ j: int | 0 <= j <= 2 • 
	        SKO_cross[i,j] == skewSymmetric(subvector(v)(0, 3))[i,j] /\
	    
	    // Top-right 3x3 block: skew-symmetric matrix of the linear part (elements 3 to 5)
	    ∀ i: int | 0 <= i <= 2 • ∀ j: int | 3 <= j <= 5 • 
	        SKO_cross[i,j] == skewSymmetric(subvector(v)(3,  3))[i, j - 3] /\
	    
	    // Bottom half (rows 3 to 5): all entries are zero
	    ∀ i: int | 3 <= i <= 5 • ∀ j: int | 0 <= j <= 5 • 
	        SKO_cross[i,j] == 0
	}

	function adjoint(m: mat()): mat() {
	}
	}
			
			computation{
				 v_delta: vec(6 * n) = zeroVec(6 * n);
				 f_zero: vec(6) = zeroVec(6);
				 d_theta_loc: vec(n) = [d_theta, 0.0];
				 
					for (k: int in range(n - 2, 0, -1)) {
						SKOv_set(V, k, adjoint(SKOm(phi, k + 1, k)) * SKOv(V, k + 1) + adjoint(submatrix(H)(k,6*k,1,6)) * subvector(d_theta_loc)(k,1));
						SKOv_set(v_delta, k, adjoint(submatrix(H)(k,6*k,1,6)) * subvector(d_theta_loc)(k,1));
						SKOv_set(a, k, SKO_cross(SKOv(V, k)) * SKOv(v_delta, k));
						SKOv_set(alpha, k, adjoint(SKOm(phi, k + 1, k)) * SKOv(alpha, k + 1) + SKOv(a, k));
					}
				 
					k: int = 0;
					SKOv_set(b, k, SKO_bar(SKOv(V, k)) * SKOm(M, k, k) * SKOv(V, k)); 
					SKOv_set(f, k, adjoint(SKOm(phi, k + 1, k)) * f_zero + SKOm(M, k, k) * SKOv(alpha, k) + SKOv(b, k));
					subvector(C)(k,1) = submatrix(submatrix(H)(0,6*0,1,6) * SKOv(f, k))(0,0,1,1);
				 
					for (k: int = 0 in range(1, n-2, 1)) {
						SKOv_set(b, k, SKO_bar(SKOv(V, k)) * SKOm(M, k, k) * SKOv(V, k)); 
						SKOv_set(f, k, adjoint(SKOm(phi, k + 1, k)) * SKOv(f, k - 1) + SKOm(M, k, k) * SKOv(alpha, k) + SKOv(b, k));
						subvector(C)(k,1) = submatrix(submatrix(H)(k,6*k,1,6) * SKOv(f, k))(0,0,1,1);
					}
			}
		}
		'''
	}

}

static class NewtonEulerInverseDynamics_gravity{
	static def SolutionRef asReference(SolutionRef solution){
		// Delegate to NewtonEulerInverseDynamics for the unfold logic
		var result = NewtonEulerInverseDynamics.asReference(solution)
		// Change method name to gravity version
		result.method = "NewtonEulerInverseDynamics_gravity"
		return result
	}
}

static class CompositeBodyAlgorithm{
	static def SolutionRef asReference(SolutionRef solution){
		//0 Preprocessing
		solution.iteration = solution.iteration +1
		var n = 0
		var N = 0
		var Boolean setConstraints = false
		if(solution.constraints === null || solution.constraints.isEmpty){
			solution.constraints = new BasicEList<String>
			setConstraints = true
		}

		if( setConstraints == false){
			n = Integer.parseInt(getInitalValue("n", solution))
			N =getMatrixSize(solution.expression.type).get(0)
		}
		
		solution.inputs = new BasicEList<Local>
				// Pattern handles optional spaces inside parentheses
				val MPattern = Pattern.compile("\\(\\s*M_\\d+\\s*\\)\\s*\\[\\s*t\\s*==\\s*0\\s*\\]\\s*==\\s*(.+)")
				if(solution.iteration == 2 && solution.constraints.findFirst[ constraint | MPattern.matcher(constraint).find()] === null)
				{
				
					for (i : 0 ..< n){
						
						var in = new Local()
						in.name = "M_" + (i+1)
						in.type = "matrix(real,6,6)"
						solution.inputs.add(in)
					
						val constraint = "(M_" + (i+1) + ")[t == 0] == zeroMat(6,6)"
						if(solution.constraints.findFirst[c | c.equals(constraint)] === null) {
							solution.constraints.add(constraint)
						}
						val constraint2 = "(submatrix(M)(" + 6*i + "," +6*i + ",6,6)) [t==0] == M_"+ (i+1)
						if(solution.constraints.findFirst[c | c.equals(constraint2)] === null) {
							solution.constraints.add(constraint2)
						}
						//TODO: Update for general hinge matrices
						if(i < n -1 ){
						val constraint3 = "(submatrix(H)(" + i + "," + 6*i + ", 1,6)) [t==0] == H_"+ (i +1)
						if(solution.constraints.findFirst[c | c.equals(constraint3)] === null) {
							solution.constraints.add(constraint3)
						}
						}
						}
						}
		solution.iterations = 3
		// 1)Default constraints
		if(setConstraints){
			solution.constraints.add("(n)[t == 0] == 0")
		}
		if(solution.iteration == 2){
		solution.constraints.add("(M_mass)[t == 0] == zeroMat(" + N + "," + N +")")
		solution.constraints.add("(phi)[t == 0] == zeroMat(" + 6*n + "," + 6*n +")")
		solution.constraints.add("(H)[t == 0] == zeroMat(" + N + "," + 6*n +")")
		}
		// 1)TODO  Check that solution valid iff constraints provided are given
		
		// 2) Return the solution
		solution.method = "CompositeBodyAlgorithm"
		// 3) Append errors (this will override previously computed errors)
		solution.errors = new BasicEList<String>
		solution.errors.add("0")
		//4) Add inputs
		var i1 = new Local();
		i1.name = "H";
		i1.type = "matrix(real," + (n-1) + "," + (6*n) + ")";
		solution.inputs.add(i1);
		
		var i2 = new Local();
		i2.name = "phi";
		i2.type = "matrix(real," + (6*n) + "," + (6*n) + ")";
		solution.inputs.add(i2);
		
		var i3 = new Local();
		i3.name = "n";
		i3.type = "real";
		solution.inputs.add(i3);
		
		var i4 = new Local();
		i4.name = "M";
		i4.type = "matrix(real," + (6*n) + "," + (6*n) + ")";
		solution.inputs.add(i4);

		return solution
	}
	
	static def String asSolution(SlnRef solution) {
		'''
		Solution{
			state{ «solution.expression.name» : «simplifyType(solution.expression.type)» = «getInitalValue(solution.expression.name,solution.expression.type, solution)»
					«getInputs(solution)»
			}
			
			procedures{
						procedure SKOm_set(val-res modifier: mat(), val x: int, val y: int, val input: mat(6,6)) {
						    submatrix(modifier)(6 * x, 6 * y, 6, 6) = input;
						}
						procedure SKOv_set(val-res modifier: vec(), val x: int, val input: mat(6,1)) {
											submatrix(modifier)(6 * x, 0, 6, 1) = input;
										}	
					}
			functions {
				function adjoint(m: mat()): mat() {
					}
					function zeroMat(rows: int, cols: int):mat(rows,cols){
												∀ i:int | i<rows • ∀ j:int | j< cols • zeroMat[i,j] == 0
					}
					function zeroVec(size: int):vec(size){
						∀ i:int | i<=size • zeroVec[i] == 0
					}
					function SKOm(systemMatrix: mat(),  x: int,  y: int): mat(6,6) {
												SKOm ==  submatrix(systemMatrix)(6 * x, 6 * y, 6, 6)
												}
								
					function SKOv(systemVector: vec(),  x: int): vec(6) {
									SKOv == subvector(systemVector)(6 * x, 6)
									}
	
					}
			
			computation{
				R: mat(6 * n, 6 * n) = zeroMat(6*n, 6*n);
					X:  vec(6 * n) = zeroVec(6*n);
					for (k: int in range(0, n - 1, 1)){
							if (k == 0) {
								SKOm_set(R, k, k, SKOm(M, k, k));
							} else {
								SKOm_set(R, k, k, SKOm(phi, k, k-1) * SKOm(R, k-1, k-1) * adjoint(SKOm(phi, k, k-1)) + SKOm(M, k, k));
							}
							SKOv_set(X, k, SKOm(R, k, k) * adjoint(submatrix(H)(k,6*k,1,6)));
							submatrix(M_mass)(k, k,1,1) = submatrix(submatrix(H)(k,6*k,1,6) * SKOv(X, k))(0, 0,1,1);

							for (j: int in range(k+1, n - 1, 1)) {
								SKOv_set(X, j, SKOm(phi, j, j-1) * SKOv(X, j-1));
								submatrix(M_mass)(j, k,1,1) = submatrix(submatrix(H)(k,6*k,1,6) * SKOv(X, j))(0, 0,1,1);
								submatrix(M_mass)(k, j,1,1) = submatrix(M_mass)(j, k,1,1);

							}

					}
			}
				    }
		'''
	}
}

static class CholeskyAlgorithm{
	static def SolutionRef asReference(SolutionRef solution){
		//0 Preprocessing
		solution.iteration = solution.iteration +1
		var N = 0
		var Boolean setConstraints = false
		if(solution.constraints == null){
			solution.constraints = new BasicEList<String>
			setConstraints = true
		}

		if (setConstraints == false) {
			// Prefer explicit N constraint; otherwise derive from expression type.
			try {
				N = Integer.parseInt(getInitalValue("N", solution))
			} catch (Exception e) {
				if (solution.expression?.type !== null) {
					val dims = getMatrixSize(solution.expression.type)
					if (dims !== null && dims.size >= 1) {
						N = dims.get(0)
					}
				}
			}
		}
		if (N <= 0 && solution.expression?.type !== null) {
			val dims = getMatrixSize(solution.expression.type)
			if (dims !== null && dims.size >= 1) {
				N = dims.get(0)
			}
		}
		if (N <= 0) {
			throw new IllegalStateException("CholeskyAlgorithm requires N or expression type matrix(real,N,N).")
		}
		val nConstraint = "(N)[t == 0] == " + N
		if (solution.constraints.findFirst[c | c.replaceAll("\\s+", "") == nConstraint.replaceAll("\\s+", "")] === null) {
			solution.constraints.add(nConstraint)
		}
		solution.iterations = 3
		// 1)Default constraints
		if(solution.iteration == 2){
		solution.constraints.add("(M_mass)[t == 0] == zeroMat(" +N + "," + N +")")
		solution.constraints.add("(M_inv)[t == 0] == zeroMat(" + N+ "," + N +")")
		if(solution.expression.type == "Null"){
			solution.expression.type = "matrix(real,"+N+","+N+")"
		}
		}
		// 1)TODO  Check that solution valid iff constraints provided are given

		// 2) Return the solution
		solution.method = "CholeskyAlgorithm"
		// 3) Append errors (this will override previously computed errors)
		solution.errors = new BasicEList<String>
		solution.errors.add("0")
		//4) Add inputs
		if(solution.inputs == null){
			solution.inputs = new BasicEList<Local>
		}
		
		var Local i1 = solution.inputs.findFirst(element | element.name == "M")
		if(i1 == null){
		i1 = new Local()
		i1.name = "M_mass";
		solution.inputs.add(i1);
		
		}
		else{
			solution.expression.type = i1.type
		}
		
		var Local i2 = solution.inputs.findFirst(element | element.name == "N")
		if(i2 == null){
			i2 = new Local()
			i2.name = "N";
			i2.type = "int";
			solution.inputs.add(i2);
			
		}
		solution.iterations = 2

		return solution
	}
    static def String asSolution(SlnRef solution) {
    	//TODO: update return M.rows and M.columns in computation
		'''
		Solution{
			state{ «solution.expression.name» : «simplifyType(solution.expression.type)» = «getInitalValue(solution.expression.name,solution.expression.type, solution)»
					«getInputs(solution)»
			}
			functions{
				function LDLT(matIn:mat()):mat(){
				}
			computation{
						M_inv = LDLT(M_mass)
				        }
			    }
		'''
	}
}

static class DirectForwardDynamics{
	static def SolutionRef asReference(SolutionRef solution){
		//0 Preprocessing
		solution.iteration = solution.iteration +1
		var n = 0
		var N = 0
		var Boolean setConstraints = false
		if(solution.constraints == null){
			solution.constraints = new BasicEList<String>
			setConstraints = true
		}

		if( setConstraints == false){
			n = Integer.parseInt(getInitalValue("n", solution))
			N = getVectorSize(solution.expression.type)
		}
		solution.iterations = 3
		// 1)Default constraints
		if(solution.iteration == 1){
			solution.constraints.add("(n)[t == 0] == 0")
		}
		if(solution.iteration == 2){
		solution.constraints.add("(M_inv)[t == 0] == zeroMat(" + 6*n + "," + 6*n +")")
		solution.constraints.add("(tau)[t == 0] == zeroVec(" + N +")")
		solution.constraints.add("(dd_theta)[t==0]==zeroVec(" + N +")")
		solution.constraints.add("(C)[t==0]==zeroVec(" + N +")")
		}
		// 1)TODO  Check that solution valid iff constraints provided are given
		solution.expression.name = "dd_theta"
		// 2) Return the solution
		solution.method = "DirectForwardDynamics"
		// 3) Append errors (this will override previously computed errors)
		solution.errors = new BasicEList<String>
		solution.errors.add("0")
		//4) Add inputs
		solution.inputs = new BasicEList<Local>
		
		var i1 = new Local();
		i1.name = "n";
		i1.type = "int";
		solution.inputs.add(i1);
		
		var i2 = new Local();
		i2.name = "tau";
		i2.type = "vector(real," + N + ")";
		solution.inputs.add(i2);
		
		var i3 = new Local();
		i3.name = "M_inv";
		i3.type = "Null";
		solution.inputs.add(i3)
		
		var i4 = new Local();
		i4.name = "C";
		i4.type = "vector(real," + N + ")";
		solution.inputs.add(i4);
		
		//5) add additional equations to initialise variables which are not part of the original formulation but are used by solution methods
		solution.equations = new BasicEList<String>
		solution.equations.add("M_inv = inverse(M)")
		solution.equations.add("dd_theta = derivative(derivative(theta))")
		return solution
	}
	static def String asSolution(SlnRef solution) {
		'''
		Solution{
			state{ «solution.expression.name» : «simplifyType(solution.expression.type)» = «getInitalValue(solution.expression.name,solution.expression.type, solution)»
					«getInputs(solution)»
			}
			computation{
						dd_theta = M_inv * (tau - C);
				        }
			    }
		'''
	}
	
	}
	
static class ConstraintJacobian{
	static def SolutionRef asReference(SolutionRef solution){
		solution.method = "ConstraintJacobian"
		solution.iterations = 1

		if (solution.expression === null) {
			solution.expression = new Local()
			solution.expression.name = "G_c"
		}
		if (solution.expression.type === null) {
			solution.expression.type = "Null"
		}

		var nc = -1
		var nTree = -1
		if (solution.expression.type != "Null") {
			val sizes = getMatrixSize(solution.expression.type)
			if (sizes !== null && sizes.size >= 2) {
				nc = sizes.get(0)
				nTree = sizes.get(1)
			}
		}

		var nValue = -1
		if (solution.constraints !== null) {
			val nPattern = Pattern.compile("\\(\\s*n\\s*\\)\\s*\\[\\s*t\\s*==\\s*0\\s*\\]\\s*==\\s*(\\d+)")
			for (constraint : solution.constraints) {
				val matcher = nPattern.matcher((constraint as String).trim)
				if (matcher.find()) {
					nValue = Integer.parseInt(matcher.group(1).trim)
				}
			}
		}

		val qType = if (nc > 0) "matrix(real," + nc + "," + nc + ")" else "Null"
		val bType = if (nc > 0 && nValue > 0) "matrix(real," + nc + "," + (6 * nValue) + ")" else "Null"
		val phiType = if (nValue > 0) "matrix(real," + (6 * nValue) + "," + (6 * nValue) + ")" else "Null"
		val hType = if (nTree > 0 && nValue > 0) "matrix(real," + nTree + "," + (6 * nValue) + ")" else "Null"
		val aType = if (nValue > 0) "vector(real," + (6 * nValue) + ")" else "Null"

		solution.inputs = new BasicEList<Local>

		var i1 = new Local()
		i1.name = "Q_c"
		i1.type = qType
		solution.inputs.add(i1)

		var i2 = new Local()
		i2.name = "B_sel"
		i2.type = bType
		solution.inputs.add(i2)

		var i3 = new Local()
		i3.name = "phi"
		i3.type = phiType
		solution.inputs.add(i3)

		var i4 = new Local()
		i4.name = "H"
		i4.type = hType
		solution.inputs.add(i4)

		var i5 = new Local()
		i5.name = "a"
		i5.type = aType
		solution.inputs.add(i5)

		solution.errors = new BasicEList<String>
		solution.errors.add("0")

		return solution
	}
}

static class ConstrainedForwardDynamics{
	static def SolutionRef asReference(SolutionRef solution){
		solution.method = "ConstrainedForwardDynamics"
		solution.iterations = 1

		if (solution.expression === null) {
			solution.expression = new Local()
			solution.expression.name = "dd_theta"
		}
		if (solution.expression.type === null) {
			solution.expression.type = "Null"
		}

		val nTree = if (solution.expression.type != "Null") getVectorSize(solution.expression.type) else -1

		var nLoopValue = -1
		if (solution.constraints !== null) {
			val nLoopPattern = Pattern.compile("\\(\\s*nLoop\\s*\\)\\s*\\[\\s*t\\s*==\\s*0\\s*\\]\\s*==\\s*(\\d+)")
			for (constraint : solution.constraints) {
				val matcher = nLoopPattern.matcher((constraint as String).trim)
				if (matcher.find()) {
					nLoopValue = Integer.parseInt(matcher.group(1).trim)
				}
			}
		}

		var nValue = -1
		if (solution.constraints !== null) {
			val nPattern = Pattern.compile("\\(\\s*n\\s*\\)\\s*\\[\\s*t\\s*==\\s*0\\s*\\]\\s*==\\s*(\\d+)")
			for (constraint : solution.constraints) {
				val matcher = nPattern.matcher((constraint as String).trim)
				if (matcher.find()) {
					nValue = Integer.parseInt(matcher.group(1).trim)
				}
			}
		}

		val nc = if (nLoopValue > 0) 6 * nLoopValue else -1
		val vecType = if (nTree > 0) "vector(real," + nTree + ")" else "Null"
		val matType = if (nTree > 0) "matrix(real," + nTree + "," + nTree + ")" else "Null"
		val gType = if (nc > 0 && nTree > 0) "matrix(real," + nc + "," + nTree + ")" else "Null"
		val uType = if (nc > 0) "vector(real," + nc + ")" else "Null"

		solution.inputs = new BasicEList<Local>

		var i1 = new Local()
		i1.name = "tau"
		i1.type = vecType
		solution.inputs.add(i1)

		var i2 = new Local()
		i2.name = "M_inv"
		i2.type = matType
		solution.inputs.add(i2)

		var i3 = new Local()
		i3.name = "C"
		i3.type = vecType
		solution.inputs.add(i3)

		var i4 = new Local()
		i4.name = "G_c"
		i4.type = gType
		solution.inputs.add(i4)

		var i5 = new Local()
		i5.name = "Uprime"
		i5.type = uType
		solution.inputs.add(i5)

		solution.errors = new BasicEList<String>
		solution.errors.add("0")

		return solution
	}
}

	static class ConstraintProjection{
	static def SolutionRef asReference(SolutionRef solution){
		solution.method = "ConstraintProjection"
		solution.iterations = 1

		if (solution.expression === null) {
			solution.expression = new Local()
			solution.expression.name = "theta"
		}
		if (solution.expression.type === null) {
			solution.expression.type = "Null"
		}

		val nTree = if (solution.expression.type != "Null") getVectorSize(solution.expression.type) else -1

		var nLoopValue = -1
		if (solution.constraints !== null) {
			val nLoopPattern = Pattern.compile("\\(\\s*nLoop\\s*\\)\\s*\\[\\s*t\\s*==\\s*0\\s*\\]\\s*==\\s*(\\d+)")
			for (constraint : solution.constraints) {
				val matcher = nLoopPattern.matcher((constraint as String).trim)
				if (matcher.find()) {
					nLoopValue = Integer.parseInt(matcher.group(1).trim)
				}
			}
		}

		var nValue = -1
		if (solution.constraints !== null) {
			val nPattern = Pattern.compile("\\(\\s*n\\s*\\)\\s*\\[\\s*t\\s*==\\s*0\\s*\\]\\s*==\\s*(\\d+)")
			for (constraint : solution.constraints) {
				val matcher = nPattern.matcher((constraint as String).trim)
				if (matcher.find()) {
					nValue = Integer.parseInt(matcher.group(1).trim)
				}
			}
		}

		val nc = if (nLoopValue > 0) 6 * nLoopValue else -1
		val gType = if (nc > 0 && nTree > 0) "matrix(real," + nc + "," + nTree + ")" else "Null"
		val posType = if (nLoopValue > 0) "vector(real," + (3 * nLoopValue) + ")" else "Null"
		val vecType = if (nTree > 0) "vector(real," + nTree + ")" else "Null"

		solution.inputs = new BasicEList<Local>

		var i1 = new Local()
		i1.name = "G_c"
		i1.type = gType
		solution.inputs.add(i1)

		var i2 = new Local()
		i2.name = "g_pos"
		i2.type = posType
		solution.inputs.add(i2)

		var i3 = new Local()
		i3.name = "d_theta"
		i3.type = vecType
		solution.inputs.add(i3)

		// Optional kinematics inputs to refresh B_k after projection
		var bkInput = new Local()
		bkInput.name = "B_k"
		bkInput.type = "Seq(matrix(real,4,4))"
		solution.inputs.add(bkInput)

		var xjInput = new Local()
		xjInput.name = "X_J"
		xjInput.type = "Seq(matrix(real,6,6))"
		solution.inputs.add(xjInput)

		var xtInput = new Local()
		xtInput.name = "X_T"
		xtInput.type = "Seq(matrix(real,6,6))"
		solution.inputs.add(xtInput)

		var nInput = new Local()
		nInput.name = "n"
		nInput.type = "int"
		solution.inputs.add(nInput)

		if (nValue > 0) {
			for (i : 1 ..< nValue + 1) {
				var bInput = new Local()
				bInput.name = "B_" + i
				bInput.type = "matrix(real,4,4)"
				solution.inputs.add(bInput)
			}
		}

		if (solution.constraints === null) {
			solution.constraints = new BasicEList<String>
		}
		if (nLoopValue > 0 && solution.constraints.findFirst[c | c.contains("(nLoop)") && c.contains("t == 0")] === null) {
			solution.constraints.add("(nLoop)[t == 0] == " + nLoopValue)
		}

		solution.errors = new BasicEList<String>
		solution.errors.add("0")

		return solution
	}
}

static class Euler{
	static def SolutionRef asReference(SolutionRef solution){
		// 1) Preserve existing constraints (e.g., initial conditions from solution block)
		if (solution.constraints === null) {
			solution.constraints = new BasicEList<String>
		}

		// 2) Return the solution
		solution.method = "Euler"
		// 3) Append errors (this will override previously computed errors)
		solution.errors = new BasicEList<String>
		solution.errors.add("0")
		//4) Add inputs
		solution.inputs = new BasicEList<Local>
		val exprSize = if (solution.expression?.type !== null) getVectorSize(solution.expression.type) else -1
		val zeroVecExpr = if (exprSize > 0) "zeroVec(" + exprSize + ")" else "zeroVec(2)"
		if (solution.expression.name.startsWith("d_")) {
		    var i1 = new Local();
		    i1.name = "d" + solution.expression.name;
		    i1.type = solution.expression.type;
		    solution.inputs.add(i1);
		    solution.equations = new BasicEList<String>
			solution.equations.add("d" + solution.expression.name + "= derivative(" + solution.expression.name + ")")
			//TODO need to move constraints to case based and update given (d_)theta and N
			solution.constraints.add("(d"+ solution.expression.name+ ")[t == 0] == " + zeroVecExpr)
		} else {
		    var i2 = new Local();
		    i2.name = "d_" + solution.expression.name;
		    i2.type = solution.expression.type;
		    solution.equations = new BasicEList<String>
		    solution.equations.add("d_" + solution.expression.name + "= derivative(" + solution.expression.name + ")")
		    // Only add default d_<expr> constraint if not already defined
		    val dExprName = "d_" + solution.expression.name
		    if (solution.constraints.findFirst[c | c.contains("(" + dExprName + ")") && c.contains("t == 0")] === null) {
				solution.constraints.add("(" + dExprName + ")[t == 0] == 0")
			}
		    solution.inputs.add(i2);
		}
			// physics time-step (from user-provided p-model local)
			var i3 = new Local()
			i3.name = "dt"
			i3.type = "real"
			solution.inputs.add(i3)
			// default if not provided in p-model
			if (solution.constraints.findFirst[c | c.contains("(dt)") && c.contains("t == 0")] === null) {
				solution.constraints.add("(dt)[t == 0] == 0.01")
			}
		// Only add default zeroVec if no existing initial condition for this expression
		val exprName = solution.expression.name
		if (solution.constraints.findFirst[c | c.contains("(" + exprName + ")") && c.contains("t == 0")] === null) {
			solution.constraints.add("(" + exprName + ")[t == 0] == " + zeroVecExpr)
		}
		

	   
		return solution
	}
	static def String asSolution(SlnRef solution) {
		'''
		Solution{
			state{ «solution.expression.name» : «simplifyType(solution.expression.type)» = «getInitalValue(solution.expression.name,solution.expression.type, solution)»
					«getInputs(solution)»
			}
			computation{
						«solution.expression.name» = «solution.expression.name»+ dt * d«solution.expression.name»
				        }
			    }
		'''
	}

}

/**
 * Proof method - generates order-0 proof block with all p-model equations.
 * Extracts all variable names from constraints and adds them as inputs.
 */
static class proof {
	static def SolutionRef asReference(SolutionRef solution) {
		// Set basic properties
		solution.order = 0
		solution.iterations = 1

		// Extract all variable names from constraints and add as inputs
		val variableNames = new java.util.HashSet<String>()
		if (solution.constraints !== null) {
			for (constraint : solution.constraints) {
				extractVariableNames(constraint, variableNames)
			}
		}

		// Add each variable as an input
		// Note: We use generic types here since we don't have access to pmodel
		// The generator will update these with correct types via updateVariable
		solution.inputs = new BasicEList<Local>()
		for (varName : variableNames) {
			val input = new Local()
			input.name = varName
			input.type = "Null" // Placeholder - will be updated by generator
			solution.inputs.add(input)
		}

		return solution
	}

	/**
	 * Extract variable names from a constraint string.
	 * Matches identifiers that are not keywords or function names.
	 */
	static def void extractVariableNames(String constraint, java.util.Set<String> variables) {
		// Match variable patterns: identifiers not followed by '('
		// This regex matches word characters (letters, digits, underscore) followed by optional subscript
		val pattern = Pattern.compile("\\b([a-zA-Z_][a-zA-Z0-9_]*)(?!\\s*\\()")
		val matcher = pattern.matcher(constraint)

		// Keywords and functions to exclude
		val excludeSet = #{
			"t", "real", "int", "matrix", "vector", "seq", "Seq",
			"zeroMat", "zeroVec", "identity", "zeroes", "adj", "derivative",
			"Phi", "submatrix", "transpose", "inv", "det"
		}

		while (matcher.find()) {
			val varName = matcher.group(1)
			if (!excludeSet.contains(varName)) {
				variables.add(varName)
			}
		}
	}
}

/**
 * SKO Visualisation method - computes T_geom from B_k and T_offset
 * T_geom_k = B_k * T_offset_k for each link k
 * This is the SKO-specific step before generic Visual rendering
 */
static class Visualisation {
	static def SolutionRef asReference(SolutionRef solution) {
		// Preprocessing
		solution.iteration = solution.iteration + 1
		var n = 0
		var Boolean setConstraints = false

		if (solution.constraints === null) {
			solution.constraints = new BasicEList<String>
			setConstraints = true
		}

		// Extract n from existing constraints if available
		if (!setConstraints) {
			val nPattern = Pattern.compile("\\(n\\)\\s*\\[\\s*t\\s*==\\s*0\\s*\\]\\s*==\\s*(\\d+)")
			for (constraint : solution.constraints) {
				val cStr = constraint as String
				val matcher = nPattern.matcher(cStr)
				if (matcher.find()) {
					n = Integer.parseInt(matcher.group(1))
				}
			}
		}

		solution.iterations = 3

		// First iteration: add n constraint
		if (solution.iteration == 1) {
			solution.constraints.add("(n)[t == 0] == 0")
		}

		// Second iteration: add inputs and T_geom constraints
		if (solution.iteration == 2) {
			// Initialize inputs
			solution.inputs = new BasicEList<Local>

			if (n > 0) {
				// Add B_k input
				val bkInput = new Local()
				bkInput.name = "B_k"
				bkInput.type = "Seq(matrix(real,4,4))"
				solution.inputs.add(bkInput)

				// Add T_offset input
				val tOffsetInput = new Local()
				tOffsetInput.name = "T_offset"
				tOffsetInput.type = "Seq(matrix(real,4,4))"
				solution.inputs.add(tOffsetInput)

				// Add individual B_i and T_offset_i inputs
				for (i : 1 ..< n + 1) {
					val biInput = new Local()
					biInput.name = "B_" + i
					biInput.type = "matrix(real,4,4)"
					solution.inputs.add(biInput)

					val tOffsetKInput = new Local()
					tOffsetKInput.name = "T_offset_" + i
					tOffsetKInput.type = "matrix(real,4,4)"
					solution.inputs.add(tOffsetKInput)
				}

				// Add T_geom_k initial constraints (from p-model)
				for (i : 1 ..< n + 1) {
					val tGeomInitConstraint = "(T_geom_" + i + ")[t == 0] == zeroMat(4,4)"
					val tGeomInitLhsPattern = "\\(\\s*T_geom_" + i + "\\s*\\)\\s*\\[\\s*t\\s*==\\s*0\\s*\\]"
					val existingTGeomInit = solution.constraints.findFirst[c |
						val eqIndex = c.indexOf("==")
						eqIndex > 0 && c.substring(0, eqIndex).trim.matches(tGeomInitLhsPattern)
					]
					if (existingTGeomInit === null) {
						solution.constraints.add(tGeomInitConstraint)
					}
				}

				// Add T_geom_k algebraic constraints: T_geom_k = B_k * T_offset_k
				for (i : 1 ..< n + 1) {
					val tGeomAlgebraicConstraint = "(T_geom_" + i + ")[t == t] == B_" + i + " * T_offset_" + i
					val tGeomAlgebraicLhsPattern = "\\(\\s*T_geom_" + i + "\\s*\\)\\s*\\[\\s*t\\s*==\\s*t\\s*\\]"
					val existingTGeomAlgebraic = solution.constraints.findFirst[c |
						val eqIndex = c.indexOf("==")
						eqIndex > 0 && c.substring(0, eqIndex).trim.matches(tGeomAlgebraicLhsPattern)
					]
					if (existingTGeomAlgebraic === null) {
						solution.constraints.add(tGeomAlgebraicConstraint)
					}
				}

				// Add T_geom sequence aggregate constraint
				val tGeomList = (1..n).map["T_geom_" + it].join(", ")
				val tGeomAggregateConstraint = "(T_geom)[t == t] == <" + tGeomList + ">"
				val tGeomLhsPattern = "\\(\\s*T_geom\\s*\\)\\s*\\[\\s*t\\s*==\\s*t\\s*\\]"
				val existingTGeom = solution.constraints.findFirst[c |
					val eqIndex = c.indexOf("==")
					eqIndex > 0 && c.substring(0, eqIndex).trim.matches(tGeomLhsPattern)
				]
				if (existingTGeom !== null) {
					solution.constraints.set(solution.constraints.indexOf(existingTGeom), tGeomAggregateConstraint)
				} else {
					solution.constraints.add(tGeomAggregateConstraint)
				}
			}
		}

		// Set method and errors
		solution.method = "Visualisation"
		solution.errors = new BasicEList<String>
		solution.errors.add("0")

		return solution
	}

	static def String asSolution(SlnRef solution) {
		'''
		Solution{
			state{ «solution.expression.name» : «LibUtils.simplifyType(solution.expression.type)» = «LibUtils.getInitalValue(solution.expression.name, solution.expression.type, solution)»
			       «LibUtils.getInputs(solution)»
			}
			computation{
				// T_geom_k = B_k * T_offset_k for each link
				«solution.expression.name» = «solution.expression.name»;
			}
		}
		'''
	}
}

/**
 * ViscousDamping method - computes damping torque tau_d = damping * d_theta
 */
static class ViscousDamping {
	static def SolutionRef asReference(SolutionRef solution) {
		// Set method name
		solution.method = "ViscousDamping"
		solution.iterations = 1

		// Set expression type if not already set
		if (solution.expression === null) {
			solution.expression = new Local()
			solution.expression.name = "tau_d"
		}
		val exprSize = if (solution.expression?.type !== null) getVectorSize(solution.expression.type) else -1
		val dof = if (exprSize > 0) exprSize else 2
		solution.expression.type = "vector(real," + dof + ")"

		// Initialize constraints and inputs if null
		if (solution.constraints === null) {
			solution.constraints = new BasicEList<String>()
		}
		solution.inputs = new BasicEList<Local>()

		// Add tau_d initial constraint
		solution.constraints.add("(tau_d)[t == 0] == zeroVec(" + dof + ")")

		// Add damping coefficient constraint
		solution.constraints.add("(damping)[t == 0] == zeroMat(" + dof + "," + dof + ")")

		// Add damping coefficient input
		var i1 = new Local()
		i1.name = "damping"
		i1.type = "matrix(real," + dof + "," + dof + ")"
		solution.inputs.add(i1)

		// Add d_theta input
		var i2 = new Local()
		i2.name = "d_theta"
		i2.type = "vector(real," + dof + ")"
		solution.inputs.add(i2)

		// Add dt input
		var i3 = new Local()
		i3.name = "dt"
		i3.type = "real"
		solution.inputs.add(i3)

		// Add errors
		solution.errors = new BasicEList<String>()
		solution.errors.add("0")

		return solution
	}
}

def static String simplifyType(String input) {
	return LibUtils.simplifyType(input)
}

// SolutionRef utils
def static String getInitalValue(String expression, SolutionRef solution){
	// Pattern handles optional spaces inside parentheses: "( n )" or "(n)"
	val pattern = Pattern.compile("\\(\\s*" + expression + "\\s*\\)\\s*\\[\\s*t\\s*==\\s*0\\s*\\]\\s*==\\s*(.+)")

		val IC = solution.constraints.findFirst[ constraint | 
			pattern.matcher(constraint as String).find() 
		]
		if (IC === null) {
			throw new IllegalStateException('No initial value found for expression: ' + expression)
		}
		// Create a new matcher instance for the matched constraint value.
		val matcher = pattern.matcher(IC as String)
		if (!matcher.find()) {
			throw new IllegalStateException("Pattern did not match the constraint value: " + IC)
		}
		val IC_value = matcher.group(1).trim()
		return IC_value
}


def static List<Integer> getMatrixSize(String expression) {
	return LibUtils.getMatrixSize(expression)
}

def static int getVectorSize(String expression) {
	val size = LibUtils.getVectorSize(expression)
	return if (size == 0) -1 else size
}
// SlnRef utils - delegating to LibUtils for shared functionality

def static String getInitalValue(String name, String type, SlnRef solution) {
    return LibUtils.getInitalValue(name, type, solution)
}

def static String getInputs(SlnRef solution) {
    return LibUtils.getInputs(solution)
}

}
