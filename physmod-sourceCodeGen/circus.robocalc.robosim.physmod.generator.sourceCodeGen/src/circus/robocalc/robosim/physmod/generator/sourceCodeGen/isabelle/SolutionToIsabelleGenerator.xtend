package circus.robocalc.robosim.physmod.generator.sourceCodeGen.isabelle

import org.eclipse.xtext.generator.IFileSystemAccess2
import circus.robocalc.robosim.physmod.slnDF.slnDF.Solution
import circus.robocalc.robosim.physmod.slnDF.slnDF.Proof
import circus.robocalc.robosim.physmod.slnDF.slnDF.RelationalExpression
import circus.robocalc.robosim.physmod.slnDF.slnDF.Type
import circus.robocalc.robosim.physmod.slnDF.slnDF.VecType
import circus.robocalc.robosim.physmod.slnDF.slnDF.MatType
import circus.robocalc.robosim.physmod.slnDF.slnDF.SeqType
import circus.robocalc.robosim.physmod.slnDF.slnDF.IntType
import circus.robocalc.robosim.physmod.slnDF.slnDF.FloatType
import circus.robocalc.robosim.physmod.slnDF.slnDF.BoolType
import circus.robocalc.robosim.physmod.slnDF.slnDF.Expression
import circus.robocalc.robosim.physmod.slnDF.slnDF.Addition
import circus.robocalc.robosim.physmod.slnDF.slnDF.Multiplication
import circus.robocalc.robosim.physmod.slnDF.slnDF.Unary
import circus.robocalc.robosim.physmod.slnDF.slnDF.FunctionCall
import circus.robocalc.robosim.physmod.slnDF.slnDF.VariableReference
import circus.robocalc.robosim.physmod.slnDF.slnDF.IntegerExp
import circus.robocalc.robosim.physmod.slnDF.slnDF.FloatExp
import circus.robocalc.robosim.physmod.slnDF.slnDF.VectorOrMatrix
import circus.robocalc.robosim.physmod.slnDF.slnDF.SequenceLiteral
import circus.robocalc.robosim.physmod.slnDF.slnDF.RowLiteral
import circus.robocalc.robosim.physmod.slnDF.slnDF.Primary
import circus.robocalc.robosim.physmod.slnDF.slnDF.Submatrix
import circus.robocalc.robosim.physmod.slnDF.slnDF.TypeRef
import circus.robocalc.robosim.physmod.slnDF.slnDF.StringType
import org.eclipse.xtext.nodemodel.util.NodeModelUtils
import java.util.ArrayList
import java.util.List
import java.io.BufferedInputStream
import java.io.BufferedReader
import java.io.File
import java.io.FileInputStream
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.nio.file.Files
import java.nio.file.Path
import java.nio.file.Paths
import java.nio.charset.StandardCharsets
import static org.eclipse.xtext.xbase.lib.CollectionLiterals.*

/**
 * Generates Isabelle theories containing system block equations extracted from
 * Solution DSL artefacts.
 */
class SolutionToIsabelleGenerator {

    val String mode

    new(String mode) {
        this.mode = if (mode === null || mode.trim.isEmpty) "computation" else mode.toLowerCase
    }

    def void generate(Solution solution, String solutionDSL, IFileSystemAccess2 fsa) {
        if (solution === null) {
            return
        }
        val sanitizedName = sanitizeName(solution.name)
        val theoryName = sanitizedName + "_" + mode.toUpperCase  // Theory name with uppercase mode
        val fileName = theoryName + ".thy"  // Filename MUST match theory name
        val content = buildTheory(sanitizedName, solution, solutionDSL)
        fsa.generateFile(fileName, content)
    }

    def String buildTheory(String solutionName, Solution solution, String solutionDSL) {
        val theoryName = solutionName + "_" + mode.toUpperCase
        val builder = new StringBuilder

        // Use ISAVodes format for equations mode
        if (mode.equalsIgnoreCase("equations")) {
            builder.append('''
section \<open> «solutionName» Physics Equations \<close>

theory «theoryName»
  imports "Hybrid-Verification.Hybrid_Verification"
begin

''')
            builder.append(generateISAVodesFormat(solutionName, solution, solutionDSL))
            builder.append("end\n")
        } else {
            // Use old format for non-equations mode
            builder.append('''theory «theoryName»
  imports Main
begin

text \<open>System equations generated for mode «mode.toUpperCase».\<close>

''')
            val blocks = extractBlockSections(solutionDSL)
            if (blocks.empty) {
                builder.append('''text \<open>No block equations were detected in the Solution DSL.\<close>

''')
            } else {
                for (block : blocks) {
                    builder.append('''text \<open>
''')
                    builder.append(escapeForIsabelle(block))
                    builder.append('''
\<close>

''')
                }
            }
            builder.append("end\n")
        }
        builder.toString
    }

    def private String generateISAVodesFormat(String solutionName, Solution solution, String solutionDSL) {
        val builder = new StringBuilder

        // Extract state variables from EMF model (mirrors C++ generator approach)
        val stateVars = extractStateVariables(solution, solutionDSL)

        // Extract initial conditions and algebraic constraints from proof
        val initialConds = extractInitialConditions(solution.proof, solutionDSL)
        val stateInitialConds = extractInitialConditionsFromState(solution)
        mergeInitialConditions(initialConds, stateInitialConds)
        val algebraicEqs = extractAlgebraicConstraints(solution.proof, solutionDSL)

        // Declare Geom record type if any variables use it
        val hasGeomType = stateVars.exists[isabelleType.contains("Geom")]
        if (hasGeomType) {
            builder.append('''
text \<open> Geometry datatype for link visualization \<close>
record Geom =
  geomType :: string
  geomVal :: "real list"

''')
        }

        // Generate dataspace
        builder.append(generateDataspace(solutionName, stateVars, initialConds))
        builder.append("\n")

        // Generate context with initial conditions and algebraic constraints
        if (!algebraicEqs.empty || !initialConds.empty) {
            builder.append(generateContext(solutionName, algebraicEqs, initialConds))
            builder.append("\n")
        }

        builder.toString
    }

    def private String generateDataspace(String name, List<StateVar> vars, List<InitialCondition> inits) {
        val builder = new StringBuilder
        builder.append("dataspace ").append(name.toLowerCase).append("_system =\n")

        // Variables section - each on separate line with ISAVodes matrix/vector syntax
        if (!vars.empty) {
            builder.append("  variables\n")
            for (v : vars) {
                // Only quote complex types (vectors, matrices, lists), not simple types
                val typeStr = if (v.isabelleType.equals("real") || v.isabelleType.equals("int") || v.isabelleType.equals("bool")) {
                    v.isabelleType  // No quotes for simple types
                } else {
                    "\"" + v.isabelleType + "\""  // Quotes for complex types
                }
                builder.append("    ").append(v.name).append(" :: ").append(typeStr).append("\n")
            }
            builder.append("  \n")  // Blank line after variables
        }

        builder.toString
    }

