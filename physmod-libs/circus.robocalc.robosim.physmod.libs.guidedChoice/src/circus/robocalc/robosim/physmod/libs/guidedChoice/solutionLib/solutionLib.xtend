package circus.robocalc.robosim.physmod.libs.guidedChoice.solutionLib

import org.eclipse.emf.common.util.EList
import org.eclipse.emf.ecore.impl.MinimalEObjectImpl
import org.eclipse.emf.common.util.BasicEList
import circus.robocalc.robosim.physmod.libs.guidedChoice.formulation.CGA_gen
import circus.robocalc.robosim.physmod.libs.guidedChoice.formulation.FEATHERSTONE_gen
import circus.robocalc.robosim.physmod.libs.guidedChoice.formulation.SKO_gen
import circus.robocalc.robosim.physmod.libs.guidedChoice.formulation.SKO_closed_gen
import circus.robocalc.robosim.physmod.libs.guidedChoice.formulation.Vis_gen
import circus.robocalc.robosim.physmod.libs.guidedChoice.formulation.Mapping_gen
import circus.robocalc.robosim.physmod.libs.guidedChoice.formulation.MappingPM_gen
import circus.robocalc.robosim.physmod.libs.guidedChoice.formulation.Actuator_gen

class SolutionRef {
    public var Local expression
    public var EList<String> constants
    public var EList<Local> inputs
    public var String method
    public var int order
    public var int group
    public var EList<String> constraints
    public var EList<String> errors
    public var EList<String> equations
    public var EList<String> inputs2
    public var int iterations = 0
    public var int iteration = 0

    // Copy method for SolutionRef
    def create result: new SolutionRef copy() {
        result.expression = if (expression !== null) expression.copy else null
        result.constants = if (constants !== null) new BasicEList(constants) else null
        result.inputs = if (inputs !== null) new BasicEList(inputs.map[copy]) else null
        result.method = method
        result.order = order
        result.group = group
        result.constraints = if (constraints !== null) new BasicEList(constraints) else null
        result.errors = if (errors !== null) new BasicEList(errors) else null
        result.equations = if (equations !== null) new BasicEList(equations) else null
        result.inputs2 = if (inputs2 !== null) new BasicEList(inputs2) else null
        result.iterations = iterations
    }
}

/**
 * Local variable representation
 */
class Local {
    public var String name
    public var String type

    // Updated copy method for Local using create function
    def create result: new Local copy() {
        result.name = this.name
        result.type = this.type
    }
}

/**
 * Available formulation types
 */
enum Formulation {
	SKO,
	CGA,
	FEATHERSTONE
}

/**
 * Solution library for resolving physics modeling formulations (asReference methods)
 */
class SolutionLib {

	/**
	 * Helper method to strip namespace from method name if present (for backward compatibility)
	 * Converts "SKO::Eval" to "Eval", or returns "Eval" unchanged
	 */
	static def String getMethodName(String qualifiedMethod) {
		if (qualifiedMethod !== null && qualifiedMethod.contains("::")) {
			return qualifiedMethod.split("::").get(1)
		}
		return qualifiedMethod
	}

