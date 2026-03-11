package circus.robocalc.robosim.physmod.slnDF.scoping;

import java.util.Collection;
import java.util.LinkedList;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EReference;
import org.eclipse.xtext.scoping.IScope;
import org.eclipse.xtext.scoping.Scopes;
import org.eclipse.xtext.scoping.impl.AbstractDeclarativeScopeProvider;
import circus.robocalc.robosim.physmod.slnDF.slnDF.LeftVar;
import circus.robocalc.robosim.physmod.slnDF.slnDF.Solution;
import circus.robocalc.robosim.physmod.slnDF.slnDF.State;
import circus.robocalc.robosim.physmod.slnDF.slnDF.Variable;
import circus.robocalc.robosim.physmod.slnDF.slnDF.VariableLine;

public class SlnDFScopeProvider extends AbstractDeclarativeScopeProvider {

//    @Override
//    public IScope getScope(EObject context, EReference reference) {
//        if (context instanceof LeftVar) {
//            LeftVar leftVar = (LeftVar) context;
//            // Find the enclosing Solution element.
//            Solution solution = getContainingSolution(leftVar);
//            if (solution != null && solution.getState() != null) {
//                // Collect variables from the state block.
//                Collection<Variable> variables = collectVariables(solution.getState());
//                var a = Scopes.scopeFor(variables);
//                return Scopes.scopeFor(variables);
//            }
//            return IScope.NULLSCOPE;
//        }
//        return super.getScope(context, reference);
//    }
//
//    private Solution getContainingSolution(EObject element) {
//        EObject container = element;
//        while (container != null && !(container instanceof Solution)) {
//            container = container.eContainer();
//        }
//        return (Solution) container;
//    }
//
//    private Collection<Variable> collectVariables(State state) {
//        Collection<Variable> variables = new LinkedList<Variable>();
//        for (VariableLine varLine : state.getVariables()) {
//            if (varLine.getVariable() != null) {
//                variables.add(varLine.getVariable());
//            }
//        }
//        return variables;
//    }
}
