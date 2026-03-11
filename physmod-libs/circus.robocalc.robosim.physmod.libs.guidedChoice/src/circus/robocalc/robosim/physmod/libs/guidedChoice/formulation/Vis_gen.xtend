package circus.robocalc.robosim.physmod.libs.guidedChoice.formulation

import org.eclipse.emf.common.util.EList
import org.eclipse.emf.common.util.BasicEList
import java.util.regex.Pattern
import java.io.StringReader
import circus.robocalc.robosim.physmod.libs.guidedChoice.solutionLib.SolutionRef
import circus.robocalc.robosim.physmod.libs.guidedChoice.solutionLib.Local
import circus.robocalc.robosim.physmod.slnRef.slnRef.SlnRef

// This class contains methods associated with the Vis formulation
class Vis_gen{

static class Visual{
	static def SolutionRef asReference(SolutionRef solution){

        solution.method = "Visual"
        solution.iteration = solution.iteration + 1
        
        var n = 0
        var Boolean setConstraints = false
        if (solution.constraints === null) {
            solution.constraints = new BasicEList<String>
            setConstraints = true
        }
        
        if (!setConstraints) {
            // Extract n from existing constraints
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
        
        // Second iteration: add inputs and B_k constraint
        if (solution.iteration == 2) {
            // Clear any existing inputs to prevent accumulation
            solution.inputs = new BasicEList<Local>
            
            if (n > 0) {
                // Add B_i inputs
                for (i : 1 ..< n+1) {
                    val bInput = new Local()
                    bInput.name = "B_" + i
                    bInput.type = "matrix(real,4,4)"
                    solution.inputs.add(bInput)
                }
                
                // Add geom inputs
                for (i : 1 ..< n+1) {
                    val geomInput = new Local()
                    geomInput.name = "L" + i + "_geom"
                    geomInput.type = "Geom"
                    solution.inputs.add(geomInput)
                }

                // Note: geomType/geomVal constraints are extracted by guidedChoiceGenerator from
                // either explicit constraints or RecordExp initial values in the p-model variables

                // Add B_k input only if B_k is NOT the solution expression
                if (solution.expression.name != "B_k") {
                    val bkInput = new Local()
                    bkInput.name = "B_k"
                    bkInput.type = "Seq(matrix(real,4,4))"
                    solution.inputs.add(bkInput)
                }
                
                // Add T_geom and T_offset inputs for formulation-agnostic visualization
                val tGeomInput = new Local()
                tGeomInput.name = "T_geom"
                tGeomInput.type = "Seq(matrix(real,4,4))"
                solution.inputs.add(tGeomInput)
                
                val tOffsetInput = new Local()
                tOffsetInput.name = "T_offset"
                tOffsetInput.type = "Seq(matrix(real,4,4))"
                solution.inputs.add(tOffsetInput)
                
                // Add individual T_geom_k and T_offset_k inputs
                for (i : 1 ..< n+1) {
                    val tGeomKInput = new Local()
                    tGeomKInput.name = "T_geom_" + i
                    tGeomKInput.type = "matrix(real,4,4)"
                    solution.inputs.add(tGeomKInput)
                    
                    val tOffsetKInput = new Local()
                    tOffsetKInput.name = "T_offset_" + i
                    tOffsetKInput.type = "matrix(real,4,4)"
                    solution.inputs.add(tOffsetKInput)
                }
                
                // Add X_J_k input
                val xjkInput = new Local()
                xjkInput.name = "X_J_k"
                xjkInput.type = "Seq(matrix(real,6,6))"
                solution.inputs.add(xjkInput)
                
                // Add system-level theta input (size equals number of joints n-1)
                val joints = if (n > 0) n - 1 else 0
                if (joints > 0) {
                    val thetaInput = new Local()
                    thetaInput.name = "theta"
                    thetaInput.type = "vector(real," + joints + ")"
                    solution.inputs.add(thetaInput)
                }

                // Add per-link B_i initial constraints only if they don't already exist
                for (i : 1 ..< n+1) {
                    val biConstraint = "(B_" + i + ")[t == 0] == zeroMat(4,4)"
                    val biLhsPattern = "\\(\\s*B_" + i + "\\s*\\)\\s*\\[\\s*t\\s*==\\s*0\\s*\\]"
                    val existingBi = solution.constraints.findFirst[c |

                        val eqIndex = c.indexOf("==")
                        eqIndex > 0 && c.substring(0, eqIndex).trim.matches(biLhsPattern)
                    ]
                    if (existingBi === null) {
                        solution.constraints.add(biConstraint)
                    }
                }

                // Add or replace B_k initial constraint using the same style as SKO_gen
                val bkList = (1..n).map["B_" + it].join(", ")
                val bkAggregateConstraint = "(B_k)[t == 0] == <" + bkList + ">"
                val lhsPattern = "\\(\\s*B_k\\s*\\)\\s*\\[\\s*t\\s*==\\s*0\\s*\\]"
                val existing = solution.constraints.findFirst[c |
                    
                    val eqIndex = c.indexOf("==")
                    eqIndex > 0 && c.substring(0, eqIndex).trim.matches(lhsPattern)
                ]
                if (existing !== null) {
                    solution.constraints.set(solution.constraints.indexOf(existing), bkAggregateConstraint)
                } else {
                    solution.constraints.add(bkAggregateConstraint)
                }

                // Add T_geom_k and T_offset_k constraints for formulation-agnostic visualization
                // T_offset_k: Fixed offsets from joint frames to body centers (initialized from geometry)
                for (i : 1 ..< n+1) {
                    val tOffsetConstraint = "(T_offset_" + i + ")[t == 0] == zeroMat(4,4)"
                    val tOffsetLhsPattern = "\\(\\s*T_offset_" + i + "\\s*\\)\\s*\\[\\s*t\\s*==\\s*0\\s*\\]"
                    val existingTOffset = solution.constraints.findFirst[c |
                        val eqIndex = c.indexOf("==")
                        eqIndex > 0 && c.substring(0, eqIndex).trim.matches(tOffsetLhsPattern)
                    ]
                    if (existingTOffset === null) {
                        solution.constraints.add(tOffsetConstraint)
                    }
                }
                
                // T_geom_k = B_k * T_offset_k: Compute body center frames from joint frames (algebraic)
                for (i : 1 ..< n+1) {
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
                
                // T_geom sequence constraint (algebraic)
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
                
                // T_offset sequence constraint (initial value)
                val tOffsetList = (1..n).map["T_offset_" + it].join(", ")
                val tOffsetAggregateConstraint = "(T_offset)[t == 0] == <" + tOffsetList + ">"
                val tOffsetListLhsPattern = "\\(\\s*T_offset\\s*\\)\\s*\\[\\s*t\\s*==\\s*0\\s*\\]"
                val existingTOffsetList = solution.constraints.findFirst[c |
                    val eqIndex = c.indexOf("==")
                    eqIndex > 0 && c.substring(0, eqIndex).trim.matches(tOffsetListLhsPattern)
                ]
                if (existingTOffsetList !== null) {
                    solution.constraints.set(solution.constraints.indexOf(existingTOffsetList), tOffsetAggregateConstraint)
                } else {
                    solution.constraints.add(tOffsetAggregateConstraint)
                }

                // Add or replace X_J_k initial constraint similarly (use n-1 joints for a serial chain)
                val jointCount = if (n > 0) n - 1 else 0
                if (jointCount > 0) {
                    val xjList = (1..jointCount).map["X_J_" + it].join(", ")
                    val xjkAggregateConstraint = "(X_J_k)[t == 0] == <" + xjList + ">"
                    val xjkLhsPattern = "\\(\\s*X_J_k\\s*\\)\\s*\\[\\s*t\\s*==\\s*0\\s*\\]"
                    val existingXjk = solution.constraints.findFirst[c |
                        val eqIndex = c.indexOf("==")
                        eqIndex > 0 && c.substring(0, eqIndex).trim.matches(xjkLhsPattern)
                    ]
                    if (existingXjk !== null) {
                        solution.constraints.set(solution.constraints.indexOf(existingXjk), xjkAggregateConstraint)
                    } else {
                        solution.constraints.add(xjkAggregateConstraint)
                    }

                    // Add [t==t] aggregate constraint for X_J_k sequence (matching SKO_gen line 554)
                    val xjkAlgebraicAggregateConstraint = "(X_J_k)[t == t] == <" + xjList + ">"
                    val xjkAlgebraicLhsPattern = "\\(\\s*X_J_k\\s*\\)\\s*\\[\\s*t\\s*==\\s*t\\s*\\]"
                    val existingXjkAlgebraic = solution.constraints.findFirst[c |
                        val eqIndex = c.indexOf("==")
                        eqIndex > 0 && c.substring(0, eqIndex).trim.matches(xjkAlgebraicLhsPattern)
                    ]
                    if (existingXjkAlgebraic !== null) {
                        solution.constraints.set(solution.constraints.indexOf(existingXjkAlgebraic), xjkAlgebraicAggregateConstraint)
                    } else {
                        solution.constraints.add(xjkAlgebraicAggregateConstraint)
                    }

                    // Add system-level H_i inputs and default constraints (resolved later by evaluator)
                    for (i : 1 ..< jointCount + 1) {
                        val hName = "H_" + i
                        // Input H_i: 1x6 hinge row
                        val hInput = new Local()
                        hInput.name = hName
                        hInput.type = "matrix(real,1,6)"
                        // Avoid duplicate H_i inputs
                        val existsHInput = solution.inputs !== null && solution.inputs.exists[ inp | inp.name == hInput.name ]
                        if (!existsHInput) {
                            solution.inputs.add(hInput)
                        }

                        // Add individual H_i initial value constraints with literal values
                        val hDefConstraint = if (i == 1) {
                            "(" + hName + ")[t == 0] == [|0,0,1,0,0,0|]"
                        } else if (i == 2) {
                            "(" + hName + ")[t == 0] == [|1,0,0,0,0,0|]"
                        } else {
                            "(" + hName + ")[t == 0] == zeroMat(1,6)"
                        }
                        val hDefLhsPattern = "\\(\\s*" + hName + "\\s*\\)\\s*\\[\\s*t\\s*==\\s*0\\s*\\]"
                        val existingHDef = solution.constraints.findFirst[c |
                            c.contains("==") && c.substring(0, c.lastIndexOf("==")).trim.matches(hDefLhsPattern)
                        ]
                        if (existingHDef !== null) {
                            solution.constraints.set(solution.constraints.indexOf(existingHDef), hDefConstraint)
                        } else {
                            solution.constraints.add(hDefConstraint)
                        }
                    }

                    // Add system-level H block constraints, following SKO_gen style exactly
                    for (i : 1 ..< jointCount + 1) {
                        val rowOff = i - 1
                        val colOff = 6 * (i - 1)
                        // Match reference format: (submatrix(H)(row,col, 1,6)) [t==0] == H_i
                        val hConstraint = "(submatrix(H)(" + rowOff + "," + colOff + ", 1,6)) [t==0] == H_" + i
                        // Deduplicate/replace if present
                        val hPattern = "\\(submatrix\\(H\\)\\(" + rowOff + "," + colOff + ",\\s*1,6\\)\\)\\s*\\[\\s*t\\s*==\\s*0\\s*\\]"
                        val existingH = solution.constraints.findFirst[c |
                            c.contains("==") && c.substring(0, c.lastIndexOf("==")).trim.matches(hPattern)
                        ]
                        if (existingH !== null) {
                            solution.constraints.set(solution.constraints.indexOf(existingH), hConstraint)
                        } else {
                            solution.constraints.add(hConstraint)
                        }
                    }
                }
                // Add or replace theta initial condition to zero vector of size (n-1)
                val thetaSize = if (n > 0) n - 1 else 0
                if (thetaSize > 0) {
                    val thetaConstraint = "(theta)[t == 0] == zeroVec(" + thetaSize + ")"
                    val thetaLhsPattern = "\\(\\s*theta\\s*\\)\\s*\\[\\s*t\\s*==\\s*0\\s*\\]"
                    val existingTheta = solution.constraints.findFirst[c |
                        c.contains("==") && c.substring(0, c.lastIndexOf("==")).trim.matches(thetaLhsPattern)
                    ]
                    if (existingTheta !== null) {
                        solution.constraints.set(solution.constraints.indexOf(existingTheta), thetaConstraint)
                    } else {
                        solution.constraints.add(thetaConstraint)
                    }
                }

                // Note: Geometric constraints (geomType, geomVal) should come from model resolution
                // Don't manually add geometric constraints here - let them be resolved from the model

                // Add individual X_J_i constraints
                for (jointIndex : 1 .. thetaSize) {
                    val xjName = "X_J_" + jointIndex
                    // Check if X_J_i input exists (should be added elsewhere)
                    val xjInput = solution.inputs.findFirst[it.name == xjName]
                    if (xjInput === null) {
                        val newXjInput = new Local()
                        newXjInput.name = xjName
                        newXjInput.type = "matrix(real,6,6)"
                        solution.inputs.add(newXjInput)
                    }
                    
                    // Add initial constraint with 6x6 identity matrix (at t==0, no rotation)
                    val identityMatrix = "[|1.0,0.0,0.0,0.0,0.0,0.0;0.0,1.0,0.0,0.0,0.0,0.0;0.0,0.0,1.0,0.0,0.0,0.0;0.0,0.0,0.0,1.0,0.0,0.0;0.0,0.0,0.0,0.0,1.0,0.0;0.0,0.0,0.0,0.0,0.0,1.0|]"
                    val xjInitConstraint = "(" + xjName + ") [ t == 0] ==" + identityMatrix
                    val xjInitLhsPattern = "\\(\\s*" + xjName + "\\s*\\)\\s*\\[\\s*t\\s*==\\s*0\\s*\\]"
                    val existingXjInit = solution.constraints.findFirst[c |
                        c.contains("==") && c.substring(0, c.lastIndexOf("==")).trim.matches(xjInitLhsPattern)
                    ]
                    if (existingXjInit === null) {
                        solution.constraints.add(xjInitConstraint)
                    }
                    
                    // Add algebraic constraint for X_J_i as a function of theta
                    // Use zeroMat as placeholder - the generator will resolve the actual equation
                    val xjAlgebraicConstraint = "(" + xjName + ") [t == t] ==zeroMat(6,6)"

                    // Check if this algebraic constraint already exists
                    val xjAlgebraicLhsPattern = "\\(\\s*" + xjName + "\\s*\\)\\s*\\[\\s*t\\s*==\\s*t\\s*\\]"
                    val existingXjAlgebraic = solution.constraints.findFirst[c |
                        c.contains("==") && c.substring(0, c.lastIndexOf("==")).trim.matches(xjAlgebraicLhsPattern)
                    ]
                    if (existingXjAlgebraic === null) {
                        solution.constraints.add(xjAlgebraicConstraint)
                    }
                }
            }
        }
        
        // Set method and errors
        solution.method = "Visual"
        solution.errors = new BasicEList<String>
        solution.errors.add("0")
        
        return solution
	}

	static def String asSolution(SlnRef solution) {
		'''
		Solution{
			state{ «solution.expression.name» : «simplifyType(solution.expression.type)» = «getInitalValue(solution.expression.name, solution)»;
			       «getInputs(solution)»
			}
			datatypes {
			    Geom: {
			        geomType: String;
			        geomVal: vec();
			        meshUri: String;
			        meshScale: vec()
			    }
			}
			functions{
				function zeroMat(rows: int, cols: int): mat(rows, cols) {
					for (i: int in range(0, rows, 1)) {
						for (j: int in range(0, cols, 1)) {
							zeroMat[i,j] == 0
						}
					}
				}
				function zeroVec(size: int): vec(size) {
					for (i: int in range(0, size, 1)) {
						zeroVec[i] == 0
					}
				}
				function X_J(H: mat(), q: vec(), i: int): mat(6,6) {
					// Across spatial transform matrix for joint i
					// Using H (joint twist) and q (joint variable)
				}
			}
			computation{}
		}
		'''
	}
}

def static String simplifyType(String input) {
	return LibUtils.simplifyType(input)
}

def static String getInitalValue(String expression, SolutionRef solution){
	return LibUtils.getInitalValue(expression, solution)
}

def static String getInitalValue(String expression, SlnRef solution){
    var IC_value = LibUtils.getInitalValue(expression, solution)
    if (IC_value === null) {
        throw new IllegalStateException('No initial value found for expression: ' + expression)
    }
    // Convert sequences "<…>" → "seq(…)" for Solution DSL compatibility
    if (IC_value.startsWith("<") && IC_value.endsWith(">")) {
        IC_value = "seq(" + IC_value.substring(1, IC_value.length - 1).trim + ")"
    }
    return IC_value
}

def static String getInputs(SlnRef solution){
	// Delegate to LibUtils.getInputs which uses the 3-parameter getInitalValue
	// that properly converts sequence syntax <...> to seq(...)
	return LibUtils.getInputs(solution)
 }

}
