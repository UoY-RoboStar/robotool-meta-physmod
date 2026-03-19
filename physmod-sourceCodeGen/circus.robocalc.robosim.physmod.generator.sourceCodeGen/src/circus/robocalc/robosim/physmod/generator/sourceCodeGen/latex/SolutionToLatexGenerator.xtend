/*
 * Copyright (c) 2025-2026 University of York and others
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

package circus.robocalc.robosim.physmod.generator.sourceCodeGen.latex

import com.google.inject.Injector
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.AbstractGenerator
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGeneratorContext
import org.eclipse.xtext.resource.SaveOptions
import org.eclipse.xtext.serializer.ISerializer
import circus.robocalc.robosim.physmod.slnDF.SlnDFStandaloneSetup
import circus.robocalc.robosim.physmod.slnDF.slnDF.SlnDFPackage
import circus.robocalc.robosim.physmod.slnDF.slnDF.Solution

/**
 * Generates LaTeX from slnDF Solution models.
 *
 */
class SolutionToLatexGenerator extends AbstractGenerator {

	var Injector injector
	var ISerializer serializer

	def private Injector getInjector() {
		if (injector === null) {
			if (!org.eclipse.emf.ecore.EPackage.Registry.INSTANCE.containsKey("http://circus.robocalc.robosim.physmod/slnDF")) {
				org.eclipse.emf.ecore.EPackage.Registry.INSTANCE.put(
					"http://circus.robocalc.robosim.physmod/slnDF",
					SlnDFPackage.eINSTANCE
				)
			}
			SlnDFStandaloneSetup.doSetup()
			injector = new SlnDFStandaloneSetup().createInjectorAndDoEMFRegistration()
		}
		return injector
	}

	def private ISerializer getSerializer() {
		if (serializer === null) {
			serializer = getInjector().getInstance(ISerializer)
		}
		return serializer
	}

	override void doGenerate(Resource res, IFileSystemAccess2 fsa, IGeneratorContext context) {
		for (e : res.allContents.toIterable.filter(Solution)) {
			fsa.generateFile("solution.tex", e.compile)
		}
	}

	def String compile(Solution sln) {
		compileFlat(sln)
	}

	def private String compileFlat(Solution sln) {
		val saveOptions = SaveOptions.newBuilder().format().getOptions()
		val solutionText = getSerializer().serialize(sln, saveOptions)
		val result = applySKOMappings(solutionText)

		'''
			\documentclass{article}
			\usepackage{amsmath,amssymb}
			\usepackage{listings}
			\usepackage[margin=1in]{geometry}
			\begin{document}
			\begin{lstlisting}[basicstyle=\ttfamily\footnotesize,mathescape=false,breaklines=true,breakatwhitespace=true,columns=fullflexible,keepspaces=true,showstringspaces=false,escapeinside={(*@}{@*)}]
			«result»
			\end{lstlisting}
			\end{document}
		'''.toString
	}

