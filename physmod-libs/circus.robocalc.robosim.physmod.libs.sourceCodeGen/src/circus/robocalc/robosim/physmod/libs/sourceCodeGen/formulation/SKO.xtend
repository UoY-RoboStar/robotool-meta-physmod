package circus.robocalc.robosim.physmod.libs.sourceCodeGen.formulation


import org.eclipse.emf.common.util.EList
import org.eclipse.emf.common.util.BasicEList
import java.util.regex.Pattern
import java.io.StringReader
import java.util.ArrayList
import javax.script.ScriptEngineManager
import java.util.List
import circus.robocalc.robosim.physmod.slnRef.slnRef.SlnRef
import circus.robocalc.robosim.physmod.slnDF.slnDF.SlnDFFactory
import circus.robocalc.robosim.physmod.libs.sourceCodeGen.solutionLib.SolutionRef
import circus.robocalc.robosim.physmod.libs.sourceCodeGen.solutionLib.Local
import static circus.robocalc.robosim.physmod.libs.sourceCodeGen.libUtils.libUtils.*

// This class contains methods associated with the SKO formulation
class SKO{
static class PlatformMapping{
static val actuatorPathRegistry = new java.util.concurrent.ConcurrentHashMap<String, java.util.LinkedHashMap<String, String>>()

static def String asSolution(SlnRef solution) {

    // Determine vector length from type or actuator constraints
    var vecLength = -1

    // Try parsing from type: "vector(real, N)" -> N
    val typePattern = Pattern.compile("vector\\s*\\(\\s*[^,]+\\s*,\\s*(\\d+)\\s*\\)")
    val typeMatcher = typePattern.matcher(solution.expression.type)
    if (typeMatcher.find()) {
        vecLength = Integer.parseInt(typeMatcher.group(1).trim)
    }

    // Look for actuator path constraints and determine max index if type parsing failed
    // Use the expression name from the solution (e.g., "u", "tau") to match constraints
    val exprName = solution.expression.name
    val actuatorPattern = Pattern.compile("\\(\\s*" + Pattern.quote(exprName) + "\\s*\\(\\s*(\\d+)\\s*\\)\\s*\\)\\s*\\[\\s*t\\s*==\\s*t\\s*\\]\\s*==\\s*(.+)")
    val actuatorAssignments = new java.util.ArrayList<String>()
    val actuatorInputs = new java.util.LinkedHashMap<String, String>()  // varName -> fullPath
    var maxActuatorIndex = 0

    for (constraint : solution.constraints) {
        val text = (constraint.value as String).trim
        val m = actuatorPattern.matcher(text)
        if (m.find()) {
            val index = Integer.parseInt(m.group(1).trim)    // e.g. 0, 1
            val pmapPath = m.group(2).trim                    // e.g. "p_mapping.SimpleArmSerial..."
            val cleanedPath = cleanPlatformMappingPath(pmapPath)
            // Use the cleaned path as the variable name (replace dots with underscores)
            val varName = cleanedPath.replace(".", "_")
            actuatorInputs.put(varName, cleanedPath)
            // Use variable name in assignment; the name itself documents the mapping
            actuatorAssignments.add('''subvector(«exprName»)(«index»,1) = «varName»;''')
            if (index > maxActuatorIndex) {
                maxActuatorIndex = index
            }
        }
    }

    // If type parsing failed, use max actuator index; fallback to 2
    if (vecLength <= 0) {
        vecLength = if (maxActuatorIndex > 0) maxActuatorIndex else 2
    }

    // Use the IC_value from getInitalValue - it will handle conversion properly
    val IC_value = getInitalValue(solution.expression.name,solution.expression.type, solution)

    // Generate computation block with actuator assignments or fallback to placeholder
    val computationBody = if (!actuatorAssignments.isEmpty) {
        actuatorAssignments.join("\n        ")
    } else {
        "skip;"
    }

    // Store actuator paths in registry before returning template
    actuatorPathRegistry.put(solution.expression.name, actuatorInputs)

    // Generate input declarations for actuator variables
    val actuatorInputDecls = if (!actuatorInputs.isEmpty) {
        actuatorInputs.keySet.map[varName | varName + " : float = 0.0;"].join("\n            ")
    } else {
        ""
    }

    // Generate proof block constraints for interface mappings
    // These establish the correspondence between tau indices and actuator ports
    val proofConstraints = new java.util.ArrayList<String>()
    for (constraint : solution.constraints) {
        val text = (constraint.value as String).trim
        val m = actuatorPattern.matcher(text)
        if (m.find()) {
            val index = Integer.parseInt(m.group(1).trim)
            val pmapPath = m.group(2).trim
            val cleanedPath = cleanPlatformMappingPath(pmapPath)
            val varName = cleanedPath.replace(".", "_")
            // Add proof constraint: exprName(index) == actuator_variable
            proofConstraints.add(exprName + "(" + index + ") == " + varName + ";")
        }
    }

    val proofBlock = if (!proofConstraints.isEmpty) {
        '''
        proof {
            // Interface mapping constraints: actuator inputs to tau vector
            «proofConstraints.join("\n            ")»
        }'''
    } else {
        ""
    }

    return '''
    Solution temp {
        state{ «solution.expression.name» : «simplifyType(solution.expression.type)» = «IC_value»;
            «actuatorInputDecls»
        }

        functions {
            function zeroMat(rows: int, cols: int):mat() {
                for (i: int in range(0, rows, 1)) {
                    for (j: int in range(0, cols, 1)) {
                        zeroMat[i,j] == 0
                    }
                }
            }

            function zeroVec(size: int):vec() {
                for (i: int in range(0, size, 1)) {
                    zeroVec[i] == 0
                }
            }
        }

        computation{«computationBody»}
        «proofBlock»
    }
    '''
}

static def getActuatorPaths() {
    actuatorPathRegistry
}
}

static def String cleanPlatformMappingPath(String originalPath) {
    if (originalPath === null) {
        return ""
    }
    // Normalize whitespace and adjust known subsystem names
    var cleaned = originalPath.replaceAll("\\s+", "")
    // Replace SimpleArmSerial with SimpleArm to match runtime mapping struct
    cleaned = cleaned.replace("SimpleArmSerial", "SimpleArm")
    return cleaned
}


static class Eval{
	static def String asSolution(SlnRef solution) {

		val IC_value = getInitalValue(solution.expression.name,solution.expression.type, solution)

		// Extract n from solution constraints
		var n = 3 // default value
		val pattern = Pattern.compile("\\(\\s*n\\s*\\)\\s*\\[\\s*t\\s*==\\s*0\\s*\\]\\s*==\\s*(\\d+)")
		for (constraint : solution.constraints) {
			val matcher = pattern.matcher((constraint.value as String).trim)
			if (matcher.find()) {
				n = Integer.parseInt(matcher.group(1).trim)
			}
		}

		val blockSize = 6 // SKO uses 6x6 blocks
		switch solution.expression.name{
			
			case "phi":{
				'''
			Solution temp {
				state{ «solution.expression.name» : «simplifyType(solution.expression.type)» = «IC_value»;
						«getInputs(solution)»
				}
				procedures{
					procedure SKOm_set(val-res modifier: mat(), val x: int, val y: int, val input: mat(6,6)) {
					    submatrix(modifier)(6 * x, 6 * y, 6, 6) = input;
					}
					procedure SKOv_set(val-res modifier: vec(), val x: int, val input: vec(6)) {
					    subvector(modifier)(6 * x, 6) = input;
					}

					// Force transform φ(i,j) for SKO formulation
					// Computes spatial force transformation from frame j to frame i
					procedure CalcPhi_proc(val i: int, val j: int, val B_k: seq(mat(4,4)), val-res result: mat(6,6)) {
					    R_i: mat(3,3) = submatrix(B_k[i - 1])(0, 0, 3, 3);
					    R_j: mat(3,3) = submatrix(B_k[j - 1])(0, 0, 3, 3);
					    R_ij: mat(3,3) = transpose(R_i) * R_j;
					    p_i: vec(3) = submatrix(B_k[i - 1])(0, 3, 3, 1);
					    p_j: vec(3) = submatrix(B_k[j - 1])(0, 3, 3, 1);
					    p_ij_i: vec(3) = transpose(R_i) * (p_j - p_i);
					    skew_p: mat(3,3) = skewSymmetric(p_ij_i);

					    // Build 6x6 spatial force transform: [R_ij, skew(p_ij_i)*R_ij; 0, R_ij]
					    for(row: int in range(0, 3, 1)) {
					        for(col: int in range(0, 3, 1)) {
					            submatrix(result)(row, col, 1, 1) = submatrix(R_ij)(row, col, 1, 1);
					        }
					    }
					    for(row: int in range(0, 3, 1)) {
					        for(col: int in range(3, 6, 1)) {
					            submatrix(result)(row, col, 1, 1) = submatrix(skew_p * R_ij)(row, col - 3, 1, 1);
					        }
					    }
					    for(row: int in range(3, 6, 1)) {
					        for(col: int in range(0, 3, 1)) {
					            submatrix(result)(row, col, 1, 1) = 0.0;
					        }
					    }
					    for(row: int in range(3, 6, 1)) {
					        for(col: int in range(3, 6, 1)) {
					            submatrix(result)(row, col, 1, 1) = submatrix(R_ij)(row - 3, col - 3, 1, 1);
					        }
					    }
					}

					// Motion transform φ*(i,j) for SKO formulation
					// Computes spatial motion transformation from frame j to frame i
					procedure CalcPhiStar_proc(val i: int, val j: int, val B_k: seq(mat(4,4)), val-res result: mat(6,6)) {
					    R_i: mat(3,3) = submatrix(B_k[i - 1])(0, 0, 3, 3);
					    R_j: mat(3,3) = submatrix(B_k[j - 1])(0, 0, 3, 3);
					    R_ij: mat(3,3) = transpose(R_i) * R_j;
					    p_i: vec(3) = submatrix(B_k[i - 1])(0, 3, 3, 1);
					    p_j: vec(3) = submatrix(B_k[j - 1])(0, 3, 3, 1);
					    p_ij_i: vec(3) = transpose(R_i) * (p_j - p_i);
					    skew_p: mat(3,3) = skewSymmetric(p_ij_i);
					    neg_R_skew: mat(3,3) = -R_ij * skew_p;

					    // Build 6x6 spatial motion transform: [R_ij, 0; -R_ij*skew(p_ij_i), R_ij]
					    for(row: int in range(0, 3, 1)) {
					        for(col: int in range(0, 3, 1)) {
					            submatrix(result)(row, col, 1, 1) = submatrix(R_ij)(row, col, 1, 1);
					        }
					    }
					    for(row: int in range(0, 3, 1)) {
					        for(col: int in range(3, 6, 1)) {
					            submatrix(result)(row, col, 1, 1) = 0.0;
					        }
					    }
					    for(row: int in range(3, 6, 1)) {
					        for(col: int in range(0, 3, 1)) {
					            submatrix(result)(row, col, 1, 1) = submatrix(neg_R_skew)(row - 3, col, 1, 1);
					        }
					    }
					    for(row: int in range(3, 6, 1)) {
					        for(col: int in range(3, 6, 1)) {
					            submatrix(result)(row, col, 1, 1) = submatrix(R_ij)(row - 3, col - 3, 1, 1);
					        }
					    }
					}
				}
				functions {
					    function Identity(n: int): mat() { }

					function zeroMat(rows: int, cols: int):mat() { }
					function zeroVec(size: int):vec() { }
							
					function l(Pose1: vec(3), Pose2: vec(3)): vec(3) { }
							        				
			         		function lx(x: vec(3), y: vec(3)): mat(3,3) { 
			         				lx[0,0] == 0 /\
			        				lx[0,1] == -l(x,y)[2]/\
			        				lx[0,2] == l(x,y)[1]/\
			        				lx[1,0] == l(x,y)[2]/\
			        				lx[1,1] == 0 /\
			        				lx[1,2] == -l(x,y)[0]/\
			        				lx[2,0] == -l(x,y)[1]/\
			        				lx[2,1] == l(x,y)[0]/\
			        				lx[2,2] == 0
			         			}
					    	function getFramePosition(frame: int, B_k: seq(mat(4,4))): vec(3) {
					    				getFramePosition == submatrix(B_k[frame - 1])(0, 3, 3, 1)
					    			}

					        function SKOm(systemMatrix: mat(), x: int, y: int): mat(6,6) {
					        			SKOm == submatrix(systemMatrix)(6 * x, 6 * y, 6, 6)
					        		}
					        
					        function SKOv(systemVector: vec(), x: int): vec(6) {
					        			SKOv == subvector(systemVector)(6 * x, 6)
					        		}
					        							
					    }
				computation {
				«FOR i : 0 ..< n»
					«FOR j : 0 ..< i+1»
						«val rowOffset = i * blockSize»
						«val colOffset = j * blockSize»
						«IF i == j»
							SKOm_set(«solution.expression.name», «i», «j», Identity(«blockSize»));
					«ELSE»
					temp_«i»_«j»: mat(6,6) = zeroMat(6, 6);
					{CalcPhi_proc(«i+1», «j+1», B_k, temp_«i»_«j»);}
					SKOm_set(«solution.expression.name», «i», «j», temp_«i»_«j»);
					«ENDIF»
					«ENDFOR»
				«ENDFOR»
   				 }
			}
			'''
			}
			case solution.expression.name.matches('B\\d+'):{
				'''
				Solution temp {
					state{ «solution.expression.name» : «simplifyType(solution.expression.type)» = «IC_value»}
					computation{ «solution.expression.name» =  Eval.«solution.expression.name»}
				}
				'''
			}

		case "B_k":{
			// Forward kinematics: delegate to ForwardKinematics formulation
			return SKO.ForwardKinematics.asSolution(solution)
		}


		}
		
		}
		

}

static class NewtonEulerInverseDynamics{
	static def String asSolution(SlnRef solution) {
		'''
		Solution temp {
            state{ «solution.expression.name» : «simplifyType(solution.expression.type)» = «getInitalValue(solution.expression.name,solution.expression.type, solution)»;
					«getInputs(solution)»
			}
			procedures{
				procedure SKOm_set(val-res modifier: mat(), val x: int, val y: int, val input: mat(6,6)) {
				    submatrix(modifier)(6 * x, 6 * y, 6, 6) = input;
				}
				procedure SKOv_set(val-res modifier: vec(), val x: int, val input: vec(6)) {
				    subvector(modifier)(6 * x, 6) = input;
				}
			}

			functions{
				function skewSymmetric(v: vec(3)): mat(3,3) {
					skewSymmetric[0,0] == 0 /\
					skewSymmetric[0,1] == -v[2] /\
					skewSymmetric[0,2] == v[1] /\
					skewSymmetric[1,0] == v[2] /\
					skewSymmetric[1,1] == 0 /\
					skewSymmetric[1,2] == -v[0] /\
					skewSymmetric[2,0] == -v[1] /\
					skewSymmetric[2,1] == v[0] /\
					skewSymmetric[2,2] == 0
				}
				
				// Motion cross operator crm(v) = [ω× 0; v_lin× ω×]
				function SKO_cross(v: vec(6)): mat(6,6) {
				    // Top-left 3x3 block: skew-symmetric of angular part (ω×)
				    for (i: int in range(0, 3, 1)) {
				        for (j: int in range(0, 3, 1)) {
				            SKO_cross[i,j] == skewSymmetric(subvector(v)(0, 3))[i,j]
				        }
				    } /\
				    // Top-right 3x3 block: zeros
				    for (i: int in range(0, 3, 1)) {
				        for (j: int in range(3, 6, 1)) {
				            SKO_cross[i,j] == 0
				        }
				    } /\
				    // Bottom-left 3x3 block: skew-symmetric of linear part (v_lin×)
				    for (i: int in range(3, 6, 1)) {
				        for (j: int in range(0, 3, 1)) {
				            SKO_cross[i,j] == skewSymmetric(subvector(v)(3, 3))[i - 3, j]
				        }
				    } /\
				    // Bottom-right 3x3 block: skew-symmetric of angular part (ω×)
				    for (i: int in range(3, 6, 1)) {
				        for (j: int in range(3, 6, 1)) {
				            SKO_cross[i,j] == skewSymmetric(subvector(v)(0, 3))[i - 3, j - 3]
				        }
				    }
				}
				
				// Force cross operator crf(v) = [ω× v_lin×; 0 ω×]
				function SKO_cross_force(v: vec(6)): mat(6,6) {
				    // Top-left: ω×
				    for (i: int in range(0, 3, 1)) {
				        for (j: int in range(0, 3, 1)) {
				            SKO_cross_force[i,j] == skewSymmetric(subvector(v)(0, 3))[i,j]
				        }
				    } /\
				    // Top-right: v_lin×
				    for (i: int in range(0, 3, 1)) {
				        for (j: int in range(3, 6, 1)) {
				            SKO_cross_force[i,j] == skewSymmetric(subvector(v)(3, 3))[i, j - 3]
				        }
				    } /\
				    // Bottom-left zeros
				    for (i: int in range(3, 6, 1)) {
				        for (j: int in range(0, 3, 1)) {
				            SKO_cross_force[i,j] == 0
				        }
				    } /\
				    // Bottom-right: ω×
				    for (i: int in range(3, 6, 1)) {
				        for (j: int in range(3, 6, 1)) {
				            SKO_cross_force[i,j] == skewSymmetric(subvector(v)(0, 3))[i - 3, j - 3]
				        }
				    }
				}

	function zeroMat(rows: int, cols: int):mat() {
					for (i: int in range(0, rows, 1)) {
						for (j: int in range(0, cols, 1)) {
							zeroMat[i,j] == 0
						}
					}
				}
	function zeroVec(size: int):vec() {
					for (i: int in range(0, size, 1)) {
						zeroVec[i] == 0
					}
				}

		function transpose(m: mat()): mat() {
		}

		function CalcPhi(i: int, j: int, B_k: seq(mat(4,4))): mat(6,6) { }
		}

					computation{
            // ===== RNEA Forward Pass (no gravity): base toward tip (k=0 to n-2) =====
            // vJ = H*(k) * theta_dot(k), motion transform uses CalcPhi().transpose()
            for (k: int in range(0, n - 1, 1)) {
                vJ: vec(6) = transpose(submatrix(H)(k,6*k,1,6)) * subvector(d_theta)(k,1);
                if (k == 0) {
                    // Parent is base: V(base) = 0, α(base) = 0 (no gravity)
                    SKOv_set(V, k, vJ);
                    SKOv_set(a, k, SKO_cross(SKOv(V, k)) * vJ);
                    SKOv_set(alpha, k, SKOv(a, k));
                } else {
                    // Parent is k-1: φ*(k+1,k) = φ(k,k+1)^T = motion from link(k-1) to link(k)
                    X_m: mat(6,6) = transpose(CalcPhi(k, k + 1, B_k));
                    SKOv_set(V, k, X_m * SKOv(V, k - 1) + vJ);
                    SKOv_set(a, k, SKO_cross(SKOv(V, k)) * vJ);
                    SKOv_set(alpha, k, X_m * SKOv(alpha, k - 1) + SKOv(a, k));
                }
            }

            // ===== RNEA Backward Pass: tip toward base (k=n-2 to 0) =====
            for (k: int in range(n - 2, -1, -1)) {
                SKOv_set(b, k, SKOm(M, k, k) * SKOv(alpha, k) + SKO_cross_force(SKOv(V, k)) * SKOm(M, k, k) * SKOv(V, k));
                if (k == n - 2) {
                    // Tip link: no child force to accumulate
                    SKOv_set(f, k, SKOv(b, k));
                } else {
                    // CalcPhi(k+1, k+2) = force transform from child(k+1) to parent(k)
                    Xf: mat(6,6) = CalcPhi(k + 1, k + 2, B_k);
                    SKOv_set(f, k, Xf * SKOv(f, k + 1) + SKOv(b, k));
                }
            }
            // Extract torques
            for (k: int in range(0, n - 1, 1)) {
                subvector(C)(k,1) = submatrix(submatrix(H)(k,6*k,1,6) * SKOv(f, k))(0,0,1,1);
            }
		}
		}
		'''
	}

}

static class NewtonEulerInverseDynamics_gravity{
	static def String asSolution(SlnRef solution) {
		'''
		Solution temp {
            state{ «solution.expression.name» : «simplifyType(solution.expression.type)» = «getInitalValue(solution.expression.name,solution.expression.type, solution)»;
					«getInputs(solution)»
			}
			procedures{
				procedure SKOm_set(val-res modifier: mat(), val x: int, val y: int, val input: mat(6,6)) {
				    submatrix(modifier)(6 * x, 6 * y, 6, 6) = input;
				}
				procedure SKOv_set(val-res modifier: vec(), val x: int, val input: vec(6)) {
				    subvector(modifier)(6 * x, 6) = input;
				}
			}

			functions{
				function skewSymmetric(v: vec(3)): mat(3,3) {
					skewSymmetric[0,0] == 0 /\
					skewSymmetric[0,1] == -v[2] /\
					skewSymmetric[0,2] == v[1] /\
					skewSymmetric[1,0] == v[2] /\
					skewSymmetric[1,1] == 0 /\
					skewSymmetric[1,2] == -v[0] /\
					skewSymmetric[2,0] == -v[1] /\
					skewSymmetric[2,1] == v[0] /\
					skewSymmetric[2,2] == 0
				}
				
				// Motion cross operator crm(v) = [ω× 0; v_lin× ω×]
				function SKO_cross(v: vec(6)): mat(6,6) {
				    // Top-left 3x3 block: skew-symmetric of angular part (ω×)
				    for (i: int in range(0, 3, 1)) {
				        for (j: int in range(0, 3, 1)) {
				            SKO_cross[i,j] == skewSymmetric(subvector(v)(0, 3))[i,j]
				        }
				    } /\
				    // Top-right 3x3 block: zeros
				    for (i: int in range(0, 3, 1)) {
				        for (j: int in range(3, 6, 1)) {
				            SKO_cross[i,j] == 0
				        }
				    } /\
				    // Bottom-left 3x3 block: skew-symmetric of linear part (v_lin×)
				    for (i: int in range(3, 6, 1)) {
				        for (j: int in range(0, 3, 1)) {
				            SKO_cross[i,j] == skewSymmetric(subvector(v)(3, 3))[i - 3, j]
				        }
				    } /\
				    // Bottom-right 3x3 block: skew-symmetric of angular part (ω×)
				    for (i: int in range(3, 6, 1)) {
				        for (j: int in range(3, 6, 1)) {
				            SKO_cross[i,j] == skewSymmetric(subvector(v)(0, 3))[i - 3, j - 3]
				        }
				    }
				}
				
				// Force cross operator crf(v) = [ω× v_lin×; 0 ω×]
				function SKO_cross_force(v: vec(6)): mat(6,6) {
				    // Top-left: ω×
				    for (i: int in range(0, 3, 1)) {
				        for (j: int in range(0, 3, 1)) {
				            SKO_cross_force[i,j] == skewSymmetric(subvector(v)(0, 3))[i,j]
				        }
				    } /\
				    // Top-right: v_lin×
				    for (i: int in range(0, 3, 1)) {
				        for (j: int in range(3, 6, 1)) {
				            SKO_cross_force[i,j] == skewSymmetric(subvector(v)(3, 3))[i, j - 3]
				        }
				    } /\
				    // Bottom-left zeros
				    for (i: int in range(3, 6, 1)) {
				        for (j: int in range(0, 3, 1)) {
				            SKO_cross_force[i,j] == 0
				        }
				    } /\
				    // Bottom-right: ω×
				    for (i: int in range(3, 6, 1)) {
				        for (j: int in range(3, 6, 1)) {
				            SKO_cross_force[i,j] == skewSymmetric(subvector(v)(0, 3))[i - 3, j - 3]
				        }
				    }
				}

	function zeroMat(rows: int, cols: int):mat() {
					for (i: int in range(0, rows, 1)) {
						for (j: int in range(0, cols, 1)) {
							zeroMat[i,j] == 0
						}
					}
				}
	function zeroVec(size: int):vec() {
					for (i: int in range(0, size, 1)) {
						zeroVec[i] == 0
					}
				}

		function transpose(m: mat()): mat() {
		}

		function CalcPhi(i: int, j: int, B_k: seq(mat(4,4))): mat(6,6) { }
		}

					computation{
	             // Gravity handling (world frame, +Z up)
	             // RNEA uses a "pseudo" base acceleration equal to -gravity.
	             // With gravity = [0, 0, -g], we set a_grav = [0, 0, +g] in the linear Z component.
		             a_grav: vec(6) = [0.0, 0.0, 0.0, 0.0, 0.0, 9.81];
		             d_theta_loc: vec(n) = zeroVec(n);
		             for (i: int in range(0, n - 1, 1)) {
		                 d_theta_loc[i] = d_theta[i];
		             }
		             d_theta_loc[n - 1] = 0.0;
	
		            // ===== RNEA Forward Pass: base toward tip =====
		            // Index convention: B_k[n-1]=base, B_k[n-2]=first body from base, B_k[0]=tip.
		            // Motion transform φ*(i,j) = φ(j,i)^T: spatial motion transform from frame j to frame i.
		            // CalcPhi(i,j) is the spatial force transform φ(i,j) from frame j to frame i.
		            for (k: int in range(n - 2, -1, -1)) {
		                vJ: vec(6) = transpose(submatrix(H)(k,6*k,1,6)) * subvector(d_theta_loc)(k,1);
		                if (k == n - 2) {
		                    // Parent is base: V(base) = 0, α(base) = gravity
		                    // Motion transform from base (frame n) to this body (frame k+1)
		                    X_m: mat(6,6) = transpose(CalcPhi(n, k + 1, B_k));
		                    SKOv_set(V, k, vJ);
		                    SKOv_set(a, k, SKO_cross(SKOv(V, k)) * vJ);
		                    SKOv_set(alpha, k, X_m * a_grav + SKOv(a, k));
		                } else {
		                    // Parent is k+1 (frame k+2): motion transform from parent to this body
		                    X_m: mat(6,6) = transpose(CalcPhi(k + 2, k + 1, B_k));
		                    SKOv_set(V, k, X_m * SKOv(V, k + 1) + vJ);
		                    SKOv_set(a, k, SKO_cross(SKOv(V, k)) * vJ);
		                    SKOv_set(alpha, k, X_m * SKOv(alpha, k + 1) + SKOv(a, k));
		                }
		            }
	
	            // ===== RNEA Backward Pass: tip toward base (k=0 to n-2) =====
		            for (k: int in range(0, n - 1, 1)) {
		                SKOv_set(b, k, SKOm(M, k, k) * SKOv(alpha, k) + SKO_cross_force(SKOv(V, k)) * SKOm(M, k, k) * SKOv(V, k));
		                if (k == 0) {
		                    // Tip link: no child force to accumulate
		                    SKOv_set(f, k, SKOv(b, k));
		                } else {
		                    // Force transform from child (k-1) to this body (k)
		                    Xf: mat(6,6) = CalcPhi(k + 1, k, B_k);
		                    SKOv_set(f, k, Xf * SKOv(f, k - 1) + SKOv(b, k));
		                }
		            }
	            // Extract torques
	            for (k: int in range(0, n - 1, 1)) {
	                subvector(C)(k,1) = submatrix(submatrix(H)(k,6*k,1,6) * SKOv(f, k))(0,0,1,1);
            }
		}
		}
		'''
	}

}

static class CompositeBodyAlgorithm{
	static def String asSolution(SlnRef solution) {
		// Extract n from solution constraints
		var nValue = 3 // default value
		val pattern = Pattern.compile("\\(\\s*n\\s*\\)\\s*\\[\\s*t\\s*==\\s*0\\s*\\]\\s*==\\s*(\\d+)")
		for (constraint : solution.constraints) {
			val matcher = pattern.matcher((constraint.value as String).trim)
			if (matcher.find()) {
				nValue = Integer.parseInt(matcher.group(1).trim)
			}
		}

		// Compute 6*n
		val dimension = 6 * nValue

		'''
        Solution temp {
            state{ «solution.expression.name» : «simplifyType(solution.expression.type)» = «getInitalValue(solution.expression.name,solution.expression.type, solution)»;
					«getInputs(solution)»
			}

			procedures{
				procedure SKOm_set(val-res modifier: mat(), val x: int, val y: int, val input: mat(6,6)) {
				    submatrix(modifier)(6 * x, 6 * y, 6, 6) = input;
				}
				procedure SKOv_set(val-res modifier: vec(), val x: int, val input: vec(6)) {
				    subvector(modifier)(6 * x, 6) = input;
				}
				}
				functions {
					function transpose(m: mat()): mat() { }
					function CalcPhi(i: int, j: int, B_k: seq(mat(4,4))): mat(6,6) { }
				}
	
				computation{
					R: mat(«dimension», «dimension») = zeroMat(6*n, 6*n);
					X: vec(«dimension») = zeroVec(6*n);
	
					// ===== φ-based CRBA for mass matrix =====
					// Index convention: k=0 is outboard (tip), higher k is toward base.
					// Transform composite inertia from child frame into parent frame via:
					//   R_parent += φ * R_child * φ^T
					// where φ = force transform from child -> parent.
					for (k: int in range(0, n - 1, 1)) {
						if (k == 0) {
							// Tip link: just the link's own inertia
							SKOm_set(R, k, k, SKOm(M, k, k));
						} else {
							// Transform composite inertia from child (k-1) frame into parent (k) frame.
							Xf: mat(6,6) = CalcPhi(k + 1, k, B_k);
							SKOm_set(R, k, k, Xf * SKOm(R, k - 1, k - 1) * transpose(Xf) + SKOm(M, k, k));
						}
					}
	
					// Column method for off-diagonal elements
					for (k: int in range(0, n - 1, 1)) {
						SKOv_set(X, k, SKOm(R, k, k) * transpose(submatrix(H)(k,6*k,1,6)));
							submatrix(M_mass)(k, k,1,1) = submatrix(submatrix(H)(k,6*k,1,6) * SKOv(X, k))(0, 0,1,1);
							for (j: int in range(k + 1, n - 1, 1)) {
								// Propagate X from k toward base using φ(j, j-1) (force transform).
								phi_f: mat(6,6) = CalcPhi(j + 1, j, B_k);
								SKOv_set(X, j, phi_f * SKOv(X, j - 1));
								submatrix(M_mass)(j, k,1,1) = submatrix(submatrix(H)(j,6*j,1,6) * SKOv(X, j))(0, 0,1,1);
								submatrix(M_mass)(k, j,1,1) = submatrix(M_mass)(j, k,1,1);
							}
						}
				}
		        }
		'''
	}
}

static class CholeskyAlgorithm{
    static def String asSolution(SlnRef solution) {
    	//TODO: update return M.rows and M.columns in computation
		'''
        Solution temp {
            state{ «solution.expression.name» : «simplifyType(solution.expression.type)» = «getInitalValue(solution.expression.name,solution.expression.type, solution)»;
					«getInputs(solution)»
			}
			functions{
				function LDLT(matIn:mat()):mat(){
				}
			}
			computation{
						M_inv = LDLT(M_mass);
				        }
			    }
		'''
	}
}

static class ViscousDamping{
	static def String asSolution(SlnRef solution) {
		'''
        Solution temp {
            state{ «solution.expression.name» : «simplifyType(solution.expression.type)» = «getInitalValue(solution.expression.name,solution.expression.type, solution)»;
					«getInputs(solution)»
			}
			computation{
						tau_d = damping * d_theta;
				        }
			    }
		'''
	}

}

static class DirectForwardDynamics{
	static def String asSolution(SlnRef solution) {
		// Check if tau_d is in inputs
		val hasTauD = solution.inputs.exists[it.value?.name == "tau_d"]
		'''
        Solution temp {
            state{ «solution.expression.name» : «simplifyType(solution.expression.type)» = «getInitalValue(solution.expression.name,solution.expression.type, solution)»;
					«getInputs(solution)»
					«IF !hasTauD»
					tau_d : «simplifyType(solution.expression.type)» = «getInitalValue(solution.expression.name,solution.expression.type, solution)»;
					«ENDIF»
			}
			computation{
						dd_theta = M_inv * (tau - C - tau_d);
				        }
			    }
		'''
	}

}

static class ConstraintJacobian{
	static def String asSolution(SlnRef solution) {

		// Infer (nc, nTree) from the declared type of G_c: matrix(real, nc, nTree)
		var nc = 0
		var nTree = 0
		try {
			val sizes = getMatrixSize(solution.expression.type)
			if (sizes !== null && sizes.size >= 2) {
				nc = sizes.get(0)
				nTree = sizes.get(1)
			}
		} catch (Exception _) {
			nc = 0
			nTree = 0
		}

		// Optional: also compute Uprime here (same constraint dimension nc)
		val hasUprime = solution.inputs.exists[it.value?.name == "Uprime"]

		'''
        Solution temp {
            state{ «solution.expression.name» : «simplifyType(solution.expression.type)» = «getInitalValue(solution.expression.name,solution.expression.type, solution)»;
                    «IF !hasUprime»
                    Uprime : vec(«nc»);
                    «ENDIF»
                    «getInputs(solution)»
            }
            computation{
                        // Jain (Operator Formulations) closed-chain Jacobian:
                        //   G_c = Q_c * B_sel * phi* * H*
                        // with U' term for acceleration-level constraints:
                        //   Uprime = - Q_c * B_sel * phi* * a
                        G_c = Q_c * B_sel * adj(phi) * adj(H);
                        «IF !hasUprime»
                        Uprime = - Q_c * B_sel * adj(phi) * a;
                        «ENDIF»
                        }
                }
        '''
	}
}

static class ConstrainedForwardDynamics{
	static def String asSolution(SlnRef solution) {
		// Optional damping term (tau_d) support, mirroring DirectForwardDynamics
		val hasTauD = solution.inputs.exists[it.value?.name == "tau_d"]

		// Try to infer nLoop from constraints: (nLoop)[t==0]==k  => nc = 6*k
		var nLoopValue = 1
		val nLoopPattern = Pattern.compile("\\(\\s*nLoop\\s*\\)\\s*\\[\\s*t\\s*==\\s*0\\s*\\]\\s*==\\s*(\\d+)")
		for (constraint : solution.constraints) {
			val matcher = nLoopPattern.matcher((constraint.value as String).trim)
			if (matcher.find()) {
				nLoopValue = Integer.parseInt(matcher.group(1).trim)
			}
		}
		val nc = 6 * nLoopValue

		// nTree is the size of dd_theta (vector(real,nTree))
		val nTree = getVectorSize(solution.expression.type)

		'''
        Solution temp {
            state{ «solution.expression.name» : «simplifyType(solution.expression.type)» = «getInitalValue(solution.expression.name,solution.expression.type, solution)»;
                    «getInputs(solution)»
                    «IF !hasTauD»
                    // If the model has no damping term, treat tau_d as zero
                    tau_d : «simplifyType(solution.expression.type)» = zeroVec(«nTree»);
                    «ENDIF»
                    // Lagrange multipliers for loop constraints
                    lambda_c : vec(«nc»);
            }
            functions{
                // LDLT is provided by the backend; returns the inverse of the input matrix
                function LDLT(matIn:mat()):mat(){
                }
            }
            computation{
                        // Unconstrained acceleration
                        dd_theta_0: vec(«nTree») = M_inv * (tau - C - tau_d);

                        // Schur complement solve for multipliers:
                        //   (G M^-1 G^T) lambda_c = (U' - G ddtheta_0)
                        S: mat(«nc»,«nc») = G_c * M_inv * adj(G_c);
                        S_inv: mat(«nc»,«nc») = LDLT(S);
                        rhs: vec(«nc») = Uprime - (G_c * dd_theta_0);

                        lambda_c = S_inv * rhs;

                        // Constrained acceleration:
                        //   ddtheta = ddtheta_0 + M^-1 G^T lambda_c
                        dd_theta = dd_theta_0 + (M_inv * adj(G_c) * lambda_c);
                        }
                }
        '''
	}
}

static class Euler{
	static def String asSolution(SlnRef solution) {
		val expressionName = solution.expression.name
		val derivativeName = if (expressionName.startsWith("d_")) {
			"dd_" + expressionName.substring(2)
		} else {
			"d_" + expressionName
		}

		'''
        Solution temp {
            state{ «expressionName» : «simplifyType(solution.expression.type)» = «getInitalValue(expressionName,solution.expression.type, solution)»;
					«getInputs(solution)»
			}
			computation{
						«expressionName» = «expressionName» + dt * «derivativeName»;
						}
				}
		'''
	}

}

static class AcrossJointTransform {
	static def String asSolution(SlnRef solution) {
		val expressionName = solution.expression.name
		val baseName = expressionName
		val IC_value = getInitalValue(expressionName, solution.expression.type, solution)
		var n = 0
		for (input : solution.inputs) {
			val name = input.value?.name
			if (name !== null && name.startsWith(baseName + "_")) {
				val suffix = name.substring(baseName.length + 1)
				if (suffix.matches("\\d+")) {
					val idx = Integer.parseInt(suffix)
					if (idx > n) {
						n = idx
					}
				}
			}
		}

		'''
        Solution temp {
            state{ «expressionName» : «simplifyType(solution.expression.type)» = «IC_value»;
					«getInputs(solution)»
			}
			computation{
						«FOR i : 0 ..< n»
						«expressionName»[«i»] = «baseName»_«i+1»;
						«ENDFOR»
				        }
			    }
		'''
	}
}

static class ForwardKinematics {
	static def String asSolution(SlnRef solution) {
		val IC_value = getInitalValue(solution.expression.name,solution.expression.type, solution)
		// Extract X_J constraints from slnRef [ t == t] constraints
		val xjConstraints = extractXJConstraints(solution)
		val stateDecls = new StringBuilder
		stateDecls.append(solution.expression.name + " : " + simplifyType(solution.expression.type))
		if (IC_value !== null && IC_value != "seq()") {
			stateDecls.append(" = " + IC_value)
		}
		stateDecls.append(";\n")
		for (input : solution.inputs) {
			val isExpr = solution.expression !== null && input.value.name == solution.expression.name
			if (!isExpr) {
				val init = getInitalValue(input.value.name, input.value.type, solution)
				stateDecls.append(input.value.name + " : " + simplifyType(input.value.type))
				if (init !== null && init != "seq()") {
					stateDecls.append(" = " + init)
				}
				stateDecls.append(";\n")
			}
		}
		val xjAssignments = new StringBuilder
		for (entry : xjConstraints.entrySet) {
			val key = entry.key
			if (key !== null && key.startsWith("X_J_")) {
				val idx = Integer.parseInt(key.substring(4)) - 1
				xjAssignments.append("X_J[" + idx + "] = " + entry.value + ";\n")
			}
		}

		'''
		Solution temp {
			state{ «stateDecls.toString»
			}

			procedures {
				procedure T_from_X(val X: mat(6,6), res result: mat(4,4)) {
					R: mat(3,3);
					BL: mat(3,3);
					S: mat(3,3);
					p: vec(3);

					// R = X[0:3,0:3]
					for (i: int in range(0, 3, 1)) {
						for (j: int in range(0, 3, 1)) {
							R[i,j] = X[i,j];
						}
					}

					// BL = X[3:6,0:3]
					for (i: int in range(0, 3, 1)) {
						for (j: int in range(0, 3, 1)) {
							BL[i,j] = X[i+3,j];
						}
					}

					// S = -BL * R^T
					for (i: int in range(0, 3, 1)) {
						for (j: int in range(0, 3, 1)) {
							S[i,j] = 0;
							for (k: int in range(0, 3, 1)) {
								// S[i,j] -= BL[i,k] * R[j,k]
								S[i,j] = S[i,j] - BL[i,k] * R[j,k];
							}
						}
					}

					// p from S = skew(p)
					p[0] = S[2,1];
					p[1] = S[0,2];
					p[2] = S[1,0];

					// Build 4x4 homogeneous transform [R|p; 0|1]
					for (i: int in range(0, 3, 1)) {
						for (j: int in range(0, 3, 1)) {
							result[i,j] = R[i,j];
						}
					}
					for (i: int in range(0, 3, 1)) {
						result[i,3] = p[i];
					}
					result[3,0] = 0;
					result[3,1] = 0;
					result[3,2] = 0;
					result[3,3] = 1;
				}
			}

            functions {
                function Identity(n: int, m: int): mat() { }
                // Math helpers to allow trig in generated code
                function cos(x: float): float { }
                function sin(x: float): float { }
            }

            computation {
                // X_J assignments from slnRef [ t == t] constraints
                «xjAssignments.toString»
                T_XT: mat(4,4);
                T_XJ: mat(4,4);
                // Forward kinematics: propagate base -> tip
                // B_k[n-1] = base frame (unchanged)
                // Traverse joints from n-2 down to 0: B_k[i] = B_k[i+1] * X_T[i] * X_J[i]
                for (k: int in range(n - 2, -1, -1)) {
                    T_from_X(X_T[k], T_XT);
                    T_from_X(X_J[k], T_XJ);
                    «solution.expression.name»[k] = «solution.expression.name»[k + 1] * T_XT * T_XJ;
                }
            }
		}
		'''
	}