    def private String generateContext(String name, List<AlgebraicEquation> eqs, List<InitialCondition> inits) {
        val builder = new StringBuilder
        builder.append("context ").append(name.toLowerCase).append("_system\n")
        builder.append("begin\n\n")
        
        // Generate initial conditions as definitions
        if (!inits.empty) {
            for (ic : inits) {
                if (ic.comment !== null && !ic.comment.trim.isEmpty) {
                    builder.append("(* ").append(ic.comment).append(" *)\n")
                }
                val equation = escapeTermForIsabelle(ic.equation)
                builder.append("definition ").append(ic.name).append(" where \"").append(ic.name)
                builder.append(" \\<equiv> (").append(equation).append(")\\<^sup>e\"\n")
            }
            builder.append("\n")
        }
        
        // Generate algebraic constraints as definitions
        if (!eqs.empty) {
            builder.append("text \\<open> System algebraic constraints \\<close>\n\n")
            for (eq : eqs) {
                val equation = escapeTermForIsabelle(eq.equation)
                builder.append("definition ").append(eq.name).append(" where \"").append(eq.name)
                builder.append(" \\<equiv> (").append(equation).append(")\\<^sup>e\"\n")
            }
            builder.append("\n")
        }
        
        builder.append("end\n")
        builder.toString
    }

    // Helper classes for structured data
    static class StateVar {
        public String name
        public String isabelleType

        new(String name, String isabelleType) {
            this.name = name
            this.isabelleType = isabelleType
        }
    }

    static class InitialCondition {
        public String name
        public String equation
        public String comment

        new(String name, String equation) {
            this.name = name
            this.equation = equation
            this.comment = null
        }

        new(String name, String equation, String comment) {
            this.name = name
            this.equation = equation
            this.comment = comment
        }
    }

    static class GeomConversion {
        public String equation
        public String comment

        new(String equation, String comment) {
            this.equation = equation
            this.comment = comment
        }
    }

    static class MeshBounds {
        public double minX = Double.POSITIVE_INFINITY
        public double minY = Double.POSITIVE_INFINITY
        public double minZ = Double.POSITIVE_INFINITY
        public double maxX = Double.NEGATIVE_INFINITY
        public double maxY = Double.NEGATIVE_INFINITY
        public double maxZ = Double.NEGATIVE_INFINITY
        public boolean valid = false

        def void addVertex(double x, double y, double z) {
            minX = Math.min(minX, x)
            minY = Math.min(minY, y)
            minZ = Math.min(minZ, z)
            maxX = Math.max(maxX, x)
            maxY = Math.max(maxY, y)
            maxZ = Math.max(maxZ, z)
            valid = true
        }

        def double getSizeX() { return Math.abs(maxX - minX) }
        def double getSizeY() { return Math.abs(maxY - minY) }
        def double getSizeZ() { return Math.abs(maxZ - minZ) }
    }

    static class AlgebraicEquation {
        public String name
        public String equation

        new(String name, String equation) {
            this.name = name
            this.equation = equation
        }
    }

    def private List<StateVar> extractStateVariables(Solution solution, String solutionDSL) {
        val result = new ArrayList<StateVar>()
        val derivativeVars = new java.util.HashSet<String>()  // Track which vars need derivatives
        
        if (solution.state !== null && solution.state.variables !== null) {
            for (varLine : solution.state.variables) {
                val varName = varLine.variable.name
                val varType = convertEMFTypeToIsabelle(varLine.variable.type)
                result.add(new StateVar(varName, varType))
            }
        }
        
        // Detect derivative variables from proof block
        if (solutionDSL !== null && solution.proof !== null) {
            val proofText = extractProofBlockText(solutionDSL)
            if (proofText !== null) {
                // Look for derivative(varname) patterns
                val derivPattern = java.util.regex.Pattern.compile("derivative\\s*\\(\\s*([a-zA-Z_][a-zA-Z0-9_]*)\\s*\\)")
                val matcher = derivPattern.matcher(proofText)
                while (matcher.find()) {
                    val baseVar = matcher.group(1)
                    derivativeVars.add(baseVar)
                }
                
                // Also look for derivative(derivative(varname)) for second derivatives
                val deriv2Pattern = java.util.regex.Pattern.compile("derivative\\s*\\(\\s*derivative\\s*\\(\\s*([a-zA-Z_][a-zA-Z0-9_]*)\\s*\\)\\s*\\)")
                val matcher2 = deriv2Pattern.matcher(proofText)
                while (matcher2.find()) {
                    val baseVar = matcher2.group(1)
                    derivativeVars.add(baseVar)
                }
            }
        }
        
        // Add derivative variables (theta' and theta'') if theta has derivatives
        for (baseVarName : derivativeVars) {
            // Find the base variable to get its type
            val baseVar = result.findFirst[v | v.name.equals(baseVarName)]
            if (baseVar !== null) {
                // Add first derivative
                result.add(new StateVar(baseVarName + "'", baseVar.isabelleType))
                // Add second derivative
                result.add(new StateVar(baseVarName + "''", baseVar.isabelleType))
            }
        }
        
        return result
    }

    /**
     * Convert EMF Type object to Isabelle type string with ISAVodes syntax
     * Mirrors the C++ generator's approach but outputs ISAVodes-specific syntax
     */
    def private String convertEMFTypeToIsabelle(Type type) {
        switch type {
            VecType: {
                val size = type.size
                return "real ^" + size  // ISAVodes: "real ^n" with space
            }
            MatType: {
                val rows = type.rows
                val cols = type.columns
                return "real mat[" + rows + ", " + cols + "]"  // ISAVodes: mat[rows, cols]
            }
            SeqType: {
                val innerType = convertEMFTypeToIsabelle(type.baseType)
                // Parenthesize complex types in lists
                if (innerType.contains("mat") || innerType.contains("^") || innerType.contains(" ")) {
                    return "(" + innerType + ") list"
                }
                return innerType + " list"
            }
            TypeRef: {
                // Custom type reference (e.g., Geom)
                // First try to get the resolved type name
                val customType = type.type
                if (customType !== null && !customType.eIsProxy && customType.name !== null) {
                    return customType.name  // Return the custom type name directly
                }
                // For unresolved references, extract name from the node model
                val typeRefFeature = type.eClass.getEStructuralFeature("type")
                if (typeRefFeature !== null) {
                    val nodes = NodeModelUtils.findNodesForFeature(type, typeRefFeature)
                    if (!nodes.empty) {
                        val typeName = nodes.get(0).text.trim
                        if (!typeName.isEmpty) {
                            return typeName  // Return the type name from source text
                        }
                    }
                }
                return "real"  // fallback
            }
            StringType: return "string"
            IntType: return "int"
            FloatType: return "real"
            BoolType: return "bool"
            default: return "real"  // fallback
        }
    }

