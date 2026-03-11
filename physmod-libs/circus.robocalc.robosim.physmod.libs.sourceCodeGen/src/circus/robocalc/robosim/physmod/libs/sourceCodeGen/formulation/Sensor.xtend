package circus.robocalc.robosim.physmod.libs.sourceCodeGen.formulation

import circus.robocalc.robosim.physmod.libs.sourceCodeGen.solutionLib.SolutionRef
import circus.robocalc.robosim.physmod.slnRef.slnRef.SlnRef
import static circus.robocalc.robosim.physmod.libs.sourceCodeGen.libUtils.libUtils.*
import static circus.robocalc.robosim.physmod.libs.sourceCodeGen.formulation.SKO.getInitalValue

// Formulation-agnostic sensor methods: extract joint state for p_mapping output.
class Sensor {

    // Reads theta[i] and outputs to sensor AngleOut.
    static class JointEncoderAngle {
        static def SolutionRef asReference(SolutionRef solution) {
            solution.method = "JointEncoderAngle"
            return solution
        }

        static def String asSolution(SlnRef solution) {
            val exprName = solution.expression.name
            val exprType = simplifyType(solution.expression.type)
            val IC_value = getInitalValue(exprName, solution.expression.type, solution)

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

            // Extract sensor path and index from constraints
            // Constraints have form: (Link.Sensor.ThetaIn) [ t == t] ==theta(i)
            var sensorPath = ""
            var thetaIndex = "0"
            if (solution.constraints !== null) {
                for (constraint : solution.constraints) {
                    val constraintStr = constraint.value
                    if (constraintStr.contains("ThetaIn") && constraintStr.contains("theta(")) {
                        // Extract sensor path (everything before .ThetaIn)
                        val pathPattern = java.util.regex.Pattern.compile("\\(([^)]+\\.ThetaIn)\\)")
                        val pathMatcher = pathPattern.matcher(constraintStr)
                        if (pathMatcher.find()) {
                            sensorPath = pathMatcher.group(1).replace(".ThetaIn", "")
                        }
                        // Extract theta index
                        val indexPattern = java.util.regex.Pattern.compile("theta\\((\\d+)\\)")
                        val indexMatcher = indexPattern.matcher(constraintStr)
                        if (indexMatcher.find()) {
                            thetaIndex = indexMatcher.group(1)
                        }
                    }
                }
            }

            // Generate the sensor path variable name (replace . with _)
            val sensorVarName = sensorPath.replace(".", "_") + "_AngleOut"

            '''
            Solution joint_encoder_angle {
                state {
                    «exprName» : float = 0.0;
                    «sensorVarName» : float = 0.0;
«inputDecls.toString()»                }

                computation {
                    «exprName» = theta[«thetaIndex»];
                    «sensorVarName» = «exprName»;
                }
            }
            '''
        }
    }

    // Reads d_theta[i] and outputs to sensor VelocityOut.
    static class JointEncoderVelocity {
        static def SolutionRef asReference(SolutionRef solution) {
            solution.method = "JointEncoderVelocity"
            return solution
        }

        static def String asSolution(SlnRef solution) {
            val exprName = solution.expression.name
            val exprType = simplifyType(solution.expression.type)
            val IC_value = getInitalValue(exprName, solution.expression.type, solution)

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

            // Extract sensor path and index from constraints
            // Constraints have form: (Link.Sensor.DThetaIn) [ t == t] ==d_theta(i)
            var sensorPath = ""
            var dthetaIndex = "0"
            if (solution.constraints !== null) {
                for (constraint : solution.constraints) {
                    val constraintStr = constraint.value
                    if (constraintStr.contains("DThetaIn") && constraintStr.contains("d_theta(")) {
                        // Extract sensor path (everything before .DThetaIn)
                        val pathPattern = java.util.regex.Pattern.compile("\\(([^)]+\\.DThetaIn)\\)")
                        val pathMatcher = pathPattern.matcher(constraintStr)
                        if (pathMatcher.find()) {
                            sensorPath = pathMatcher.group(1).replace(".DThetaIn", "")
                        }
                        // Extract d_theta index
                        val indexPattern = java.util.regex.Pattern.compile("d_theta\\((\\d+)\\)")
                        val indexMatcher = indexPattern.matcher(constraintStr)
                        if (indexMatcher.find()) {
                            dthetaIndex = indexMatcher.group(1)
                        }
                    }
                }
            }

            // Generate the sensor path variable name (replace . with _)
            val sensorVarName = sensorPath.replace(".", "_") + "_VelocityOut"

            '''
            Solution joint_encoder_velocity {
                state {
                    «exprName» : float = 0.0;
                    «sensorVarName» : float = 0.0;
«inputDecls.toString()»                }

                computation {
                    «exprName» = d_theta[«dthetaIndex»];
                    «sensorVarName» = «exprName»;
                }
            }
            '''
        }
    }
}
