package circus.robocalc.robosim.physmod.libs.sourceCodeGen.libUtils

import org.eclipse.emf.common.util.EList
import org.eclipse.emf.common.util.BasicEList
import java.util.regex.Pattern
import java.util.List
import circus.robocalc.robosim.physmod.slnDF.slnDF.SlnDFFactory
import circus.robocalc.robosim.physmod.slnDF.SlnDFStandaloneSetup
import org.eclipse.xtext.parser.IParser
import org.eclipse.xtext.serializer.ISerializer
import java.io.StringReader
import circus.robocalc.robosim.physmod.slnDF.slnDF.Expression
import org.eclipse.emf.ecore.util.EcoreUtil
import circus.robocalc.robosim.physmod.slnRef.slnRef.SlnRef
import circus.robocalc.robosim.physmod.libs.sourceCodeGen.solutionLib.SolutionRef
import circus.robocalc.robosim.physmod.libs.sourceCodeGen.solutionLib.Local
import static circus.robocalc.robosim.physmod.libs.sourceCodeGen.formulation.SKO.*

// This class contains utility methods for source code generation (asSolution) solutions
class libUtils{
	
def static String simplifyType(String input) {
    val trimmed = input.trim
    
    // For sequences, e.g. "Seq(matrix(real,4,4))" becomes "Seq(mat(4,4))". Must be first.
	val sequencePattern = Pattern.compile("Seq\\((.*)\\)")
	val sequenceMatcher = sequencePattern.matcher(trimmed)
	if (sequenceMatcher.find()) {
	    val innerType = sequenceMatcher.group(1).trim
	    return "seq(" + simplifyType(innerType) + ")"
	}


	// int -> int
	if (trimmed == "int") {
	    return "int"
	}

	// float -> float
	if (trimmed == "float") {
	    return "float"
	}

	// bool -> bool	
	if (trimmed == "bool") {
	    return "bool"
	}

    // Simplify base type "real" to "float"
    if (trimmed == "real") {
        return "float"
    }
    
    // Treat Null as numeric scalar for generation (maps to float)
    if (trimmed.equalsIgnoreCase("Null")) {
        return "float"
    }
    
    // For vectors, e.g. "vector(real,2)" becomes "vec(2)"
    val vectorPattern = Pattern.compile("vector\\([^,]+,\\s*(\\d+)\\)")
    val vectorMatcher = vectorPattern.matcher(trimmed)
    if (vectorMatcher.find()) {
        val size = vectorMatcher.group(1).trim
        return "vec(" + size + ")"
    }
    
    // For matrices, e.g. "matrix(real,2,2)" becomes "mat(2,2)"
    val matrixPattern = Pattern.compile("matrix\\([^,]+,\\s*(\\d+),\\s*(\\d+)\\)")
    val matrixMatcher = matrixPattern.matcher(trimmed)
    if (matrixMatcher.find()) {
        val rows = matrixMatcher.group(1).trim
        val cols = matrixMatcher.group(2).trim
        return "mat(" + rows + "," + cols + ")"
    }

    // Handle custom types like "Geom"
    if (trimmed == "Geom") {
        return "Geom"
    }
	
    
    throw new IllegalArgumentException("Input type not recognized: " + input)
}

//Returns the initial value of the expression


// SolutionRef utils
def static String getInitalValue(String expression, SolutionRef solution){
	val pattern = Pattern.compile("\\(" + expression + "\\)\\s*\\[\\s*t\\s*==\\s*0\\s*\\]\\s*==\\s*(.+)")

		val IC = solution.constraints.findFirst[ constraint | 
			pattern.matcher(constraint as String).find() 
		]
		if (IC === null) {
			throw new IllegalStateException('No initial value found for expression: ' + expression)
		}
		// Create a new matcher instance for the matched constraint value.
		val matcher = pattern.matcher(IC as String)
		if (!matcher.find()) {
			throw new IllegalStateException("Pattern did not match the constraint value: " + IC)
		}
		val IC_value = matcher.group(1).trim()
		return IC_value
}

def static int getMatrixSize(String expression){
	val pattern = Pattern.compile("matrix\\s*\\(\\s*[^,]+\\s*,\\s*(\\d+)\\s*,\\s*(\\d+)\\s*\\)")
	val matcher = pattern.matcher(expression)
	if (matcher.find()) {
		val rows = matcher.group(1).trim()
		return Integer.parseInt(rows)
	}
	throw new IllegalArgumentException("Input type not recognized: " + expression)
}

def static String getVectorSize(String expression){
	val pattern = Pattern.compile("vector\\s*\\([^,]+,\\s*(\\d+)\\s*\\)");
	val matcher = pattern.matcher(expression)
	if (matcher.find()) {
		val size = matcher.group(1).trim()
		return size
	}
	throw new IllegalArgumentException("Input type not recognized: " + expression)
}

// SlnRef utils

def static String getInitalValue(String expression, SlnRef solution){
    // Special handling for M_1, M_2, M_3, etc. - redirect to submatrix(M)(...) constraints
    val massMatrixPattern = Pattern.compile("^M_(\\d+)$")
    val massMatrixMatcher = massMatrixPattern.matcher(expression)
    if (massMatrixMatcher.matches()) {
        val index = Integer.parseInt(massMatrixMatcher.group(1))
        val rowOffset = (index - 1) * 6

        // Search for constraint: (submatrix(M)(rowOffset,rowOffset,6,6))[t==0]==[|...|]
        val submatrixPattern = Pattern.compile(
            "\\(\\s*submatrix\\(M\\)\\(" + rowOffset + "\\s*,\\s*" + rowOffset + "\\s*,\\s*6\\s*,\\s*6\\)\\s*\\)" +
            "\\s*\\[\\s*t\\s*==\\s*0\\s*\\]\\s*==\\s*(\\[\\|.+?\\|\\])"
        )

        val submatrixConstraint = solution.constraints.findFirst[ constraint |
            submatrixPattern.matcher(constraint.value as String).find()
        ]

        if (submatrixConstraint !== null) {
            val subMatcher = submatrixPattern.matcher(submatrixConstraint.value as String)
            if (subMatcher.find()) {
                var matrixValue = subMatcher.group(1).trim()
                // Convert [|...|] to [...] format
                if (matrixValue.startsWith("[|") && matrixValue.endsWith("|]")) {
                    val inner = matrixValue.substring(2, matrixValue.length - 2).trim()
                    val rows = inner.split("\\s*;\\s*")
                    val normalizedRows = new java.util.ArrayList<String>()
                    for (r : rows) {
                        val rt = r.trim()
                        if (rt.length != 0) {
                            val cols = rt.split("\\s*,\\s*")
                            val normCols = new java.util.ArrayList<String>()
                            for (c : cols) {
                                // Remove spaces around minus signs and normalize
                                var cv = c.trim().replaceAll("\\s*-\\s+", "-").replaceAll("-\\s+", "-")
                                if (cv == "-0.0") cv = "0.0"
                                if (cv == "-0") cv = "0"
                                // No need to wrap negative numbers - grammar now supports SIGNED_FLOAT/SIGNED_INT terminals
                                if (cv.length > 0) normCols.add(cv)
                            }
                            if (!normCols.isEmpty) normalizedRows.add(normCols.join(","))
                        }
                    }
                    return "[" + normalizedRows.join("; ") + "]"
                }
                return matrixValue
            }
        }
        // If submatrix constraint not found, fall through to regular handling
    }

    val pattern = Pattern.compile("\\(" + expression + "\\)\\s*\\[\\s*t\\s*==\\s*0\\s*\\]\\s*==\\s*(.+)")

    val IC = solution.constraints.findFirst[ constraint |
        pattern.matcher(constraint.value as String).find()
    ]
    // If not found directly, fall back to a default based on declared type
    if (IC === null) {
        return defaultZeroForType(findTypeFor(expression, solution))
    }
    // Create a new matcher instance for the matched constraint value.
    val matcher = pattern.matcher(IC.value as String)
    if (!matcher.find()) {
        return defaultZeroForType(findTypeFor(expression, solution))
    }
    var IC_value = matcher.group(1).trim()
    
    // Convert sequences "<…>" → "seq(…)"
    if (IC_value.startsWith("<") && IC_value.endsWith(">")) {
        IC_value = "seq(" + IC_value.substring(1, IC_value.length - 1).trim() + ")"
    }

    // Normalize vector/matrix literal delimiters inside sequences (e.g., seq([|...|], ...) -> seq([ ... ], ...))
    if (IC_value.contains("[|") || IC_value.contains("(|")) {
        IC_value = IC_value
            .replace("[|", "[")
            .replace("|]", "]")
            .replace("(|", "[")
            .replace("|)", "]")
    }
    
    // Convert matrix/vector literals from [|…|] or (|…|) into canonical "[ … ]" form
    if ((IC_value.startsWith("(|") && IC_value.endsWith("|)")) ||
        (IC_value.startsWith("[|") && IC_value.endsWith("|]"))) {
        val rawInner = if (IC_value.startsWith("(|")) IC_value.substring(2, IC_value.length - 2).trim else IC_value.substring(2, IC_value.length - 2).trim
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
    // Normalize whitespace around negatives (e.g., "- 0.0" → "-0.0")
    IC_value = IC_value.replaceAll("-\\s+", "-")
    // normalize negative zeros
    IC_value = IC_value.replace("-0.0", "0.0").replace("-0]", "0]")
    
	
	return IC_value
}


// Determine declared type string for an expression name within a SolutionRef
def private static String findTypeFor(String name, SlnRef solution) {
    if (solution.expression !== null && solution.expression.name == name) {
        return solution.expression.type
    }
    val match = solution.inputs.findFirst[i | i.value !== null && i.value.name == name]
    if (match !== null) return match.value.type
    return "real" // safe scalar default
}

// Produce a sensible zero literal for a given declared type string
def static String defaultZeroForType(String typeString) {
    if (typeString === null) return "0"
    val t = typeString.trim
    // Seq(...)
    if (t.startsWith("Seq(")) return "seq()"
    // matrix(real,R,C)
    val m = Pattern.compile("^matrix\\s*\\([^,]+,\\s*(\\d+)\\s*,\\s*(\\d+)\\)", Pattern.CASE_INSENSITIVE).matcher(t)
    if (m.find) {
        return "zeroMat(" + m.group(1).trim + ", " + m.group(2).trim + ")"
    }
    // vector(real,N)
    val v = Pattern.compile("^vector\\s*\\([^,]+,\\s*(\\d+)\\)", Pattern.CASE_INSENSITIVE).matcher(t)
    if (v.find) {
        return "zeroVec(" + v.group(1).trim + ")"
    }
    // Null or scalar
    if (t.equalsIgnoreCase("Null")) return "0"
    return "0"
}



def static String getInputs(SlnRef solution){
	var inputs = ""
    for (input : solution.inputs){
        val isExpr = solution.expression !== null && input.value.name == solution.expression.name
        if (!isExpr) {
            val rawType = if (input.value?.type === null) "" else input.value.type.trim
            val isSeqType = rawType.startsWith("Seq(") || rawType.startsWith("seq(")
            val initVal = if (isSeqType)
                getInitalValue(input.value.name, solution)
            else
                getInitalValue(input.value.name, input.value.type, solution)
            inputs += input.value.name + " : " + simplifyType(input.value.type)
            if (initVal !== null && initVal != "seq()") {
                inputs += " = " + initVal
            }
            inputs += ";" + "\n"
        }
    }
	return inputs
 }

def static String getInputsExcluding(SlnRef solution, String excludeName){
    val ex = if (excludeName === null) "" else excludeName.trim
    var inputs = ""
    for (input : solution.inputs){
        val nm = if (input.value?.name === null) "" else input.value.name.trim
        val isExpr = solution.expression !== null && nm.equals(solution.expression.name?.trim)
        val isExcluded = nm.equals(ex)
        if (!isExpr && !isExcluded) {
            val rawType = if (input.value?.type === null) "" else input.value.type.trim
            val isSeqType = rawType.startsWith("Seq(") || rawType.startsWith("seq(")
            val initVal = if (isSeqType)
                getInitalValue(nm, solution)
            else
                getInitalValue(nm, input.value.type, solution)
            inputs += nm + " : " + simplifyType(input.value.type)
            if (initVal !== null && initVal != "seq()") {
                inputs += " = " + initVal
            }
            inputs += ";" + "\n"
        }
    }
    return inputs
}

}
