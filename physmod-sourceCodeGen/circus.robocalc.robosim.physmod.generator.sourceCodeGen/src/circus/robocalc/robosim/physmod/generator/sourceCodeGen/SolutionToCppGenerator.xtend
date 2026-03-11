/*
 * Copyright (c) 2023-2025 University of York and others
 * 
 * This program and the accompanying materials are made available under the
 * terms of the Eclipse Public License 2.0 which is available at
 * http://www.eclipse.org/legal/epl-2.0.
 * 
 * SPDX-License-Identifier: EPL-2.0
 * 
 * Contributors:
 *   Arjun Badyal - initial definition
 ********************************************************************************/

package circus.robocalc.robosim.physmod.generator.sourceCodeGen

import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EStructuralFeature
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.AbstractGenerator
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGeneratorContext
import circus.robocalc.robosim.physmod.slnDF.slnDF.Addition
import circus.robocalc.robosim.physmod.slnDF.slnDF.Assignment
import circus.robocalc.robosim.physmod.slnDF.slnDF.Block
import circus.robocalc.robosim.physmod.slnDF.slnDF.BlockMatrix
import circus.robocalc.robosim.physmod.slnDF.slnDF.Computation
import circus.robocalc.robosim.physmod.slnDF.slnDF.Equality
import circus.robocalc.robosim.physmod.slnDF.slnDF.Expression
import circus.robocalc.robosim.physmod.slnDF.slnDF.FloatExp
import circus.robocalc.robosim.physmod.slnDF.slnDF.BooleanExp
import circus.robocalc.robosim.physmod.slnDF.slnDF.BoolType
import circus.robocalc.robosim.physmod.slnDF.slnDF.FloatType
import circus.robocalc.robosim.physmod.slnDF.slnDF.ForLoop
import circus.robocalc.robosim.physmod.slnDF.slnDF.FuncLeftExpr
import circus.robocalc.robosim.physmod.slnDF.slnDF.FuncLeftSubmatrix
import circus.robocalc.robosim.physmod.slnDF.slnDF.FuncLeftSubvector
import circus.robocalc.robosim.physmod.slnDF.slnDF.Function
import circus.robocalc.robosim.physmod.slnDF.slnDF.SemanticExpression
import org.eclipse.emf.common.util.EList
import circus.robocalc.robosim.physmod.slnDF.slnDF.FunctionCall
import circus.robocalc.robosim.physmod.slnDF.slnDF.FunctionForLoop
import circus.robocalc.robosim.physmod.slnDF.slnDF.FunctionIfThen
import circus.robocalc.robosim.physmod.slnDF.slnDF.Functions
import circus.robocalc.robosim.physmod.slnDF.slnDF.IfThenElse
import circus.robocalc.robosim.physmod.slnDF.slnDF.IntType
import circus.robocalc.robosim.physmod.slnDF.slnDF.IntegerExp
import circus.robocalc.robosim.physmod.slnDF.slnDF.LeftDArr
import circus.robocalc.robosim.physmod.slnDF.slnDF.LeftExpr
import circus.robocalc.robosim.physmod.slnDF.slnDF.LeftRecordField
import circus.robocalc.robosim.physmod.slnDF.slnDF.LeftSubmatrix
import circus.robocalc.robosim.physmod.slnDF.slnDF.LeftSubvector
import circus.robocalc.robosim.physmod.slnDF.slnDF.LeftVar
import circus.robocalc.robosim.physmod.slnDF.slnDF.MatType
import circus.robocalc.robosim.physmod.slnDF.slnDF.Multiplication
import circus.robocalc.robosim.physmod.slnDF.slnDF.ParameterDeclaration
import circus.robocalc.robosim.physmod.slnDF.slnDF.Primary
import circus.robocalc.robosim.physmod.slnDF.slnDF.Procedure
import circus.robocalc.robosim.physmod.slnDF.slnDF.ProcedureCall
import circus.robocalc.robosim.physmod.slnDF.slnDF.Procedures
import circus.robocalc.robosim.physmod.slnDF.slnDF.RecordExp
import circus.robocalc.robosim.physmod.slnDF.slnDF.RelationalExpression
import circus.robocalc.robosim.physmod.slnDF.slnDF.RowLiteral
import circus.robocalc.robosim.physmod.slnDF.slnDF.SKIP
import circus.robocalc.robosim.physmod.slnDF.slnDF.SemanticExpression
import circus.robocalc.robosim.physmod.slnDF.slnDF.SemExprSeq
import circus.robocalc.robosim.physmod.slnDF.slnDF.SeqType
import circus.robocalc.robosim.physmod.slnDF.slnDF.SequenceLiteral
import circus.robocalc.robosim.physmod.slnDF.slnDF.Solution
import circus.robocalc.robosim.physmod.slnDF.slnDF.State
import circus.robocalc.robosim.physmod.slnDF.slnDF.Statement
import circus.robocalc.robosim.physmod.slnDF.slnDF.Submatrix
import circus.robocalc.robosim.physmod.slnDF.slnDF.Subvector
import circus.robocalc.robosim.physmod.slnDF.slnDF.Type
import circus.robocalc.robosim.physmod.slnDF.slnDF.TypeRef
import circus.robocalc.robosim.physmod.slnDF.slnDF.Unary
import circus.robocalc.robosim.physmod.slnDF.slnDF.VMBlock
import circus.robocalc.robosim.physmod.slnDF.slnDF.VariableLine
import circus.robocalc.robosim.physmod.slnDF.slnDF.VariableReference
import circus.robocalc.robosim.physmod.slnDF.slnDF.VecType
import circus.robocalc.robosim.physmod.slnDF.slnDF.VectorOrMatrix
import circus.robocalc.robosim.physmod.slnDF.slnDF.DataTypes
import circus.robocalc.robosim.physmod.slnDF.slnDF.CustomType
import circus.robocalc.robosim.physmod.slnDF.slnDF.DataType
import circus.robocalc.robosim.physmod.slnDF.slnDF.Field
import circus.robocalc.robosim.physmod.slnDF.slnDF.FieldDefinition
import circus.robocalc.robosim.physmod.slnDF.slnDF.StringType
import circus.robocalc.robosim.physmod.slnDF.slnDF.StringExp
import org.eclipse.xtext.nodemodel.util.NodeModelUtils

/**
 * Generates C++ code from Solution models.
 * 
 * Moved from SolutionDSL-textual to T5_sourceCodeGen for integration into the full pipeline.
 */
class SolutionToCppGenerator extends AbstractGenerator {
    
    var String currentFunctionName = ""
    var String currentLeftExpr = ""
    
    override void doGenerate(Resource res, IFileSystemAccess2 fsa, IGeneratorContext context) {
        for (e : res.allContents.toIterable.filter(Solution)) {
            fsa.generateFile(
                "solution.cpp",
                e.compile
            )
        }
    }

