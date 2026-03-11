// ===============================================
// package physmod::trivial::actuators (Trivial actuators for trivial formulation)
// ===============================================

package physmod::trivial::actuators

import physmod::math::*

actuator TrivialMotor {
  input TorqueIn : real
  output TorqueOut : real

  equation TorqueIn == TorqueOut
}

// Controlled actuator with explicit B_ctrl matrix for control-theoretic proofs.
// B_ctrl relates control input u to torque output: TorqueOut = B_ctrl * ControlIn
// For a simple scalar gain, B_ctrl is 1x1 (identity = passthrough).
// Override B_ctrl in local actuator definitions for custom gains.
actuator ControlledMotor {
  const B_ctrl : matrix(real, 1, 1) = [| 1.0 |]
  input ControlIn : real
  output TorqueOut : real

  equation TorqueOut == B_ctrl * ControlIn
}

endpackage