	/**
	 * Extract X_J_i constraints from [ t == t] algebraic constraints.
	 * Returns a map from variable name (e.g., "X_J_1") to DSL matrix expression.
	 */
	private static def java.util.LinkedHashMap<String, String> extractXJConstraints(SlnRef solution) {
		val result = new java.util.LinkedHashMap<String, String>()

		// Pattern for "(X_J_N) [ t == t] ==[|...|]"
		val xjPattern = Pattern.compile("\\(\\s*(X_J_\\d+)\\s*\\)\\s*\\[\\s*t\\s*==\\s*t\\s*\\]\\s*==\\s*(\\[\\|.+?\\|\\])")

		for (constraint : solution.constraints) {
			val text = (constraint.value as String).trim
			val matcher = xjPattern.matcher(text)
			if (matcher.find()) {
				val varName = matcher.group(1).trim  // e.g., "X_J_1"
				var matrixLiteral = matcher.group(2).trim  // e.g., "[|cos(theta(0)),0,...|]"

				// Convert [|...|] to [...] and theta(i) to theta[i]
				val dslMatrix = convertToDSLSyntax(matrixLiteral)
				result.put(varName, dslMatrix)
			}
		}

		return result
	}

	/**
	 * Converts slnRef matrix syntax to DSL syntax.
	 * - [|...|] becomes [...]
	 * - theta(i) becomes theta[i]
	 * - sin(theta(i)) becomes sin(theta[i])
	 * - cos(theta(i)) becomes cos(theta[i])
	 */
	private static def String convertToDSLSyntax(String input) {
		var result = input

		// Strip [| and |] to get inner content
		if (result.startsWith("[|") && result.endsWith("|]")) {
			result = result.substring(2, result.length - 2).trim
		}

		// Convert theta(N) to theta[N]
		result = result.replaceAll("theta\\((\\d+)\\)", "theta[$1]")

		// Build DSL matrix literal [...]
		return "[" + result + "]"
	}
}

// Additional utility functions needed by SKO methods (these override the simpler versions in libUtils)

def static List<Integer> getMatrixSize(String expression) {
    val pattern = Pattern.compile(
        // Allow any type name (one or more chars other than comma),
        // then two integers for rows and cols.
        "^\\s*matrix\\s*\\(\\s*[^,]+\\s*,\\s*(\\d+)\\s*,\\s*(\\d+)\\s*\\)\\s*$",
        Pattern.CASE_INSENSITIVE
    )
    val matcher = pattern.matcher(expression.trim)
    if (matcher.find) {
        val rows = Integer::parseInt(matcher.group(1).trim)
        val cols = Integer::parseInt(matcher.group(2).trim)
        return #[ rows, cols ]
    }
    return null
}

/**
 * Attempts to parse a vector type of the form "vector(<anyType>, <length>)".
 * Returns length if matched, or -1 otherwise.
 */
def static int getVectorSize(String expression) {
    val pattern = Pattern.compile(
        "^\\s*vector\\s*\\(\\s*[^,]+\\s*,\\s*(\\d+)\\s*\\)\\s*$",
        Pattern.CASE_INSENSITIVE
    )
    val matcher = pattern.matcher(expression.trim)
    if (matcher.find) {
        return Integer::parseInt(matcher.group(1).trim)
    }
    return -1
}

def static String getInitalValue( String name, String type, SlnRef solution) {
    // Determine declared dimensions from the expression's type:
    var declRows = 0
    var declCols = 0
    try {
        // If expression is a matrix, getMatrixSize returns [rows, cols]
        val sizes = getMatrixSize(type)
        declRows = sizes.get(0)
        declCols = sizes.get(1)
    } catch (Exception _) {
        // Otherwise treat as a vector: 1×N
        val vecLen = getVectorSize(type)
        declRows = 1
        declCols = vecLen
    }

    // We will search for any "submatrix(expr)(rowIndex,colIndex,numRows,numCols)[t==0]==[|…|]"
    // or "(|…|)" constraints (to support 1D vectors).
    val quotedExpr = name
    val subPattern = Pattern.compile(
        "\\(\\s*submatrix\\(" + quotedExpr + "\\)\\(([^)]+)\\)\\s*\\)\\s*" +    // "(submatrix(expr)(rowIndex,colIndex,numRows,numCols))"
        "\\[\\s*t\\s*==\\s*0\\s*\\]\\s*==\\s*(\\[\\|.+?\\|\\]|\\(\\|.+?\\|\\))"   // "[t==0]==[|…|]" or "[t==0]==(|…|)"
    )

    // We'll collect each matching constraint into a record: [rowIndex, colIndex, numRows, numCols, rawLiteral].
    val blocks = new java.util.ArrayList<java.util.List<Object>>()

    for (constraint : solution.constraints) {
        val text = (constraint.value as String).trim
        val m = subPattern.matcher(text)
        if (m.find) {
            // m.group(1) is "rowIndex,colIndex,numRows,numCols"
            // m.group(2) is either "[| … |]" or "(| … |)"
            val indicesRaw = m.group(1).trim           // e.g. "0,0,6,6"
            val rawLit     = m.group(2).trim           // e.g. "[t==0]==[|…|]" or "[t==0]==(|…|)"

            // Parse "rowIndex,colIndex,numRows,numCols" into four integers
            val parts    = indicesRaw.split(",")
            val rowIndex = Integer::parseInt(parts.get(0).trim)
            val colIndex = Integer::parseInt(parts.get(1).trim)
            val numRows  = Integer::parseInt(parts.get(2).trim)
            val numCols  = Integer::parseInt(parts.get(3).trim)

            // Store as [rowIndex, colIndex, numRows, numCols, rawLit]
            val entry = new java.util.ArrayList<Object>()
            entry.add(rowIndex)
            entry.add(colIndex)
            entry.add(numRows)
            entry.add(numCols)
            entry.add(rawLit)
            blocks.add(entry)
        }
    }

    // If we found at least one "submatrix" constraint, assemble a full matrix of size declRows×declCols.
    if (!blocks.isEmpty) {
        // 1) Initialize full matrix to zeros using declared size:
        val full = new java.util.ArrayList<java.util.ArrayList<String>>()
        for (r : 0 ..< declRows) {
            val rowList = new java.util.ArrayList<String>()
            for (c : 0 ..< declCols) {
                rowList.add("0")
            }
            full.add(rowList)
        }

        // 2) For each block, parse its "[|…|]" or "(|…|)" literal into a 2D list of Strings,
        //    then copy those values into 'full' at offset (rowIndex, colIndex).
        for (entry : blocks) {
            val rowIndex = (entry.get(0) as Integer)
            val colIndex = (entry.get(1) as Integer)
            val numRows  = (entry.get(2) as Integer)
            val numCols  = (entry.get(3) as Integer)
            val rawLit   = (entry.get(4) as String)     // "[|…|]" or "(|…|)"

            // Strip either "[|"… "|]" or "(|"… "|)" to get inner text
            val inner =
                if (rawLit.startsWith("[|") && rawLit.endsWith("|]")) {
                    rawLit.substring(2, rawLit.length - 2).trim
                } else if (rawLit.startsWith("(|") && rawLit.endsWith("|)")) {
                    rawLit.substring(2, rawLit.length - 2).trim
                } else {
                    throw new IllegalStateException("Unexpected literal: " + rawLit)
                }

            // Split rows by ';'. For 1D "(|…|)", there will be no semicolons → rowStrings.size == 1.
            val rowStrings = inner.split("\\s*;\\s*")
            if (rowStrings.size !== numRows) {
                throw new IllegalStateException(
                    "Submatrix row count mismatch: expected " + numRows + " but found " + rowStrings.size
                )
            }

            // For each rowString, split by ',' to get columns
            for (dr : 0 ..< numRows) {
                val cols = rowStrings.get(dr).split("\\s*,\\s*")
                if (cols.size !== numCols) {
                    throw new IllegalStateException(
                        "Submatrix column count mismatch: expected " + numCols + " but found " + cols.size
                    )
                }
                // Copy each entry into 'full' at (rowIndex+dr, colIndex+dc)
                for (dc : 0 ..< numCols) {
                    full.get(rowIndex + dr).set(colIndex + dc, cols.get(dc).trim)
                }
            }
        }

        // 3) Build the DSL matrix literal "[ … ]". Each row is comma-separated, rows by semicolons.
        val sb = new StringBuilder
        sb.append("[")
        for (r : 0 ..< declRows) {
            sb.append(full.get(r).join(","))
            if (r < declRows - 1) {
                sb.append("; ")
            }
        }
        sb.append("]")

        return sb.toString
    }

    // If no "submatrix" constraints were found, fall back to single-value lookup:
    val directPattern = Pattern.compile(
        "\\(\\s*" + quotedExpr + "\\s*\\)" +                 // "(expression)"
        "\\s*\\[\\s*t\\s*==\\s*0\\s*\\]\\s*" +               // "[ t == 0 ]"
        "==\\s*(.+)"                                         // "== RHS"
    )
    val IC = solution.constraints.findFirst[ constraint |
        directPattern.matcher(constraint.value as String).find()
    ]
    if (IC === null) {
        // No initial value constraint found, return default zero for the type
        return defaultZeroForType(type)
    }

    val matcher = directPattern.matcher(IC.value as String)
    matcher.find()
    var IC_value = matcher.group(1).trim

    // Convert sequences "<…>" → "seq(…)"
    if (IC_value.startsWith("<") && IC_value.endsWith(">")) {
        IC_value = "seq(" +
            IC_value.substring(1, IC_value.length - 1).trim +
            ")"
    }

    // Convert "(|…|)" vector → "[…]" and "[|…|]" matrix → "[…]"
    if ((IC_value.startsWith("(|") && IC_value.endsWith("|)")) ||
        (IC_value.startsWith("[|") && IC_value.endsWith("|]"))) {
        // Strip either "(|"…"|)" or "[|"…"|]" to get inner
        val rawInner =
            if (IC_value.startsWith("(|")) IC_value.substring(2, IC_value.length - 2).trim
            else IC_value.substring(2, IC_value.length - 2).trim
        // Split rows by ';' (none for a vector)
        val rows = rawInner.split("\\s*;\\s*")
        val normalizedRows = new java.util.ArrayList<String>()
        for (r : rows) {
            var rt = r.trim
            if (rt.length != 0) {
                val cols = rt.split("\\s*,\\s*")
                val normCols = new java.util.ArrayList<String>()
                for (c : cols) {
                    var cv = c.trim
                    cv = cv.replaceAll("-\\s+", "-")
                    // normalize negative zeros
                    if (cv == "-0.0") cv = "0.0"
                    if (cv == "-0") cv = "0"
                    if (cv.length > 0) normCols.add(cv)
                }
                if (!normCols.isEmpty) normalizedRows.add(normCols.join(","))
            }
        }
        IC_value = "[" + normalizedRows.join("; ") + "]"
    }

    return IC_value
}

static class proof {
    // Helper to convert SlnRef literal syntax to Solution DSL syntax
    static def String convertLiteralSyntax(String value) {
        var result = value

        // Convert angle bracket sequences to seq() syntax
        result = result.replaceAll("<([^>]+)>", "seq($1)")

        // Convert matrix/vector literals from [|…|] or (|…|) to canonical "[ … ]" form
        if ((result.contains("(|") && result.contains("|)")) ||
            (result.contains("[|") && result.contains("|]"))) {

            // Handle nested structures by finding the outermost brackets
            val startPattern = if (result.contains("[|")) "\\[\\|" else "\\(\\|"
            val endPattern = if (result.contains("[|")) "\\|\\]" else "\\|\\)"
            val pattern = Pattern.compile(startPattern + "(.+?)" + endPattern)
            val matcher = pattern.matcher(result)

            val sb = new StringBuffer()
            while (matcher.find()) {
                val rawInner = matcher.group(1).trim
                val rows = rawInner.split("\\s*;\\s*")
                val normalizedRows = new java.util.ArrayList<String>()

                for (r : rows) {
                    var rt = r.trim
                    if (rt.length != 0) {
                        val cols = rt.split("\\s*,\\s*")
                        val normCols = new java.util.ArrayList<String>()
                        for (c : cols) {
                            var cv = c.trim
                            cv = cv.replaceAll("-\\s+", "-")
                            // normalize negative zeros
                            if (cv == "-0.0") cv = "0.0"
                            if (cv == "-0") cv = "0"
                            if (cv.length > 0) normCols.add(cv)
                        }
                        if (!normCols.isEmpty) normalizedRows.add(normCols.join(","))
                    }
                }

                val replacement = "[" + normalizedRows.join("; ") + "]"
                matcher.appendReplacement(sb, java.util.regex.Matcher.quoteReplacement(replacement))
            }
            matcher.appendTail(sb)
            result = sb.toString
        }

        return result
    }