    def String compile(Solution sln) {
        var StringBuilder cppCode = new StringBuilder()

        cppCode.append("#include <iostream>\n#include <Eigen/Dense>\n#include <Eigen/Geometry>\n#include <vector>\n#include <string>\n\n")
        if (sln.datatypes !== null) {
            cppCode.append(generateDataTypes(sln.datatypes))
        }
        cppCode.append(generateState(sln.state))
        if (sln.procedures !== null) {
            cppCode.append(generateProcedures(sln.procedures))
        }
        if (sln.functions !== null) {
            cppCode.append(generateFunctions(sln.functions))
        }
        if (sln.functions !== null || sln.procedures !== null) {
            cppCode.append("\n")
        }
        cppCode.append("int main() {\n")
        cppCode.append("    initGlobals();\n")
        for (stmt : sln.computation.lines) {
            val stmtCode = if (stmt instanceof Block) {
                val blk = stmt as Block
                if (blk.statements.size == 1) {
                    val only = blk.statements.get(0)
                    if (only instanceof ForLoop || only instanceof IfThenElse) {
                        generateBlock(blk)
                    } else {
                        generateCppStatement(only)
                    }
                } else {
                    generateBlock(blk)
                }
            } else if (stmt instanceof ForLoop || stmt instanceof IfThenElse) {
                val innerCode = generateCppStatement(stmt)
                "{\n" + indent(innerCode, 4) + "\n}"
            } else {
                generateCppStatement(stmt)
            }
            cppCode.append(indent(stmtCode, 4) + "\n")
        }
        cppCode.append("    return 0;\n")
        cppCode.append("}\n")
        
        return cppCode.toString
    }

def String generateState(State state) {
    var cppCode = new StringBuilder()
    for (v : state.variables) {
        val varName = v.variable.name
        var typeStr = mapType(v.variable.type)

        if (typeStr == "null" || typeStr == "Geom") {
            if (varName !== null && varName.contains("geom")) {
                typeStr = "int"
            } else {
                typeStr = "int"
            }
        }
        
        cppCode.append(typeStr + " " + varName + ";\n")
    }
    cppCode.append("\n")
    // Split initialization into two passes:
    // 1. Non-SeqType variables (individual matrices, vectors, etc.)
    // 2. SeqType variables (vectors of matrices) - must come after component initialization
    // Track variable names with their initialization code
    val nonSeqInitsWithNames = state.variables
        .filter[v | v.variable.initialValue !== null && !(v.variable.type instanceof SeqType)]
        .map[v | {
            val name = v.variable.name
            currentLeftExpr = name
            val initValue = v.variable.initialValue
            
            if (v.variable.type instanceof MatType) {
                val mt = v.variable.type as MatType
                val rowsExpr = mt.rows !== 0 ? mt.rows.toString : "/*?*/"
                val colsExpr = mt.columns !== 0 ? mt.columns.toString : "/*?*/"
                val literal = switch initValue {
                    Primary case (initValue as Primary).base instanceof VectorOrMatrix:
                        (initValue as Primary).base as VectorOrMatrix
                    VectorOrMatrix:
                        initValue as VectorOrMatrix
                    default:
                        null
                }
                val partialLiteralCode = if (literal !== null)
                        generatePartialMatrixLiteralAssignment(name, mt, literal, rowsExpr, colsExpr)
                    else
                        null
                
                if (initValue instanceof Primary && (initValue as Primary).base instanceof BlockMatrix) {
                    val initCode = generateCppExpression(initValue as Expression)
                    val code = "    " + name + " = Eigen::MatrixXd::Zero(" + rowsExpr + ", " + colsExpr + ");\n" +
                           initCode + "\n"
                    return Pair.of(name, code)
                }
                
                if (partialLiteralCode !== null) {
                    return Pair.of(name, partialLiteralCode)
                }
                
                val initCode = if (initValue instanceof Expression)
                                   generateCppExpression(initValue as Expression)
                               else
                                   initValue !== null ? initValue.toString : "/* undefined */"
                
                if (initValue instanceof Primary && 
                    (initValue as Primary).base instanceof VectorOrMatrix) {
                    // Check if this is a partial literal that needs element-wise assignment
                    val litBase = (initValue as Primary).base as VectorOrMatrix
                    val partialCheck = generatePartialMatrixLiteralAssignment(name, mt, litBase, rowsExpr, colsExpr)
                    if (partialCheck !== null) {
                        return Pair.of(name, partialCheck)
                    }
                    val code = "    " + name + " = Eigen::MatrixXd::Zero(" + rowsExpr + ", " + colsExpr + ");\n" +
                           "    " + name + " << " + initCode + ";\n"
                    return Pair.of(name, code)
                }
                if (initValue instanceof VectorOrMatrix) {
                    // Check if this is a partial literal that needs element-wise assignment
                    val partialCheck = generatePartialMatrixLiteralAssignment(name, mt, initValue as VectorOrMatrix, rowsExpr, colsExpr)
                    if (partialCheck !== null) {
                        return Pair.of(name, partialCheck)
                    }
                    val code = "    " + name + " = Eigen::MatrixXd::Zero(" + rowsExpr + ", " + colsExpr + ");\n" +
                           "    " + name + " << " + initCode + ";\n"
                    return Pair.of(name, code)
                }
                if (initCode != null && initCode.contains(",") && !initCode.contains("(") && !initCode.startsWith("zeroMat") && !initCode.startsWith("Identity")) {
                    // Check if this is a partial literal by counting elements
                    val elements = initCode.split(",").length
                    val expectedElements = mt.rows * mt.columns
                    if (elements < expectedElements) {
                        // Partial literal detected - use element-wise assignment
                        if (literal !== null) {
                            // Use existing literal extraction
                            val partialCheck = generatePartialMatrixLiteralAssignment(name, mt, literal, rowsExpr, colsExpr)
                            if (partialCheck !== null) {
                                return Pair.of(name, partialCheck)
                            }
                        } else {
                            // Fallback: parse initCode string to create element-wise assignments
                            val elementValues = initCode.split(",").map[trim]
                            val builder = new StringBuilder
                            builder.append("    " + name + " = Eigen::MatrixXd::Zero(" + rowsExpr + ", " + colsExpr + ");\n")
                            
                            // Parse elements row by row (assuming row-major order)
                            var elementIndex = 0
                            for (rowIdx : 0 ..< mt.rows) {
                                for (colIdx : 0 ..< mt.columns) {
                                    if (elementIndex < elementValues.length) {
                                        val value = elementValues.get(elementIndex).trim
                                        // Only set non-zero elements (optimization)
                                        if (!value.equals("0") && !value.equals("0.0")) {
                                            builder.append("    " + name + "(" + rowIdx + ", " + colIdx + ") = " + value + ";\n")
                                        }
                                        elementIndex++
                                    }
                                }
                            }
                            return Pair.of(name, builder.toString)
                        }
                    }
                    val code = "    " + name + " = Eigen::MatrixXd(" + rowsExpr + ", " + colsExpr + ");\n" +
                           "    " + name + " << " + initCode + ";\n"
                    return Pair.of(name, code)
                } else {
                    val code = "    " + name + " = " + initCode + ";\n"
                    return Pair.of(name, code)
                }
            } else if (v.variable.type instanceof VecType) {
                val vt = v.variable.type as VecType
                val sizeExpr = vt.size !== 0 ? vt.size.toString : "/*?*/"
                val initCode = if (initValue instanceof Expression)
                                   generateCppExpression(initValue as Expression)
                               else
                                   initValue !== null ? initValue.toString : "/* undefined */"
                if (initValue instanceof Primary && 
                    (initValue as Primary).base instanceof VectorOrMatrix) {
                    val code = "    " + name + " = Eigen::VectorXd::Zero(" + sizeExpr + ");\n" +
                           "    " + name + " << " + initCode + ";\n"
                    return Pair.of(name, code)
                }
                if (initValue instanceof VectorOrMatrix) {
                    val code = "    " + name + " = Eigen::VectorXd::Zero(" + sizeExpr + ");\n" +
                           "    " + name + " << " + initCode + ";\n"
                    return Pair.of(name, code)
                }
                val code = "    " + name + " = Eigen::VectorXd::Zero(" + sizeExpr + ");\n" +
                       "    " + name + " = " + initCode + ";\n"
                return Pair.of(name, code)
            } else {
                val initCode = if (initValue instanceof Expression)
                                   generateCppExpression(initValue as Expression)
                               else
                                   initValue !== null ? initValue.toString : "/* undefined */"
                val code = "    " + name + " = " + initCode + ";\n"
                Pair.of(name, code)
            }
        }]
    
    // Second pass: SeqType variables (must come after component matrices are initialized)
    // Extract component variable names referenced by sequences to ensure they're initialized first
    val seqDependencies = state.variables
        .filter[v | v.variable.initialValue !== null && (v.variable.type instanceof SeqType)]
        .flatMap[v | {
            val initValue = v.variable.initialValue
            if (initValue instanceof SequenceLiteral) {
                // Extract variable names from sequence literal (e.g., seq(X_J_1, X_J_2) -> [X_J_1, X_J_2])
                initValue.elements.filter[it instanceof VariableReference]
                    .map[it as VariableReference].map[it.variable.name]
            } else {
                emptyList
            }
        }].toSet
    
    val seqInitsWithNames = state.variables
        .filter[v | v.variable.initialValue !== null && (v.variable.type instanceof SeqType)]
        .map[v | {
            val name = v.variable.name
            currentLeftExpr = name
            val initValue = v.variable.initialValue
            val initCode = if (initValue instanceof Expression)
                               generateCppExpression(initValue as Expression)
                           else
                               initValue !== null ? initValue.toString : "/* undefined */"
            // Reassign sequence after component matrices are initialized
            // This ensures X_T[1] etc. have proper sizes when accessed
            val code = "    " + name + " = " + initCode + ";\n"
            Pair.of(name, code)
        }]
    
    // Build sorted initialization list: components referenced by sequences first, then other non-sequences, then sequences
    val allInits = newHashMap
    for (pair : nonSeqInitsWithNames) {
        allInits.put(pair.key, pair.value)
    }
    for (pair : seqInitsWithNames) {
        allInits.put(pair.key, pair.value)
    }
    
    val sortedInits = newArrayList
    // First, add all component variables (those referenced by sequences)
    for (depName : seqDependencies) {
        if (allInits.containsKey(depName)) {
            sortedInits.add(allInits.get(depName))
            allInits.remove(depName)
        }
    }
    // Then add all other non-sequence variables
    val remainingNonSeqs = nonSeqInitsWithNames.filter[p | !seqDependencies.contains(p.key) && allInits.containsKey(p.key)]
    for (pair : remainingNonSeqs) {
        sortedInits.add(pair.value)
        allInits.remove(pair.key)
    }
    // Finally, add all sequence variables
    for (pair : seqInitsWithNames) {
        if (allInits.containsKey(pair.key)) {
            sortedInits.add(pair.value)
        }
    }
    
    if (!sortedInits.isEmpty) {
         cppCode.append("void initGlobals() {\n")
         // Initialize in correct order: components first, then sequences
         for (init : sortedInits) {
             cppCode.append(init)
         }
         cppCode.append("}\n\n")
    }
    
    return cppCode.toString
}

def private String generatePartialMatrixLiteralAssignment(String name, MatType type, VectorOrMatrix literal, String rowsExpr, String colsExpr) {
    val expectedRows = type.rows
    val expectedCols = type.columns
    if (expectedRows <= 0 || expectedCols <= 0) {
        return null
    }

    // Check if this is a single-row literal that needs to be treated as partial
    val isSingleRowPartial = literal.rows.size == 1 && (literal.rows.get(0) as RowLiteral).elements.size < expectedRows * expectedCols
    
    var matchesShape = literal.rows.size == expectedRows
    if (matchesShape) {
        for (rowAny : literal.rows) {
            val row = rowAny as RowLiteral
            if (row.elements.size != expectedCols) {
                matchesShape = false
            }
        }
    }

    // If it matches shape exactly OR is a single-row partial, treat as partial
    if (matchesShape && !isSingleRowPartial) {
        return null
    }

    val builder = new StringBuilder
    builder.append("    " + name + " = Eigen::MatrixXd::Zero(" + rowsExpr + ", " + colsExpr + ");\n")
    
    if (isSingleRowPartial) {
        // Handle single-row literal: flatten and assign row by row
        val row = literal.rows.get(0) as RowLiteral
        var elementIndex = 0
        for (rowIdx : 0 ..< expectedRows) {
            for (colIdx : 0 ..< expectedCols) {
                if (elementIndex < row.elements.size) {
                    val element = row.elements.get(elementIndex)
                    val valueCode = generateCppExpression(element)
                    // Only set non-zero elements (optimization)
                    if (!valueCode.equals("0") && !valueCode.equals("0.0")) {
                        builder.append("    " + name + "(" + rowIdx + ", " + colIdx + ") = " + valueCode + ";\n")
                    }
                    elementIndex++
                }
            }
        }
    } else {
        // Handle multi-row literal
        val maxRow = Math.min(literal.rows.size, expectedRows)
        for (rowIdx : 0 ..< maxRow) {
            val row = literal.rows.get(rowIdx) as RowLiteral
            val maxCol = Math.min(row.elements.size, expectedCols)
            for (colIdx : 0 ..< maxCol) {
                val element = row.elements.get(colIdx)
                val valueCode = generateCppExpression(element)
                // Only set non-zero elements (optimization)
                if (!valueCode.equals("0") && !valueCode.equals("0.0")) {
                    builder.append("    " + name + "(" + rowIdx + ", " + colIdx + ") = " + valueCode + ";\n")
                }
            }
        }
    }
    return builder.toString
}


