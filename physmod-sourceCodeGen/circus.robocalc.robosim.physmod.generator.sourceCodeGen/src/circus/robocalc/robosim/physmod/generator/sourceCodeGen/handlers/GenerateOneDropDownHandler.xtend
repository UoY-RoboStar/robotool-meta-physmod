package circus.robocalc.robosim.physmod.generator.sourceCodeGen.handlers

import java.util.Map
import org.eclipse.core.commands.ExecutionEvent
import org.eclipse.core.commands.ExecutionException
import org.eclipse.core.commands.IHandler
import org.eclipse.core.commands.IHandlerListener
import org.eclipse.ui.commands.IElementUpdater
import org.eclipse.ui.menus.UIElement

class GenerateOneDropDownHandler implements IHandler, IElementUpdater {
	
	override execute(ExecutionEvent event) throws ExecutionException {
		CompileOne.applySelection(
			event?.getParameter(CompileOne.PARM_TARGET_LANGUAGE),
			event?.getParameter(CompileOne.PARM_TARGET_OUTPUT),
			event?.getParameter(CompileOne.PARM_TARGET_FEATURE),
			event?.getParameter(CompileOne.PARM_TARGET_LANGUAGE_DETAIL))
		return null
	}

	override updateElement(UIElement element, Map parameters) {
		val langObj = parameters?.get(CompileOne.PARM_TARGET_LANGUAGE)
		val detailObj = parameters?.get(CompileOne.PARM_TARGET_LANGUAGE_DETAIL)
		var checked = false
		if (langObj instanceof String) {
			val langStr = (langObj as String).toUpperCase
			if (langStr == "ISABELLE" && detailObj instanceof String) {
				checked = CompileOne.currentLanguage.equalsIgnoreCase("ISABELLE")
					&& CompileOne.currentIsabelleMode.equalsIgnoreCase(detailObj as String)
			} else {
				checked = CompileOne.currentLanguage.equalsIgnoreCase(langStr)
			}
		} else {
			val outputObj = parameters?.get(CompileOne.PARM_TARGET_OUTPUT)
			if (outputObj instanceof String) {
				checked = CompileOne.currentOutput.equalsIgnoreCase(outputObj as String)
			} else {
				val featureObj = parameters?.get(CompileOne.PARM_TARGET_FEATURE)
				if (featureObj instanceof String) {
					val key = (featureObj as String).toUpperCase
					checked = switch key {
						case "VISUALISATION": CompileOne.visualisationEnabled
						case "PLATFORM_MAPPING": CompileOne.platformMappingEnabled
						default: false
					}
				}
			}
		}
		element.setChecked(checked)
	}

	override addHandlerListener(IHandlerListener handlerListener) {
		
	}
	
	override dispose() {
		
	}
	
	override isEnabled() {
		return true
	}
	
	override isHandled() {
		return true
	}
	
	override removeHandlerListener(IHandlerListener handlerListener) {
		
	}
}
