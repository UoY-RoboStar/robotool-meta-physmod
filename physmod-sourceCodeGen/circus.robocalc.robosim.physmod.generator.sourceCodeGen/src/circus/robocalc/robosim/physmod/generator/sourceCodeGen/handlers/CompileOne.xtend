package circus.robocalc.robosim.physmod.generator.sourceCodeGen.handlers

import circus.robocalc.robosim.physmod.generator.sourceCodeGen.Activator
import circus.robocalc.robosim.physmod.generator.sourceCodeGen.SolutionRefGenerator
import com.google.inject.Inject
import com.google.inject.Provider
import java.util.ArrayList
import java.util.List
import org.eclipse.core.commands.ExecutionEvent
import org.eclipse.core.resources.IContainer
import org.eclipse.core.resources.IFile
import org.eclipse.core.resources.IProject
import org.eclipse.core.resources.IResource
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.core.runtime.IProgressMonitor
import org.eclipse.core.runtime.IStatus
import org.eclipse.core.runtime.Path
import org.eclipse.core.runtime.Status
import org.eclipse.core.runtime.SubMonitor
import org.eclipse.core.runtime.jobs.IJobFunction
import org.eclipse.core.runtime.jobs.Job
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.jface.viewers.ISelection
import org.eclipse.jface.viewers.IStructuredSelection
import org.eclipse.jface.viewers.LabelProvider
import org.eclipse.jface.window.Window
import org.eclipse.ui.PlatformUI
import org.eclipse.ui.dialogs.ElementListSelectionDialog
import org.eclipse.ui.handlers.HandlerUtil
import org.eclipse.ui.part.FileEditorInput
import org.eclipse.xtext.EcoreUtil2
import org.eclipse.xtext.builder.EclipseResourceFileSystemAccess2
import org.eclipse.xtext.diagnostics.Severity
import org.eclipse.xtext.generator.GeneratorContext
import org.eclipse.xtext.generator.OutputConfiguration
import org.eclipse.xtext.util.CancelIndicator
import org.eclipse.xtext.validation.CheckMode
import org.eclipse.xtext.validation.IResourceValidator

class CompileOne {
	@Inject Provider<ResourceSet> resourceSetProvider
	@Inject IResourceValidator validator
	@Inject Provider<EclipseResourceFileSystemAccess2> fileAccessProvider
	@Inject Provider<SolutionRefGenerator> genProvider

	public static val PARM_TARGET_LANGUAGE = "circus.robocalc.robosim.physmod.generator.sourceCodeGen.targetLanguage"
	public static val PARM_TARGET_OUTPUT = "circus.robocalc.robosim.physmod.generator.sourceCodeGen.targetOutput"
	public static val PARM_TARGET_FEATURE = "circus.robocalc.robosim.physmod.generator.sourceCodeGen.targetFeature"
	public static val PARM_TARGET_LANGUAGE_DETAIL = "circus.robocalc.robosim.physmod.generator.sourceCodeGen.targetLanguageDetail"
	public static var String currentLanguage = "CPP"
	public static var String currentOutput = "FULL_SIMULATION"
	public static var String currentIsabelleMode = "COMPUTATION"
	public static var boolean visualisationEnabled = false
	public static var boolean platformMappingEnabled = false
	
	def compile() {
		compile(null)
	}
	
	def compile(ExecutionEvent event) {
		System.out.println("CompileOne.compile() called - starting solution generation process")
		
		// Get the current project (like eqnComp does)
		val project = getCurrentProject(event)
		if (project === null) {
			System.err.println("Please select a project containing .slnRef files.")
			return null
		}
		
		// Find all .slnRef files in the project
		val slnRefFiles = getAllSolutionRefFiles(project)
		if (slnRefFiles.empty) {
			System.err.println("No .slnRef files found in project: " + project.name)
			return null
		}
		
		System.out.println("Found " + slnRefFiles.size + " .slnRef file(s) in project: " + project.name)
		
		// Show file selection dialog if multiple files
		val IFile selectedFile = if (slnRefFiles.size == 1) {
			// Only one file, use it directly
			slnRefFiles.get(0)
		} else {
			// Multiple files, show selection dialog
			showFileSelectionDialog(slnRefFiles)
		}
		
		if (selectedFile === null) {
			System.out.println("No file selected, operation cancelled.")
			return null
		}
		
		System.out.println("Processing selected file: " + selectedFile.fullPath)
		val languageParam = event?.getParameter(PARM_TARGET_LANGUAGE)
		val outputParam = event?.getParameter(PARM_TARGET_OUTPUT)
		val featureParam = event?.getParameter(PARM_TARGET_FEATURE)
		val detailParam = event?.getParameter(PARM_TARGET_LANGUAGE_DETAIL)
		applySelection(languageParam, outputParam, featureParam, detailParam)
		processFile(selectedFile)
		
		return null
	}
	
public static def void applySelection(String languageParam, String outputParam, String featureParam, String detailParam) {
	if (languageParam !== null && !languageParam.trim.isEmpty) {
		currentLanguage = languageParam.toUpperCase
	}
	if (outputParam !== null && !outputParam.trim.isEmpty) {
		currentOutput = outputParam.toUpperCase
		if ("STANDALONE".equals(currentOutput)) {
			platformMappingEnabled = false
		}
	}
	if (featureParam !== null && !featureParam.trim.isEmpty) {
		toggleFeature(featureParam)
	}
	if (detailParam !== null && !detailParam.trim.isEmpty) {
		currentIsabelleMode = detailParam.toUpperCase
		if (!"ISABELLE".equals(currentLanguage)) {
			currentLanguage = "ISABELLE"
		}
	}
	if (!"ISABELLE".equals(currentLanguage)) {
		currentIsabelleMode = "COMPUTATION"
	}
}
	
