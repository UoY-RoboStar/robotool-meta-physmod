package circus.robocalc.robosim.physmod.libs.sourceCodeGen.formulation

import circus.robocalc.robosim.physmod.libs.sourceCodeGen.solutionLib.SolutionRef
import circus.robocalc.robosim.physmod.slnRef.slnRef.SlnRef
import static circus.robocalc.robosim.physmod.libs.sourceCodeGen.libUtils.libUtils.*

class Vis {
    static class GeomExtraction {
        static def SolutionRef asReference(SolutionRef solution) {
            solution.method = "GeomExtraction"
            return solution
        }

        static def String asSolution(SlnRef solution) {
            // GeomExtraction formulation: extract Geom records from platform model constraints
            // and decompose them into primitive types for Solution DSL state

            // Extract initial value constraints for Geom variables
            val geomConstraints = solution.constraints.filter[c |
                c.value.contains("geom_") && (c.value.contains("[t == 0]") || c.value.contains("[ t == 0]"))
            ].toList

            // Build state variable declarations from geom constraints
            // Decompose Geom records into primitive types that Solution DSL supports
            val stateDecls = new StringBuilder()
            for (constraint : geomConstraints) {
                // Parse constraint to extract variable name and Geom record
                // Format: (geom_ij) [t == 0] == Geom (| geomType = "..." , geomVal = [...] |)
                val constraintStr = constraint.value.trim

                // Extract variable name (between first '(' and ')')
                val startParen = constraintStr.indexOf('(')
                val endParen = constraintStr.indexOf(')')
                if (startParen >= 0 && endParen > startParen) {
                    val varName = constraintStr.substring(startParen + 1, endParen).trim

                    // Extract the Geom record value (everything after the last '==')
                    val assignmentPos = constraintStr.lastIndexOf("==")
                    if (assignmentPos > 0) {
                        val geomValue = constraintStr.substring(assignmentPos + 2).trim

                        // Parse Geom record: Geom (| geomType = "..." , geomVal = [...] |)
                        val geomTypeMatch = geomValue.indexOf("geomType")
                        val geomValMatch = geomValue.indexOf("geomVal")

                        if (geomTypeMatch > 0 && geomValMatch > 0) {
                            // Extract geomType value (quoted string)
                            val typeStart = geomValue.indexOf('"', geomTypeMatch)
                            val typeEnd = geomValue.indexOf('"', typeStart + 1)
                            if (typeStart > 0 && typeEnd > typeStart) {
                                val geomType = geomValue.substring(typeStart + 1, typeEnd)

                                // Extract geomVal vector [| ... |] and convert to Solution DSL syntax [ ... ]
                                val valStart = geomValue.indexOf("[|", geomValMatch)
                                val valEnd = geomValue.indexOf("|]", valStart)
                                if (valStart > 0 && valEnd > valStart) {
                                    // Extract content between [| and |]
                                    val vectorContent = geomValue.substring(valStart + 2, valEnd).trim
                                    // Convert to Solution DSL vector syntax
                                    val geomValSolutionDSL = "[" + vectorContent + "]"

                                    // Count dimensions for vec type
                                    val dimCount = if (vectorContent.isEmpty) 0 else vectorContent.split(",").length

                                    // Generate decomposed state variables
                                    stateDecls.append("        ").append(varName).append("_type : string = \"").append(geomType).append("\";\n")
                                    stateDecls.append("        ").append(varName).append("_dims : vec(").append(dimCount).append(") = ").append(geomValSolutionDSL).append(";\n")
                                }
                            }
                        }
                    }
                }
            }

            '''
            Solution geom_extraction {
                datatypes {
                    Geom { geomType: String; geomVal: vec(); meshUri: String; meshScale: vec() }
                }

                state {
«stateDecls.toString()»
                }

                procedures {
                }

                functions {
                }

                computation {
                    // Geom records are constant, no computation needed
                }
            }
            '''
        }
    }

    static class Visual {
        static def SolutionRef asReference(SolutionRef solution) {
            solution.method = "Visual"
            return solution
        }

