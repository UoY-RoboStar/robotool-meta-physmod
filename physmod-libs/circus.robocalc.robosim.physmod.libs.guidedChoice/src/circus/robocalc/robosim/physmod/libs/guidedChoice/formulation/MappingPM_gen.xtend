package circus.robocalc.robosim.physmod.libs.guidedChoice.formulation

import org.eclipse.emf.common.util.BasicEList
import circus.robocalc.robosim.physmod.libs.guidedChoice.solutionLib.SolutionRef
import circus.robocalc.robosim.physmod.libs.guidedChoice.solutionLib.Local
import circus.robocalc.robosim.physmod.slnRef.slnRef.SlnRef

import static circus.robocalc.robosim.physmod.libs.guidedChoice.formulation.LibUtils.*

/**
 * MappingPM_gen contains solution methods for mapping.pm file definitions.
 *
 * These methods handle the d-model to p-model interface mappings defined in mapping.pm files:
 * - MappingPM_Operation: maps d-model operations to p-model actuator inputs
 * - MappingPM_InputEvent: maps p-model sensor outputs to d-model input events
 *
 * This is distinct from Mapping_gen which handles p-model to platform interface mappings.
 * The relationship is: d-model <-> p-model <-> platform
 *   - MappingPM_gen handles: d-model <-> p-model (from mapping.pm)
 *   - Mapping_gen handles: p-model <-> platform (from p-model solutions)
 */
class MappingPM_gen {

    /**
     * MappingPM_Operation: handles d-model operation to p-model actuator mappings.
     *
     * This method processes constraints from mapping.pm OperationMapping definitions,
     * which establish how RoboChart operations (e.g., ApplyTorque) map to p-model
     * actuator control inputs.
     *
     * Example constraint from mapping.pm:
     *   operation ApplyTorque {
     *       equation AcrobotControlled::Link1::ElbowJoint::ElbowMotor.ControlIn == tau
     *   }
     *
     * The expression name is the operation name (e.g., "ApplyTorque").
     * The constraints establish the relationship between operation parameters and actuator ports.
     */
    static class MappingPM_Operation {
        static def SolutionRef asReference(SolutionRef solution) {
            // Ensure method has the correct name
            solution.method = "MappingPM_Operation"

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

            // Default constraints - initialize to zero at t=0
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
     * MappingPM_InputEvent: handles p-model sensor to d-model input event mappings.
     *
     * This method processes constraints from mapping.pm InputEventMapping definitions,
     * which establish how p-model sensor outputs map to RoboChart input events.
     *
     * Example constraint from mapping.pm:
     *   input event shoulderAngle?sa {
     *       equation sa == AcrobotControlled::BaseLink::ShoulderEncoder.AngleOut
     *   }
     *
     * The expression name is the event name (e.g., "shoulderAngle").
     * The constraints establish the relationship between sensor outputs and event parameters.
     */
    static class MappingPM_InputEvent {
        static def SolutionRef asReference(SolutionRef solution) {
            // Ensure method has the correct name
            solution.method = "MappingPM_InputEvent"

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

            // Default constraints - initialize to zero at t=0
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
}