    def String generateCppExpression(Expression expr) {
        if (expr === null) {
            return "/* undefined */"
        }
		if (expr instanceof Primary) {
			val prim = expr
			var String code = generateCppExpression(prim.base)
			if (prim.indexes !== null && !prim.indexes.isEmpty) {
				if(prim.base instanceof VariableReference && (prim.base as VariableReference).variable.type instanceof SeqType){
					for (idx : prim.indexes) {
						val firstExpr = adjustSequenceIndex(idx.first, generateCppExpression(idx.first))
						if (idx.second !== null) {
							val secondExpr = adjustSequenceIndex(idx.second, generateCppExpression(idx.second))
							code = code + "[" + firstExpr + "," + secondExpr + "]"
						} else {
							code = code + "[" + firstExpr + "]"
						}
					}
				}
				else{
					for (idx : prim.indexes) {
						val firstAdj = adjustSequenceIndex(idx.first, generateCppExpression(idx.first))
						if (idx.second !== null) {
							val secondAdj = adjustSequenceIndex(idx.second, generateCppExpression(idx.second))
							code = code + "(" + firstAdj + "," + secondAdj + ")"
						} else {
							code = code + "(" + firstAdj + ")"
						}
					}
				}
			}
			return code
		}

        switch expr {
            RelationalExpression: {
                if(expr.operator == "==" && (expr.right instanceof VectorOrMatrix|| expr.left instanceof Submatrix)){
                    val leftExpr = generateCppExpression(expr.left)
                    val rightExpr = generateCppExpression(expr.right)
                    return leftExpr + " << " + rightExpr
                } else {
                    val leftExpr = generateCppExpression(expr.left)
                    val rightExpr = generateCppExpression(expr.right)
                    return leftExpr + " " + expr.operator + " " + rightExpr
                }
            }
            Addition: {
                val leftExpr = generateCppExpression(expr.left)
                val rightExpr = generateCppExpression(expr.right)
                return "(" + leftExpr + " " + expr.operator + " " + rightExpr + ")"
            }
            Multiplication: {
                val leftExpr = generateCppExpression(expr.left)
                val rightExpr = generateCppExpression(expr.right)
                return "(" + leftExpr + " " + expr.operator + " " + rightExpr + ")"
            }
            Unary: {
                return "-" + generateCppExpression(expr.operand)
            }
            FunctionCall: {
            var functionName = if (expr.function !== null && expr.function.name !== null) 
                expr.function.name 
            else 
                null
            if (functionName === null) {
                functionName = inferFunctionName(expr)
            }
            val argList = expr.arguments.map[generateCppExpression(it)].toList
            val args = argList.join(", ")
            
            // Check if function name is null (unresolved reference)
            if (functionName === null) {
                // For unresolved functions, check argument count to infer the function
                if (expr.arguments.size == 1) {
                    // Single argument - likely zeroVec
                    val size = generateCppExpression(expr.arguments.get(0))
                    return "Eigen::VectorXd::Zero(" + size + ")"
                } else if (expr.arguments.size == 2) {
                    // Two arguments - likely zeroMat
                    val rows = generateCppExpression(expr.arguments.get(0))
                    val cols = generateCppExpression(expr.arguments.get(1))
                    return "Eigen::MatrixXd::Zero(" + rows + ", " + cols + ")"
                } else {
                    // Unknown function
                    return "/* unresolved function */(" + args + ")"
                }
            }
            
            // Handle known functions
            if ((functionName == "cos" || functionName == "sin") && argList.size == 1) {
                return "std::" + functionName + "(" + args + ")"
            } else if (functionName == "sqrt" && argList.size == 1) {
                return "std::sqrt(" + args + ")"
            } else if (functionName == "pow" && argList.size == 2) {
                return "std::pow(" + argList.get(0) + ", " + argList.get(1) + ")"
            } else if (functionName == "ind" && argList.size == 3) {
                val z = argList.get(0)
                val lower = argList.get(1)
                val upper = argList.get(2)
                return "((" + z + " >= " + lower + " && " + z + " <= " + upper + ") ? 1.0 : 0.0)"
            } else if (functionName == "integral" && argList.size == 3) {
                val integrand = argList.get(0)
                val lower = argList.get(1)
                val upper = argList.get(2)
                return "(" + integrand + " * (" + upper + " - " + lower + "))"
            } else if (functionName == "zeroMat" && expr.arguments.size == 2) {
                val rows = generateCppExpression(expr.arguments.get(0))
                val cols = generateCppExpression(expr.arguments.get(1))
                return "Eigen::MatrixXd::Zero(" + rows + ", " + cols + ")"
            } else if (functionName == "Identity" || functionName == "identity") {
                if (argList.size == 1) {
                    val size = argList.get(0)
                    return "Eigen::MatrixXd::Identity(" + size + ", " + size + ")"
                } else if (argList.size == 2) {
                    return "Eigen::MatrixXd::Identity(" + argList.get(0) + ", " + argList.get(1) + ")"
                }
            } else if (functionName == "zeroVec" && expr.arguments.size == 1) {
                val size = generateCppExpression(expr.arguments.get(0))
                return "Eigen::VectorXd::Zero(" + size + ")"
            } else if (functionName == "null" && expr.arguments.size == 1) {
                // "null" function is likely meant to be zeroVec
                val size = generateCppExpression(expr.arguments.get(0))
                return "Eigen::VectorXd::Zero(" + size + ")"
            } else if (functionName == "transpose" || functionName == "adj" || functionName == "adjoint") {
                return generateCppExpression(expr.arguments.get(0)) + ".transpose()"
            } else if (functionName == "LDLT" && expr.arguments.size == 1) {
                val mat = generateCppExpression(expr.arguments.get(0))
                return mat + ".ldlt().solve(Eigen::MatrixXd::Identity(" +mat + ".rows(),"+ mat+ ".cols()))"
            } else {
                return functionName + "(" + args + ")"
            }
        }

            Submatrix: {
                val numRowsExpr = generateCppExpression(expr.numRows)
                val numColsExpr = generateCppExpression(expr.numCols)

                // Check if this is a 1x1 block - use element access to get scalar value
                if (numRowsExpr.equals("1") && numColsExpr.equals("1")) {
                    return generateCppExpression(expr.variable) + "(" +
                           generateCppExpression(expr.rowStart) + ", " +
                           generateCppExpression(expr.colStart) + ")"
                }

                return generateCppExpression(expr.variable) + ".block(" +
                       generateCppExpression(expr.rowStart) + ", " +
                       generateCppExpression(expr.colStart) + ", " +
                       numRowsExpr + ", " +
                       numColsExpr + ")"
            }
            Subvector: {
                return generateCppExpression(expr.variable) + ".segment(" +
                       generateCppExpression(expr.start) + ", " +
                       generateCppExpression(expr.size) + ")"
            }
            
            
            BlockMatrix: {
                val lit = expr
                return lit.blocks.map[blkAny | {
                    val blk = blkAny as VMBlock
                    currentLeftExpr + ".block(" +
                    generateCppExpression(blk.rowStart) + ", " +
                    generateCppExpression(blk.colStart) + ", " +
                    generateCppExpression(blk.numRows) + ", " +
                    generateCppExpression(blk.numCols) + ") << " +
                    generateCppExpression(blk.expr) + ";\n"
                }].join("")
            }
           
            
            VectorOrMatrix: {
                if (expr.rows.size == 1) {
                    val row = expr.rows.get(0) as RowLiteral
                    val elements = row.elements.map[generateCppExpression(it)].join(", ")
                    return elements
                } else {
                    val allElements = expr.rows.flatMap[row | (row as RowLiteral).elements]
                                        .map[generateCppExpression(it)]
                                        .join(", ")
                    return allElements
                }
            }
            VariableReference: {
                val varName = expr.variable.name
                // Handle null as empty vector for procedure parameters
                if (varName !== null && (varName.equals("null") || varName.toString.equals("null"))) {
                    return "std::vector<Eigen::MatrixXd>()"
                }
                return varName
            }
            SequenceLiteral: {
                if (expr.elements.isEmpty) {
                    return "std::vector<int>()"
                } else {
                    val firstElem = expr.elements.get(0)
                    val firstElemExpr = generateCppExpression(firstElem)
                    val elementsStr = expr.elements.map[generateSequenceElementExpression(it)].join(", ")
                    val elemType = inferSequenceElementCppType(firstElem, firstElemExpr)
                    return "std::vector<" + elemType + ">({ " + elementsStr + " })"
                }
            }
            IntegerExp: {
                return expr.value.toString
            }
            FloatExp: {
                return expr.value.toString
            }
            BooleanExp: {
                return expr.value.toString
            }
            StringExp: {
                val value = expr.value
                // Ensure the string value is properly quoted for C++
                if (value !== null && !value.startsWith("\"")) {
                    return "\"" + value + "\""
                }
                return value
            }
            RecordExp: {
                val recordExp = expr as RecordExp
                val structName = recordExp.record.name
                val customType = recordExp.record
                
                if (customType.type instanceof DataType) {
                    val dataType = customType.type as DataType
                    val fieldValues = dataType.fields.map[ structField |
                        val fieldDef = recordExp.definitions.findFirst[ it.field == structField.name ]
                        if (fieldDef !== null) {
                            generateCppExpression(fieldDef.value)
                        } else {
                            "/* missing field: " + structField.name + " */"
                        }
                    ].join(", ")
                    return structName + "{" + fieldValues + "}"
                } else {
                    val fieldValues = recordExp.definitions.map[ fieldDef |
                        generateCppExpression(fieldDef.value)
                    ].join(", ")
                    return structName + "{" + fieldValues + "}"
                }
            }
            default: {
                throw new UnsupportedOperationException("Unsupported expression type: " + expr)
            }
        }
    }

