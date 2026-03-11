/*
 * Copyright (c) 2026 University of York and others
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

import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.AbstractGenerator
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGeneratorContext
import com.google.inject.Injector
import circus.robocalc.robosim.physmod.slnRef.slnRef.SlnRefs
import circus.robocalc.robosim.physmod.slnDF.slnDF.Solution
import org.eclipse.emf.common.util.BasicEList
import circus.robocalc.robosim.physmod.libs.sourceCodeGen.solutionLib.SolutionLib
import circus.robocalc.robosim.physmod.generator.sourceCodeGen.MultiFileCppGenerator
import circus.robocalc.robosim.physmod.generator.sourceCodeGen.latex.SolutionToLatexGenerator
import circus.robocalc.robosim.physmod.generator.sourceCodeGen.isabelle.SolutionToIsabelleGenerator
import circus.robocalc.robosim.physmod.libs.sourceCodeGen.solutionLib.Formulation
import circus.robocalc.robosim.physmod.slnRef.slnRef.SlnRef
import circus.robocalc.robosim.physmod.slnRef.slnRef.Local
import circus.robocalc.robosim.physmod.slnDF.slnDF.SlnDFFactory
import circus.robocalc.robosim.physmod.slnRef.slnRef.SlnRefFactory
import circus.robocalc.robosim.physmod.slnRef.slnRef.Constraint
import circus.robocalc.robosim.physmod.slnRef.slnRef.Input
import circus.robocalc.robosim.physmod.slnDF.slnDF.State
import com.google.inject.Inject
import org.eclipse.xtext.serializer.ISerializer
import com.google.inject.Provider
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.xtext.validation.IResourceValidator
import org.eclipse.xtext.validation.IConcreteSyntaxValidator
import org.eclipse.xtext.testing.util.ParseHelper
import org.eclipse.core.resources.IProject
import org.eclipse.core.resources.IFile
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.common.util.URI
import java.io.File
import java.util.Map
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.ui.IWorkbenchWindow
import org.eclipse.ui.IEditorPart
import org.eclipse.ui.IWorkbenchPage
import org.eclipse.ui.IEditorInput
import org.eclipse.core.resources.IResource
import org.eclipse.ui.PlatformUI
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.core.runtime.Path
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.xtext.generator.GeneratorContext
import org.eclipse.xtext.util.CancelIndicator
import circus.robocalc.robosim.physmod.slnDF.SlnDFStandaloneSetup
import circus.robocalc.robosim.physmod.slnRef.SlnRefStandaloneSetup
import org.eclipse.emf.ecore.resource.impl.ResourceImpl
import org.eclipse.xtext.serializer.impl.Serializer
import org.eclipse.xtext.resource.SaveOptions
import java.util.ArrayList
import java.util.List
import com.google.inject.Key
import com.google.inject.TypeLiteral
import java.nio.charset.StandardCharsets

/**
 * T5 sourceCodeGen:
 * 1. SlnRef -> Solution (this class)
 * 2. Solution -> C++ (delegated to SolutionToCppGenerator)
 */
class SolutionRefGenerator extends AbstractGenerator {
	@Inject Provider<ResourceSet> resourceSetProvider
	@Inject IResourceValidator validator
	
	// Lazy initialization to allow EPackage registration first
	var Injector _injector = null
	var ISerializer _serializer = null
	var IConcreteSyntaxValidator _syntaxValidator = null
	
	// Store current resource for solution name derivation
	var Resource currentResource = null
	
	def private getInjector() {
		if (_injector === null) {
			// Register SolutionDSL EPackage BEFORE creating injector
			if (!org.eclipse.emf.ecore.EPackage.Registry.INSTANCE.containsKey("http://circus.robocalc.robosim.physmod/slnDF")) {
				org.eclipse.emf.ecore.EPackage.Registry.INSTANCE.put(
					"http://circus.robocalc.robosim.physmod/slnDF",
					circus.robocalc.robosim.physmod.slnDF.slnDF.SlnDFPackage.eINSTANCE
				)
			}
			// Ensure EMF registrations are done once, then create injector explicitly
			SlnDFStandaloneSetup.doSetup()
			_injector = new SlnDFStandaloneSetup().createInjectorAndDoEMFRegistration()
		}
		return _injector
	}
	
