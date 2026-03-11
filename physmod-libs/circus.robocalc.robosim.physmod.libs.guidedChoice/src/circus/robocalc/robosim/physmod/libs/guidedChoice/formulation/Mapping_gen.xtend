package circus.robocalc.robosim.physmod.libs.guidedChoice.formulation

import org.eclipse.emf.common.util.BasicEList
import circus.robocalc.robosim.physmod.libs.guidedChoice.solutionLib.SolutionRef
import circus.robocalc.robosim.physmod.libs.guidedChoice.solutionLib.Local
import circus.robocalc.robosim.physmod.slnRef.slnRef.SlnRef

import static circus.robocalc.robosim.physmod.libs.guidedChoice.formulation.LibUtils.*

/**
 * Mapping_gen contains formulation-agnostic interface mapping methods.
 * 
 * Unlike formulation-specific methods (e.g., SKO_gen, Featherstone_gen), these mapping
 * methods work identically regardless of which physics formulation is being used.
 */
class Mapping_gen {

    /**
     * PlatformMapping method for actuator input mappings (p_mapping).
     *
     * This method generates constraints that establish the correspondence between
     * system-level variables and platform-specific actuator ports.
     *
     * Works for any expression name (tau, u, etc.) - user provides the mapping
     * constraints in the input solution block.
     *
     * Example constraints:
     *   (u(0)) [t == t] == p_mapping.RobotName.LinkName.ActuatorName.ControlIn
     *   (tau(0)) [t == t] == p_mapping.RobotName.LinkName.ActuatorName.TorqueIn
     *
     * The p_mapping prefix indicates values provided by the d-model (controller)
     * through the platform mapping interface at runtime.
     */
    static class PlatformMapping {
        static def SolutionRef asReference(SolutionRef solution) {
            // Ensure method has the correct name
            solution.method = "PlatformMapping"

            val exprName = solution.expression.name
            val exprType = solution.expression.type

            // Preprocessing
            solution.iteration = solution.iteration + 1

            if (solution.constraints === null) {
                solution.constraints = new BasicEList<String>
            }

            // Determine vector size for initialization (if applicable)
            var N = 1
            try {
                N = getVectorSize(exprType)
            } catch (Exception e) {
                // Not a vector type, use scalar initialization
                N = 0
            }

            solution.iterations = 2

            // Default constraints - initialize to zero
            if (solution.iteration == 1) {
                if (N > 0) {
                    solution.constraints.add("(" + exprName + ")[t == 0] == zeroVec(" + N + ")")
                } else {
                    solution.constraints.add("(" + exprName + ")[t == 0] == 0")
                }
            }

            // Append errors
            solution.errors = new BasicEList<String>
            solution.errors.add("0")

            // Add the expression variable as an input (so constraint binding works)
            if (solution.inputs === null) {
                solution.inputs = new BasicEList<Local>
            }
            // Add expression itself as an input if not already present
            if (!solution.inputs.exists[name == exprName]) {
                val input_expr = new Local()
                input_expr.name = exprName
                input_expr.type = exprType
                solution.inputs.add(input_expr)
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
                computation{«solution.expression.name» = «solution.expression.name»;}
            }
            '''
        }
    }

    /**
     * WorldMapping method for sensor input mappings (w_mapping).
     *
     * This method generates constraints that establish the correspondence between
     * system-level variables and world engine sensor ports.
     *
     * Works for any expression name - user provides the mapping constraints
     * in the input solution block.
     *
     * Example constraints:
     *   (sensor(0)) [t == t] == w_mapping.RobotName.LinkName.SensorName.SignalIn
     *
     * The w_mapping prefix indicates values provided by the world engine
     * (environment simulation) through the world mapping interface.
     */
    static class WorldMapping {
        static def SolutionRef asReference(SolutionRef solution) {
            // Ensure method has the correct name
            solution.method = "WorldMapping"

            val exprName = solution.expression.name
            val exprType = solution.expression.type

            // Preprocessing
            solution.iteration = solution.iteration + 1

            if (solution.constraints === null) {
                solution.constraints = new BasicEList<String>
            }

            // Determine vector size for initialization (if applicable)
            var N = 1
            try {
                N = getVectorSize(exprType)
            } catch (Exception e) {
                // Not a vector type, use scalar initialization
                N = 0
            }

            solution.iterations = 2

            // Default constraints - initialize to zero
            if (solution.iteration == 1) {
                if (N > 0) {
                    solution.constraints.add("(" + exprName + ")[t == 0] == zeroVec(" + N + ")")
                } else {
                    solution.constraints.add("(" + exprName + ")[t == 0] == 0")
                }
            }

            // Append errors
            solution.errors = new BasicEList<String>
            solution.errors.add("0")

            // Add the expression variable as an input (so constraint binding works)
            if (solution.inputs === null) {
                solution.inputs = new BasicEList<Local>
            }
            // Add expression itself as an input if not already present
            if (!solution.inputs.exists[name == exprName]) {
                val input_expr = new Local()
                input_expr.name = exprName
                input_expr.type = exprType
                solution.inputs.add(input_expr)
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
                computation{«solution.expression.name» = «solution.expression.name»;}
            }
            '''
        }
    }

    /**
     * SensorOutputMapping method for sensor output mappings (p_mapping outputs).
     *
     * This method generates constraints that establish the correspondence between
     * physics state variables (theta, d_theta) and sensor output ports.
     *
     * Example constraints for JointEncoder sensors:
     *   (p_mapping.RobotName.LinkName.SensorName.AngleOut) [t == t] == theta(0)
     *   (p_mapping.RobotName.LinkName.SensorName.VelocityOut) [t == t] == d_theta(0)
     *
     * The p_mapping prefix indicates values exposed to the d-model (controller)
     * through the platform mapping interface at runtime.
     */
    static class SensorOutputMapping {
        static def SolutionRef asReference(SolutionRef solution) {
            // Ensure method has the correct name
            solution.method = "SensorOutputMapping"

            // Preprocessing
            solution.iteration = solution.iteration + 1

            if (solution.constraints === null) {
                solution.constraints = new BasicEList<String>
            }

            solution.iterations = 1

            // Append errors
            solution.errors = new BasicEList<String>
            solution.errors.add("0")

            // Add theta and d_theta as inputs (the state variables being mapped to sensors)
            if (solution.inputs === null) {
                solution.inputs = new BasicEList<Local>
            }

            // Add theta input if not present
            if (!solution.inputs.exists[name == "theta"]) {
                val theta_input = new Local()
                theta_input.name = "theta"
                theta_input.type = "vector(real,2)"
                solution.inputs.add(theta_input)
            }

            // Add d_theta input if not present
            if (!solution.inputs.exists[name == "d_theta"]) {
                val d_theta_input = new Local()
                d_theta_input.name = "d_theta"
                d_theta_input.type = "vector(real,2)"
                solution.inputs.add(d_theta_input)
            }

            return solution
        }

        static def String asSolution(SlnRef solution) {
            '''
            Solution{
                state{ «solution.expression.name» : «simplifyType(solution.expression.type)» = 0
                        «getInputs(solution)»
                }
                computation{
                    // Sensor outputs are mapped from physics state variables
                    // theta -> AngleOut, d_theta -> VelocityOut
                    «solution.expression.name» = «solution.expression.name»;
                }
            }
            '''
        }
    }
}