    def String inferSequenceElementCppType(Expression elem, String elemExpr) {
        if (elem instanceof Primary) {
            val base = (elem as Primary).base
            if (base instanceof VectorOrMatrix) {
                val literal = base as VectorOrMatrix
                if (literal.rows.size <= 1) {
                    return "Eigen::VectorXd"
                }
                return "Eigen::MatrixXd"
            }
            if (base instanceof BlockMatrix) {
                return "Eigen::MatrixXd"
            }
        }
        if (elem instanceof VectorOrMatrix) {
            val literal = elem as VectorOrMatrix
            if (literal.rows.size <= 1) {
                return "Eigen::VectorXd"
            }
            return "Eigen::MatrixXd"
        }
        if (elem instanceof BlockMatrix) {
            return "Eigen::MatrixXd"
        }
        return inferSequenceElementCppType(elemExpr)
    }

    def String generateSequenceElementExpression(Expression elem) {
        switch elem {
            Primary: {
                val base = (elem as Primary).base
                if (base instanceof VectorOrMatrix) {
                    val literal = base as VectorOrMatrix
                    if (literal.rows.size <= 1) {
                        val row = literal.rows.get(0) as RowLiteral
                        val elements = row.elements.map[generateCppExpression(it)].join(", ")
                        val size = row.elements.size
                        return "([](){ Eigen::VectorXd tmp(" + size + "); tmp << " + elements + "; return tmp; }())"
                    } else {
                        val rowCount = literal.rows.size
                        val firstRow = literal.rows.get(0) as RowLiteral
                        val colCount = firstRow.elements.size
                        val elements = literal.rows.flatMap[row | (row as RowLiteral).elements]
                            .map[generateCppExpression(it)]
                            .join(", ")
                        return "([](){ Eigen::MatrixXd tmp(" + rowCount + ", " + colCount + "); tmp << " + elements + "; return tmp; }())"
                    }
                }
                if (base instanceof BlockMatrix) {
                    return generateCppExpression(elem)
                }
                return generateCppExpression(elem)
            }
            VectorOrMatrix: {
                val literal = elem as VectorOrMatrix
                if (literal.rows.size <= 1) {
                    val row = literal.rows.get(0) as RowLiteral
                    val elements = row.elements.map[generateCppExpression(it)].join(", ")
                    val size = row.elements.size
                    return "([](){ Eigen::VectorXd tmp(" + size + "); tmp << " + elements + "; return tmp; }())"
                } else {
                    val rowCount = literal.rows.size
                    val firstRow = literal.rows.get(0) as RowLiteral
                    val colCount = firstRow.elements.size
                    val elements = literal.rows.flatMap[row | (row as RowLiteral).elements]
                        .map[generateCppExpression(it)]
                        .join(", ")
                    return "([](){ Eigen::MatrixXd tmp(" + rowCount + ", " + colCount + "); tmp << " + elements + "; return tmp; }())"
                }
            }
            default: {
                return generateCppExpression(elem)
            }
        }
    }

    def String inferSequenceElementCppType(String elemExpr) {
        if (elemExpr === null || elemExpr.isEmpty) {
            return "int"
        }
        if (elemExpr.startsWith("Eigen::VectorXd::") || elemExpr.startsWith("Eigen::VectorXd(")) {
            return "Eigen::VectorXd"
        }
        if (elemExpr.startsWith("Eigen::MatrixXd::") || elemExpr.startsWith("Eigen::MatrixXd(")) {
            return "Eigen::MatrixXd"
        }
        return "typename std::remove_reference<decltype(" + elemExpr + ")>::type"
    }

    def String inferFunctionName(FunctionCall call) {
        if (call === null) {
            return null
        }
        val node = NodeModelUtils.findActualNodeFor(call)
        if (node === null) {
            return null
        }
        val text = node.text
        if (text === null) {
            return null
        }
        val idx = text.indexOf("(")
        if (idx <= 0) {
            return null
        }
        return text.substring(0, idx).trim
    }

    /**
     * Generate C++ struct and enum definitions from DataTypes section.
     */
    def String generateDataTypes(DataTypes datatypes) {
        val StringBuilder cppCode = new StringBuilder()
        for (customType : datatypes.datatypes) {
            if (customType.type instanceof DataType) {
                val dataType = customType.type as DataType
                cppCode.append("struct ").append(customType.name).append(" {\n")
                for (field : dataType.fields) {
                    cppCode.append("    ").append(mapType(field.type))
                           .append(" ").append(field.name).append(";\n")
                }
                cppCode.append("};\n\n")
            } else if (customType.type !== null && customType.type.eClass?.name == 'EnumType') {
                val e = customType.type as EObject
                val litFeat = e.eClass.getEStructuralFeature('literals')
                val lits = if (litFeat !== null) {
                    val raw = e.eGet(litFeat) as java.util.List<Object>
                    raw.map[ litObj |
                        val lit = litObj as EObject
                        val nameFeat = lit.eClass.getEStructuralFeature('name')
                        (lit.eGet(nameFeat) as String)
                    ].join(', ')
                } else {
                    ''
                }
                cppCode.append("enum class ").append(customType.name)
                       .append(" { ").append(lits).append(" };\n\n")
            }
        }
        return cppCode.toString()
    }

    


    def String generateProcedures(Procedures procedures) {
        val StringBuilder cppCode = new StringBuilder
        for (var i = 0; i < procedures.procedures.size; i++) {
             cppCode.append(generateProcedure(procedures.procedures.get(i)))
             if (i < procedures.procedures.size - 1) {
                 cppCode.append("\n")
             }
        }
        if (procedures.procedures.size >= 3) {
            cppCode.append("\n")
        }
        return cppCode.toString
    }

    def String generateProcedure(Procedure procedure) {
        val procedureName = procedure.name
        val returnType = "void"
        val parameters = procedure.parameters.map[ param |
             val kw = getParameterKeyword(param)
             if (kw == "res" || kw == "val-res")
                  mapType(param.variable.type) + " &" + param.variable.name
             else
                  mapType(param.variable.type) + " " + param.variable.name
        ].join(", ")
        val statements = procedure.line.map[ generateCppStatement(it) ].join("\n    ")

        return '''
«returnType» «procedureName»(«parameters») {
    «statements»
}
'''
    }

    private def String adjustSequenceIndex(Expression expr, String rendered) {
        if (isIntegerExpression(expr)) {
            return rendered
        }
        return "static_cast<int>(" + rendered + ")"
    }

    private def boolean isIntegerExpression(Expression expr) {
        if (expr instanceof IntegerExp) return true
        if (expr instanceof VariableReference) {
            return (expr as VariableReference).variable.type instanceof IntType
        }
        if (expr instanceof Primary) {
            return isIntegerExpression((expr as Primary).base)
        }
        if (expr instanceof Addition) {
            return isIntegerExpression((expr as Addition).left) && isIntegerExpression((expr as Addition).right)
        }
        if (expr instanceof Multiplication) {
            return isIntegerExpression((expr as Multiplication).left) && isIntegerExpression((expr as Multiplication).right)
        }
        if (expr instanceof Unary) {
            return isIntegerExpression((expr as Unary).operand)
        }
        return false
    }