	/**
	 * Shows a dialog to let the user select which .slnRef file to process.
	 */
	private def IFile showFileSelectionDialog(List<IFile> files) {
		val dialog = new ElementListSelectionDialog(
			PlatformUI.workbench.activeWorkbenchWindow.shell,
			new LabelProvider() {
				override getText(Object element) {
					if (element instanceof IFile) {
						val file = element as IFile
						// Show relative path from project root
						val relativePath = file.projectRelativePath.toString
						return relativePath
					}
					return super.getText(element)
				}
			}
		)
		
		dialog.setTitle("Select Solution Reference File")
		dialog.setMessage("Choose a .slnRef file to generate solution from:")
		dialog.setElements(files.toArray)
		dialog.setMultipleSelection(false)
		
		if (dialog.open === Window.OK) {
			val result = dialog.firstResult
			if (result instanceof IFile) {
				return result as IFile
			}
		}
		
		return null
	}
	
	private def IProject getCurrentProject(ExecutionEvent event) {
		// Try to get project from selection
		val selection = if (event !== null) {
			try {
				HandlerUtil.getCurrentSelection(event)
			} catch (Exception e) {
				PlatformUI.workbench.activeWorkbenchWindow?.activePage?.selection
			}
		} else {
			PlatformUI.workbench.activeWorkbenchWindow?.activePage?.selection
		}
		
		if (selection instanceof IStructuredSelection) {
			val element = selection.firstElement
			if (element instanceof IResource) {
				return (element as IResource).project
			}
		}
		
		// Try to get from active editor
		try {
			val activePage = PlatformUI.workbench.activeWorkbenchWindow?.activePage
			val activeEditor = activePage?.activeEditor
			if (activeEditor !== null) {
				val input = activeEditor.editorInput
				if (input instanceof org.eclipse.ui.part.FileEditorInput) {
					val file = (input as org.eclipse.ui.part.FileEditorInput).file
					return file.project
				}
			}
		} catch (Exception e) {
			// Continue
		}
		
		return null
	}
	
	private def void processFile(IFile file) {
		val IJobFunction f = new IJobFunction {
			override run(IProgressMonitor monitor) {
				monitor.taskName = "Generating solution from " + file.name
				
				val ResourceSet rs = resourceSetProvider.get()
				val URI uri = URI::createPlatformResourceURI(file.fullPath.toString, true)
				val Resource resource = rs.getResource(uri, true)
				
				EcoreUtil2.resolveAll(rs)
				
				val previousFormat = System.getProperty("physmod.output.format")
				val previousMode = System.getProperty("physmod.generation.mode")
				val previousVisual = System.getProperty("physmod.visualisation.enabled")
				try {
					// Validate the resource
					val issues = validator.validate(resource, CheckMode.ALL, CancelIndicator.NullImpl).filter [ i |
						i.severity == Severity.ERROR
					]
					if (!issues.empty) {
						issues.forEach[System.err.println(it)]
						return new Status(IStatus.ERROR, Activator.PLUGIN_ID,
							"File " + file.name + " contains validation errors.\n" +
								issues.map[it.toString].reduce[p1, p2|p1 + "\n" + p2])
					}

					// Apply command parameters to system properties
					applyConfiguration()

					// Configure and start the generator
					val context = new GeneratorContext => [
						cancelIndicator = CancelIndicator.NullImpl
					]
					val fsa = fileAccessProvider.get
					
					// Set up DEFAULT_OUTPUT configuration (required by generator)
					val defaultConfig = new OutputConfiguration("DEFAULT_OUTPUT")
					defaultConfig.setDescription("Default Output Configuration")
					defaultConfig.setOutputDirectory("src-gen/")
					defaultConfig.setOverrideExistingResources(true)
					defaultConfig.setCreateOutputDirectory(true)
					defaultConfig.setCanClearOutputDirectory(false)
					defaultConfig.setCleanUpDerivedResources(true)
					defaultConfig.setSetDerivedProperty(true)
					defaultConfig.setKeepLocalHistory(true)
					fsa.outputConfigurations.put(defaultConfig.name, defaultConfig)
					
					// Set up SOLUTION_GENERATOR configuration
					val dc = new OutputConfiguration("SOLUTION_GENERATOR")
					dc.setDescription("Configuration for Solution Generator")
					dc.setOutputDirectory("src-gen/")
					dc.setOverrideExistingResources(true)
					dc.setCreateOutputDirectory(true)
					dc.setCanClearOutputDirectory(false)
					dc.setCleanUpDerivedResources(true)
					dc.setSetDerivedProperty(true)
					dc.setKeepLocalHistory(true)
					fsa.outputConfigurations.put(dc.name, dc)
					
					fsa.setProject(file.project)
					
					val sm = SubMonitor.convert(monitor, 1)
					sm.taskName = "Generating solution from " + file.name
					fsa.monitor = sm
					
					val generator = genProvider.get
					generator.doGenerate(resource, fsa, context)
					
					sm.done
					monitor.done
					return Status.OK_STATUS
				} finally {
					restoreProperty("physmod.output.format", previousFormat)
					restoreProperty("physmod.generation.mode", previousMode)
					restoreProperty("physmod.visualisation.enabled", previousVisual)
				}
			}
		}
		val Job job = Job.create("Generating Solution from " + file.name, f);
		job.setPriority(Job.BUILD);
		job.schedule();
	}
	