	def private getSerializer() {
		if (_serializer === null) {
			_serializer = getInjector().getInstance(ISerializer)
		}
		return _serializer
	}
	
	def private getSyntaxValidator() {
		if (_syntaxValidator === null) {
			_syntaxValidator = getInjector().getInstance(IConcreteSyntaxValidator)
		}
		return _syntaxValidator
	}

	def private String loadTemplateResource(String resourcePath) {
		val stream = SolutionRefGenerator.getClassLoader().getResourceAsStream(resourcePath)
		if (stream === null) {
			throw new IllegalStateException("Missing generator template resource: " + resourcePath)
		}
		try {
			// Use Java 8 compatible approach instead of stream.readAllBytes()
			val reader = new java.io.BufferedReader(new java.io.InputStreamReader(stream, StandardCharsets.UTF_8))
			val builder = new StringBuilder()
			var String line
			while ((line = reader.readLine()) !== null) {
				if (builder.length() > 0) {
					builder.append("\n")
				}
				builder.append(line)
			}
			return builder.toString()
		} finally {
			stream.close()
		}
	}
	
	// ParseHelper instances for parsing generated text
	ParseHelper<circus.robocalc.robosim.physmod.slnRef.slnRef.SlnRefs> parseHelper
	ParseHelper<Solution> parseHelper2
	
	new() {
		// Initialize ParseHelper instances using the respective injectors
		circus.robocalc.robosim.physmod.slnRef.SlnRefStandaloneSetup.doSetup()
		val solutionRefInjector = new circus.robocalc.robosim.physmod.slnRef.SlnRefStandaloneSetup().createInjectorAndDoEMFRegistration()
		parseHelper = solutionRefInjector.getInstance(ParseHelper)
		parseHelper2 = getInjector().getInstance(ParseHelper)
	}

    override void doGenerate(Resource resource, IFileSystemAccess2 fsa, IGeneratorContext context) {
        // Store resource for solution name derivation
        currentResource = resource
        
        // Check output format
        val outputFormat = getOutputFormat()
        val isabelleMode = getIsabelleMode()

        // Check if multi-file generation is requested (only for cpp)
        val multiFileMode = shouldGenerateMultipleFiles()

        for (e : resource.allContents.toIterable.filter(SlnRefs)) {
            // Generate the intermediate Solution .sln file
            val solutionText = e.compile()
            fsa.generateFile(
                "solution.sln",
                solutionText
            )

            // Parse the generated Solution text into a Solution object
            // Reuse the parseHelper2 initialized in constructor to avoid XMI lookup issues
            val solution = parseHelper2.parse(solutionText)

            if (solution !== null) {
                if (outputFormat == "latex") {
                    // Generate LaTeX document
                    val latexGenerator = new SolutionToLatexGenerator()
                    latexGenerator.doGenerate(solution.eResource, fsa, context)
                } else if (outputFormat == "isabelle") {
                    val isabelleGenerator = new SolutionToIsabelleGenerator(isabelleMode)
                    isabelleGenerator.generate(solution, solutionText, fsa)
                } else {
                    // Generate C++ code (default)
                    if (multiFileMode) {
                        // Generate multiple specialized C++ files
                        val multiFileGenerator = new MultiFileCppGenerator()
                        multiFileGenerator.doGenerate(solution.eResource, fsa, context)
                    } else {
                        // Generate single C++ file (original behavior)
                        val cppGenerator = new SolutionToCppGenerator()
                        val cppCode = cppGenerator.compile(solution)
                        fsa.generateFile(
                            "solution.cpp",
                            cppCode
                        )
                    }
                }
            }
        }
    }
    
    /**
     * Determine if multi-file generation should be used
     * For now, configurable via system property to maintain compatibility
     */
    def boolean shouldGenerateMultipleFiles() {
        return true
    }

    /**
     * Get the output format from system property.
     * Returns "latex" or "cpp" (default is "cpp").
     */
    def String getOutputFormat() {
        val format = System.getProperty("physmod.output.format")
        if (format !== null) {
            val lower = format.toLowerCase
            if (lower == "latex" || lower == "isabelle" || lower == "cpp") {
                return lower
            }
        }
        return "cpp"
    }
    