    /**
     * Determines the parameter keyword by inspecting its textual representation.
     * We assume the first token of the parameter declaration is the keyword.
     */
    def String getParameterKeyword(ParameterDeclaration param) {
        val node = NodeModelUtils.findActualNodeFor(param)
        if (node !== null) {
             val text = node.getText.trim
             if(text.startsWith("val-res"))
                 return "val-res"
             if(text.startsWith("res"))
                 return "res"
             if(text.startsWith("val"))
                 return "val"
        }
        return ""
    }
    
    def String generateFunctions(Functions functions) {
        val StringBuilder cppCode = new StringBuilder
        val seen = new java.util.HashSet<String>()
        for (function : functions.functions) {
            val fname = function.name
            if (fname === null) {
                // skip unnamed
            } else if (fname == 'zeroVec' || fname == 'zeroMat' || fname == 'Identity') {
                // skip helpers duplicated elsewhere
            } else if (seen.contains(fname)) {
                // skip duplicate
            } else {
                seen.add(fname)
                cppCode.append(generateFunction(function))
            }
        }
        return cppCode.toString
    }

/**
 * Generates a C++ function from a DSL Function node.
 */
def String generateFunction(Function function) {
    this.currentFunctionName = function.name
    val functionName = function.name
    val cReturnType = mapType(function.returnType)
    val parameters = if (function.parameters !== null)
         function.parameters.map[ v | mapType(v.type) + " " + v.name ].join(", ")
       else ""
    // Special-case known helper functions to generate concrete implementations
    if (functionName == 'zeroMat' && function.parameters.size == 2) {
        val rowsParam = function.parameters.get(0).name
        val colsParam = function.parameters.get(1).name
        return '''Eigen::MatrixXd zeroMat(int «rowsParam», int «colsParam») {
    return Eigen::MatrixXd::Zero(«rowsParam», «colsParam»);
}
'''
    }
	    if (functionName == 'zeroVec' && function.parameters.size == 1) {
	        val sizeParam = function.parameters.get(0).name
	        return '''Eigen::VectorXd zeroVec(int «sizeParam») {
	    return Eigen::VectorXd::Zero(«sizeParam»);
	}
'''
	    }
        if (functionName == 'zeroMatSeq' && function.parameters.size == 3) {
            val lengthParam = function.parameters.get(0).name
            val rowsParam = function.parameters.get(1).name
            val colsParam = function.parameters.get(2).name
            return '''std::vector<Eigen::MatrixXd> zeroMatSeq(int «lengthParam», int «rowsParam», int «colsParam») {
    std::vector<Eigen::MatrixXd> result;
    result.reserve(«lengthParam»);
    for (int i = 0; i < «lengthParam»; ++i) {
        result.push_back(Eigen::MatrixXd::Zero(«rowsParam», «colsParam»));
    }
    return result;
}
'''
        }
        if (functionName == 'zeroVecSeq' && function.parameters.size == 2) {
            val lengthParam = function.parameters.get(0).name
            val sizeParam = function.parameters.get(1).name
            return '''std::vector<Eigen::VectorXd> zeroVecSeq(int «lengthParam», int «sizeParam») {
    std::vector<Eigen::VectorXd> result;
    result.reserve(«lengthParam»);
    for (int i = 0; i < «lengthParam»; ++i) {
        result.push_back(Eigen::VectorXd::Zero(«sizeParam»));
    }
    return result;
}
'''
        }
        if ((functionName == 'cos' || functionName == 'sin') && function.parameters.size == 1) {
            return ""
        }
	    if (functionName == 'Identity') {
	        if (function.parameters.size == 1) {
	            val nParam = function.parameters.get(0).name
	            return '''Eigen::MatrixXd Identity(int «nParam») {
	    return Eigen::MatrixXd::Identity(«nParam», «nParam»);
}
'''
        } else if (function.parameters.size == 2) {
            val nParam = function.parameters.get(0).name
            val mParam = function.parameters.get(1).name
            return '''Eigen::MatrixXd Identity(int «nParam», int «mParam») {
    return Eigen::MatrixXd::Identity(«nParam», «mParam»);
}
'''
        }
    }
    if (functionName == 'LDLT' && function.parameters.size == 1) {
        val matParam = function.parameters.get(0).name
        return '''Eigen::MatrixXd LDLT(const Eigen::MatrixXd& «matParam») {
    return «matParam».ldlt().solve(Eigen::MatrixXd::Identity(«matParam».rows(), «matParam».cols()));
}
'''
    }
    if (functionName == 'transpose' && function.parameters.size == 1) {
        val param = function.parameters.get(0)
        val paramName = param.name
        val paramType = mapType(param.type)
        return '''«cReturnType» transpose(const «paramType»& «paramName») {
    return «paramName».transpose();
}
'''
    }
    if (functionName == 'adj' && function.parameters.size == 1) {
        val param = function.parameters.get(0)
        val paramName = param.name
        val paramType = mapType(param.type)
        return '''«cReturnType» adj(const «paramType»& «paramName») {
    return «paramName».transpose();
}
'''
    }
    if (functionName == 'motorIdentity' && function.parameters.size == 0) {
        return '''Eigen::VectorXd motorIdentity() {
    Eigen::VectorXd result = Eigen::VectorXd::Zero(8);
    result(0) = 1.0;
    return result;
}
'''
    }
    if (functionName == 'motorReverse' && function.parameters.size == 1) {
        val paramName = function.parameters.get(0).name
        return '''Eigen::VectorXd motorReverse(Eigen::VectorXd «paramName») {
    Eigen::VectorXd result = Eigen::VectorXd::Zero(8);
    if («paramName».size() >= 8) {
        result = «paramName»;
    } else if («paramName».size() > 0) {
        result.head(«paramName».size()) = «paramName»;
    }
    result(0) = result(0);
    result(1) = -result(1);
    result(2) = -result(2);
    result(3) = -result(3);
    result(4) = -result(4);
    result(5) = -result(5);
    result(6) = -result(6);
    result(7) = result(7);
    return result;
}
'''
    }
    if (functionName == 'motorProduct' && function.parameters.size == 2) {
        val m1Param = function.parameters.get(0).name
        val m2Param = function.parameters.get(1).name
        return '''Eigen::VectorXd motorProduct(Eigen::VectorXd «m1Param», Eigen::VectorXd «m2Param») {
    Eigen::VectorXd result = Eigen::VectorXd::Zero(8);

    auto rotorQuat = [](const Eigen::VectorXd& m) {
        return Eigen::Quaterniond(m(0), -m(3), m(2), -m(1));
    };
    auto dualQuat = [](const Eigen::VectorXd& m) {
        return Eigen::Quaterniond(m(7), -m(4), -m(5), -m(6));
    };

    const Eigen::Quaterniond r1 = rotorQuat(«m1Param»);
    const Eigen::Quaterniond d1 = dualQuat(«m1Param»);
    const Eigen::Quaterniond r2 = rotorQuat(«m2Param»);
    const Eigen::Quaterniond d2 = dualQuat(«m2Param»);

    const Eigen::Quaterniond r = r1 * r2;
    Eigen::Quaterniond d;
    d.coeffs() = (r1 * d2).coeffs() + (d1 * r2).coeffs();

    result(0) = r.w();
    result(3) = -r.x();
    result(2) = r.y();
    result(1) = -r.z();

    result(7) = d.w();
    result(4) = -d.x();
    result(5) = -d.y();
    result(6) = -d.z();

    return result;
}
'''
    }
    if (functionName == 'motorToMatrix' && function.parameters.size == 1) {
        val paramName = function.parameters.get(0).name
        return '''Eigen::MatrixXd motorToMatrix(Eigen::VectorXd «paramName») {
    Eigen::Quaterniond r(«paramName»(0), -«paramName»(3), «paramName»(2), -«paramName»(1));
    Eigen::Quaterniond d(«paramName»(7), -«paramName»(4), -«paramName»(5), -«paramName»(6));

    const double nr = r.norm();
    if (nr > 1e-12) {
        r.coeffs() /= nr;
        d.coeffs() /= nr;
    } else {
        r = Eigen::Quaterniond::Identity();
        d.coeffs().setZero();
    }

    Eigen::MatrixXd T = Eigen::MatrixXd::Identity(4, 4);
    T.block<3,3>(0, 0) = r.toRotationMatrix();

    const Eigen::Quaterniond tQuat = d * r.conjugate();
    const Eigen::Vector3d t = 2.0 * Eigen::Vector3d(tQuat.x(), tQuat.y(), tQuat.z());
    T.block<3,1>(0, 3) = t;

    return T;
}
'''
    }
    if (functionName == 'CalcPhi' && function.parameters.size == 3) {
        return '''Eigen::MatrixXd CalcPhi(int i, int j, std::vector<Eigen::MatrixXd> B_k) {
    // Force transform φ(i,j) from frame j to frame i
    Eigen::Matrix3d R_i = B_k[i - 1].block<3,3>(0, 0);
    Eigen::Matrix3d R_j = B_k[j - 1].block<3,3>(0, 0);
    Eigen::Matrix3d R_ij = R_i.transpose() * R_j;
    Eigen::Vector3d p_i = B_k[i - 1].block<3,1>(0, 3);
    Eigen::Vector3d p_j = B_k[j - 1].block<3,1>(0, 3);
    Eigen::Vector3d p_ij_i = R_i.transpose() * (p_j - p_i);
    // skew(p) matrix
    Eigen::Matrix3d skew_p;
    skew_p << 0, -p_ij_i(2), p_ij_i(1),
              p_ij_i(2), 0, -p_ij_i(0),
              -p_ij_i(1), p_ij_i(0), 0;
    Eigen::MatrixXd X = Eigen::MatrixXd::Zero(6, 6);
    X.block<3,3>(0,0) = R_ij;
    X.block<3,3>(0,3) = skew_p * R_ij;
    X.block<3,3>(3,3) = R_ij;
    return X;
}
'''
    }
    if (functionName == 'adjoint' && function.parameters.size == 1 && mapType(function.parameters.get(0).type).startsWith('Eigen::Matrix')) {
        val paramName = function.parameters.get(0).name
        return cReturnType + " " + functionName + "(" + parameters + ") {\n" +
               indent("return " + paramName + ".transpose();", 4) + "\n" +
               "}\n"
    }
    val initVal = defaultReturnValueFor(function.returnType)
    var String body = cReturnType + " result = " + initVal + ";\n"
    val predicates = predicateElements(function)
    for (p : predicates) {
         body = body + generatePredicate(p as SemanticExpression) + "\n"
    }

    body = body + "return result;"
    
    return cReturnType + " " + functionName + "(" + parameters + ") {\n" +
           indent(body, 4) + "\n" +
           "}\n"
}

def generateFuncLeftExpr(FuncLeftExpr expr){
    if(expr instanceof FuncLeftSubmatrix){
     return generateFuncLeftSubmatrix(expr)	
    }
    
    else if(expr instanceof FuncLeftSubvector){
        return generateFuncLeftSubvector(expr)
    }
    else if(expr.function !== null && expr.index !== null){
         val idx = expr.index;
        if (idx.second !== null) {
            return "result" +
                   "(" + generateCppExpression(idx.first) + "," + 
                   generateCppExpression(idx.second) + ")";
        } else {
            return "result" +
                   "(" + generateCppExpression(idx.first) + ")";
        }
    }
    
    else if(expr.function !== null && expr.index === null){
        return "result";
    }
    
    else if(expr instanceof LeftExpr){
        return generateLeftExpression(expr)
    }
}

def String generateFuncLeftSubmatrix(FuncLeftSubmatrix lsm) {
        val varName = "result"
        val numRowsExpr = generateCppExpression(lsm.numRows)
        val numColsExpr = generateCppExpression(lsm.numCols)

        // Check if this is a 1x1 block - use element access instead
        if (numRowsExpr.equals("1") && numColsExpr.equals("1")) {
            return varName + "(" +
                   generateCppExpression(lsm.rowStart) + ", " +
                   generateCppExpression(lsm.colStart) + ")";
        }

        return varName +
               ".block(" +
               generateCppExpression(lsm.rowStart) + ", " +
               generateCppExpression(lsm.colStart) + ", " +
               numRowsExpr + ", " +
               numColsExpr +
               ")";
    }