    def private List<InitialCondition> extractInitialConditions(Proof proof, String solutionDSL) {
        val result = new ArrayList<InitialCondition>()
        if (solutionDSL === null) {
            return result
        }
        
        val nameCounts = new java.util.HashMap<String, Integer>()

        // First, extract initial conditions from the state block
        val stateBlockText = extractStateBlockText(solutionDSL)
        if (stateBlockText !== null) {
            val lines = stateBlockText.split("\n")
            for (line : lines) {
                val trimmed = line.trim
                // Look for state variable declarations with non-default initializations
                // Format: varName : type = value;
                if (trimmed.contains(":") && trimmed.contains("=") && trimmed.endsWith(";")) {
                    try {
                        val colonIdx = trimmed.indexOf(":")
                        if (colonIdx > 0) {
                            val varName = trimmed.substring(0, colonIdx).trim
                            val eqIdx = trimmed.indexOf("=", colonIdx + 1)
                            if (eqIdx > colonIdx) {
                                val value = trimmed.substring(eqIdx + 1).trim.replaceAll(";", "").trim
                                val geomConversion = convertGeomInitializer(varName, value)
                                if (geomConversion !== null) {
                                    val baseName = sanitizeVarName(varName) + "_init"
                                    val count = nameCounts.get(baseName)
                                    val n = if (count === null) 0 else count.intValue
                                    val uniqueName = if (n == 0) baseName else baseName + "_" + (n + 1)
                                    nameCounts.put(baseName, n + 1)
                                    result.add(new InitialCondition(uniqueName, geomConversion.equation, geomConversion.comment))
                                } else if (!isDefaultValue(value)) {
                                    // Create initial condition equation: varName = value
                                    val equation = varName + " = " + convertValueToIsabelle(value)
                                    val baseName = sanitizeVarName(varName) + "_init"
                                    val count = nameCounts.get(baseName)
                                    val n = if (count === null) 0 else count.intValue
                                    val uniqueName = if (n == 0) baseName else baseName + "_" + (n + 1)
                                    nameCounts.put(baseName, n + 1)
                                    result.add(new InitialCondition(uniqueName, equation))
                                }
                            }
                        }
                    } catch (Exception e) {
                        // Skip malformed lines
                    }
                }
            }
        }

        // Also extract from proof block if there are [t==0] annotations
        if (proof !== null) {
            val proofBlockText = extractProofBlockText(solutionDSL)
            if (proofBlockText !== null) {
                val lines = proofBlockText.split("\n")
                var inInitialConditions = false

                for (line : lines) {
                    val trimmed = line.trim
                    if (trimmed.contains("Initial conditions") && trimmed.contains("[t==0]")) {
                        inInitialConditions = true
                    } else if (trimmed.contains("Algebraic constraints") && trimmed.contains("[t==t]")) {
                        inInitialConditions = false
                    } else if (inInitialConditions && trimmed.contains("==") && !trimmed.startsWith("//")) {
                        // Extract equation
                        val equation = convertProofEquationToIsabelle(trimmed)
                        val varName = extractVariableName(trimmed)
                        val baseName = sanitizeVarName(varName) + "_init"
                        val count = nameCounts.get(baseName)
                        val n = if (count === null) 0 else count.intValue
                        val uniqueName = if (n == 0) baseName else baseName + "_" + (n + 1)
                        nameCounts.put(baseName, n + 1)
                        result.add(new InitialCondition(uniqueName, equation))
                    }
                }
            }
        }
        
        return result
    }

    def private List<InitialCondition> extractInitialConditionsFromState(Solution solution) {
        val result = new ArrayList<InitialCondition>()
        if (solution === null || solution.state === null || solution.state.variables === null) {
            return result
        }

        val nameCounts = new java.util.HashMap<String, Integer>()
        for (varLine : solution.state.variables) {
            val variable = varLine.variable
            if (variable === null || variable.initialValue === null) {
                // skip
            } else {
                val valueNode = NodeModelUtils.getNode(variable.initialValue)
                val valueText = if (valueNode !== null) valueNode.text.trim else null
                if (valueText === null || valueText.isEmpty) {
                    // skip
                } else if (isDefaultValue(valueText)) {
                    // skip
                } else {
                    val varName = variable.name
                    val baseName = sanitizeVarName(varName) + "_init"
                    val count = nameCounts.get(baseName)
                    val n = if (count === null) 0 else count.intValue
                    val uniqueName = if (n == 0) baseName else baseName + "_" + (n + 1)
                    nameCounts.put(baseName, n + 1)

                    val varType = convertEMFTypeToIsabelle(variable.type)
                    if ("Geom".equals(varType)) {
                        val geomConversion = convertGeomInitializer(varName, valueText)
                        if (geomConversion !== null) {
                            result.add(new InitialCondition(uniqueName, geomConversion.equation, geomConversion.comment))
                        } else {
                            result.add(new InitialCondition(uniqueName, varName + " = " + valueText))
                        }
                    } else {
                        val equation = varName + " = " + convertValueToIsabelle(valueText)
                        result.add(new InitialCondition(uniqueName, equation))
                    }
                }
            }
        }

        return result
    }

    def private void mergeInitialConditions(List<InitialCondition> target, List<InitialCondition> additions) {
        if (additions === null || additions.empty) {
            return
        }
        val seen = new java.util.HashSet<String>()
        for (ic : target) {
            seen.add(ic.name)
        }
        for (ic : additions) {
            if (!seen.contains(ic.name)) {
                target.add(ic)
                seen.add(ic.name)
            }
        }
    }

    def private String extractStateBlockText(String solutionDSL) {
        if (solutionDSL === null) return null
        
        val stateIdx = solutionDSL.indexOf("state {")
        if (stateIdx === -1) return null
        
        val startIdx = stateIdx + "state {".length
        var depth = 1
        var i = startIdx
        while (i < solutionDSL.length && depth > 0) {
            val ch = solutionDSL.charAt(i)
            if (ch == '{') {
                depth = depth + 1
            } else if (ch == '}') {
                depth = depth - 1
            }
            i = i + 1
        }
        if (depth != 0) return null
        val endIdx = i - 1
        return solutionDSL.substring(startIdx, endIdx)
    }

    def private boolean isDefaultValue(String value) {
        if (value === null || value.isEmpty) return true
        
        // Check for zero initializations
        if (value.equals("0") || value.equals("0.0")) return true
        if (value.startsWith("zeroVec(") || value.startsWith("zeroMat(")) return true
        if (value.equals("seq()") || value.equals("<>")) return true
        
        return false
    }

    def private GeomConversion convertGeomInitializer(String varName, String value) {
        if (value === null || !value.contains("Geom")) {
            return null
        }
        val geomType = extractGeomType(value)
        if (geomType === null) {
            return null
        }
        val geomTypeClean = geomType.toLowerCase
        if (!geomTypeClean.contains("mesh")) {
            return null
        }

        val geomValRaw = extractGeomList(value, "geomVal")
        val meshUriRaw = extractGeomString(value, "meshUri")
        val meshScaleRaw = extractGeomList(value, "meshScale")

        var comment = ""
        var List<Double> geomVals = if (geomValRaw !== null) parseNumericList(geomValRaw) else new ArrayList<Double>()

        val meshUri = stripStringLiteral(meshUriRaw)
        val meshScale = parseNumericList(meshScaleRaw)
        val bounds = computeMeshBounds(meshUri, meshScale)
        if (bounds !== null && bounds.valid) {
            geomVals = #[bounds.sizeX, bounds.sizeY, bounds.sizeZ]
            comment = "geom upper bound: mesh bounding box computed from " + meshUri
        } else {
            if ((geomVals === null || geomVals.empty) && meshScale !== null && meshScale.size >= 3) {
                geomVals = #[meshScale.get(0), meshScale.get(1), meshScale.get(2)]
            }
            if (geomVals === null || geomVals.empty) {
                geomVals = #[1.0, 1.0, 1.0]
            }
            comment = "geom upper bound: mesh bounds unavailable for " + meshUri + ", using fallback box"
        }
        val equation = varName + " = " + formatGeomBox(geomVals)
        return new GeomConversion(equation, comment)
    }

    def private String extractGeomType(String value) {
        val pattern = java.util.regex.Pattern.compile("geomType\\s*=\\s*([^,}]+)")
        val matcher = pattern.matcher(value)
        if (matcher.find()) {
            return matcher.group(1).trim.replaceAll("\"", "")
        }
        return null
    }