    /**
     * Determine solution name from system property, resource URI, or default to "physics"
     * Priority:
     * 1. System property: physmod.solution.name
     * 2. Resource URI filename (without extension)
     * 3. Default: "physics"
     */
    def String getSolutionName() {
        // Check system property first
        val sysProp = System.getProperty("physmod.solution.name")
        if (sysProp !== null && !sysProp.trim.isEmpty) {
            return sysProp.trim
        }
        
        // Try to derive from resource URI
        if (currentResource !== null && currentResource.URI !== null) {
            val uri = currentResource.URI
            val lastSegment = uri.lastSegment
            if (lastSegment !== null && !lastSegment.isEmpty) {
                // Remove extension if present
                val nameWithoutExt = if (lastSegment.contains(".")) {
                    lastSegment.substring(0, lastSegment.lastIndexOf("."))
                } else {
                    lastSegment
                }
                // Convert to valid identifier (replace invalid chars with underscores)
                val sanitizedName = nameWithoutExt.replaceAll("[^a-zA-Z0-9_]", "_")
                if (!sanitizedName.isEmpty) {
                    return sanitizedName
                }
            }
        }
        
        // Default fallback
        return "physics"
    }

    def String getIsabelleMode() {
        val mode = System.getProperty("physmod.isabelle.mode")
        if (mode === null || mode.trim.isEmpty) {
            return "computation"
        }
        return mode.toLowerCase
    }
    