    /**
     * Returns the list of semantic predicate elements for a function across grammar versions:
     * - New grammar: predicate is a SemExprSeq with an 'elements' list
     * - Old grammar: predicate is directly an EList<SemanticExpression>
     */
    def Iterable<SemanticExpression> predicateElements(Function function) {
        if (function === null || function.predicate === null) {
            return newArrayList
        }
        val Object pred = function.predicate
        // Case 1: older grammar where predicate is an EList<SemanticExpression>
        if (pred instanceof Iterable<?>) {
            return (pred as Iterable<Object>).filter[ it instanceof SemanticExpression ].map[ it as SemanticExpression ]
        }
        // Case 2: newer grammar where predicate is a SemExprSeq with 'elements'
        if (pred instanceof EObject) {
            val eObj = pred as EObject
            val feat = eObj.eClass.getEStructuralFeature('elements')
            if (feat !== null) {
                val list = eObj.eGet(feat) as java.util.List<Object>
                return list.filter[ it instanceof SemanticExpression ].map[ it as SemanticExpression ]
            }
        }
        return newArrayList
    }

    /**
     * Generates a C++ expression for a left-hand side subvector access.
     * Uses Eigen's .segment syntax.
     */
def String generateFuncLeftSubvector(FuncLeftSubvector lsv) {
        val varName = "result"
        return varName +
               ".segment(" +
               generateCppExpression(lsv.start) + ", " +
               generateCppExpression(lsv.size) +
               ")";
    }

    def private String normalizeExpression(String expr) {
        if (expr === null) {
            return ""
        }
        var normalized = expr.replace(" ", "").replace("\t", "")
        normalized = stripOuterParens(normalized)
        return normalized
    }

    def private boolean shouldIncludeUpperBound(String normFrom, String normTo, String rawTo) {
        // The GuidedChoice SKO pipeline emits ranges like range(1, n - 2, 1)
        // that are intended to include the upper bound. Detect this specific
        // shape so we can keep matrix index loops (range(0, 3, 1)) exclusive.
        if (normFrom != "1") {
            return false
        }
        if (normTo == "n-2") {
            return true
        }
        val rawNoSpace = if (rawTo !== null) rawTo.replace(" ", "") else ""
        return rawNoSpace.contains("n-2")
    }

    def private String stripOuterParens(String expr) {
        var result = expr
        while (result.startsWith("(") && result.endsWith(")") && result.length > 2) {
            result = result.substring(1, result.length - 1)
        }
        return result
    }


/**
 * Generates the C++ code corresponding to a predicate.
 * SemanticExpression nodes include FunctionForLoop and FunctionIfThen.
 * For any (non-semantic) expression we update the temporary result variable.
 *
 * In particular, if the expression (or its Primary base) is a relational expression
 * with "==" and its left side matches the current function name, then we produce an assignment
 * that updates "result" instead of using the function's name.
 */
def String generatePredicate(SemanticExpression sem) {
    switch (sem) {
        Equality: {
            val lhs = generateFuncLeftExpr(sem.left)
            val rhs = generateCppExpression(sem.right)
            return lhs + " = " + rhs + ";"
        }
        FunctionForLoop:  return generateFunctionForLoop(sem)
        FunctionIfThen: return generateFunctionIfThen(sem)
        default: throw new UnsupportedOperationException("Unsupported semantic predicate: " + sem)
    }
}




/**
 * Helper method: if the generated left-hand side string refers to a function call (or index/submatrix access)
 * whose base is the current function name, then replace that base with "result."
 */
def String adjustLHS(String lhsStr) {
    val trimmed = lhsStr.trim()
    val pattern = this.currentFunctionName
    val regExp = java.util.regex.Pattern.compile(pattern)
    val matcher = regExp.matcher(trimmed)
    if (matcher.find()) {
        val end = matcher.end()
        if (end < trimmed.length()) {
            return "result" + trimmed.substring(end)
        } else {
            return "result"
        }
    }
    return trimmed
}

def String generateFunctionForLoop(FunctionForLoop ffl) {
    val varType = mapType(ffl.variable.type)
    val varName = ffl.variable.name
    // Handle both SemanticExpression and SemExprSeq
    val bodyStmt = if (ffl.body instanceof SemExprSeq) {
        val semExprSeq = ffl.body as SemExprSeq
        if (semExprSeq.elements !== null && !semExprSeq.elements.empty) {
            semExprSeq.elements.map[generatePredicate(it)].join("\n    ")
        } else {
            ""
        }
    } else {
        generatePredicate(ffl.body as SemanticExpression)
    }
    
    if (ffl.rangeExpression !== null) {
        val fromArgRaw = generateCppExpression(ffl.rangeExpression.from)
        val toArgRaw = generateCppExpression(ffl.rangeExpression.to)
        val incArgRaw = generateCppExpression(ffl.rangeExpression.increment)
        val fromArg = fromArgRaw
        val toArg = toArgRaw
        val incArg = incArgRaw.trim
        val normFrom = normalizeExpression(fromArgRaw)
        val normTo = normalizeExpression(toArgRaw)
        val normInc = normalizeExpression(incArg)
        
        // Solution DSL range(from, to, inc) uses the SAME semantics as Python/Xtend range
        // range(0, 3, 1) means [0,1,2] NOT [0,1,2,3]
        // So C++ needs i < to (exclusive upper bound)
        val condition = if (normInc == "1") {
            if (shouldIncludeUpperBound(normFrom, normTo, toArgRaw)) {
                varName + " <= " + toArg
            } else {
                varName + " < " + toArg
            }
        } else if (normInc == "-1") {
            varName + " >= " + toArg
        } else {
            // For other increments, less common - need to handle properly
            varName + " <= " + toArg
        }
        
        val increment = if (normInc == "1") {
            varName + "++"
        } else {
            varName + " += " + incArg
        }
        
        return "for (" + varType + " " + varName + " = " + fromArg + "; " + condition + "; " + increment + ") {\n    " + bodyStmt + "\n}"
    }
    
    val node = NodeModelUtils.findActualNodeFor(ffl)
    val text = if (node !== null) node.getText else ""
    val pattern = java.util.regex.Pattern.compile("range\\(([^)]+)\\)")
    val matcher = pattern.matcher(text)
    if (matcher.find) {
    val args = matcher.group(1).split(",").map[it.trim]
        if (args.size == 3) {
            val fromArg = args.get(0)
            val toArg = args.get(1)
            val incArg = args.get(2)

            // Solution DSL range(from, to, inc) uses Python/Xtend semantics with EXCLUSIVE upper bound
            // range(0, 3, 1) means [0,1,2] NOT [0,1,2,3]
            val condition = if (incArg == "1") {
                varName + " < " + toArg
            } else if (incArg == "-1") {
                varName + " > " + toArg
            } else {
                // For other increments, less common - need to handle properly
                varName + " <= " + toArg
            }

            val increment = if (incArg == "1") {
                varName + "++"
            } else {
                varName + " += " + incArg
            }

            return "for (" + varType + " " + varName + " = " + fromArg + "; " + condition + "; " + increment + ") {\n    " + bodyStmt + "\n}"
        }
    }
    return "// FunctionForLoop parse error"
}


def String generateFunctionIfThen(FunctionIfThen fit) {
    val cond = generateCppExpression(fit.condition)
    return "if (" + cond + ") {\n    " + 
           generatePredicate(fit.thenExpr as SemanticExpression) + 
           "\n} else {\n    " + 
           generatePredicate(fit.elseExpr as SemanticExpression) + 
           "\n}"
}



/**
 * Generates a default return value for a given C++ type.
 */
def String defaultReturnValue(String type) {
    if (type == "int") {
         return "0"
    } else if (type == "double") {
         return "0.0"
    } else if (type.startsWith("Eigen::VectorXd")) {
         return "Eigen::VectorXd()"
    } else if (type.startsWith("Eigen::MatrixXd")) {
         return "Eigen::MatrixXd()"
    } else {
         return "{}"
    }
}