        static def String asSolution(SlnRef solution) {
            // Visual formulation: purely declarative - just state definitions for visualization
            // The visualization system will read these values directly, no computation needed

            // Build state variables, handling Geom types specially
            val stateVars = new StringBuilder()
            
            // First, add the expression (T_geom) as the primary output state variable
            if (solution.expression !== null) {
                val exprName = solution.expression.name
                val exprType = simplifyType(solution.expression.type)
                var exprInit = getInitalValue(exprName, solution)
                // Convert sequence syntax <...> to seq(...) for Solution DSL compatibility
                if (exprInit !== null && exprInit.startsWith("<") && exprInit.endsWith(">")) {
                    val seqContent = exprInit.substring(1, exprInit.length - 1).trim
                    // Skip empty sequences - they can't be represented in Solution DSL
                    if (seqContent.isEmpty) {
                        exprInit = null
                    } else {
                        exprInit = "seq(" + seqContent + ")"
                    }
                }
                // Also skip seq() with empty content - invalid syntax
                if (exprInit !== null && exprInit.equals("seq()")) {
                    exprInit = null
                }
                if (exprInit !== null) {
                    stateVars.append("        ").append(exprName).append(" : ").append(exprType).append(" = ").append(exprInit).append(";\n")
                }
            }
            
            // Then add all inputs except the expression (which was already added)
            for (input : solution.inputs) {
                val isExpr = solution.expression !== null && input.value.name == solution.expression.name
                if (!isExpr) {
                    val varName = input.value.name
                    val varType = simplifyType(input.value.type)

                    // Special handling for Geom types - build record initializer from field constraints
                    if (varType.equals("Geom")) {
                        val geomInit = buildGeomInitializer(varName, solution)
                        stateVars.append("        ").append(varName).append(" : Geom = ").append(geomInit).append(";\n")
                    } else {
                        var initVal = getInitalValue(varName, solution)
                        // Convert sequence syntax <...> to seq(...) for Solution DSL compatibility
                        if (initVal !== null && initVal.startsWith("<") && initVal.endsWith(">")) {
                            val seqContent = initVal.substring(1, initVal.length - 1).trim
                            // Skip empty sequences - they can't be represented in Solution DSL
                            if (seqContent.isEmpty) {
                                initVal = null
                            } else {
                                initVal = "seq(" + seqContent + ")"
                            }
                        }
                        // Also skip seq() with empty content - invalid syntax
                        if (initVal !== null && initVal.equals("seq()")) {
                            initVal = null
                        }
                        if (initVal !== null) {
                            stateVars.append("        ").append(varName).append(" : ").append(varType).append(" = ").append(initVal).append(";\n")
                        }
                    }
                }
            }

            '''
            Solution physics_standalone_visual {
                datatypes {
                    Geom { geomType: string; geomVal: vec(); meshUri: string; meshScale: vec() }
                }

                state {
                    // Input state from slnRef
«stateVars.toString()»
                }

                computation {
                    // Empty - visualization is purely declarative
                }
            }
            '''
        }

        /** Build Geom record initializer from field constraints */
        static def String buildGeomInitializer(String varName, SlnRef solution) {
            val typePattern = java.util.regex.Pattern.compile(
                "\\(\\s*" + varName + "\\s*\\.\\s*geomType\\s*\\)\\s*\\[\\s*t\\s*==\\s*0\\s*\\]\\s*==\\s*(.+)"
            )
            val valPattern = java.util.regex.Pattern.compile(
                "\\(\\s*" + varName + "\\s*\\.\\s*geomVal\\s*\\)\\s*\\[\\s*t\\s*==\\s*0\\s*\\]\\s*==\\s*\\[\\|(.+?)\\|\\]"
            )
            val meshUriPattern = java.util.regex.Pattern.compile(
                "\\(\\s*" + varName + "\\s*\\.\\s*meshUri\\s*\\)\\s*\\[\\s*t\\s*==\\s*0\\s*\\]\\s*==\\s*(.+)"
            )
            val meshScalePattern = java.util.regex.Pattern.compile(
                "\\(\\s*" + varName + "\\s*\\.\\s*meshScale\\s*\\)\\s*\\[\\s*t\\s*==\\s*0\\s*\\]\\s*==\\s*\\[\\|(.+?)\\|\\]"
            )

            var String geomType = null
            var String geomVal = null
            var String meshUri = null
            var String meshScale = null

            for (constraint : solution.constraints) {
                val constraintStr = constraint.value as String
                val typeMatcher = typePattern.matcher(constraintStr)
                if (typeMatcher.find()) {
                    geomType = normalizeStringLiteral(typeMatcher.group(1).trim())
                }
                val valMatcher = valPattern.matcher(constraintStr)
                if (valMatcher.find()) {
                    geomVal = "[" + valMatcher.group(1).trim().replaceAll("\\s+", " ") + "]"
                }
                val uriMatcher = meshUriPattern.matcher(constraintStr)
                if (uriMatcher.find()) {
                    meshUri = normalizeStringLiteral(uriMatcher.group(1).trim())
                }
                val scaleMatcher = meshScalePattern.matcher(constraintStr)
                if (scaleMatcher.find()) {
                    meshScale = "[" + scaleMatcher.group(1).trim().replaceAll("\\s+", " ") + "]"
                }
            }

            if (geomType !== null && geomVal !== null) {
                val meshUriValue = if (meshUri !== null) meshUri else "\"\""
                val meshScaleValue = if (meshScale !== null) meshScale else "[1.0]"
                return '''Geom { geomType = «geomType», geomVal = «geomVal», meshUri = «meshUriValue», meshScale = «meshScaleValue» }'''
            }

            return "Geom { geomType = \"\", geomVal = [0.0], meshUri = \"\", meshScale = [1.0] }"
        }

        private static def String normalizeStringLiteral(String value) {
            val trimmed = value.trim
            if (trimmed.startsWith("\"") && trimmed.endsWith("\"")) {
                return trimmed
            }
            return "\"" + trimmed + "\""
        }
    }
}
