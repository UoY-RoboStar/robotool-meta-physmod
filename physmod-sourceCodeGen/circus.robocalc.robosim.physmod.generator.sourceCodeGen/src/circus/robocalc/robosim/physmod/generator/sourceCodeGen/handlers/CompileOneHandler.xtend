package circus.robocalc.robosim.physmod.generator.sourceCodeGen.handlers

import com.google.inject.Inject
import org.eclipse.core.commands.AbstractHandler
import org.eclipse.core.commands.ExecutionEvent
import org.eclipse.core.commands.ExecutionException

class CompileOneHandler extends AbstractHandler {
	@Inject extension CompileOne

	override Object execute(ExecutionEvent event) throws ExecutionException {
		System.out.println("CompileOneHandler.execute() called - starting solution generation")
		try {
			compile(event)
			System.out.println("CompileOneHandler.execute() completed successfully")
			return null
		} catch (Exception e) {
			System.err.println("CompileOneHandler.execute() failed with exception: " + e.message)
			e.printStackTrace()
			throw e
		}
	}
}