    static def String asSolution(SlnRef solution) {
        // Extract equations from constraints - both [t==0] initial conditions and [t==t] algebraic constraints
        val initialConditions = new ArrayList<String>()
        val algebraicConstraints = new ArrayList<String>()

        // Pattern for initial conditions: "(lhs) [ t == 0 ] ==rhs"
        val t0Pattern = Pattern.compile("\\(([^)]+)\\)\\s*\\[\\s*t\\s*==\\s*0\\s*\\]\\s*==(.+)")
        // Pattern for algebraic constraints: "(lhs) [ t == t ] ==rhs"
        val ttPattern = Pattern.compile("\\(([^)]+)\\)\\s*\\[\\s*t\\s*==\\s*t\\s*\\]\\s*==(.+)")

        for (constraint : solution.constraints) {
            val text = (constraint.value as String).trim

            val t0Matcher = t0Pattern.matcher(text)
            val ttMatcher = ttPattern.matcher(text)

            if (t0Matcher.find()) {
                // Initial condition [t==0]
                val lhs = t0Matcher.group(1).trim
                var rhs = t0Matcher.group(2).trim

                // Convert syntax for Solution DSL
                rhs = convertLiteralSyntax(rhs)

                initialConditions.add(lhs + " == " + rhs + ";")
            } else if (ttMatcher.find()) {
                // Algebraic constraint [t==t]
                val lhs = ttMatcher.group(1).trim
                var rhs = ttMatcher.group(2).trim

                // Convert syntax for Solution DSL
                rhs = convertLiteralSyntax(rhs)

                algebraicConstraints.add(lhs + " == " + rhs + ";")
            }
        }

        // Build initial conditions section
        val initialConditionsBody = if (!initialConditions.isEmpty) {
            "// Initial conditions [t==0]\n        " + initialConditions.join("\n        ")
        } else {
            "// No initial conditions"
        }

        // Build algebraic constraints section
        val algebraicConstraintsBody = if (!algebraicConstraints.isEmpty) {
            "// Algebraic constraints [t==t]\n        " + algebraicConstraints.join("\n        ")
        } else {
            "// No algebraic constraints"
        }

        // Only include algebraic constraints in proof block (state block has initial conditions)
        val proofBody = algebraicConstraintsBody

        // Extract state variables from inputs using getInputs() helper like Eval does
        // This will extract actual initial values from [t==0] constraints
        val stateDecls = getInputs(solution)

        return '''
        Solution proof_solution {
            state {
                «stateDecls»
            }

            functions {
                function adj(m : mat()) : mat() {}
                function derivative(v : vec()) : vec() {}
                function zeroMat(r : int, c : int) : mat() {}
                function zeroVec(n : int) : vec() {}
                function identity(n : int) : mat() {}
                function zeroes(n : int) : mat() {}
                function Phi(i : int, j : int, B : seq(mat())) : mat() {}
            }

            computation {
                skip;
            }

            proof {
                «proofBody»
            }
        }
        '''
    }
}

static class Visual {
    static def String asSolution(SlnRef solution) {
        // Visual formulation for SKO: generates T_geom computation block
        // T_geom_i = B_i * T_offset_i for each link

        // Build state variables from inputs
        val stateVars = new StringBuilder()

        // Add the expression (T_geom) as the primary output state variable
        if (solution.expression !== null) {
            val exprName = solution.expression.name
            val exprType = simplifyType(solution.expression.type)
            var exprInit = getInitalValue(exprName, solution.expression.type, solution)
            // Convert sequence syntax <...> to seq(...) for Solution DSL compatibility
            if (exprInit !== null && exprInit.startsWith("<") && exprInit.endsWith(">")) {
                val seqContent = exprInit.substring(1, exprInit.length - 1).trim
                if (!seqContent.isEmpty) {
                    exprInit = "seq(" + seqContent + ")"
                } else {
                    exprInit = null
                }
            }
            if (exprInit !== null && !exprInit.equals("seq()")) {
                stateVars.append("        ").append(exprName).append(" : ").append(exprType).append(" = ").append(exprInit).append(";\n")
            }
        }

        // Add all inputs except the expression (which was already added)
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
                    var initVal = getInitalValue(varName, input.value.type, solution)
                    // Convert sequence syntax <...> to seq(...) for Solution DSL compatibility
                    if (initVal !== null && initVal.startsWith("<") && initVal.endsWith(">")) {
                        val seqContent = initVal.substring(1, initVal.length - 1).trim
                        if (!seqContent.isEmpty) {
                            initVal = "seq(" + seqContent + ")"
                        } else {
                            initVal = null
                        }
                    }
                    if (initVal !== null && !initVal.equals("seq()")) {
                        stateVars.append("        ").append(varName).append(" : ").append(varType).append(" = ").append(initVal).append(";\n")
                    }
                }
            }
        }

        // Extract [t == t] constraints that define T_geom computations
        // Format: (T_geom_i) [ t == t] ==B_i * T_offset_i
        val computationLines = new StringBuilder()
        val tGeomPattern = Pattern.compile("\\(\\s*(T_geom_\\d+)\\s*\\)\\s*\\[\\s*t\\s*==\\s*t\\s*\\]\\s*==\\s*(.+)")

        for (constraint : solution.constraints) {
            val constraintStr = (constraint.value as String).trim
            val matcher = tGeomPattern.matcher(constraintStr)
            if (matcher.find()) {
                val tGeomVar = matcher.group(1).trim   // e.g., T_geom_1
                val expression = matcher.group(2).trim  // e.g., B_1 * T_offset_1
                computationLines.append("            ").append(tGeomVar).append(" = ").append(expression).append(";\n")
            }
        }

        '''
        Solution physics_standalone_visual {
            datatypes {
                Geom { geomType: string; geomVal: vec() }
            }

            state {
«stateVars.toString()»
            }

            computation {
«IF computationLines.length > 0»
«computationLines.toString()»«ELSE»
                skip;
«ENDIF»
            }
        }
        '''
    }

    /** Build Geom record initializer from field constraints */
    static def String buildGeomInitializer(String varName, SlnRef solution) {
        // Find constraints: (varName . geomType) [ t == 0] ==box  (no quotes around value)
        //                  (varName . geomVal) [ t == 0] ==[| 0.5 , 0.5 |]
        val typePattern = Pattern.compile(
            "\\(\\s*" + varName + "\\s*\\.\\s*geomType\\s*\\)\\s*\\[\\s*t\\s*==\\s*0\\s*\\]\\s*==\\s*(.+)"
        )
        val valPattern = Pattern.compile(
            "\\(\\s*" + varName + "\\s*\\.\\s*geomVal\\s*\\)\\s*\\[\\s*t\\s*==\\s*0\\s*\\]\\s*==\\s*\\[\\|(.+?)\\|\\]"
        )

        var String geomType = null
        var String geomVal = null

        for (constraint : solution.constraints) {
            val constraintStr = constraint.value as String
            val typeMatcher = typePattern.matcher(constraintStr)
            if (typeMatcher.find()) {
                // geomType is e.g. "box" or "cylinder" - no quotes in constraint, add quotes for DSL
                geomType = "\"" + typeMatcher.group(1).trim() + "\""
            }
            val valMatcher = valPattern.matcher(constraintStr)
            if (valMatcher.find()) {
                // Convert [| a, b, c |] to [a, b, c]
                geomVal = "[" + valMatcher.group(1).trim().replaceAll("\\s+", " ") + "]"
            }
        }

        if (geomType !== null && geomVal !== null) {
            return '''Geom { geomType = «geomType», geomVal = «geomVal» }'''
        }

        // Fallback if constraints not found
        return "Geom { geomType = \"\", geomVal = [] }"
    }
}

