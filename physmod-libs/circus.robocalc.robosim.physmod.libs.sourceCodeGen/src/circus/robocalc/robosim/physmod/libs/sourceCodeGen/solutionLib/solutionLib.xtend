package circus.robocalc.robosim.physmod.libs.sourceCodeGen.solutionLib

import org.eclipse.emf.common.util.EList
import org.eclipse.emf.ecore.impl.MinimalEObjectImpl
import org.eclipse.emf.common.util.BasicEList
import circus.robocalc.robosim.physmod.libs.sourceCodeGen.formulation.SKO
import circus.robocalc.robosim.physmod.libs.sourceCodeGen.formulation.SKO_closed
import circus.robocalc.robosim.physmod.libs.sourceCodeGen.formulation.CGA
import circus.robocalc.robosim.physmod.libs.sourceCodeGen.formulation.FEATHERSTONE
import circus.robocalc.robosim.physmod.slnRef.slnRef.SlnRef
import circus.robocalc.robosim.physmod.libs.sourceCodeGen.formulation.Vis
import circus.robocalc.robosim.physmod.libs.sourceCodeGen.formulation.Actuator
import circus.robocalc.robosim.physmod.libs.sourceCodeGen.formulation.Sensor

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
        result.iteration = iteration
    }
}

class Local {
    public var String name
    public var String type

    // Updated copy method for Local using create function
    def create result: new Local copy() {
        result.name = this.name
        result.type = this.type
    }
}

enum Formulation {
	SKO,
	CGA,
	FEATHERSTONE
}

class SolutionLib {
    static def returnSolution(Formulation formulation, SlnRef solution) {
        switch formulation {
            case SKO:
                switch solution.method {
                    case "PlatformMapping":
                        return SKO.PlatformMapping.asSolution(solution)
                    case "Eval":
                        return SKO.Eval.asSolution(solution)
                    case "NewtonEulerInverseDynamics":
                        return SKO.NewtonEulerInverseDynamics.asSolution(solution)
                    case "NewtonEulerInverseDynamics_gravity":
                        return SKO.NewtonEulerInverseDynamics_gravity.asSolution(solution)
                    case "CompositeBodyAlgorithm":
                        return SKO.CompositeBodyAlgorithm.asSolution(solution)
                    case "CholeskyAlgorithm":
                        return SKO.CholeskyAlgorithm.asSolution(solution)
                    case "ViscousDamping":
                        return SKO.ViscousDamping.asSolution(solution)
                    case "DirectForwardDynamics":
                        return SKO.DirectForwardDynamics.asSolution(solution)
                    case "ConstraintJacobian":
                        return SKO.ConstraintJacobian.asSolution(solution)
                    case "ConstrainedForwardDynamics":
                        return SKO.ConstrainedForwardDynamics.asSolution(solution)
                    case "ConstraintProjectionClosedChain":
                        return SKO_closed.ConstraintProjectionClosedChain.asSolution(solution)
                    case "LoopPositionResidualsClosedChain":
                        return SKO_closed.LoopPositionResidualsClosedChain.asSolution(solution)
                    case "Euler":
                        return SKO.Euler.asSolution(solution)
                    case "ForwardKinematics":
                        return SKO.ForwardKinematics.asSolution(solution)
                    case "ForwardKinematicsClosedChain":
                        return SKO_closed.ForwardKinematicsClosedChain.asSolution(solution)
                    case "AcrossJointTransform":
                        return SKO.AcrossJointTransform.asSolution(solution)
                    case "GeomExtraction":
                        return Vis.GeomExtraction.asSolution(solution)
                    case "Visual":
                        return SKO.Visual.asSolution(solution)
                    case "Visualisation":
                        return SKO.Visualisation.asSolution(solution)
                    case "Proof":
                        return SKO.proof.asSolution(solution)
                    case "proof":
                        return SKO.proof.asSolution(solution)
                    case "ControlledActuator":
                        return Actuator.ControlledActuator.asSolution(solution)
                    case "SensorOutputMapping":
                        return SKO.SensorOutputMapping.asSolution(solution)
                    case "JointEncoderAngle":
                        return Sensor.JointEncoderAngle.asSolution(solution)
                    case "JointEncoderVelocity":
                        return Sensor.JointEncoderVelocity.asSolution(solution)
                    default:
                        throw new IllegalArgumentException("Unknown solution method: " + solution.method)
                }
            case CGA:
                switch solution.method {
                    case "ForwardKinematics":
                        return CGA.ForwardKinematics.asSolution(solution)
                    case "InverseDynamicsRNEA":
                        return CGA.InverseDynamicsRNEA.asSolution(solution)
                    case "ABAForwardDynamics":
                        return CGA.ABAForwardDynamics.asSolution(solution)
                    case "Euler":
                        return CGA.Euler.asSolution(solution)
                    case "Visual":
                        return Vis.Visual.asSolution(solution)
                    case "GeomExtraction":
                        return Vis.GeomExtraction.asSolution(solution)
                    default:
                        throw new IllegalArgumentException("Unknown CGA method: " + solution.method)
                }
            case FEATHERSTONE:
                switch solution.method {
                    case "RNEABias":
                        return FEATHERSTONE.RNEABias.asSolution(solution)
                    case "CRBA":
                        return FEATHERSTONE.CRBA.asSolution(solution)
                    case "LDLTAlgorithm":
                        return FEATHERSTONE.LDLTAlgorithm.asSolution(solution)
                    case "ForwardDynamics":
                        return FEATHERSTONE.ForwardDynamics.asSolution(solution)
                    case "ABAForwardDynamics":
                        return FEATHERSTONE.ABAForwardDynamics.asSolution(solution)
                    case "Euler":
                        return FEATHERSTONE.Euler.asSolution(solution)
                    case "Visual":
                        return Vis.Visual.asSolution(solution)
                    case "GeomExtraction":
                        return Vis.GeomExtraction.asSolution(solution)
                    default:
                        throw new IllegalArgumentException("Unknown FEATHERSTONE method: " + solution.method)
                }
            default:
                throw new IllegalArgumentException("Unknown formulation: " + formulation)
        }
    }
}