	/**
	 * Gets all .slnRef files in the given project (recursively).
	 * Based on PhysModUtils.getAllPhysModFiles pattern.
	 */
	private def List<IFile> getAllSolutionRefFiles(IProject project) {
		val List<IFile> files = new ArrayList<IFile>()
		try {
			if (project.open) {
				collectSolutionRefFiles(project, files)
			}
		} catch (Exception e) {
			System.err.println("Error collecting .slnRef files: " + e.message)
		}
		return files
	}
	
	/**
	 * Recursively collects .slnRef files from a container.
	 */
	private def void collectSolutionRefFiles(org.eclipse.core.resources.IContainer container, List<IFile> files) {
		try {
			for (member : container.members) {
				if (member instanceof org.eclipse.core.resources.IContainer) {
					collectSolutionRefFiles(member as org.eclipse.core.resources.IContainer, files)
				} else if (member instanceof IFile) {
					val file = member as IFile
					if ("slnRef".equals(file.fileExtension)) {
						files.add(file)
					}
				}
			}
		} catch (Exception e) {
			// Continue processing other files
		}
	}

	private static def void applyConfiguration() {
		configureLanguage(currentLanguage)
		configureGenerationMode(currentOutput, platformMappingEnabled)
		configureVisualisation(visualisationEnabled)
	}

	private static def void configureLanguage(String targetLanguage) {
		val selection = targetLanguage?.trim?.toUpperCase ?: "CPP"
		switch selection {
			case "LATEX": System.setProperty("physmod.output.format", "latex")
			case "PYTHON": System.setProperty("physmod.output.format", "python")
			case "ISABELLE": System.setProperty("physmod.output.format", "isabelle")
			default: System.setProperty("physmod.output.format", "cpp")
		}
		if (selection == "ISABELLE") {
			System.setProperty("physmod.isabelle.mode", currentIsabelleMode.toLowerCase)
		} else {
			System.clearProperty("physmod.isabelle.mode")
		}
	}

	private static def void configureGenerationMode(String targetOutput, boolean mappingEnabled) {
		if (mappingEnabled) {
			System.setProperty("physmod.generation.mode", "FULL_SIMULATION_MAPPING")
		} else {
			val mode = switch targetOutput?.trim?.toUpperCase {
				case "STANDALONE": "STANDALONE"
				default: "FULL_SIMULATION"
			}
			System.setProperty("physmod.generation.mode", mode)
		}
	}

	private static def void configureVisualisation(boolean enabled) {
		System.setProperty("physmod.visualisation.enabled", Boolean.toString(enabled))
	}

	private static def void toggleFeature(String featureParam) {
		val key = featureParam?.trim?.toUpperCase
		switch key {
			case "VISUALISATION": visualisationEnabled = !visualisationEnabled
			case "PLATFORM_MAPPING": {
				platformMappingEnabled = !platformMappingEnabled
				if (platformMappingEnabled) {
					currentOutput = "FULL_SIMULATION"
				}
			}
			default: {
				// ignore unknown feature identifiers
			}
		}
	}

	private def void restoreProperty(String key, String previousValue) {
		if (previousValue === null) {
			System.clearProperty(key)
		} else {
			System.setProperty(key, previousValue)
		}
	}
}