    def String generateCppStatement(Statement stmt) {
        if (stmt instanceof Block) {
            return generateBlock(stmt)
        } else if (stmt instanceof VariableLine) {
            return generateCPPVariableLine(stmt)
        } else if (stmt instanceof ForLoop) {
            return generateForLoop(stmt)
        } else if (stmt instanceof IfThenElse) {
            return generateIfThenElse(stmt)
        } else if (stmt instanceof Assignment) {
            return generateAssignment(stmt)
        } else if (stmt instanceof ProcedureCall) {
            return generateProcedureCall(stmt) + ";"
        } else if (stmt instanceof SKIP) {
            return "// skip;"
        } else {
            throw new UnsupportedOperationException("Unsupported statement type: " + stmt)
        }
    }

    def String generateBlock(Block block) {
        val inner = block.statements.map[ indent(generateCppStatement(it), 4) ].join("\n")
        return "{\n" + inner + "\n}"
    }

    def String indent(String text, int spaces) {
        var StringBuilder builder = new StringBuilder
        for (i : 0 ..< spaces) {
            builder.append(" ")
        }
        val indentation = builder.toString
        return text.split("\n").map[ line | indentation + line ].join("\n")
    }

    def String generateCPPVariableLine(VariableLine varLine) {
    val variable = varLine.variable
    val varName = variable.name
    val cType = mapType(variable.type) // mapType should convert the DSL type to a C++ type.
    if (variable.initialValue !== null) {
        val init = generateCppExpression(variable.initialValue)
        if(variable.type instanceof VecType){
            val VecType vt = variable.type as VecType
        if (vt.size !== 0 && variable.initialValue instanceof Primary &&
            (variable.initialValue as Primary).base instanceof VectorOrMatrix) {
            return cType + " " + varName + " = Eigen::VectorXd::Zero(" +
                   vt.size.toString + ");"+ "\n"
                   + varName + "<<" + init+';';
        } else {
            return cType + " " + varName + "; // TODO: Dimension not provided for vector " + varName + "\n"
                    + varName + "=" + init+';';
        }
        }
        return cType + " " + varName + " = " + init + ";"
    } else if (variable.type instanceof MatType) {
        // Cast the type to MatType to extract rows and columns.
        val MatType mt = variable.type as MatType
        if (mt.rows !== 0 && mt.columns !== 0) {
            return cType + " " + varName + " = Eigen::MatrixXd::Zero(" +
                   mt.rows.toString + ", " +
                   mt.columns.toString + ");";
        } else {
            return cType + " " + varName + "; // TODO: Dimensions not provided for matrix " + varName;
        }
    } else if (variable.type instanceof VecType) {
        // Cast the type to VecType to extract the size.
        val VecType vt = variable.type as VecType
        if (vt.size !== 0) {
            return cType + " " + varName + " = Eigen::VectorXd::Zero(" +
                   vt.size.toString + ");";
        } else {
            return cType + " " + varName + "; // TODO: Dimension not provided for vector " + varName;
        }
    } else {
        return cType + " " + varName + ";"
    }
}


    def String generateAssignment(Assignment assign) {
        // Generate the left-hand side expression and the right-hand side expression.
        val lhs = generateLeftExpression(assign.left)
        currentLeftExpr = lhs
        val rhs = generateCppExpression(assign.right)
        
        // Determine block or segment assignment
        val isBlockOrSegment = lhs.contains(".block(") || lhs.contains(".segment(")
        val isVectorOrMatrixLiteral = assign.right instanceof Primary && (assign.right as Primary).base instanceof VectorOrMatrix
        val isDirectVectorOrMatrixLiteral = assign.right instanceof VectorOrMatrix
        
        if (isBlockOrSegment) {
            if (isVectorOrMatrixLiteral || isDirectVectorOrMatrixLiteral) {
                return lhs + " << " + rhs + ";"
            } else {
                // Prefer standard assignment for blocks/segments (works for matrix, vector, and scalar RHS)
                return lhs + " = " + rhs + ";"
            }
        }
        if (isVectorOrMatrixLiteral || isDirectVectorOrMatrixLiteral) {
            return lhs + " << " + rhs + ";"
        }
        // Fallback to standard assignment
        return lhs + " = " + rhs + ";"
    }

    def String generateLeftExpression(LeftExpr lExpr) {
    if (lExpr === null) {
        return "/* undefined */";
    }
    if (lExpr instanceof LeftVar) {
        return lExpr.variable.name.toString;
    } else if (lExpr instanceof LeftDArr) {
        // In the updated grammar, the Index rule has a mandatory 'first'
        // and an optional 'second'. If 'second' is provided, generate a two-dimensional access.
        val idx = lExpr.index;
        val varName = lExpr.variable.name.toString;
        val varType = lExpr.variable.type;
        
        // Use array indexing for sequences, function call syntax for matrices/vectors
        if (varType instanceof SeqType) {
            if (idx.second !== null) {
                val firstAdj = adjustSequenceIndex(idx.first, generateCppExpression(idx.first))
                val secondAdj = adjustSequenceIndex(idx.second, generateCppExpression(idx.second))
                return varName + "[" + firstAdj + "][" + secondAdj + "]";
            } else {
                val firstAdj = adjustSequenceIndex(idx.first, generateCppExpression(idx.first))
                return varName + "[" + firstAdj + "]";
            }
        } else {
            if (idx.second !== null) {
                val firstAdj = adjustSequenceIndex(idx.first, generateCppExpression(idx.first))
                val secondAdj = adjustSequenceIndex(idx.second, generateCppExpression(idx.second))
                return varName + "(" + firstAdj + "," + secondAdj + ")";
            } else {
                val firstAdj = adjustSequenceIndex(idx.first, generateCppExpression(idx.first))
                return varName + "(" + firstAdj + ")";
            }
        }
    } else if (lExpr instanceof LeftSubmatrix) {
         return generateLeftSubmatrix(lExpr);
    } else if (lExpr instanceof LeftSubvector) {
         return generateLeftSubvector(lExpr);
    } else if (lExpr instanceof LeftRecordField) {
         return generateLeftRecordField(lExpr);
    } else {
        throw new UnsupportedOperationException("Unsupported left-hand side expression type: " + lExpr.eClass.name);
    }
}


    /**
     * Generates a C++ expression for a left-hand side submatrix access.
     * Uses Eigen's .block syntax.
     */
    def String generateLeftSubmatrix(LeftSubmatrix lsm) {
        val varName = lsm.variable.name.toString
        val numRowsExpr = generateCppExpression(lsm.numRows)
        val numColsExpr = generateCppExpression(lsm.numCols)

        // Check if this is a 1x1 block - use element access instead
        if (numRowsExpr.equals("1") && numColsExpr.equals("1")) {
            // Submatrix coordinates in Solution DSL are 0-based; do not adjust
            return varName + "(" +
                   generateCppExpression(lsm.rowStart) + ", " +
                   generateCppExpression(lsm.colStart) + ")";
        }

        return varName +
               ".block(" +
               generateCppExpression(lsm.rowStart) + ", " +
               generateCppExpression(lsm.colStart) + ", " +
               numRowsExpr + ", " +
               numColsExpr +
               ")";
    }