	/**
	 * Convert SKO helpers in serialized slnDF text into LaTeX fragments.
	 */
	def String applySKOMappings(String text) {
		if (text === null) {
			return ""
		}

		var result = text

		result = replaceWithGroups(result, "SKOv\\s*\\(([^,]+),\\s*([^\\)]+)\\)", [ g1, g2 |
			"(*@$" + g1 + "_{" + g2 + "}$@*)"
		])

		result = replaceWithGroups(result, "SKOm\\s*\\(([^,]+),\\s*([^,]+),\\s*([^\\)]+)\\)", [ g1, g2, g3 |
			"(*@$" + g1 + "_{" + g2 + "," + g3 + "}$@*)"
		])

		result = replaceWithGroups(result, "SKO_cross_force\\s*\\(([^\\)]+)\\)", [ g1 |
			"(*@$[ " + g1 + " ]_{\\times}^{*}$@*)"
		])

		result = replaceWithGroups(result, "SKO_cross\\s*\\(([^\\)]+)\\)", [ g1 |
			"(*@$[ " + g1 + " ]_{\\times}$@*)"
		])

		result = replaceWithGroups(result, "subvector\\s*\\(([^\\)]+)\\)\\s*\\(([^,]+),\\s*([^\\)]+)\\)", [ g1, g2, g3 |
			"(*@$" + g1 + "_{" + g2 + ":" + g2 + "+" + g3 + "-1}$@*)"
		])

		result = replaceWithGroups(
			result,
			"submatrix\\s*\\(([^\\)]+)\\)\\s*\\(([^,]+),\\s*([^,]+),\\s*([^,]+),\\s*([^\\)]+)\\)",
			[ g1, g2, g3, g4, g5 |
				"(*@$" + g1 + "_{" + g2 + ":" + g2 + "+" + g4 + "-1, " + g3 + ":" + g3 + "+" + g5 + "-1}$@*)"
			]
		)

		result = replaceWithGroups(
			result,
			"SKOv_set\\s*\\(\\s*([^,]+?)\\s*,\\s*([^,]+?)\\s*,\\s*([\\s\\S]+?)\\)\\s*;",
			[ g1, g2, g3 |
				"(*@$" + stripEscapeMarkers(g1) + "_{" + g2 + "} = " + g3 + "$@*);"
			]
		)

		result = replaceWithGroups(
			result,
			"SKOm_set\\s*\\(\\s*([^,]+?)\\s*,\\s*([^,]+?)\\s*,\\s*([^,]+?)\\s*,\\s*([\\s\\S]+?)\\)\\s*;",
			[ g1, g2, g3, g4 |
				"(*@$" + stripEscapeMarkers(g1) + "_{" + g2 + "," + g3 + "} = " + g4 + "$@*);"
			]
		)

		result = replaceOutsideEscapeMarkers(result, "\\btheta\\b", "(*@$\\theta$@*)")
		result = replaceOutsideEscapeMarkers(result, "\\bd_theta\\b", "(*@$\\dot{\\theta}$@*)")
		result = replaceOutsideEscapeMarkers(result, "\\bdd_theta\\b", "(*@$\\ddot{\\theta}$@*)")
		result = replaceOutsideEscapeMarkers(result, "\\bphi\\b", "(*@$\\Phi$@*)")
		result = replaceOutsideEscapeMarkers(result, "\\bPhi\\b", "(*@$\\Phi$@*)")
		result = replaceOutsideEscapeMarkers(result, "\\btau\\b", "(*@$\\tau$@*)")
		result = replaceOutsideEscapeMarkers(result, "\\balpha\\b", "(*@$\\alpha$@*)")

		// Re-run setters after scalar substitutions so nested replacements still collapse
		result = replaceWithGroups(
			result,
			"SKOv_set\\s*\\(\\s*([^,]+?)\\s*,\\s*([^,]+?)\\s*,\\s*([\\s\\S]+?)\\)\\s*;",
			[ g1, g2, g3 |
				"(*@$" + stripEscapeMarkers(g1) + "_{" + g2 + "} = " + g3 + "$@*);"
			]
		)
		result = replaceWithGroups(
			result,
			"SKOm_set\\s*\\(\\s*([^,]+?)\\s*,\\s*([^,]+?)\\s*,\\s*([^,]+?)\\s*,\\s*([\\s\\S]+?)\\)\\s*;",
			[ g1, g2, g3, g4 |
				"(*@$" + stripEscapeMarkers(g1) + "_{" + g2 + "," + g3 + "} = " + g4 + "$@*);"
			]
		)

		return result
	}

