package circus.robocalc.robosim.physmod.libs.guidedChoice.formulation

import java.util.regex.Pattern
import java.util.List
import java.util.ArrayList
import circus.robocalc.robosim.physmod.libs.guidedChoice.solutionLib.SolutionRef
import circus.robocalc.robosim.physmod.slnRef.slnRef.SlnRef

class LibUtils {

	def static String simplifyType(String input) {
		val trimmed = input.trim
		val sequencePattern = Pattern.compile("Seq\\((.*)\\)")
		val sequenceMatcher = sequencePattern.matcher(trimmed)
		if (sequenceMatcher.find()) {
			val innerType = sequenceMatcher.group(1).trim
			return "seq(" + simplifyType(innerType) + ")"
		}
		if (trimmed == "int") return "int"
		if (trimmed == "float") return "float"
		if (trimmed == "real") return "real"
		if (trimmed == "boolean") return "bool"

		val matrixPattern = Pattern.compile("matrix\\(real,(\\d+),(\\d+)\\)")
		val matrixMatcher = matrixPattern.matcher(trimmed)
		if (matrixMatcher.find()) {
			val rows = matrixMatcher.group(1)
			val cols = matrixMatcher.group(2)
			return "mat(" + rows + "," + cols + ")"
		}

		val vectorPattern = Pattern.compile("vector\\(real,(\\d+)\\)")
		val vectorMatcher = vectorPattern.matcher(trimmed)
		if (vectorMatcher.find()) {
			val size = vectorMatcher.group(1)
			return "vec(" + size + ")"
		}
		return trimmed
	}

	def static List<Integer> getMatrixSize(String expression) {
		val matrixPattern = Pattern.compile("matrix\\(real,(\\d+),(\\d+)\\)")
		val matcher = matrixPattern.matcher(expression.trim)
		if (matcher.find()) {
			val rows = Integer.parseInt(matcher.group(1))
			val cols = Integer.parseInt(matcher.group(2))
			val result = new ArrayList<Integer>()
			result.add(rows)
			result.add(cols)
			return result
		}
		return null
	}

	def static int getVectorSize(String expression) {
		val vectorPattern = Pattern.compile("vector\\(real,(\\d+)\\)")
		val matcher = vectorPattern.matcher(expression.trim)
		if (matcher.find()) {
			return Integer.parseInt(matcher.group(1))
		}
		return 0
	}

	def static String getInitalValue(String expression, SolutionRef solution) {
		val constraints = solution.constraints
		if (constraints === null) {
			throw new IllegalStateException("No initial value found for expression: " + expression + " (no constraints)")
		}

		val pattern = Pattern.compile("\\(\\s*" + expression + "\\s*\\)\\s*\\[\\s*t\\s*==\\s*0\\s*\\]\\s*==\\s*(.+)")
		val IC = constraints.findFirst[ constraint | 
			pattern.matcher(constraint as String).find() 
		]
		if (IC === null) {
			throw new IllegalStateException("No initial value found for expression: " + expression)
		}
		// Create a new matcher instance for the matched constraint value.
		val matcher = pattern.matcher(IC as String)
		if (!matcher.find()) {
			throw new IllegalStateException("Pattern did not match the constraint value: " + IC)
		}
		val IC_value = matcher.group(1).trim()
		return IC_value
	}

	def static String getInitalValue(String expression, SlnRef solution) {
		val constraints = solution.constraints
		if (constraints === null) return null

		val lhsPattern = "\\(\\s*" + expression + "\\s*\\)\\s*\\[\\s*t\\s*==\\s*0\\s*\\]"
		for (constraint : constraints) {
			val c = constraint.value as String
			if (c !== null && c.contains("==")) {
				val eqIndex = c.indexOf("==")
				if (eqIndex > 0) {
					val lhs = c.substring(0, eqIndex).trim
					if (lhs.matches(lhsPattern)) {
						return c.substring(eqIndex + 2).trim
					}
				}
			}
		}
		return null
	}

