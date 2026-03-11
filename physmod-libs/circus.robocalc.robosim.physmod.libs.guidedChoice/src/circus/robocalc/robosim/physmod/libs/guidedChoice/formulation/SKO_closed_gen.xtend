package circus.robocalc.robosim.physmod.libs.guidedChoice.formulation

import org.eclipse.emf.common.util.BasicEList
import java.util.regex.Pattern
import circus.robocalc.robosim.physmod.libs.guidedChoice.solutionLib.SolutionRef
import circus.robocalc.robosim.physmod.libs.guidedChoice.solutionLib.Local

class SKO_closed_gen{
	static class ForwardKinematicsClosedChain{
		static def SolutionRef asReference(SolutionRef solution){
			return solution
		}
	}

	static class ConstraintProjectionClosedChain{
		static def SolutionRef asReference(SolutionRef solution){
			solution.method = "ConstraintProjectionClosedChain"
			solution.iterations = 1

			if (solution.expression === null) {
				solution.expression = new Local()
				solution.expression.name = "theta"
			}
			if (solution.expression.type === null) {
				solution.expression.type = "Null"
			}

			val nTree = if (solution.expression.type != "Null") SKO_gen.getVectorSize(solution.expression.type) else -1

			var nLoopValue = -1
			if (solution.constraints !== null) {
				val nLoopPattern = Pattern.compile("\\(\\s*nLoop\\s*\\)\\s*\\[\\s*t\\s*==\\s*0\\s*\\]\\s*==\\s*(\\d+)")
				for (constraint : solution.constraints) {
					val matcher = nLoopPattern.matcher((constraint as String).trim)
					if (matcher.find()) {
						nLoopValue = Integer.parseInt(matcher.group(1).trim)
					}
				}
			}

			var nValue = -1
			if (solution.constraints !== null) {
				val nPattern = Pattern.compile("\\(\\s*n\\s*\\)\\s*\\[\\s*t\\s*==\\s*0\\s*\\]\\s*==\\s*(\\d+)")
				for (constraint : solution.constraints) {
					val matcher = nPattern.matcher((constraint as String).trim)
					if (matcher.find()) {
						nValue = Integer.parseInt(matcher.group(1).trim)
					}
				}
			}

			val nc = if (nLoopValue > 0) 6 * nLoopValue else -1
			val gType = if (nc > 0 && nTree > 0) "matrix(real," + nc + "," + nTree + ")" else "Null"
			val posType = if (nLoopValue > 0) "vector(real," + (3 * nLoopValue) + ")" else "Null"
			val vecType = if (nTree > 0) "vector(real," + nTree + ")" else "Null"

			solution.inputs = new BasicEList<Local>

			var i1 = new Local()
			i1.name = "G_c"
			i1.type = gType
			solution.inputs.add(i1)

			var i2 = new Local()
			i2.name = "g_pos"
			i2.type = posType
			solution.inputs.add(i2)

			var i3 = new Local()
			i3.name = "d_theta"
			i3.type = vecType
			solution.inputs.add(i3)

			var bkInput = new Local()
			bkInput.name = "B_k"
			bkInput.type = "Seq(matrix(real,4,4))"
			solution.inputs.add(bkInput)

			var xjInput = new Local()
			xjInput.name = "X_J"
			xjInput.type = "Seq(matrix(real,6,6))"
			solution.inputs.add(xjInput)

			var xtInput = new Local()
			xtInput.name = "X_T"
			xtInput.type = "Seq(matrix(real,6,6))"
			solution.inputs.add(xtInput)

			var nInput = new Local()
			nInput.name = "n"
			nInput.type = "int"
			solution.inputs.add(nInput)

			if (nValue > 0) {
				for (i : 1 ..< nValue + 1) {
					var bInput = new Local()
					bInput.name = "B_" + i
					bInput.type = "matrix(real,4,4)"
					solution.inputs.add(bInput)
				}
			}

			if (solution.constraints === null) {
				solution.constraints = new BasicEList<String>
			}
			if (nLoopValue > 0 && solution.constraints.findFirst[c | c.contains("(nLoop)") && c.contains("t == 0")] === null) {
				solution.constraints.add("(nLoop)[t == 0] == " + nLoopValue)
			}

			solution.errors = new BasicEList<String>
			solution.errors.add("0")

			return solution
		}
	}

	static class LoopPositionResidualsClosedChain{
		static def SolutionRef asReference(SolutionRef solution){
			solution.method = "LoopPositionResidualsClosedChain"
			solution.iterations = 1

			if (solution.expression === null) {
				solution.expression = new Local()
				solution.expression.name = "g_pos"
			}
			if (solution.expression.type === null) {
				solution.expression.type = "Null"
			}

			var nLoopValue = -1
			if (solution.constraints !== null) {
				val nLoopPattern = Pattern.compile("\\(\\s*nLoop\\s*\\)\\s*\\[\\s*t\\s*==\\s*0\\s*\\]\\s*==\\s*(\\d+)")
				for (constraint : solution.constraints) {
					val matcher = nLoopPattern.matcher((constraint as String).trim)
					if (matcher.find()) {
						nLoopValue = Integer.parseInt(matcher.group(1).trim)
					}
				}
			}

			val posType = if (nLoopValue > 0) "vector(real," + (3 * nLoopValue) + ")" else "Null"
			solution.expression.type = posType

			solution.inputs = new BasicEList<Local>
			var bkInput = new Local()
			bkInput.name = "B_k"
			bkInput.type = "Seq(matrix(real,4,4))"
			solution.inputs.add(bkInput)

			if (solution.constraints === null) {
				solution.constraints = new BasicEList<String>
			}
			if (nLoopValue > 0 && solution.constraints.findFirst[c | c.contains("(nLoop)") && c.contains("t == 0")] === null) {
				solution.constraints.add("(nLoop)[t == 0] == " + nLoopValue)
			}

			solution.errors = new BasicEList<String>
			solution.errors.add("0")

			return solution
		}
	}
}