    def String compile(SlnRefs slnRefs) {
        // Compile the provided SlnRef normally for all scenarios; no example-specific templates

    // Lists to collect the serialized text fragments from all SlnRefs
    var List<String> datatypeTexts = new ArrayList<String>()
    // Note: stateTexts removed - state variables are now collected in stateVarMap
    var List<String> proceduresTexts = new ArrayList<String>()
    var List<String> functionsTexts = new ArrayList<String>()
    var List<String> computationTexts = new ArrayList<String>()
    var List<String> proofTexts = new ArrayList<String>()

    // Map to store best version of each state variable (name -> VariableLine)
    // Prefers versions with initial values over those without
    var Map<String, circus.robocalc.robosim.physmod.slnDF.slnDF.VariableLine> stateVarMap = new java.util.LinkedHashMap<String, circus.robocalc.robosim.physmod.slnDF.slnDF.VariableLine>()

    // Configure SaveOptions (formatting enabled; validation is assumed to be handled elsewhere).
    val saveOptions = SaveOptions.newBuilder().format().getOptions()

    // Process each individual SlnRef entry (regardless of group), sorted by order field
    for (slnRef : slnRefs.solutionRefs.sortBy[order]) {
        // Extract method name (with or without namespace)
        var String methodName = slnRef.method
        if (slnRef.method !== null && slnRef.method.contains("::")) {
            val parts = slnRef.method.split("::")
            if (parts.length >= 2) {
                methodName = parts.get(parts.length - 1)
            }
        }

        var String solutionText = null
        val originalMethod = slnRef.method
        try {
            // Determine formulation from the SlnRef method field namespace
            var Formulation formulation = Formulation.SKO  // default
            if (originalMethod !== null && originalMethod.contains("::")) {
                val parts = originalMethod.split("::")
                if (parts.length == 2) {
                    try {
                        formulation = Formulation.valueOf(parts.get(0))
                    } catch (IllegalArgumentException e) {
                        formulation = Formulation.SKO
                    }
                }
            }

            // Temporarily set method to unnamespaced version for library lookup
            slnRef.method = methodName

            // Call library; fall back to template if the library cannot handle PlatformMapping
            solutionText = SolutionLib.returnSolution(formulation, slnRef)

            if (originalMethod !== null && originalMethod.contains("NewtonEulerInverseDynamics")) {
                solutionText = solutionText.replace("vec(n)", "vec()")
                solutionText = solutionText.replaceAll(
                    "(?m)^\\s*M\\s*:\\s*mat\\(18,18\\)\\s*=\\s*zeroMat\\(18,\\s*18\\);\\s*$",
                    ""
                )
            }

            if (solutionText === null || solutionText.trim.isEmpty) {
                throw new IllegalStateException("No Solution DSL generated for expression '" +
                    slnRef.expression?.name + "' with method '" + originalMethod + "'.")
            }
            
            // Parse the solution.
            val Solution solution = parseHelper2.parse(solutionText)
            if (solution === null) {
                throw new IllegalStateException("Failed to parse generated Solution for expression '" +
                    slnRef.expression?.name + "'. DSL content:\n" + solutionText)
            }
            if (solution.eResource !== null && !solution.eResource.errors.empty) {
                throw new IllegalStateException("Parse errors for generated Solution '" +
                    slnRef.expression?.name + "': " + solution.eResource.errors + "\nDSL content:\n" + solutionText)
            }

            // Serialize datatypes if present (from formulation like GeomExtraction)
            if (solution.datatypes !== null) {
                val dtText = serializer.serialize(solution.datatypes, saveOptions)
                datatypeTexts.add(dtText)
            }

            // Collect state variables, preferring those with non-trivial initial values
            if (solution.state !== null && solution.state.variables !== null) {
                for (variableLine : solution.state.variables) {
                    val varName = variableLine.variable.name.toString
                    val hasInitValue = variableLine.variable.initialValue !== null

                    if (!stateVarMap.containsKey(varName)) {
                        stateVarMap.put(varName, variableLine)
                    } else {
                        // Check if new one is better than old one
                        val existing = stateVarMap.get(varName)
                        val existingHasInitValue = existing.variable.initialValue !== null

                        // Determine if we should replace: prefer non-null over null, and non-zero over zero
                        var shouldReplace = false
                        if (hasInitValue && !existingHasInitValue) {
                            // New has init value, old doesn't - replace
                            shouldReplace = true
                        } else if (hasInitValue && existingHasInitValue) {
                            // Both have init values - check if existing is trivial (0, zeroVec, zeroMat) and new is non-trivial
                            val existingInitText = serializer.serialize(existing.variable.initialValue, saveOptions).trim
                            val newInitText = serializer.serialize(variableLine.variable.initialValue, saveOptions).trim
                            // Trivial values: "0", "0.0", "zeroVec(...)", "zeroMat(...)"
                            val existingIsTrivial = existingInitText == "0" || existingInitText == "0.0" ||
                                existingInitText.startsWith("zeroVec(") || existingInitText.startsWith("zeroMat(")
                            // Non-trivial values: anything that's not a zero scalar or zeroVec/zeroMat
                            val newIsNonTrivial = newInitText != "0" && newInitText != "0.0" &&
                                !newInitText.startsWith("zeroVec(") && !newInitText.startsWith("zeroMat(")
                            if (existingIsTrivial && newIsNonTrivial) {
                                shouldReplace = true
                            }
                        }

                        if (shouldReplace) {
                            stateVarMap.put(varName, variableLine)
                        }
                    }
                }
            }

            // Serialize the procedures component.
            if (solution.procedures !== null) {
                val procText = serializer.serialize(solution.procedures, saveOptions)
                proceduresTexts.add(procText)
            }

            // Serialize the functions component.
            if (solution.functions !== null) {
                val funcText = serializer.serialize(solution.functions, saveOptions)
                functionsTexts.add(funcText)
            }

            // Serialize the computation component.
            if (solution.computation !== null) {
                val compText = serializer.serialize(solution.computation, saveOptions)
                computationTexts.add(compText)
            }

            // Serialize the proof component (if present).
            if (solution.proof !== null) {
                val proofText = serializer.serialize(solution.proof, saveOptions)
                proofTexts.add(proofText)
            }
        } catch (Exception ex) {
            throw new RuntimeException("Failed to compile SolutionRef entry '" +
                slnRef.expression?.name + "' (method=" + originalMethod + "). Generated DSL:\n" +
                (solutionText !== null ? solutionText : "<null>"), ex)
        } finally {
            // Restore original method so downstream consumers see the original metadata.
            slnRef.method = originalMethod
        }
    }

    // Build the final DSL text by combining all serialized fragments into a single Solution
    var StringBuilder finalText = new StringBuilder()
    val solutionName = getSolutionName()
    finalText.append("Solution " + solutionName + " {\n")

    // Append the datatypes block.
    finalText.append("    datatypes {\n")
    for (dtText : datatypeTexts) {
         // Remove extra curly braces if present.
         finalText.append(indent(removeEnclosingCurly(dtText), 8))
         finalText.append("\n")
    }
    finalText.append("    }\n")

    // Append the state block by serializing collected state variables
    finalText.append("    state {\n")
    for (varEntry : stateVarMap.entrySet) {
         val variableLine = varEntry.value
         val varLineText = serializer.serialize(variableLine, saveOptions)
         // The serializer includes the semicolon and newline, just indent it
         finalText.append(indent(varLineText.trim, 8))
         finalText.append("\n")
    }
    finalText.append("    }\n")

    // Append the procedures block contents only (deduplicated)
    if (!proceduresTexts.isEmpty) {
        finalText.append("    procedures {\n")
        val seenProcSigs = new java.util.HashMap<String, String>()  // signature -> full procedure definition
        for (procText : proceduresTexts) {
             val content = extractBlockContents(procText)
             // Extract all individual procedure definitions from this procedures block
             val individualProcs = extractIndividualProcedures(content)
             for (procDef : individualProcs) {
                 // Extract signature (everything before the opening brace of procedure body)
                 val sigMatch = java.util.regex.Pattern.compile("^\\s*procedure\\s+([^{]+)\\{").matcher(procDef)
                 if (sigMatch.find()) {
                     val signature = sigMatch.group(1).replaceAll("\\s+", " ").trim
                     // If we haven't seen this signature, or the new one has more content (implementation), use it
                     val existing = seenProcSigs.get(signature)
                     if (existing === null || procDef.length > existing.length) {
                         seenProcSigs.put(signature, procDef)
                     }
                 }
             }
        }
        // Now append all unique procedures
        for (procDef : seenProcSigs.values) {
            finalText.append(indent(procDef, 8))
            finalText.append("\n")
        }
        finalText.append("    }\n")
    }

    // Append the functions block contents only (deduplicated by signature, preferring implementations)
    if (!functionsTexts.isEmpty) {
        finalText.append("    functions {\n")
        val seenFuncSigs = new java.util.HashMap<String, String>()  // signature -> full function definition
        for (funcText : functionsTexts) {
             val content = extractBlockContents(funcText)
             // Extract all individual function definitions from this functions block
             val individualFuncs = extractIndividualFunctions(content)
             for (funcDef : individualFuncs) {
                 // Extract signature (everything before the opening brace of function body)
                 val sigMatch = java.util.regex.Pattern.compile("^\\s*function\\s+([^{]+)\\{").matcher(funcDef)
                 if (sigMatch.find()) {
                     val signature = sigMatch.group(1).replaceAll("\\s+", " ").trim
                     // If we haven't seen this signature, or the new one has more content (implementation), use it
                     val existing = seenFuncSigs.get(signature)
                     if (existing === null || funcDef.length > existing.length) {
                         seenFuncSigs.put(signature, funcDef)
                     }
                 }
             }
        }
        // Now append all unique functions
        for (funcDef : seenFuncSigs.values) {
            finalText.append(indent(funcDef, 8))
            finalText.append("\n")
        }
        finalText.append("    }\n")
    }

    // Append the computation block as is (since each computation is intended to have its own enclosing braces)
    finalText.append("    computation {\n")
    for (compText : computationTexts) {
        finalText.append(indent(compText, 8))
        finalText.append("\n")
    }
    finalText.append("    }\n")

    // Append the proof block if present
    if (!proofTexts.isEmpty) {
        finalText.append("    proof {\n")
        for (proofText : proofTexts) {
            finalText.append(indent(extractProofStatements(proofText), 8))
            finalText.append("\n")
        }
        finalText.append("    }\n")
    }

    finalText.append("}\n")

    // Return the merged Solution
    var result = finalText.toString
    return result
    }


/**
 * Removes the outermost curly braces from a text, if present.
 */
def String removeEnclosingCurly(String text) {
    val trimmed = text.trim
    if (trimmed.startsWith("{") && trimmed.endsWith("}")) {
        // Remove the first and last character, then trim again.
        return trimmed.substring(1, trimmed.length - 1).trim
    }
    return text
}

// Extract content between the first outermost braces
def String extractBlockContents(String text) {
    val trimmed = text.trim
    val start = trimmed.indexOf('{')
    val end = trimmed.lastIndexOf('}')
    if (start >= 0 && end > start) {
        return trimmed.substring(start + 1, end).trim
    }
    return removeEnclosingCurly(text)
}

/**
 * Extracts proof statements from a serialized proof block.
 * The proof block contains relational expressions separated by semicolons.
 */
def String extractProofStatements(String text) {
    // Extract the content between the outermost braces
    return extractBlockContents(text)
}

/**
 * Extracts individual function definitions from a functions block content.
 * Parses the content and splits it into separate function definitions by tracking brace depth.
 */
def java.util.List<String> extractIndividualFunctions(String content) {
    val functions = new java.util.ArrayList<String>()
    val pattern = java.util.regex.Pattern.compile("function\\s+")
    val matcher = pattern.matcher(content)

    var int lastEnd = 0
    while (matcher.find()) {
        val functionStart = matcher.start()

        // Find the end of this function by tracking brace depth
        var int braceDepth = 0
        var int functionEnd = -1
        var boolean foundOpenBrace = false

        var int i = functionStart
        while (i < content.length()) {
            val c = content.charAt(i)
            if (c.toString.equals("{")) {
                braceDepth++
                foundOpenBrace = true
            } else if (c.toString.equals("}")) {
                braceDepth--
                if (foundOpenBrace && braceDepth == 0) {
                    functionEnd = i + 1
                    // break
                    i = content.length()  // Exit loop
                }
            }
            i++
        }

        if (functionEnd > functionStart) {
            val funcDef = content.substring(functionStart, functionEnd).trim()
            if (!funcDef.isEmpty()) {
                functions.add(funcDef)
            }
        }
    }

    return functions
}

/**
 * Extracts individual procedure definitions from a procedures block content.
 * Parses the content and splits it into separate procedure definitions by tracking brace depth.
 */
def java.util.List<String> extractIndividualProcedures(String content) {
    val procedures = new java.util.ArrayList<String>()
    val pattern = java.util.regex.Pattern.compile("procedure\\s+")
    val matcher = pattern.matcher(content)

    var int lastEnd = 0
    while (matcher.find()) {
        val procedureStart = matcher.start()

        // Find the end of this procedure by tracking brace depth
        var int braceDepth = 0
        var int procedureEnd = -1
        var boolean foundOpenBrace = false

        var int i = procedureStart
        while (i < content.length()) {
            val c = content.charAt(i)
            if (c.toString.equals("{")) {
                braceDepth++
                foundOpenBrace = true
            } else if (c.toString.equals("}")) {
                braceDepth--
                if (foundOpenBrace && braceDepth == 0) {
                    procedureEnd = i + 1
                    // break
                    i = content.length()  // Exit loop
                }
            }
            i++
        }

        if (procedureEnd > procedureStart) {
            val procDef = content.substring(procedureStart, procedureEnd).trim()
            if (!procDef.isEmpty()) {
                procedures.add(procDef)
            }
        }
    }

    return procedures
}

/**
 * Indents each line of the given text by the specified number of spaces.
 */
def String indent(String text, int spaces) {
    var StringBuilder builder = new StringBuilder
    for (i : 0 ..< spaces) {
        builder.append(" ")
    }
    val indentation = builder.toString
    return text.split("\n").map[ line | indentation + line ].join("\n")
}
	
    def SlnRef convertToClass(SlnRef slnRef){
    	var factory = SlnRefFactory.eINSTANCE;
    	var solutionRef = factory.createSlnRef()
    	solutionRef.expression = factory.createLocal()
    	solutionRef.expression.name = slnRef.expression.name
    	solutionRef.expression.type = slnRef.expression.type
    	solutionRef.method = slnRef.method
        for(input: slnRef.inputs){
        	var tempInput = factory.createInput()
        	var tempLocal = factory.createLocal()
        	tempLocal.name = input.value.name
        	tempLocal.type = input.value.type
        	tempInput.value = tempLocal
            solutionRef.inputs.add(tempInput)
        }
        for (constraint: slnRef.constraints){
        	var tempConstraint = factory.createConstraint()
            tempConstraint.value = constraint.value
            solutionRef.constraints.add(tempConstraint)
        }
        solutionRef.order = slnRef.order

    	return solutionRef
    }
}