    def private String extractGeomString(String value, String fieldName) {
        val pattern = java.util.regex.Pattern.compile(fieldName + "\\s*=\\s*\"([^\"]*)\"")
        val matcher = pattern.matcher(value)
        if (matcher.find()) {
            return matcher.group(1).trim
        }
        return null
    }

    def private String extractGeomList(String value, String fieldName) {
        val pattern = java.util.regex.Pattern.compile(fieldName + "\\s*=\\s*\\[([^\\]]*)\\]")
        val matcher = pattern.matcher(value)
        if (matcher.find()) {
            return matcher.group(1).trim
        }
        return null
    }

    def private String stripStringLiteral(String raw) {
        if (raw === null) return ""
        var cleaned = raw.trim
        if (cleaned.startsWith("\"") && cleaned.endsWith("\"")) {
            cleaned = cleaned.substring(1, cleaned.length - 1)
        }
        return cleaned
    }

    def private List<Double> parseNumericList(String raw) {
        if (raw === null) return null
        val cleaned = raw.replaceAll("[\\[\\]\\|]", " ")
        val matcher = java.util.regex.Pattern.compile("[-+]?\\d*\\.?\\d+(?:[eE][-+]?\\d+)?").matcher(cleaned)
        val result = new ArrayList<Double>()
        while (matcher.find()) {
            try {
                result.add(Double.parseDouble(matcher.group(0)))
            } catch (Exception e) {
                // Skip malformed numbers
            }
        }
        return result
    }

    def private String formatGeomBox(List<Double> geomVals) {
        val values = geomVals.map[v | v.toString].join(", ")
        return "Geom { geomType = \"box\", geomVal = [" + values + "] }"
    }

    def private MeshBounds computeMeshBounds(String meshUri, List<Double> meshScale) {
        if (meshUri === null || meshUri.trim.isEmpty) {
            return null
        }
        val meshPath = resolveMeshPath(meshUri)
        if (meshPath === null || !Files.exists(meshPath)) {
            return null
        }
        val bounds = parseMeshFile(meshPath)
        if (bounds === null || !bounds.valid) {
            return null
        }
        val scale = normalizeScale(meshScale)
        if (scale !== null) {
            bounds.minX *= scale.get(0)
            bounds.maxX *= scale.get(0)
            bounds.minY *= scale.get(1)
            bounds.maxY *= scale.get(1)
            bounds.minZ *= scale.get(2)
            bounds.maxZ *= scale.get(2)
        }
        return bounds
    }

    def private List<Double> normalizeScale(List<Double> meshScale) {
        if (meshScale === null || meshScale.empty) {
            return null
        }
        if (meshScale.size >= 3) {
            return #[Math.abs(meshScale.get(0)), Math.abs(meshScale.get(1)), Math.abs(meshScale.get(2))]
        }
        if (meshScale.size == 1) {
            val s = Math.abs(meshScale.get(0))
            return #[s, s, s]
        }
        return null
    }

    def private Path resolveMeshPath(String meshUri) {
        var cleaned = meshUri.trim
        if (cleaned.startsWith("file://")) {
            cleaned = cleaned.substring("file://".length)
        } else if (cleaned.startsWith("package://")) {
            cleaned = cleaned.substring("package://".length)
        }
        val direct = Paths.get(cleaned)
        if (Files.exists(direct)) {
            return direct
        }
        val suffix = if (cleaned.contains("/")) cleaned.substring(cleaned.indexOf("/") + 1) else null
        var current = Paths.get(System.getProperty("user.dir"))
        for (i : 0 ..< 6) {
            val candidate = current.resolve(cleaned)
            if (Files.exists(candidate)) {
                return candidate
            }
            if (suffix !== null) {
                val found = findBySuffix(current, suffix)
                if (found !== null) {
                    return found
                }
            }
            val parent = current.parent
            if (parent === null) {
                return null
            }
            current = parent
        }
        return null
    }

    def private Path findBySuffix(Path root, String suffix) {
        try {
            val stream = Files.find(root, 6, [path, attrs | path.toString.replace("\\", "/").endsWith(suffix)])
            val found = stream.findFirst
            stream.close
            if (found.isPresent) {
                return found.get
            }
        } catch (Exception e) {
            // Ignore lookup failures
        }
        return null
    }

    def private MeshBounds parseMeshFile(Path meshPath) {
        val fileName = meshPath.fileName.toString.toLowerCase
        if (fileName.endsWith(".obj")) {
            return parseObj(meshPath)
        } else if (fileName.endsWith(".stl")) {
            return parseStl(meshPath)
        } else if (fileName.endsWith(".dae")) {
            return parseDae(meshPath)
        }
        return null
    }

    def private MeshBounds parseObj(Path meshPath) {
        val bounds = new MeshBounds()
        var BufferedReader reader = null
        try {
            reader = Files.newBufferedReader(meshPath, StandardCharsets.UTF_8)
            var line = reader.readLine
            while (line !== null) {
                val trimmed = line.trim
                if (trimmed.startsWith("v ")) {
                    val parts = trimmed.split("\\s+")
                    if (parts.length >= 4) {
                        bounds.addVertex(Double.parseDouble(parts.get(1)), Double.parseDouble(parts.get(2)), Double.parseDouble(parts.get(3)))
                    }
                }
                line = reader.readLine
            }
        } catch (Exception e) {
            return null
        } finally {
            if (reader !== null) reader.close
        }
        return bounds
    }

    def private MeshBounds parseStl(Path meshPath) {
        val file = meshPath.toFile
        if (file.length >= 84) {
            try {
                val input = new BufferedInputStream(new FileInputStream(file))
                val header = ByteBuffer.allocate(84).array
                val read = input.read(header)
                if (read == 84) {
                    val buf = ByteBuffer.wrap(header, 80, 4).order(ByteOrder.LITTLE_ENDIAN)
                    val triCount = buf.getInt(0)
                    val expected = 84L + ((triCount as long) * 50L)
                    if (expected == file.length) {
                        input.close
                        return parseBinaryStl(meshPath, triCount)
                    }
                }
                input.close
            } catch (Exception e) {
                // Fall back to ASCII
            }
        }
        return parseAsciiStl(meshPath)
    }

    def private MeshBounds parseBinaryStl(Path meshPath, int triCount) {
        val bounds = new MeshBounds()
        var BufferedInputStream input = null
        try {
            input = new BufferedInputStream(new FileInputStream(meshPath.toFile))
            val header = ByteBuffer.allocate(84).array
            input.read(header)
            val buffer = ByteBuffer.allocate(50).array
            for (i : 0 ..< triCount) {
                val read = input.read(buffer)
                if (read != 50) {
                    return bounds
                }
                val bb = ByteBuffer.wrap(buffer).order(ByteOrder.LITTLE_ENDIAN)
                bb.position(12) // skip normal
                for (v : 0 ..< 3) {
                    val x = bb.getFloat
                    val y = bb.getFloat
                    val z = bb.getFloat
                    bounds.addVertex(x, y, z)
                }
            }
        } catch (Exception e) {
            return null
        } finally {
            if (input !== null) input.close
        }
        return bounds
    }

    def private MeshBounds parseAsciiStl(Path meshPath) {
        val bounds = new MeshBounds()
        var BufferedReader reader = null
        try {
            reader = Files.newBufferedReader(meshPath, StandardCharsets.UTF_8)
            var line = reader.readLine
            while (line !== null) {
                val trimmed = line.trim
                if (trimmed.startsWith("vertex")) {
                    val parts = trimmed.split("\\s+")
                    if (parts.length >= 4) {
                        bounds.addVertex(Double.parseDouble(parts.get(1)), Double.parseDouble(parts.get(2)), Double.parseDouble(parts.get(3)))
                    }
                }
                line = reader.readLine
            }
        } catch (Exception e) {
            return null
        } finally {
            if (reader !== null) reader.close
        }
        return bounds
    }