    /**
     * Generates a C++ expression for a left-hand side subvector access.
     * Uses Eigen's .segment syntax.
     */
    def String generateLeftSubvector(LeftSubvector lsv) {
        val varName = lsv.variable.name.toString
        val sizeExpr = generateCppExpression(lsv.size)

        // Check if this is a 1-element segment - use element access instead
        if (sizeExpr.equals("1")) {
            val startAdj = adjustSequenceIndex(lsv.start, generateCppExpression(lsv.start))
            return varName + "(" + startAdj + ")";
        }

        return varName +
               ".segment(" +
               adjustSequenceIndex(lsv.start, generateCppExpression(lsv.start)) + ", " +
               sizeExpr +
               ")";
    }

    /**
     * Helper to generate a C++ expression for a record field access.
     */
    def String generateLeftRecordField(LeftRecordField lrf) {
        // Use the original source text for the record field access, e.g., "obj.field"
    val node = NodeModelUtils.findActualNodeFor(lrf)
    if (node !== null) {
        return node.getText()
    }
        // Fallback if node unavailable
        return "/* record field */"
    }
    
    /**
     * Generates a C++ procedure call.
     */
    def String generateProcedureCall(ProcedureCall call) {
        // arguments is always a (possibly empty) list
        val args = if (!call.arguments.isEmpty) 
                       call.arguments.map[ generateCppExpression(it) ].join(", ")
                   else
                       ""
        return call.procedure.name + "(" + args + ")"
    }


    def String generateForLoop(ForLoop loop) {
        generateForLoop(loop, 0)
    }
    
    def String generateForLoop(ForLoop loop, int indentLevel) {
        val indent = (0..<indentLevel).map["    "].join
        val bodyIndent = (0..<(indentLevel + 1)).map["    "].join
        
        if (loop.rangeExpression !== null) {
            val varName = loop.elementVariable.name
        val startExprRaw = generateCppExpression(loop.rangeExpression.from)
        val endExprRaw   = generateCppExpression(loop.rangeExpression.to)
        val incrExprRaw  = generateCppExpression(loop.rangeExpression.increment)
        val varDecl   = mapType(loop.elementVariable.type) + " " + varName + " = " + startExprRaw
        val normStart = normalizeExpression(startExprRaw)
        val normEnd   = normalizeExpression(endExprRaw)
        val normIncr  = normalizeExpression(incrExprRaw)

        // Solution DSL range(from, to, inc) uses Python/Xtend semantics with EXCLUSIVE upper bound
        // range(0, 3, 1) means [0,1,2] NOT [0,1,2,3]
        val condition = if (normIncr == "1") {
            if (shouldIncludeUpperBound(normStart, normEnd, endExprRaw)) {
                varName + " <= " + endExprRaw
            } else {
                varName + " < " + endExprRaw
            }
        } else if (normIncr.startsWith("-")) {
            varName + " > " + endExprRaw
        } else {
            // For other increments, less common - need to handle properly
            varName + " <= " + endExprRaw
        }

        val increment = if (normIncr == "1") {
            varName + "++"
        } else {
            varName + " += " + incrExprRaw
        }
        val bodyCode  = loop.lines.map[generateCppStatementAtIndent(it, indentLevel + 1)].join("\n" + bodyIndent)
        return "for (" + varDecl + "; " + condition + "; " + increment + ") {\n" + bodyIndent + bodyCode + "\n" + indent + "}"
        } else {
            val rangeStr = generateCppExpression(loop.rangeVariable)
            val decl     = mapType(loop.elementVariable.type) + " " + loop.elementVariable.name
            val bodyCode = loop.lines.map[generateCppStatementAtIndent(it, indentLevel + 1)].join("\n" + bodyIndent)
            return "for (" + decl + " : " + rangeStr + ") {\n" + bodyIndent + bodyCode + "\n" + indent + "}"
        }
    }

    def String generateIfThenElse(IfThenElse ifStmt) {
        generateIfThenElse(ifStmt, 0)
    }
    
    def String generateIfThenElse(IfThenElse ifStmt, int indentLevel) {
        val indent = (0..<indentLevel).map["    "].join
        val bodyIndent = (0..<(indentLevel + 1)).map["    "].join
        
        val condition = generateCppExpression(ifStmt.condition)
        val thenBody = ifStmt.thenStatements.map[generateCppStatementAtIndent(it, indentLevel + 1)].join("\n" + bodyIndent)
        val elseBody = ifStmt.elseStatements?.map[generateCppStatementAtIndent(it, indentLevel + 1)]?.join("\n" + bodyIndent)
    
        if (elseBody !== null && !elseBody.trim.isEmpty) {
            return "if (" + condition + ") {\n" + bodyIndent + thenBody + "\n" + indent + "} else {\n" + bodyIndent + elseBody + "\n" + indent + "}"
        } else {
            return "if (" + condition + ") {\n" + bodyIndent + thenBody + "\n" + indent + "}"
        }
    }

    def String generateCppStatementAtIndent(Statement stmt, int indentLevel) {
        if (stmt instanceof ForLoop) {
            return generateForLoop(stmt, indentLevel)
        } else if (stmt instanceof IfThenElse) {
            return generateIfThenElse(stmt, indentLevel)
        } else if (stmt instanceof Block) {
            return generateBlock(stmt)
        } else {
            return generateCppStatement(stmt)
        }
    }

    def String generateComputation(Computation computation) {
        val statements = computation.lines.map[
            generateCppStatement(it)
        ].join("\n    ")
    
        return '''
// Computation Block
    «statements»
'''
    }
    
    def String defaultReturnValueFor(Type type) {
        if (type instanceof MatType) {
             val MatType mt = type as MatType
             // Assume the DSL provides the number of rows and columns as integers
             val rowsExpr = mt.rows !== 0 ? mt.rows.toString : null
             val colsExpr = mt.columns !== 0 ? mt.columns.toString : null
             if (rowsExpr !== null && colsExpr !== null) {
                 return "Eigen::MatrixXd::Zero(" + rowsExpr + ", " + colsExpr + ")"
             } else {
                 return "Eigen::MatrixXd()"
             }
        } else if (type instanceof VecType) {
             val VecType vt = type as VecType
             val sizeExpr = vt.size !== 0 ? vt.size.toString : null
             if (sizeExpr !== null) {
                 return "Eigen::VectorXd::Zero(" + sizeExpr + ")"
             } else {
                 return "Eigen::VectorXd()"
             }
        } else if (type instanceof SeqType) {
             return "std::vector<" + mapType((type as SeqType).baseType) + ">()"
        } else if (type?.eClass?.name == 'BoolType') {
             return "false"
        } else if (type instanceof IntType) {
             return "0"
        } else if (type instanceof FloatType) {
             return "0.0"
        } else if (type?.eClass?.name == 'StringType') {
             return "std::string()"
        } else {
             return "0"
        }
    }

    def String mapType(Type type) {
        // First check if type is null
        if (type === null) {
            return "int"
        }

        // Check by eClass name first (more reliable for cross-grammar compatibility)
        val eClassName = type.eClass?.name
        if (eClassName !== null) {
            switch (eClassName) {
                case "IntType": return "int"
                case "FloatType": return "double"
                case "StringType": return "std::string"
                case "BoolType": return "bool"
                case "VecType": {
                    // Handled below by instanceof
                }
                case "MatType": {
                    // Handled below by instanceof
                }
                case "SeqType": {
                    // Handled below by instanceof
                }
            }
        }

        // Handle each type by instanceof as fallback
        if (type instanceof IntType) {
            return "int"
        } else if (type instanceof FloatType) {
            return "double"
        } else if (type instanceof StringType) {
            return "std::string"
        } else if (type instanceof VecType) {
            return "Eigen::VectorXd"
        } else if (type instanceof MatType) {
            return "Eigen::MatrixXd"
        } else if (type instanceof SeqType) {
            return "std::vector<" + mapType((type as SeqType).baseType) + ">"
        } else if (type instanceof TypeRef) {
            val typeRef = type as TypeRef
            if (typeRef.type === null) {
                // Type reference not resolved - default to int
                return "int"
            }
            var typeName = typeRef.type.name

            // If typeName is null, try to get it from the source text (for unresolved proxies)
            if (typeName === null || typeName == "null" || typeName.equals("null")) {
                val node = NodeModelUtils.findActualNodeFor(typeRef)
                if (node !== null) {
                    val sourceText = node.getText()?.trim()
                    if (sourceText !== null && !sourceText.isEmpty()) {
                        typeName = sourceText
                    }
                }
            }

            if (typeName === null || typeName == "null" || typeName.equals("null")) {
                // Name is null or "null" string, default to int
                return "int"
            }
            // Handle special custom types
            if (typeName == "Geom" || typeName.equals("Geom")) {
                return "int"  // Geom is typically used as an ID/index
            }
            // Handle built-in types referenced by name
            if (typeName == "string" || typeName.equals("string")) {
                return "std::string"
            }
            // Check one more time for "null" string before returning
            if (typeName.toString() == "null" || typeName.toString().equals("null")) {
                return "int"
            }
            // For other custom types, return the type name but check it's not "null"
            val finalType = typeName.toString()
            if (finalType == "null" || finalType.equals("null")) {
                return "int"
            }
            return finalType
        } else if (type?.eClass?.name == 'BoolType') {
            return "bool"
        } else if (type?.eClass?.name == 'StringType') {
            return "std::string"
        } else {
            // Default fallback
            return "int"
        }
    }
}