	/**
	 * Resolve a solution using the specified formulation
	 */
    static def resolveSolution(Formulation Formulation, SolutionRef solution){
        val methodName = getMethodName(solution.method)
        switch Formulation {
            case SKO:
                switch methodName {
                    case "Eval":
                        return SKO_gen.Eval.asReference(solution)
                    case "AcrossJointTransform":
                        return SKO_gen.Eval.asReference(solution)
                    case "GeneralisedPosition_method1":
                        return SKO_gen.GeneralisedPosition_method1.asReference(solution)
                    case "GeneralisedPosition_method1_closedChain":
                        return SKO_gen.GeneralisedPosition_method1_closedChain.asReference(solution)
                    case "GeneralisedPosition_method1_closedChain_gravity_damping":
                        return SKO_gen.GeneralisedPosition_method1_closedChain_gravity_damping.asReference(solution)
                    case "PlatformMapping":
                        return Mapping_gen.PlatformMapping.asReference(solution)
                    case "WorldMapping":
                        return Mapping_gen.WorldMapping.asReference(solution)
                    case "SensorOutputMapping":
                        return Mapping_gen.SensorOutputMapping.asReference(solution)
                    case "NewtonEulerInverseDynamics":
                        return SKO_gen.NewtonEulerInverseDynamics.asReference(solution)
                    case "NewtonEulerInverseDynamics_gravity":
                        return SKO_gen.NewtonEulerInverseDynamics_gravity.asReference(solution)
                    case "GeneralisedPosition_method1_gravity_damping":
                        return SKO_gen.GeneralisedPosition_method1_gravity_damping.asReference(solution)
                    case "ViscousDamping":
                        return SKO_gen.ViscousDamping.asReference(solution)
                    case "CompositeBodyAlgorithm":
                        return SKO_gen.CompositeBodyAlgorithm.asReference(solution)
                    case "CholeskyAlgorithm":
                        return SKO_gen.CholeskyAlgorithm.asReference(solution)
                    case "DirectForwardDynamics":
                        return SKO_gen.DirectForwardDynamics.asReference(solution)
                    case "ForwardKinematicsClosedChain":
                        return SKO_closed_gen.ForwardKinematicsClosedChain.asReference(solution)
                    case "ConstraintJacobian":
                        return SKO_gen.ConstraintJacobian.asReference(solution)
                    case "ConstrainedForwardDynamics":
                        return SKO_gen.ConstrainedForwardDynamics.asReference(solution)
                    case "ConstraintProjectionClosedChain":
                        return SKO_closed_gen.ConstraintProjectionClosedChain.asReference(solution)
                    case "LoopPositionResidualsClosedChain":
                        return SKO_closed_gen.LoopPositionResidualsClosedChain.asReference(solution)
                    case "ConstraintProjection":
                        return SKO_gen.ConstraintProjection.asReference(solution)
                    case "Euler":
                        return SKO_gen.Euler.asReference(solution)
                    case "proof":
                        return SKO_gen.proof.asReference(solution)
                    case "Visualisation":
                        return SKO_gen.Visualisation.asReference(solution)
                    case "Visual":
                        return Vis_gen.Visual.asReference(solution)
                    case "Vis": {
                        solution.method = "Visual"
                        return Vis_gen.Visual.asReference(solution)
                    }
                    case "ControlledActuator":
                        return Actuator_gen.ControlledActuator.asReference(solution)
                    default: {
                        // Handle MappingPM methods with suffixes (e.g., MappingPM_Operation_ApplyTorque)
                        if (methodName !== null && methodName.startsWith("MappingPM_Operation")) {
                            return MappingPM_gen.MappingPM_Operation.asReference(solution)
                        }
                        if (methodName !== null && methodName.startsWith("MappingPM_InputEvent")) {
                            return MappingPM_gen.MappingPM_InputEvent.asReference(solution)
                        }
                    }
                }
            case CGA:
                switch methodName {
                    case "GeneralisedPosition_method1":
                        return CGA_gen.GeneralisedPosition_method1.asReference(solution)
                    case "ForwardKinematics":
                        return CGA_gen.ForwardKinematics.asReference(solution)
                    case "InverseDynamicsRNEA":
                        return CGA_gen.InverseDynamicsRNEA.asReference(solution)
                    case "ABAForwardDynamics":
                        return CGA_gen.ABAForwardDynamics.asReference(solution)
                    case "Euler":
                        return CGA_gen.Euler.asReference(solution)
                    case "Visual":
                        return Vis_gen.Visual.asReference(solution)
                    case "Vis": {
                        solution.method = "Visual"
                        return Vis_gen.Visual.asReference(solution)
                    }
                    default:
                        return solution
                }
            case FEATHERSTONE:
                switch methodName {
                    case "GeneralisedPosition_method1":
                        return FEATHERSTONE_gen.GeneralisedPosition_method1.asReference(solution)
                    case "GeneralisedPosition_method2":
                        return FEATHERSTONE_gen.GeneralisedPosition_method2.asReference(solution)
                    case "Visual":
                        return Vis_gen.Visual.asReference(solution)
                    case "Vis": {
                        solution.method = "Visual"
                        return Vis_gen.Visual.asReference(solution)
                    }
                    default:
                        return solution
                }
        }
        return solution
    }
}
