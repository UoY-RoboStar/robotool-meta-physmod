package circus.robocalc.robosim.physmod.slnDF.formatting2

import com.google.inject.Inject
import org.eclipse.xtext.formatting2.AbstractFormatter2
import org.eclipse.xtext.formatting2.IFormattableDocument
import circus.robocalc.robosim.physmod.slnDF.services.SlnDFGrammarAccess
import circus.robocalc.robosim.physmod.slnDF.slnDF.Solution
import circus.robocalc.robosim.physmod.slnDF.slnDF.Statement
import circus.robocalc.robosim.physmod.slnDF.slnDF.ForLoop
import circus.robocalc.robosim.physmod.slnDF.slnDF.IfThenElse
import circus.robocalc.robosim.physmod.slnDF.slnDF.VariableLine
import circus.robocalc.robosim.physmod.slnDF.slnDF.Variable
import circus.robocalc.robosim.physmod.slnDF.slnDF.Functions
import circus.robocalc.robosim.physmod.slnDF.slnDF.Function
import circus.robocalc.robosim.physmod.slnDF.slnDF.State
import circus.robocalc.robosim.physmod.slnDF.slnDF.Procedures
import circus.robocalc.robosim.physmod.slnDF.slnDF.Computation



class SlnDFFormatter extends AbstractFormatter2 {

	@Inject extension SlnDFGrammarAccess


	



	def dispatch void format(Solution solution, extension IFormattableDocument document) {
	    // Solution opening brace
	    document.append(solution.regionFor.keyword("{")) [ newLine ]

	    	if (solution.datatypes !== null) {
	        document.prepend(solution.regionFor.keyword("datatypes")) [ newLine ]
	        solution.datatypes.format(document)
	        document.append(solution.regionFor.keyword("datatypes")) [ newLine ]
	    }

	    document.prepend(solution.regionFor.keyword("state")) [ newLine ]
	    solution.state.format(document)
	    document.append(solution.regionFor.keyword("state")) [ newLine ]

	    	if (solution.procedures !== null) {
	        document.prepend(solution.regionFor.keyword("procedures")) [ newLine ]
	        solution.procedures.format(document)
	        document.append(solution.regionFor.keyword("procedures")) [ newLine ]
	    }

	    	if (solution.functions !== null) {
	        document.prepend(solution.regionFor.keyword("functions")) [ newLine ]
	        solution.functions.format(document)
	        document.append(solution.regionFor.keyword("functions")) [ newLine ]
	    }

	    document.prepend(solution.regionFor.keyword("computation")) [ newLine ]
	    solution.computation.format(document)

	    document.prepend(solution.regionFor.keyword("}")) [ newLine ]
	}

	// Format Functions block
	def dispatch void format(Functions functions, extension IFormattableDocument document) {
	    document.append(functions.regionFor.keyword("{")) [ newLine ]
	    
	    functions.functions.forEach [ f |
	        f.format(document)
	        document.append(f) [ newLine ]
	    ]
	    
	    document.prepend(functions.regionFor.keyword("}")) [ newLine ]
	}

	// Format individual Function
	def dispatch void format(Function function, extension IFormattableDocument document) {
	    document.prepend(function.regionFor.keyword("function")) [ newLine ]
	    document.append(function.regionFor.keyword("{")) [ newLine ]
	    
//	    function.predicate.forEach [ p |
//	        p.format(document)
//	        p.append[newLine]
//	    ]
//	    
	    document.prepend(function.regionFor.keyword("}")) [ newLine ]
	}

    // Format State block
    def dispatch void format(State state, extension IFormattableDocument document) {
	    document.append(state.regionFor.keyword("{")) [ newLine ]
        state.variables.forEach [ v |
	        v.format(document)
        ]
	    document.prepend(state.regionFor.keyword("}")) [ newLine ]
    }

    // Format Procedures block
    def dispatch void format(Procedures procedures, extension IFormattableDocument document) {
	    document.append(procedures.regionFor.keyword("{")) [ newLine ]
        // best-effort: add spacing around braces; detailed content formatting is grammar-driven
	    document.prepend(procedures.regionFor.keyword("}")) [ newLine ]
    }

    // Format Computation block
	def dispatch void format(Computation computation, extension IFormattableDocument document) {
	    document.append(computation.regionFor.keyword("{")) [ newLine ]
	    computation.lines.forEach [ s |
	        document.append(s) [ newLine ]
	    ]
	    document.prepend(computation.regionFor.keyword("}")) [ newLine ]
	}

	// For Variable, the semicolon is now part of the grammar.
	def dispatch void format(VariableLine variable, extension IFormattableDocument document) {
	    document.append(variable) [ newLine ]
	}

	def dispatch void format(Variable variable, extension IFormattableDocument document) {
	    document.append(variable) [ newLine ]
	}

	// For any generic Statement, format it and then ensure a newline.
	def dispatch void format(Statement statement, extension IFormattableDocument document) {
	    //statement.format(document)
	    document.append(statement) [ newLine ]
	}

	// For loops need special handling to force newlines between inner statements.
	def dispatch void format(ForLoop forLoop, extension IFormattableDocument document) {
	    // Format the for loop header (up to the opening brace)
	    // (Assumes the grammar defines "for ( ... ) {" accordingly.)
	    document.prepend(forLoop.regionFor.keyword("for")) [ newLine ]
	    //forLoop.format(document) // formats the for loop header, including the "{" token
	    
	    // Now, force a newline after the opening brace.
	    document.append(forLoop.regionFor.keyword("{")) [ newLine ]
	    
	    // Format each inner statement in the loop body.
	    forLoop.lines.forEach [ s |
	        //s.format(document)
	        document.append(s) [ newLine ]
	    ]
	    
	    // Ensure the closing brace is on its own line.
	    document.prepend(forLoop.regionFor.keyword("}")) [ newLine ]
	}

	// Similarly, handle if-then-else constructs.
	def dispatch void format(IfThenElse ifThenElse, extension IFormattableDocument document) {
	    document.prepend(ifThenElse.regionFor.keyword("if")) [ newLine ]
	   // ifThenElse.format(document) // formats the "if ( ... ) {" part
	    
	    // Format the 'then' block.
	    ifThenElse.thenStatements.forEach [ s |
	        //s.format(document)
	        document.append(s) [ newLine ]
	    ]
	    // Ensure the closing brace for the 'if' block is on its own line.
	    document.prepend(ifThenElse.regionFor.keyword("}")) [ newLine ]
	    
	    // If an else-part is present, format it.
	    if (ifThenElse.elseStatements !== null && !ifThenElse.elseStatements.isEmpty) {
	        document.prepend(ifThenElse.regionFor.keyword("else")) [ newLine ]
	        // Format the else block header (i.e. "else {")
	        // (Assumes your grammar provides an "else" keyword region.)
	        // Now format each statement in the else block.
	        ifThenElse.elseStatements.forEach [ s |
	            //s.format(document)
	            document.append(s) [ newLine ]
	        ]
	        // Ensure the closing brace for the 'else' block is on its own line.
	        document.prepend(ifThenElse.regionFor.keyword("}")) [ newLine ]
	    }
	}
}
