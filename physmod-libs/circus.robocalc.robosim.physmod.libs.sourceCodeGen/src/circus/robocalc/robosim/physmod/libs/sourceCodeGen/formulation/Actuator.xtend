package circus.robocalc.robosim.physmod.libs.sourceCodeGen.formulation

import circus.robocalc.robosim.physmod.libs.sourceCodeGen.solutionLib.SolutionRef
import circus.robocalc.robosim.physmod.slnRef.slnRef.SlnRef
import static circus.robocalc.robosim.physmod.libs.sourceCodeGen.libUtils.libUtils.*
import static circus.robocalc.robosim.physmod.libs.sourceCodeGen.formulation.SKO.getInitalValue

// Formulation-agnostic actuator control methods: tau = B_ctrl * u (or tau = u if no B_ctrl).
class Actuator {

    // Generates tau = B_ctrl * u computation.
    static class ControlledActuator {
        static def SolutionRef asReference(SolutionRef solution) {
            solution.method = "ControlledActuator"
            return solution
        }

        static def String asSolution(SlnRef solution) {
            val exprName = solution.expression.name
            val exprType = simplifyType(solution.expression.type)
            val IC_value = getInitalValue(exprName, solution.expression.type, solution)

            // Determine vector size from type
            var vecSize = 2 // default
            val typePattern = java.util.regex.Pattern.compile("vector\\s*\\(\\s*[^,]+\\s*,\\s*(\\d+)\\s*\\)")
            val typeMatcher = typePattern.matcher(solution.expression.type)
            if (typeMatcher.find()) {
                vecSize = Integer.parseInt(typeMatcher.group(1).trim)
            }

            // Check if B_ctrl and u inputs are present
            var hasBCtrl = false
            var hasU = false
            if (solution.inputs !== null) {
                for (input : solution.inputs) {
                    if (input.value.name == "B_ctrl") hasBCtrl = true
                    if (input.value.name == "u") hasU = true
                }
            }

            // Build input declarations from solution inputs
            val inputDecls = new StringBuilder()
            if (solution.inputs !== null) {
                for (input : solution.inputs) {
                    val inputName = input.value.name
                    val inputType = simplifyType(input.value.type)
                    val inputInit = getInitalValue(inputName, input.value.type, solution)
                    inputDecls.append("        ").append(inputName).append(" : ").append(inputType)
                    inputDecls.append(" = ").append(inputInit).append(";\n")
                }
            }

            // Generate computation based on available inputs
            // If no B_ctrl/u inputs, this is a placeholder - actual tau comes from PlatformMapping
            val computation = if (hasBCtrl && hasU) {
                exprName + " = B_ctrl * u;"
            } else if (hasU) {
                // Direct pass-through: tau = u
                exprName + " = u;"
            } else {
                // No inputs - this is just a marker block, tau populated elsewhere
                "skip;"
            }

            '''
            Solution controlled_actuator {
                state {
                    «exprName» : «exprType» = «IC_value»;
«inputDecls.toString()»                }

                computation {
                    «computation»
                }
            }
            '''
        }
    }
}