    def private MeshBounds parseDae(Path meshPath) {
        val bounds = new MeshBounds()
        var String content = null
        try {
            content = new String(Files.readAllBytes(meshPath), StandardCharsets.UTF_8)
        } catch (Exception e) {
            return null
        }
        if (content === null) return null
        val floatArrayPattern = java.util.regex.Pattern.compile("<float_array[^>]*>([^<]+)</float_array>")
        val matcher = floatArrayPattern.matcher(content)
        while (matcher.find()) {
            val floatText = matcher.group(1).trim
            val values = parseNumericList(floatText)
            if (values !== null && values.size >= 3) {
                val count = values.size - (values.size % 3)
                var i = 0
                while (i + 2 < count) {
                    bounds.addVertex(values.get(i), values.get(i + 1), values.get(i + 2))
                    i = i + 3
                }
                if (bounds.valid) {
                    return bounds
                }
            }
        }
        return bounds.valid ? bounds : null
    }

    def private String convertValueToIsabelle(String value) {
        var result = value
        
        // Convert seq(...) to list notation [...]
        result = result.replaceAll("seq\\s*\\(", "[").replaceAll("\\)$", "]")
        
        // Try to convert matrix literals to ISAVodes format
        result = convertMatrixLiteral(result)
        
        // Convert function calls
        result = convertFunctionCalls(result)
        
        return result
    }
    
    /**
     * Convert flat matrix notation [a,b,c d,e,f] or [|a,b,c;d,e,f|] or [a,b,c; d,e,f] to ISAVodes format \<^bold>[[a,b,c],[d,e,f]\<^bold>]
     */
    def private String convertMatrixLiteral(String value) {
        if (value === null || value.isEmpty) {
            return value
        }
        
        var trimmed = value.trim
        
        // Handle [|...|] matrix notation
        if (trimmed.startsWith("[|") && trimmed.endsWith("|]")) {
            trimmed = trimmed.substring(2, trimmed.length - 2).trim
            
            // Split by semicolons for rows
            val rows = trimmed.split(";")
            if (rows.length <= 1) {
                return value  // Single row
            }
            
            // Build ISAVodes matrix
            val builder = new StringBuilder
            builder.append("\\<^bold>[")
            for (var i = 0; i < rows.length; i++) {
                builder.append("[").append(rows.get(i).trim).append("]")
                if (i < rows.length - 1) {
                    builder.append(",\n  ")
                }
            }
            builder.append("\\<^bold>]")
            return builder.toString
        }
        
        // Handle [...; ...] matrix notation (semicolons separate rows)
        if (trimmed.startsWith("[") && trimmed.contains(";")) {
            val inner = trimmed.substring(1, trimmed.length - 1).trim
            
            // Split by semicolons for rows
            val rows = inner.split(";")
            if (rows.length <= 1) {
                return value  // Single row
            }
            
            // Build ISAVodes matrix
            val builder = new StringBuilder
            builder.append("\\<^bold>[")
            for (var i = 0; i < rows.length; i++) {
                builder.append("[").append(rows.get(i).trim).append("]")
                if (i < rows.length - 1) {
                    builder.append(",\n  ")
                }
            }
            builder.append("\\<^bold>]")
            return builder.toString
        }
        
        // Handle [... ...] matrix notation with spaces
        if (!trimmed.startsWith("[")) {
            return value
        }
        
        // Check if this looks like a matrix (contains space-separated rows)
        if (!trimmed.matches("\\[.*\\s+.*\\]")) {
            return value  // Not a matrix, just a list
        }
        
        // Don't convert if it's a list of identifiers (like [B_1, B_2, B_3])
        if (trimmed.matches("\\[[A-Z_][a-zA-Z0-9_,\\s]*\\]")) {
            return value  // List of variable names, not a matrix literal
        }
        
        try {
            // Remove outer brackets
            val inner = trimmed.substring(1, trimmed.length - 1).trim
            
            // Split by spaces to get rows (spaces separate rows in the input)
            val rows = inner.split("\\s+")
            
            if (rows.length <= 1) {
                return value  // Single row, not really a matrix
            }
            
            // Build ISAVodes matrix: \<^bold>[[row1],[row2],...]\<^bold>]
            val builder = new StringBuilder
            builder.append("\\<^bold>[")
            for (var i = 0; i < rows.length; i++) {
                builder.append("[").append(rows.get(i)).append("]")
                if (i < rows.length - 1) {
                    builder.append(",\n  ")  // Newline and indent for readability
                }
            }
            builder.append("\\<^bold>]")
            
            return builder.toString
        } catch (Exception e) {
            // If parsing fails, return original
            return value
        }
    }
    