	private def String replaceOutsideEscapeMarkers(String input, String regex, String replacement) {
		val parts = new java.util.ArrayList<String>()
		val inEscape = new java.util.ArrayList<Boolean>()

		var pos = 0
		var currentlyInEscape = false
		var i = 0
		while (i < input.length()) {
			if (i + 3 <= input.length() && input.substring(i, i + 3).equals("(*@")) {
				if (i > pos) {
					parts.add(input.substring(pos, i))
					inEscape.add(currentlyInEscape)
				}
				parts.add("(*@")
				inEscape.add(false)
				pos = i + 3
				i = i + 3
				currentlyInEscape = true
			} else if (i + 3 <= input.length() && input.substring(i, i + 3).equals("@*)")) {
				if (i > pos) {
					parts.add(input.substring(pos, i))
					inEscape.add(currentlyInEscape)
				}
				parts.add("@*)")
				inEscape.add(false)
				pos = i + 3
				i = i + 3
				currentlyInEscape = false
			} else {
				i = i + 1
			}
		}
		if (pos < input.length()) {
			parts.add(input.substring(pos))
			inEscape.add(currentlyInEscape)
		}

		val sb = new StringBuilder()
		for (var j = 0; j < parts.size(); j++) {
			val part = parts.get(j)
			if (part.equals("(*@") || part.equals("@*)")) {
				sb.append(part)
			} else if (inEscape.get(j)) {
				sb.append(part)
			} else {
				val pattern = java.util.regex.Pattern.compile(regex)
				val matcher = pattern.matcher(part)
				val temp = new StringBuffer()
				while (matcher.find()) {
					matcher.appendReplacement(temp, java.util.regex.Matcher.quoteReplacement(replacement))
				}
				matcher.appendTail(temp)
				sb.append(temp.toString())
			}
		}
		return sb.toString()
	}

	private def String replaceWithGroups(String input, String regex, (String)=>String replacer) {
		val pattern = java.util.regex.Pattern.compile(regex)
		val matcher = pattern.matcher(input)
		val sb = new StringBuffer()
		while (matcher.find()) {
			val replacement = replacer.apply(matcher.group(1))
			matcher.appendReplacement(sb, java.util.regex.Matcher.quoteReplacement(replacement))
		}
		matcher.appendTail(sb)
		return sb.toString()
	}

	private def String replaceWithGroups(String input, String regex, (String, String)=>String replacer) {
		val pattern = java.util.regex.Pattern.compile(regex)
		val matcher = pattern.matcher(input)
		val sb = new StringBuffer()
		while (matcher.find()) {
			val replacement = replacer.apply(matcher.group(1), matcher.group(2))
			matcher.appendReplacement(sb, java.util.regex.Matcher.quoteReplacement(replacement))
		}
		matcher.appendTail(sb)
		return sb.toString()
	}

	private def String replaceWithGroups(String input, String regex, (String, String, String)=>String replacer) {
		val pattern = java.util.regex.Pattern.compile(regex)
		val matcher = pattern.matcher(input)
		val sb = new StringBuffer()
		while (matcher.find()) {
			val replacement = replacer.apply(matcher.group(1), matcher.group(2), matcher.group(3))
			matcher.appendReplacement(sb, java.util.regex.Matcher.quoteReplacement(replacement))
		}
		matcher.appendTail(sb)
		return sb.toString()
	}

	private def String replaceWithGroups(String input, String regex, (String, String, String, String)=>String replacer) {
		val pattern = java.util.regex.Pattern.compile(regex)
		val matcher = pattern.matcher(input)
		val sb = new StringBuffer()
		while (matcher.find()) {
			val replacement = replacer.apply(matcher.group(1), matcher.group(2), matcher.group(3), matcher.group(4))
			matcher.appendReplacement(sb, java.util.regex.Matcher.quoteReplacement(replacement))
		}
		matcher.appendTail(sb)
		return sb.toString()
	}

	private def String replaceWithGroups(String input, String regex, (String, String, String, String, String)=>String replacer) {
		val pattern = java.util.regex.Pattern.compile(regex)
		val matcher = pattern.matcher(input)
		val sb = new StringBuffer()
		while (matcher.find()) {
			val replacement = replacer.apply(
				matcher.group(1),
				matcher.group(2),
				matcher.group(3),
				matcher.group(4),
				matcher.group(5)
			)
			matcher.appendReplacement(sb, java.util.regex.Matcher.quoteReplacement(replacement))
		}
		matcher.appendTail(sb)
		return sb.toString()
	}

	private def String stripEscapeMarkers(String input) {
		if (input === null) {
			return ""
		}

		var s = input.trim
		if (s.startsWith("(*@") && s.endsWith("@*)")) {
			s = s.substring(3, s.length - 3).trim
		}
		if (s.startsWith("$") && s.endsWith("$")) {
			s = s.substring(1, s.length - 1).trim
		}
		return s
	}
}