/**
 * SKO::Visualisation method - computes T_geom sequence (transform matrices for visualization)
 * T_geom_i = B_i * T_offset_i for each link
 * This method is a placeholder for T_geom setup; actual computation is in Visual method.
 */
static class Visualisation {
    static def String asSolution(SlnRef solution) {
        // Visualisation method computes T_geom sequence (transform matrices for visualization)
        // T_geom_i = B_i * T_offset_i for each link
        val exprName = solution.expression.name
        val exprType = simplifyType(solution.expression.type)

        // Extract n (number of links) from constraints if available, otherwise default to 3
        var n = 3
        val nPattern = Pattern.compile("\\(\\s*n\\s*\\)\\s*\\[\\s*t\\s*==\\s*0\\s*\\]\\s*==\\s*(\\d+)")
        for (constraint : solution.constraints) {
            val matcher = nPattern.matcher((constraint.value as String).trim)
            if (matcher.find()) {
                n = Integer.parseInt(matcher.group(1).trim)
            }
        }

        // Build T_geom_i and T_offset_i state declarations
        val stateDecls = new StringBuilder()
        for (i : 1 ..< n + 1) {
            stateDecls.append("        T_geom_").append(i).append(" : mat(4,4) = zeroMat(4, 4);\n")
            stateDecls.append("        T_offset_").append(i).append(" : mat(4,4) = zeroMat(4, 4);\n")
        }

        // Build T_geom sequence initialization
        val seqElements = new StringBuilder()
        for (i : 1 ..< n + 1) {
            if (i > 1) seqElements.append(", ")
            seqElements.append("T_geom_").append(i)
        }

        // Build computation lines for T_geom_i = B_i * T_offset_i
        val computationLines = new StringBuilder()
        for (i : 1 ..< n + 1) {
            computationLines.append("            T_geom_").append(i).append(" = B_").append(i).append(" * T_offset_").append(i).append(";\n")
        }

        '''
        Solution physics_visualisation {
            state {
                «exprName» : «exprType» = seq(«seqElements»);
«stateDecls»            }

            functions {
                function zeroMat(rows: int, cols: int):mat() { }
            }

            computation {
«computationLines»            }
        }
        '''
    }
}

