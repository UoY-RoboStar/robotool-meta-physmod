package circus.robocalc.robosim.physmod.libs.sourceCodeGen.formulation

import org.eclipse.emf.common.util.EList
import org.eclipse.emf.common.util.BasicEList
import java.util.regex.Pattern
import java.io.StringReader
import java.util.ArrayList
import javax.script.ScriptEngineManager
import java.util.List
import circus.robocalc.robosim.physmod.slnRef.slnRef.SlnRef
import circus.robocalc.robosim.physmod.slnRef.slnRef.SlnRefs
import circus.robocalc.robosim.physmod.slnDF.slnDF.SlnDFFactory
import circus.robocalc.robosim.physmod.libs.sourceCodeGen.solutionLib.SolutionRef
import circus.robocalc.robosim.physmod.libs.sourceCodeGen.solutionLib.Local
import static circus.robocalc.robosim.physmod.libs.sourceCodeGen.libUtils.libUtils.*

// SKO closed-chain specific helpers
class SKO_closed{
	static class ForwardKinematicsClosedChain {
		static def String asSolution(SlnRef solution) {
			val IC_value = SKO.getInitalValue(solution.expression.name, solution.expression.type, solution)
			// Extract X_J constraints from slnRef [ t == t] constraints
			val xjConstraints = extractXJConstraints(solution)
			var bCount = 0
			for (input : solution.inputs) {
				val name = input.value?.name
				if (name !== null && name.startsWith("B_") && !name.startsWith("B_k")) {
					val suffix = name.substring(2)
					if (suffix.matches("\\d+")) {
						val idx = Integer.parseInt(suffix)
						if (idx > bCount) {
							bCount = idx
						}
					}
				}
			}
			val stateDecls = new StringBuilder
			stateDecls.append(solution.expression.name + " : " + simplifyType(solution.expression.type))
			if (IC_value !== null && IC_value != "seq()") {
				stateDecls.append(" = " + IC_value)
			}
			stateDecls.append(";\n")
			for (input : solution.inputs) {
				val isExpr = solution.expression !== null && input.value.name == solution.expression.name
				if (!isExpr) {
					val init = SKO.getInitalValue(input.value.name, input.value.type, solution)
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

	            functions {
	                function Identity(n: int, m: int): mat() { }
	                // Math helpers to allow trig in generated code
	                function cos(x: float): float { }
	                function sin(x: float): float { }
	            }

	            computation {
	                // X_J assignments from slnRef [ t == t] constraints
	                «xjAssignments.toString»
	                T_up: mat(4,4);
	                R_up: mat(3,3);
	                BL_up: mat(3,3);
	                S_up: mat(3,3);
	                p_up: vec(3);
	                X_T_k: mat(6,6);
	                X_J_local: mat(6,6);
	                X_up: mat(6,6);
	                // Forward kinematics: propagate base -> tip using combined transform
	                for (k: int in range(n - 2, -1, -1)) {
	                    X_T_k = X_T[k];
	                    X_J_local = X_J[k];
	                    X_up = X_T_k * X_J_local;
	                    for (i: int in range(0, 3, 1)) {
	                        for (j: int in range(0, 3, 1)) {
	                            R_up[i,j] = X_up[i,j];
	                            BL_up[i,j] = X_up[i+3,j];
	                        }
	                    }
	                    for (i: int in range(0, 3, 1)) {
	                        for (j: int in range(0, 3, 1)) {
	                            S_up[i,j] = 0;
	                            for (m: int in range(0, 3, 1)) {
	                                // S = -BL * R^T -> S[i,j] -= BL[i,m] * R[j,m]
	                                S_up[i,j] = S_up[i,j] - BL_up[i,m] * R_up[j,m];
	                            }
	                        }
	                    }
	                    p_up[0] = S_up[2,1];
	                    p_up[1] = S_up[0,2];
	                    p_up[2] = S_up[1,0];
	                    for (i: int in range(0, 3, 1)) {
	                        for (j: int in range(0, 3, 1)) {
	                            T_up[i,j] = R_up[i,j];
	                        }
	                    }
	                    for (i: int in range(0, 3, 1)) {
	                        T_up[i,3] = p_up[i];
	                    }
	                    T_up[3,0] = 0;
	                    T_up[3,1] = 0;
	                    T_up[3,2] = 0;
	                    T_up[3,3] = 1;
	                    «solution.expression.name»[k] = «solution.expression.name»[k + 1] * T_up;
	                }
					«IF bCount > 0»
					// Keep B_i variables in sync with B_k
					«FOR i : 1 .. bCount»
					B_«i» = «solution.expression.name»[«i - 1»];
					«ENDFOR»
					«ENDIF»
	            }
			}
			'''
		}
	}

	static class ConstraintProjectionClosedChain{
		static def String asSolution(SlnRef solution) {
			val nTree = getVectorSize(solution.expression.type)
			val xjConstraints = extractXJConstraints(solution)
			val hasBkInput = solution.inputs.exists[it.value?.name == "B_k"]
			val hasXjInput = solution.inputs.exists[it.value?.name == "X_J"]
			val hasXtInput = solution.inputs.exists[it.value?.name == "X_T"]
			val hasNInput = solution.inputs.exists[it.value?.name == "n"]
			var bCount = 0
			for (input : solution.inputs) {
				val name = input.value?.name
				if (name !== null && name.startsWith("B_") && !name.startsWith("B_k")) {
					val suffix = name.substring(2)
					if (suffix.matches("\\d+")) {
						val idx = Integer.parseInt(suffix)
						if (idx > bCount) {
							bCount = idx
						}
					}
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

			var nLoopValue = 0
			val nLoopPattern = Pattern.compile("\\(\\s*nLoop\\s*\\)\\s*\\[\\s*t\\s*==\\s*0\\s*\\]\\s*==\\s*(\\d+)")
			for (constraint : solution.constraints) {
				val matcher = nLoopPattern.matcher((constraint.value as String).trim)
				if (matcher.find()) {
					nLoopValue = Integer.parseInt(matcher.group(1).trim)
				}
			}
			val posDim = 3 * nLoopValue

			'''
	        Solution temp {
	            state{ «solution.expression.name» : «simplifyType(solution.expression.type)» = «SKO.getInitalValue(solution.expression.name,solution.expression.type, solution)»;
	                    «getInputs(solution)»
	            }
	            functions{
	                function LDLT(matIn:mat()):mat(){
	                }
	                function zeroMat(rows: int, cols: int):mat(){
	                }
	                function zeroVec(size: int):vec(){
	                }
	            }
	            computation{
	                        «IF nLoopValue > 0»
	                        G_pos: mat(«posDim»,«nTree») = zeroMat(«posDim»,«nTree»);

	                        for (loop: int in range(0, «nLoopValue», 1)) {
	                            for (row: int in range(0, 3, 1)) {
	                                for (col: int in range(0, «nTree», 1)) {
	                                    G_pos[3 * loop + row, col] = G_c[6 * loop + 3 + row, col];
	                                }
	                            }
	                        }

	                        S: mat(«posDim»,«posDim») = G_pos * transpose(G_pos);
	                        S_inv: mat(«posDim»,«posDim») = LDLT(S);
	                        delta: vec(«posDim») = - S_inv * g_pos;
	                        «solution.expression.name» = «solution.expression.name» + (transpose(G_pos) * delta);

	                        vres: vec(«posDim») = G_pos * d_theta;
	                        vcorr: vec(«posDim») = S_inv * vres;
	                        d_theta = d_theta - (transpose(G_pos) * vcorr);
							«IF hasBkInput && hasXjInput && hasXtInput && hasNInput»
							// Refresh kinematics after projection so B_k stays consistent with theta
							«xjAssignments.toString»
							T_up: mat(4,4);
							R_up: mat(3,3);
							BL_up: mat(3,3);
							S_up: mat(3,3);
							p_up: vec(3);
							X_T_k: mat(6,6);
							X_J_local: mat(6,6);
							X_up: mat(6,6);
							for (k: int in range(n - 2, -1, -1)) {
								X_T_k = X_T[k];
								X_J_local = X_J[k];
								X_up = X_T_k * X_J_local;
								for (i: int in range(0, 3, 1)) {
									for (j: int in range(0, 3, 1)) {
										R_up[i,j] = X_up[i,j];
										BL_up[i,j] = X_up[i+3,j];
									}
								}
								for (i: int in range(0, 3, 1)) {
									for (j: int in range(0, 3, 1)) {
										S_up[i,j] = 0;
										for (m: int in range(0, 3, 1)) {
											// S = -BL * R^T -> S[i,j] -= BL[i,m] * R[j,m]
											S_up[i,j] = S_up[i,j] - BL_up[i,m] * R_up[j,m];
										}
									}
								}
								p_up[0] = S_up[2,1];
								p_up[1] = S_up[0,2];
								p_up[2] = S_up[1,0];
								for (i: int in range(0, 3, 1)) {
									for (j: int in range(0, 3, 1)) {
										T_up[i,j] = R_up[i,j];
									}
								}
								for (i: int in range(0, 3, 1)) {
									T_up[i,3] = p_up[i];
								}
								T_up[3,0] = 0;
								T_up[3,1] = 0;
								T_up[3,2] = 0;
								T_up[3,3] = 1;
								B_k[k] = B_k[k + 1] * T_up;
							}
							«IF bCount > 0»
							«FOR i : 1 .. bCount»
							B_«i» = B_k[«i - 1»];
							«ENDFOR»
							«ENDIF»
							«ENDIF»
	                        «ENDIF»
	                        }
	                }
	        '''
		}
	}

	static class LoopPositionResidualsClosedChain{
		static def String asSolution(SlnRef solution) {
			val gPosName = if (solution.expression !== null && solution.expression.name !== null)
				solution.expression.name
			else
				"g_pos"
			val gPosRawType = if (solution.expression !== null && solution.expression.type !== null)
				solution.expression.type
			else
				"Null"
			val gPosType = simplifyType(gPosRawType)
			val IC_value = SKO.getInitalValue(gPosName, gPosRawType, solution)

			val nLoopValue = extractNLoopValue(solution)
			val posDim = if (nLoopValue > 0) 3 * nLoopValue else 0
			val loopInfos = extractLoopPositionInfo(solution, nLoopValue)

			val loopDecls = new StringBuilder
			val loopBody = new StringBuilder
			if (posDim > 0) {
				loopBody.append(gPosName + " = zeroVec(" + posDim + ");\n")
				for (idx : 0 ..< loopInfos.size) {
					val info = loopInfos.get(idx)
					if (info !== null && info.parentIndex >= 0 && info.childIndex >= 0) {
						val tmpName = "g_loop_" + idx
						loopDecls.append(tmpName + " : vec(3);\n")
						val poseVec = "[|" + info.poseX + ";" + info.poseY + ";" + info.poseZ + "|]"
						loopBody.append(tmpName + " = transpose(submatrix(B_k[" + info.parentIndex + "])(0,0,3,3)) * (" +
							"submatrix(B_k[" + info.parentIndex + "])(0,3,3,1) + " +
							"submatrix(B_k[" + info.parentIndex + "])(0,0,3,3) * " + poseVec + " - " +
							"submatrix(B_k[" + info.childIndex + "])(0,3,3,1));\n")
						loopBody.append("for (i: int in range(0, 3, 1)) {\n")
						loopBody.append("    " + gPosName + "[" + (3 * idx) + " + i] = " + tmpName + "[i];\n")
						loopBody.append("}\n")
					}
				}
			}

			'''
	        Solution temp {
	            state{ «gPosName» : «gPosType» «IF IC_value !== null» = «IC_value»«ENDIF»;
	                    «getInputs(solution)»
	            }
	            functions{
	                function zeroVec(size: int):vec(){
	                }
	            }
	            computation{
	                        «loopDecls.toString»
	                        «loopBody.toString»
	                        }
	                }
	        '''
		}
	}

	/**
	 * Extract X_J_i constraints from [ t == t] algebraic constraints.
	 * Returns a map from variable name (e.g., "X_J_1") to DSL matrix expression.
	 */
	static def java.util.LinkedHashMap<String, String> extractXJConstraints(SlnRef solution) {
		val result = new java.util.LinkedHashMap<String, String>()

		// Pattern for "(X_J_N) [ t == t] ==[|...|]"
		val xjPattern = Pattern.compile("\\(\\s*(X_J_\\d+)\\s*\\)\\s*\\[\\s*t\\s*==\\s*t\\s*\\]\\s*==\\s*(\\[\\|.+?\\|\\])")

		for (constraint : solution.constraints) {
			val text = (constraint.value as String).trim
			val matcher = xjPattern.matcher(text)
			if (matcher.find()) {
				val varName = matcher.group(1).trim
				val matrixLiteral = matcher.group(2).trim
				result.put(varName, convertToDSLSyntax(matrixLiteral))
			}
		}

		return result
	}

	private static class LoopInfo {
		var int parentIndex = -1
		var int childIndex = -1
		var String poseX = "0"
		var String poseY = "0"
		var String poseZ = "0"
	}

	private static def int extractNLoopValue(SlnRef solution) {
		var nLoopValue = 0
		val nLoopPattern = Pattern.compile("\\(\\s*nLoop\\s*\\)\\s*\\[\\s*t\\s*==\\s*0\\s*\\]\\s*==\\s*(\\d+)")
		if (solution.constraints !== null) {
			for (constraint : solution.constraints) {
				val matcher = nLoopPattern.matcher((constraint.value as String).trim)
				if (matcher.find()) {
					nLoopValue = Integer.parseInt(matcher.group(1).trim)
				}
			}
		}
		return nLoopValue
	}

	private static def List<LoopInfo> extractLoopPositionInfo(SlnRef solution, int nLoopValue) {
		val infos = new ArrayList<LoopInfo>
		for (i : 0 ..< nLoopValue) {
			infos.add(new LoopInfo)
		}
		if (solution.constraints === null) {
			return infos
		}

		val bselPattern = Pattern.compile(
			"submatrix\\s*\\(\\s*B_sel\\s*\\)\\s*\\(\\s*(\\d+)\\s*,\\s*(\\d+)\\s*,\\s*6\\s*,\\s*6\\s*\\)",
			Pattern.CASE_INSENSITIVE
		)
		val identityPattern = Pattern.compile("identity\\s*\\(\\s*6\\s*\\)", Pattern.CASE_INSENSITIVE)
		val qcPattern = Pattern.compile(
			"submatrix\\s*\\(\\s*Q_c\\s*\\)\\s*\\(\\s*(\\d+)\\s*,\\s*(\\d+)\\s*,\\s*6\\s*,\\s*6\\s*\\)\\s*\\)\\s*\\[\\s*t\\s*==\\s*0\\s*\\]\\s*==\\s*(\\[\\|.+?\\|\\])",
			Pattern.CASE_INSENSITIVE
		)

		for (constraint : solution.constraints) {
			val text = (constraint.value as String).trim

			val bselMatcher = bselPattern.matcher(text)
			if (bselMatcher.find && identityPattern.matcher(text).find) {
				val rowIdx = Integer.parseInt(bselMatcher.group(1))
				val colIdx = Integer.parseInt(bselMatcher.group(2))
				val loopIdx = rowIdx / 12
				if (loopIdx >= 0 && loopIdx < infos.size) {
					val linkIndex = colIdx / 6
					if ((rowIdx % 12) < 6) {
						infos.get(loopIdx).parentIndex = linkIndex
					} else {
						infos.get(loopIdx).childIndex = linkIndex
					}
				}
			}

			val qcMatcher = qcPattern.matcher(text)
			if (qcMatcher.find) {
				val rowIdx = Integer.parseInt(qcMatcher.group(1))
				val colIdx = Integer.parseInt(qcMatcher.group(2))
				if ((rowIdx % 6) == 0 && (colIdx % 12) == 0) {
					val loopIdx = rowIdx / 6
					if (loopIdx >= 0 && loopIdx < infos.size) {
						val matrixLiteral = qcMatcher.group(3).trim
						val matrixRows = parseMatrixLiteral(matrixLiteral)
						val poseZ = getMatrixValue(matrixRows, 3, 1)
						val poseY = getMatrixValue(matrixRows, 5, 0)
						val poseX = getMatrixValue(matrixRows, 4, 2)
						val info = infos.get(loopIdx)
						info.poseX = poseX
						info.poseY = poseY
						info.poseZ = poseZ
					}
				}
			}
		}

		return infos
	}

	private static def List<List<String>> parseMatrixLiteral(String literal) {
		var content = literal.trim
		if (content.startsWith("[|") && content.endsWith("|]")) {
			content = content.substring(2, content.length - 2).trim
		}
		val rows = new ArrayList<List<String>>
		for (rowText : content.split(";")) {
			val row = new ArrayList<String>
			for (entry : rowText.split(",")) {
				val token = entry.replaceAll("\\s+", "")
				if (!token.isEmpty) {
					row.add(token)
				}
			}
			if (!row.empty) {
				rows.add(row)
			}
		}
		return rows
	}

	private static def String getMatrixValue(List<List<String>> rows, int row, int col) {
		if (row < 0 || row >= rows.size) {
			return "0"
		}
		val r = rows.get(row)
		if (col < 0 || col >= r.size) {
			return "0"
		}
		val value = r.get(col)
		return if (value === null || value.isEmpty) "0" else value
	}

	/**
	 * Converts slnRef matrix syntax to DSL syntax.
	 * - [|...|] becomes [...]
	 * - theta(i) becomes theta[i]
	 */
	private static def String convertToDSLSyntax(String input) {
		var result = input
		if (result.startsWith("[|") && result.endsWith("|]")) {
			result = result.substring(2, result.length - 2).trim
		}
		result = result.replaceAll("theta\\((\\d+)\\)", "theta[$1]")
		return "[" + result + "]"
	}
}