    /**
     * Generate Isabelle expression from AST (similar to C++ generator approach)
     */
    def private String generateIsabelleExpression(Expression expr) {
        switch expr {
            RelationalExpression: {
                val leftExpr = generateIsabelleExpression(expr.left)
                val rightExpr = generateIsabelleExpression(expr.right)
                val op = if (expr.operator == "==") "=" else expr.operator
                return leftExpr + " " + op + " " + rightExpr
            }
            Addition: {
                val leftExpr = generateIsabelleExpression(expr.left)
                val rightExpr = generateIsabelleExpression(expr.right)
                return leftExpr + " " + expr.operator + " " + rightExpr
            }
            Multiplication: {
                val leftExpr = generateIsabelleExpression(expr.left)
                val rightExpr = generateIsabelleExpression(expr.right)
                // Determine operator based on types (heuristic)
                val op = inferMultiplicationOperator(expr.left, expr.right)
                return leftExpr + " " + op + " " + rightExpr
            }
            Unary: {
                return "-" + generateIsabelleExpression(expr.operand)
            }
            Submatrix: {
                val base = generateIsabelleExpression(expr.variable)
                val rowStartStr = generateIsabelleExpression(expr.rowStart)
                val colStartStr = generateIsabelleExpression(expr.colStart)
                val numRowsStr = generateIsabelleExpression(expr.numRows)
                val numColsStr = generateIsabelleExpression(expr.numCols)

                val rowStart = parseIntOrNull(rowStartStr)
                val colStart = parseIntOrNull(colStartStr)
                val numRows = parseIntOrNull(numRowsStr)
                val numCols = parseIntOrNull(numColsStr)

                if (rowStart !== null && colStart !== null && numRows !== null && numCols !== null) {
                    return buildSubmatrixLiteral(base, rowStart, colStart, numRows, numCols)
                }

                // Fallback (best-effort): preserve structure if indices aren't literal numerals
                return "submatrix(" + base + "," + rowStartStr + "," + colStartStr + "," + numRowsStr + "," + numColsStr + ")"
            }
            FunctionCall: {
                val functionName = if (expr.function !== null && expr.function.name !== null) 
                    expr.function.name 
                else {
                    // Try to extract function name from toString when reference is unresolved
                    val exprStr = expr.toString
                    if (exprStr !== null && exprStr.contains("(")) {
                        // Extract function name before the parenthesis
                        val idx = exprStr.indexOf("(")
                        if (idx > 0) {
                            val possibleName = exprStr.substring(0, idx).trim
                            // Remove any "FunctionCallImpl" prefix
                            if (possibleName.matches("[a-zA-Z_][a-zA-Z0-9_]*")) {
                                possibleName
                            } else {
                                null
                            }
                        } else {
                            null
                        }
                    } else {
                        null
                    }
                }
                
                // Handle known functions
                if (functionName == "adj" && expr.arguments.size == 1) {
                    return "transpose " + generateIsabelleExpression(expr.arguments.get(0))
                } else if (functionName == "derivative") {
                    if (expr.arguments.size == 1) {
                        val arg = expr.arguments.get(0)
                        if (arg instanceof FunctionCall && (arg as FunctionCall).function?.name == "derivative") {
                            // Second derivative
                            return generateIsabelleExpression((arg as FunctionCall).arguments.get(0)) + "''"
                        } else {
                            // First derivative
                            return generateIsabelleExpression(arg) + "'"
                        }
                    }
                } else if (functionName == "cos" || functionName == "sin" || functionName == "tan") {
                    // Trig functions - keep syntax with arguments
                    val args = expr.arguments.map[generateIsabelleExpression(it)].join(", ")
                    return functionName + "(" + args + ")"
                } else if (functionName == "identity" && expr.arguments.size == 1) {
                    val n = parseIntOrNull(generateIsabelleExpression(expr.arguments.get(0)))
                    if (n !== null) {
                        return buildIdentityLiteral(n)
                    }
                } else if (functionName == "zeroes" && expr.arguments.size == 1) {
                    val n = parseIntOrNull(generateIsabelleExpression(expr.arguments.get(0)))
                    if (n !== null) {
                        return buildZeroesLiteral(n)
                    }
                } else if (functionName === null && expr.arguments.size > 0) {
                    // Unresolved function - just return the argument in parentheses
                    if (expr.arguments.size == 1) {
                        val arg = generateIsabelleExpression(expr.arguments.get(0))
                        return "(" + arg + ")"
                    }
                }
                
                // Default: return unknown for unhandled functions
                val args = expr.arguments.map[generateIsabelleExpression(it)].join(", ")
                return (functionName ?: "unknown") + "(" + args + ")"
            }
            VariableReference: {
                return expr.variable?.name ?: "unknown"
            }
            Primary: {
                // Handle indexing: variable(index) -> variable$index
                if (!expr.indexes.empty) {
                    val baseExpr = generateIsabelleExpression(expr.base)
                    val index = generateIsabelleExpression(expr.indexes.get(0).first)
                    return baseExpr + "$" + index
                }
                return generateIsabelleExpression(expr.base)
            }
            IntegerExp: {
                return expr.value.toString
            }
            FloatExp: {
                return expr.value.toString
            }
            VectorOrMatrix: {
                // Convert matrix literals
                return convertMatrixLiteralFromAST(expr)
            }
            SequenceLiteral: {
                val elements = expr.elements.map[generateIsabelleExpression(it)].join(", ")
                return "[" + elements + "]"
            }
            default: {
                // Fallback to string representation
                return expr?.toString ?: "unknown"
            }
        }
    }
    
    /**
     * Infer multiplication operator based on operand types (heuristic)
     */
    def private String inferMultiplicationOperator(Expression left, Expression right) {
        val leftIsMatrix = isMatrixExpression(left)
        val rightIsMatrix = isMatrixExpression(right)
        
        if (leftIsMatrix && rightIsMatrix) {
            return "**"  // matrix * matrix
        } else if (leftIsMatrix) {
            return "*v"  // matrix * vector
        } else {
            return "*"   // scalar or unknown
        }
    }
    
    /**
     * Check if expression likely represents a matrix (heuristic)
     */
    def private boolean isMatrixExpression(Expression expr) {
        switch expr {
            VariableReference: {
                val name = expr.variable?.name
                // Heuristic: uppercase first letter or contains underscore (likely a matrix variable)
                return name !== null && (Character.isUpperCase(name.charAt(0)) || name.contains("_"))
            }
            FunctionCall: {
                val fname = expr.function?.name
                return fname == "transpose" || fname == "adj"
            }
            Multiplication, Addition: {
                return true  // Assume compound expressions might be matrices
            }
            Primary: {
                // Check the base
                return isMatrixExpression(expr.base)
            }
            default: return false
        }
    }
    
    /**
     * Convert matrix literal from AST to ISAVodes format
     */
    def private String convertMatrixLiteralFromAST(VectorOrMatrix matrix) {
        val rows = matrix.rows
        if (rows === null || rows.size <= 1) {
            // Single row or vector - just use list notation
            if (rows !== null && !rows.empty) {
                val row = rows.get(0)
                if (row instanceof RowLiteral) {
                    val elements = (row as RowLiteral).elements.map[generateIsabelleExpression(it)].join(", ")
                    return "[" + elements + "]"
                }
            }
            return "[]"
        }
        
        // Multi-row matrix - use ISAVodes matrix syntax
        val builder = new StringBuilder
        builder.append("\\<^bold>[")
        for (var i = 0; i < rows.size; i++) {
            val row = rows.get(i)
            if (row instanceof RowLiteral) {
                val elements = (row as RowLiteral).elements.map[generateIsabelleExpression(it)].join(",")
                builder.append("[").append(elements).append("]")
                if (i < rows.size - 1) {
                    builder.append(",\n  ")
                }
            }
        }
        builder.append("\\<^bold>]")
        return builder.toString
    }

    def private List<AlgebraicEquation> extractAlgebraicConstraints(Proof proof, String solutionDSL) {
        val result = new ArrayList<AlgebraicEquation>()
        if (proof === null) {
            return result
        }

        val nameCounts = new java.util.HashMap<String, Integer>()

        // Use AST directly - process proof.expressions
        for (expr : proof.expressions) {
            if (expr instanceof RelationalExpression) {
                val relExpr = expr as RelationalExpression
                // Generate the equation using AST
                val equation = generateIsabelleExpression(relExpr)
                // Extract variable name from left side
                val varName = extractVarNameFromExpression(relExpr.left) ?: "constraint"
                val baseName = sanitizeVarName(varName) + "_eq"
                val count = nameCounts.get(baseName)
                val n = if (count === null) 0 else count.intValue
                val uniqueName = if (n == 0) baseName else baseName + "_" + (n + 1)
                nameCounts.put(baseName, n + 1)
                result.add(new AlgebraicEquation(uniqueName, equation))
            }
        }
        
        return result
    }
    
    /**
     * Extract variable name from expression for naming purposes
     */
    def private String extractVarNameFromExpression(Expression expr) {
        switch expr {
            VariableReference: return expr.variable?.name ?: "var"
            FunctionCall: return expr.function?.name ?: "func"
            Submatrix: {
                val base = extractVarNameFromExpression(expr.variable)
                val rs = generateIsabelleExpression(expr.rowStart)
                val cs = generateIsabelleExpression(expr.colStart)
                val nr = generateIsabelleExpression(expr.numRows)
                val nc = generateIsabelleExpression(expr.numCols)
                return "submatrix_" + base + "_" + rs + "_" + cs + "_" + nr + "_" + nc
            }
            Primary: return extractVarNameFromExpression(expr.base)
            default: return "constraint"
        }
    }

    def private Integer parseIntOrNull(String s) {
        if (s === null) return null
        try {
            return Integer.parseInt(s.trim)
        } catch (Exception e) {
            return null
        }
    }