/**
 * SensorOutputMapping method for sensor output mappings (p_mapping outputs).
 *
 * Parses constraints like:
 *   (p_mapping.AcrobotControlled.BaseLink.ShoulderEncoder.AngleOut) [t == t] == theta(0)
 *   (p_mapping.AcrobotControlled.BaseLink.ShoulderEncoder.VelocityOut) [t == t] == d_theta(0)
 *
 * Generates code that populates sensor output fields from physics state variables.
 */
static class SensorOutputMapping {
    static val sensorPathRegistry = new java.util.concurrent.ConcurrentHashMap<String, java.util.LinkedHashMap<String, String>>()

    static def String asSolution(SlnRef solution) {
        // Parse sensor output constraints: (p_mapping.path.OutputVar) [t == t] == stateVar(index)
        // These constraints document the relationship between sensor outputs and state variables.
        // The actual mapping to p_mapping struct is handled by platform_mapping_adapter.cpp
        val sensorPattern = Pattern.compile("\\(\\s*([^)]+)\\s*\\)\\s*\\[\\s*t\\s*==\\s*t\\s*\\]\\s*==\\s*(.+)")
        val sensorOutputs = new java.util.LinkedHashMap<String, String>()  // outputPath -> stateExpr

        for (constraint : solution.constraints) {
            val text = (constraint.value as String).trim
            val m = sensorPattern.matcher(text)
            if (m.find()) {
                val outputPath = m.group(1).trim   // e.g. "p_mapping.AcrobotControlled.BaseLink.ShoulderEncoder.AngleOut"
                val stateExprRaw = m.group(2).trim    // e.g. "theta(0)"
                // Convert slnRef notation theta(0) to solutionDSL notation theta[0]
                val stateExpr = convertToSolutionDSLSyntax(stateExprRaw)

                // Store the mapping for documentation/proof purposes
                if (outputPath.startsWith("p_mapping.")) {
                    val cleanedPath = cleanSensorOutputPath(outputPath)
                    sensorOutputs.put(cleanedPath, stateExpr)
                }
            }
        }

        // Store sensor outputs in registry for other components to query
        sensorPathRegistry.put(solution.expression.name, sensorOutputs)

        // Generate proof block constraints documenting sensor output relationships
        // The actual p_mapping population is done by platform_mapping_adapter.cpp
        val proofConstraints = new java.util.ArrayList<String>()
        for (entry : sensorOutputs.entrySet) {
            val outputPath = entry.key
            val stateExpr = entry.value
            // Document the relationship: sensor_output == state_expression
            proofConstraints.add("// " + outputPath + " == " + stateExpr)
        }

        val proofBlock = if (!proofConstraints.isEmpty) {
            '''
            proof {
                // Sensor output mapping constraints (documentation only)
                // Actual mapping to p_mapping struct is in platform_mapping_adapter.cpp
                «proofConstraints.join("\n            ")»
            }'''
        } else {
            ""
        }

        // Generate minimal Solution block - no computation needed since adapter handles mapping
        return '''
        Solution sensor_outputs {
            state{ «solution.expression.name» : «simplifyType(solution.expression.type)» = 0;
            }

            computation{
                // Sensor output mapping: theta/d_theta are already computed
                // The platform_mapping_adapter.cpp copies these to p_mapping struct
                skip;
            }
            «proofBlock»
        }
        '''
    }

    static def getSensorPaths() {
        sensorPathRegistry
    }

    static def String cleanSensorOutputPath(String originalPath) {
        if (originalPath === null) {
            return ""
        }
        // Normalize whitespace
        var cleaned = originalPath.replaceAll("\\s+", "")
        return cleaned
    }

    /**
     * Converts slnRef notation to solutionDSL notation.
     * Transforms vector access from parenthesis notation varName(index) to bracket notation varName[index].
     * This is necessary because slnRef uses varName(N) but solutionDSL expects varName[N] for array access.
     * Handles any variable name (theta, d_theta, tau, etc.).
     */
    static def String convertToSolutionDSLSyntax(String expr) {
        if (expr === null) {
            return ""
        }
        // Convert any identifier followed by (number) to identifier[number]
        // Pattern: word_chars followed by (digits) -> word_chars[digits]
        return expr.replaceAll("([a-zA-Z_][a-zA-Z0-9_]*)\\((\\d+)\\)", "$1[$2]")
    }
}

}