	/**
	 * Get initial value for a variable with type information from SlnRef.
	 * Handles submatrix constraints and various literal formats.
	 */
	def static String getInitalValue(String name, String type, SlnRef solution) {
		val typeNorm = if (type !== null) type.replaceAll("\\s+", "") else ""
		if (typeNorm == "Geom") {
			val geomTypeVal = findGeomFieldValue(name, "geomType", solution)
			val geomValVal = findGeomFieldValue(name, "geomVal", solution)
			val meshUriVal = findGeomFieldValue(name, "meshUri", solution)
			val meshScaleVal = findGeomFieldValue(name, "meshScale", solution)

			val geomTypeLit = quoteIfNeeded(if (geomTypeVal !== null) geomTypeVal else "box")
			val geomValLit = normalizeLiteral(if (geomValVal !== null) geomValVal else "[| 0.0 |]")
			val meshUriLit = quoteIfNeeded(if (meshUriVal !== null) meshUriVal else "")
			val meshScaleLit = normalizeLiteral(if (meshScaleVal !== null) meshScaleVal else "[| 1.0 |]")

			return "Geom { geomType = " + geomTypeLit +
				", geomVal = " + geomValLit +
				", meshUri = " + meshUriLit +
				", meshScale = " + meshScaleLit + " }"
		}

		// Determine declared dimensions from the expression's type:
		var declRows = 0
		var declCols = 0
		try {
			// If expression is a matrix, getMatrixSize returns [rows, cols]
			val sizes = getMatrixSize(type)
			if (sizes !== null) {
				declRows = sizes.get(0)
				declCols = sizes.get(1)
			} else {
				// Otherwise treat as a vector: 1×N
				val vecLen = getVectorSize(type)
				declRows = 1
				declCols = vecLen
			}
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
				val rawLit     = m.group(2).trim           // e.g. "[|…|]" or "(|…|)"

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
			throw new IllegalStateException(
				"No initial value found for expression: " + name
			)
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
			val trimmedRows = rows.map[r | r.trim]
			IC_value = "[" + trimmedRows.join("; ") + "]"
		}

		return IC_value
	}

	/**
	 * Generate input declarations for a SlnRef solution.
	 */
	def static String getInputs(SlnRef solution) {
		var inputs = ""
		for (input : solution.inputs) {
			inputs += input.value.name + " : " + simplifyType(input.value.type) + " = " + getInitalValue(input.value.name, input.value.type, solution) + ";" + "\n"
		}
		return inputs
	}

	private def static String findGeomFieldValue(String name, String field, SlnRef solution) {
		val lhsPattern = "\\(\\s*" + name + "\\s*\\.\\s*" + field + "\\s*\\)\\s*\\[\\s*t\\s*==\\s*0\\s*\\]"
		for (constraint : solution.constraints) {
			val c = constraint.value as String
			if (c !== null && c.contains("==")) {
				val eqIndex = c.indexOf("==")
				if (eqIndex > 0) {
					val lhs = c.substring(0, eqIndex).trim
					if (lhs.matches(lhsPattern)) {
						return c.substring(eqIndex + 2).trim
					}
				}
			}
		}
		return null
	}

	private def static String normalizeLiteral(String value) {
		if (value === null) return null
		val trimmed = value.trim
		if ((trimmed.startsWith("(|") && trimmed.endsWith("|)")) ||
			(trimmed.startsWith("[|") && trimmed.endsWith("|]"))) {
			val inner = trimmed.substring(2, trimmed.length - 2).trim
			val rows = inner.split("\\s*;\\s*")
			val trimmedRows = rows.map[r | r.trim]
			return "[" + trimmedRows.join("; ") + "]"
		}
		return trimmed
	}

	private def static String quoteIfNeeded(String value) {
		if (value === null) return "\"\""
		val trimmed = value.trim
		if ((trimmed.startsWith("\"") && trimmed.endsWith("\"")) ||
			(trimmed.startsWith("'") && trimmed.endsWith("'"))) {
			return trimmed
		}
		return "\"" + trimmed + "\""
	}
}