    def private String buildSubmatrixLiteral(String base, int rowStart, int colStart, int numRows, int numCols) {
        val baseTerm = if (base !== null && base.matches("[a-zA-Z_][a-zA-Z0-9_]*")) {
            base
        } else {
            "(" + (base ?: "unknown") + ")"
        }
        val builder = new StringBuilder
        builder.append("\\<^bold>[")
        for (var r = 0; r < numRows; r++) {
            builder.append("[")
            for (var c = 0; c < numCols; c++) {
                builder.append(baseTerm).append("$").append(rowStart + r).append("$").append(colStart + c)
                if (c < numCols - 1) {
                    builder.append(",")
                }
            }
            builder.append("]")
            if (r < numRows - 1) {
                builder.append(",\n  ")
            }
        }
        builder.append("\\<^bold>]")
        return builder.toString
    }

    def private String buildIdentityLiteral(int n) {
        val builder = new StringBuilder
        builder.append("\\<^bold>[")
        for (var r = 0; r < n; r++) {
            builder.append("[")
            for (var c = 0; c < n; c++) {
                builder.append(if (r == c) "1" else "0")
                if (c < n - 1) {
                    builder.append(",")
                }
            }
            builder.append("]")
            if (r < n - 1) {
                builder.append(",\n  ")
            }
        }
        builder.append("\\<^bold>]")
        return builder.toString
    }

    def private String buildZeroesLiteral(int n) {
        val builder = new StringBuilder
        builder.append("\\<^bold>[")
        for (var r = 0; r < n; r++) {
            builder.append("[")
            for (var c = 0; c < n; c++) {
                builder.append("0")
                if (c < n - 1) {
                    builder.append(",")
                }
            }
            builder.append("]")
            if (r < n - 1) {
                builder.append(",\n  ")
            }
        }
        builder.append("\\<^bold>]")
        return builder.toString
    }

    def private String extractProofBlockText(String solutionDSL) {
        if (solutionDSL === null) return null
        
        val proofIdx = solutionDSL.indexOf("proof {")
        if (proofIdx === -1) return null
        
        val startIdx = proofIdx + "proof {".length
        val endIdx = solutionDSL.indexOf("}", startIdx)
        if (endIdx === -1) return null
        
        return solutionDSL.substring(startIdx, endIdx)
    }

    def private String convertProofEquationToIsabelle(String equation) {
        var result = equation.trim
        
        // Remove trailing semicolon
        if (result.endsWith(";")) {
            result = result.substring(0, result.length - 1).trim
        }
        
        // Convert == to =
        result = result.replaceAll("==", "=")
        
        // Convert seq(...) to list notation [...] but preserve proper closing
        result = result.replaceAll("seq\\s*\\(", "[")
        
        // Convert function calls FIRST (operators, derivatives, vector indexing)
        result = convertFunctionCalls(result)
        
        // THEN try to convert matrix literals in the RHS
        // Split on = to get variable and value
        val parts = result.split("=", 2)
        if (parts.length == 2) {
            val varPart = parts.get(0).trim
            val valuePart = parts.get(1).trim
            val convertedValue = convertMatrixLiteral(valuePart)
            result = varPart + " = " + convertedValue
        }
        
        return result
    }

    def private String extractVariableName(String equation) {
        val parts = equation.split("==")
        if (parts.length > 0) {
            return parts.get(0).trim.replaceAll("[^a-zA-Z0-9_]", "_")
        }
        return "var"
    }

    def private String sanitizeVarName(String name) {
        return name.replaceAll("[^a-zA-Z0-9_]", "_").toLowerCase
    }

    def private String convertTypeToIsabelle(String physmodType) {
        if (physmodType === null) return "real"

        var cleanType = physmodType.trim
        
        // Convert physmod types to Isabelle/HOL types
        // seq(T) → T list
        if (cleanType.startsWith("seq(") || cleanType.startsWith("Seq(")) {
            val innerType = extractInnerType(cleanType, "seq")
            if (innerType !== null) {
                return convertTypeToIsabelle(innerType) + " list"
            }
            return "real list"
        }
        
        // vec(n) → real^n (Isabelle vector type)
        if (cleanType.startsWith("vec(") || cleanType.startsWith("vector(")) {
            val dimStr = extractDimension(cleanType)
            if (dimStr !== null && !dimStr.isEmpty) {
                return "real^" + dimStr
            }
            return "real vec"
        }
        
        // mat(rows,cols) → real^rows^cols (Isabelle matrix type)
        if (cleanType.startsWith("mat(") || cleanType.startsWith("matrix(")) {
            val dims = extractMatrixDimensions(cleanType)
            if (dims !== null && dims.length == 2) {
                return "real^" + dims.get(1) + "^" + dims.get(0)  // Isabelle: cols then rows
            }
            return "real mat"
        }
        
        // Primitive types
        if (cleanType.contains("int")) {
            return "int"
        } else if (cleanType.contains("float") || cleanType.contains("real")) {
            return "real"
        } else if (cleanType.contains("bool")) {
            return "bool"
        }

        // Geom datatype (geometry specification with geomType and geomVal fields)
        if (cleanType.equals("Geom") || cleanType.equals("geom")) {
            return "Geom"
        }

        // Default
        return "real"
    }
    
    def private String extractInnerType(String typeStr, String prefix) {
        try {
            val startIdx = typeStr.indexOf("(")
            if (startIdx === -1) return null
            
            val endIdx = typeStr.lastIndexOf(")")
            if (endIdx === -1 || endIdx <= startIdx) return null
            
            return typeStr.substring(startIdx + 1, endIdx).trim
        } catch (Exception e) {
            return null
        }
    }
    
    def private String extractDimension(String typeStr) {
        try {
            val startIdx = typeStr.indexOf("(")
            val endIdx = typeStr.indexOf(")")
            if (startIdx === -1 || endIdx === -1 || endIdx <= startIdx) return null
            
            val dimStr = typeStr.substring(startIdx + 1, endIdx).trim
            // Remove type prefix if present (e.g., "real,2" → "2")
            if (dimStr.contains(",")) {
                val parts = dimStr.split(",")
                return parts.get(parts.length - 1).trim
            }
            return dimStr
        } catch (Exception e) {
            return null
        }
    }
    
    def private String[] extractMatrixDimensions(String typeStr) {
        try {
            val startIdx = typeStr.indexOf("(")
            val endIdx = typeStr.indexOf(")")
            if (startIdx === -1 || endIdx === -1 || endIdx <= startIdx) return null
            
            val dimStr = typeStr.substring(startIdx + 1, endIdx).trim
            // Remove type prefix if present (e.g., "real,18,18" → ["18","18"])
            val parts = dimStr.split(",")
            if (parts.length >= 2) {
                // Return last two elements as dimensions
                val rows = parts.get(parts.length - 2).trim
                val cols = parts.get(parts.length - 1).trim
                return #[rows, cols]
            }
            return null
        } catch (Exception e) {
            return null
        }
    }

    def private String generateProofAxioms(Proof proof) {
        val builder = new StringBuilder
        builder.append("\ntext \\<open>System Equations (as axioms)\\<close>\n\n")
        builder.append("axiomatization where\n")

        var first = true
        for (expr : proof.expressions) {
            if (!first) builder.append(" and\n")
            first = false

            val axiomName = "equation_" + proof.expressions.indexOf(expr)
            // Cast to RelationalExpression if needed
            val relExpr = if (expr instanceof RelationalExpression) expr as RelationalExpression else null
            if (relExpr !== null) {
                val isabelleExpr = escapeTermForIsabelle(convertToIsabelleExpression(relExpr))
                builder.append("  ").append(axiomName).append(": \"").append(isabelleExpr).append("\"")
            }
        }
        builder.append("\n\n")
        builder.toString
    }

