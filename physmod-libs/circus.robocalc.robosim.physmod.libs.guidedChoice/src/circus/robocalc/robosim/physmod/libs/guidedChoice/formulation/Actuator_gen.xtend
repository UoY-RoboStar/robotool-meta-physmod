package circus.robocalc.robosim.physmod.libs.guidedChoice.formulation

import org.eclipse.emf.common.util.BasicEList
import circus.robocalc.robosim.physmod.libs.guidedChoice.solutionLib.SolutionRef
import circus.robocalc.robosim.physmod.libs.guidedChoice.solutionLib.Local
import circus.robocalc.robosim.physmod.slnRef.slnRef.SlnRef

import static circus.robocalc.robosim.physmod.libs.guidedChoice.formulation.LibUtils.*

/**
 * Actuator_gen contains formulation-agnostic actuator control methods.
 *
 * This library handles control input transformations that are independent of
 * the specific dynamics formulation (SKO, Featherstone, etc.):
 * - ControlledActuator: transforms control inputs u to torques tau via B_ctrl matrix
 *
 * The control input relationship is: tau = B_ctrl * u
 * where:
 * - u is the external control input vector (from p_mapping.*.ControlIn)
 * - B_ctrl is the control input matrix (composed from local actuator B_ctrl_i terms)
 * - tau is the joint torque vector (used by dynamics equations)
 *
 * For actuators without B_ctrl (e.g., TrivialMotor), tau = u directly.
 */
class Actuator_gen {

    /**
     * ControlledActuator method for B_ctrl-based control input transformation.
     *
     * This method generates:
     * 1. System B_ctrl matrix variable declaration
     * 2. Composition constraints: submatrix(B_ctrl)(i,i,1,1) == B_ctrl_i
     * 3. Control input relationship: tau = B_ctrl * u
     *
     * Example constraints for a 2-DOF robot:
     *   (B_ctrl) [t == 0] == [[B_ctrl_1, 0], [0, B_ctrl_2]]
     *   (tau) [t == t] == B_ctrl * u
     *   (u(0)) [t == t] == p_mapping.RobotName.Joint1.Actuator1.ControlIn
     *   (u(1)) [t == t] == p_mapping.RobotName.Joint2.Actuator2.ControlIn
     *
     * Users must specify:
     * - Local B_ctrl_i values for each actuator
     * - Mapping constraints from u to p_mapping.*.ControlIn
     */
    static class ControlledActuator {
        static def SolutionRef asReference(SolutionRef solution) {
            // Ensure method has the correct name
            solution.method = "ControlledActuator"

            val exprName = solution.expression.name
            val exprType = solution.expression.type

            // Preprocessing
            solution.iteration = solution.iteration + 1

            // Get vector size from expression type
            var N = 2 // default for acrobot
            try {
                N = getVectorSize(exprType)
            } catch (Exception e) {
                // Use default if parsing fails
            }

            if (solution.constraints === null) {
                solution.constraints = new BasicEList<String>
            }

            solution.iterations = 3

            // Default constraints for tau computation: tau = B_ctrl * u
            // Works for any expression name (tau, tau_sol, etc.)
            if (solution.iteration == 1) {
                // Initialize expression to zero
                solution.constraints.add("(" + exprName + ")[t == 0] == zeroVec(" + N + ")")
            }
            if (solution.iteration == 2) {
                // B_ctrl is provided as input constraint in the p-model
                // Nothing to add here - B_ctrl constraints come from model
            }
            if (solution.iteration == 3) {
                // Control input relationship: output = B_ctrl * u
                solution.constraints.add("(" + exprName + ")[t == t] == B_ctrl * u")
            }

            // Append errors
            solution.errors = new BasicEList<String>
            solution.errors.add("0")

            // Add inputs
            if (solution.inputs === null) {
                solution.inputs = new BasicEList<Local>
            }

            // Add B_ctrl as input (control input matrix)
            var Local bctrlInput = solution.inputs.findFirst(element | element.name == "B_ctrl")
            if (bctrlInput === null) {
                bctrlInput = new Local()
                bctrlInput.name = "B_ctrl"
                // B_ctrl maps from control inputs to joint torques
                // For acrobot: 2 joints, 1 control input, so B_ctrl is (2,1)
                bctrlInput.type = "matrix(real," + N + ",1)"
                solution.inputs.add(bctrlInput)
            }

            // Add u as input (control input vector from PlatformMapping)
            var Local uInput = solution.inputs.findFirst(element | element.name == "u")
            if (uInput === null) {
                uInput = new Local()
                uInput.name = "u"
                uInput.type = "vector(real,1)"
                solution.inputs.add(uInput)
            }

            // Add the expression variable itself as input (for initial condition binding)
            var Local exprInput = solution.inputs.findFirst(element | element.name == exprName)
            if (exprInput === null) {
                exprInput = new Local()
                exprInput.name = exprName
                exprInput.type = exprType
                solution.inputs.add(exprInput)
            }

            return solution
        }

        static def String asSolution(SlnRef solution) {
            val IC_value = getInitalValue(solution.expression.name, solution.expression.type, solution)

            '''
            Solution{
                state{ «solution.expression.name» : «simplifyType(solution.expression.type)» = «IC_value»
                        «getInputs(solution)»
                }
                computation{
                    «IF solution.expression.name == "tau"»
                    «solution.expression.name» = B_ctrl * u;
                    «ELSE»
                    «solution.expression.name» = «solution.expression.name»;
                    «ENDIF»
                }
            }
            '''
        }
    }

    /**
     * Generates diagonal block composition constraints for B_ctrl matrix.
     *
     * For n actuators with scalar B_ctrl_i values, generates:
     *   (submatrix(B_ctrl)(0,0,1,1)) [t == 0] == B_ctrl_1
     *   (submatrix(B_ctrl)(1,1,1,1)) [t == 0] == B_ctrl_2
     *   ...
     *
     * @param numActuators the number of actuators (size of B_ctrl matrix)
     * @return list of constraint strings
     */
    static def generateBCtrlCompositionConstraints(int numActuators) {
        val constraints = new BasicEList<String>

        for (var i = 0; i < numActuators; i++) {
            val constraint = "(submatrix(B_ctrl)(" + i + "," + i + ",1,1)) [t == 0] == B_ctrl_" + (i + 1)
            constraints.add(constraint)
        }

        return constraints
    }
}