    def private String convertToIsabelleExpression(RelationalExpression expr) {
        if (expr === null) return ""

        // Get string representation and clean it up
        var result = expr.toString.replaceAll("Impl@[0-9a-f]+", "").trim

        // Convert equality operators
        result = result.replaceAll("==", "=")

        // Convert angle bracket sequences <a,b,c> to vector notation
        // Isabelle uses different vector syntax depending on the context
        result = result.replaceAll("<([^>]+)>", "[$1]")

        // Convert matrix notation [|...|] to [[...]]
        result = result.replaceAll("\\[\\|", "[[").replaceAll("\\|\\]", "]]")

        // Handle common function calls
        result = convertFunctionCalls(result)

        return result
    }

    def private String convertFunctionCalls(String expr) {
        var result = expr

        // Convert field access: var . field -> field var (Isabelle record selector syntax)
        // e.g., L1_geom . geomType -> geomType L1_geom
        result = result.replaceAll("([a-zA-Z_][a-zA-Z0-9_]*)\\s*\\.\\s*([a-zA-Z_][a-zA-Z0-9_]*)", "$2 $1")

        // Replace adj(X) with transpose X (no parentheses in ISAVodes)
        result = result.replaceAll("adj\\s*\\(\\s*([a-zA-Z_][a-zA-Z0-9_']*)\\s*\\)", "transpose $1")
        
        // Replace derivative(derivative(v)) with v'' (second derivative)
        result = result.replaceAll("derivative\\s*\\(\\s*derivative\\s*\\(\\s*([a-zA-Z_][a-zA-Z0-9_]*)\\s*\\)\\s*\\)", "$1''")
        
        // Replace derivative(v) with v' (first derivative)
        result = result.replaceAll("derivative\\s*\\(\\s*([a-zA-Z_][a-zA-Z0-9_']*)\\s*\\)", "$1'")
        
        // Replace vector indexing: theta(0) -> theta$0
        result = result.replaceAll("([a-zA-Z_][a-zA-Z0-9_]*)\\s*\\(\\s*(\\d+)\\s*\\)", "$1\\$$2")
        
        // Convert multiplication operators using heuristics
        // Use a marker to avoid double-conversion: convert * to @MAT@ or @VEC@ then replace at end
        
        // Pattern: transpose X * transpose Y -> transpose X @MAT@ transpose Y
        result = result.replaceAll("(transpose\\s+[a-zA-Z_][a-zA-Z0-9_']*)\\s*\\*\\s*(transpose\\s+[a-zA-Z_][a-zA-Z0-9_']*)", "$1 @MAT@ $2")
        
        // Pattern: transpose X * Uppercase -> transpose X @MAT@ Uppercase
        result = result.replaceAll("(transpose\\s+[a-zA-Z_][a-zA-Z0-9_']*)\\s*\\*\\s*([A-Z_][a-zA-Z0-9_']*)", "$1 @MAT@ $2")
        
        // Pattern: Uppercase * Uppercase -> Uppercase @MAT@ Uppercase
        result = result.replaceAll("([A-Z_][a-zA-Z0-9_']*)\\s*\\*\\s*([A-Z_][a-zA-Z0-9_']*)", "$1 @MAT@ $2")
        
        // Pattern: Uppercase * transpose -> Uppercase @MAT@ transpose
        result = result.replaceAll("([A-Z_][a-zA-Z0-9_']*)\\s*\\*\\s*(transpose\\s+)", "$1 @MAT@ $2")
        
        // Pattern: Matrix * (expr) -> Matrix @VEC@ (expr)
        result = result.replaceAll("([A-Z_][a-zA-Z0-9_']*)\\s*\\*\\s*\\(", "$1 @VEC@ (")
        result = result.replaceAll("(transpose\\s+[a-zA-Z_][a-zA-Z0-9_']*)\\s*\\*\\s*\\(", "$1 @VEC@ (")

        // Pattern: Matrix * lowercase -> Matrix @VEC@ lowercase
        result = result.replaceAll("([A-Z_][a-zA-Z0-9_']*)\\s*\\*\\s*([a-z][a-zA-Z0-9_'']*)", "$1 @VEC@ $2")
        result = result.replaceAll("(transpose\\s+[a-zA-Z_][a-zA-Z0-9_']*)\\s*\\*\\s*([a-z][a-zA-Z0-9_'']*)", "$1 @VEC@ $2")
        
        // Now replace markers with actual operators
        result = result.replaceAll("@MAT@", "**")
        result = result.replaceAll("@VEC@", "*v")
        
        // seq() conversions to list notation
        result = result.replaceAll("seq\\s*\\(", "[")
        
        // Fix any remaining closing parens that should be brackets for seq
        result = result.replaceAll("\\[([^\\(]*)\\)", "[$1]")
        
        // Clean up extra spaces
        result = result.replaceAll("\\s+", " ")
        result = result.replaceAll("\\s+\\)", ")")
        result = result.replaceAll("\\(\\s+", "(")
        
        return result
    }

    def private String escapeForIsabelle(String blockText) {
        if (blockText === null) {
            return ""
        }
        blockText.replace("\\", "\\\\")
    }

    def private String escapeTermForIsabelle(String termText) {
        if (termText === null) {
            return ""
        }
        termText.replace("\"", "\\\\\"")
    }

    def static List<String> extractBlockSections(String solutionText) {
        val result = new ArrayList<String>
        if (solutionText === null || solutionText.isEmpty) {
            return result
        }

        val solutionIdx = solutionText.indexOf("Solution")
        if (solutionIdx === -1) {
            return result
        }
        val openSolution = solutionText.indexOf("{", solutionIdx)
        if (openSolution === -1) {
            return result
        }

        // Extract top-level sections inside the Solution body. Older generators emitted
        // `block <name> { ... }`, newer ones emit `<name> { ... }`. Both are handled here.
        var i = openSolution + 1
        while (i < solutionText.length) {
            while (i < solutionText.length && Character.isWhitespace(solutionText.charAt(i))) {
                i++
            }
            if (i >= solutionText.length) {
                return result
            }
            if (solutionText.charAt(i).toString.equals("}")) {
                return result
            }

            val braceIdx = solutionText.indexOf("{", i)
            if (braceIdx === -1) {
                return result
            }

            var depth = 0
            var endIdx = -1
            var j = braceIdx
            while (j < solutionText.length && endIdx == -1) {
                val ch = solutionText.charAt(j)
                if (ch.toString.equals("{")) {
                    depth++
                } else if (ch.toString.equals("}")) {
                    depth--
                    if (depth == 0) {
                        endIdx = j
                    }
                }
                j++
            }
            if (endIdx === -1) {
                return result
            }

            val blockText = solutionText.substring(i, endIdx + 1).trim
            if (!blockText.isEmpty) {
                result.add(blockText)
            }
            i = endIdx + 1
        }
        result
    }

    def private String sanitizeName(String original) {
        val base = if (original === null || original.trim.isEmpty) "Solution"
            else original.replaceAll("[^A-Za-z0-9]", "_")
        if (Character.isLetter(base.charAt(0)) && Character.isUpperCase(base.charAt(0))) {
            return base
        }
        return base.substring(0, 1).toUpperCase + base.substring(1)
    }
}
