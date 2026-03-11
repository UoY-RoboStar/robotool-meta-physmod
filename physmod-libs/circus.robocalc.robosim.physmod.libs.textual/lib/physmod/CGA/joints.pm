package physmod::CGA::joints

import physmod::math::*

// CGA joints library (motor-based rotors/translators)
//
// Motor representation (8 coefficients):
//   [ s, e12, e13, e23, e1i, e2i, e3i, e123i ]
//
// Revolute joints store the rotor generator as a 3-vector:
//   axis_rot = [ e12, e13, e23 ]
//
// Revolute joint motor: M(q) = frame * Rotor(q)
//   where Rotor(q) = cos(q/2) + sin(q/2) * axis_rot

// Core motor helpers (declarations for use in joint equations)
function motorProduct(m1: vector(real,8), m2: vector(real,8)): vector(real,8) {}

// Fixed joint: no generalized coordinate.
joint FixedJoint_CGA {
  InOut motor_frame : vector(real,8)
  InOut motor_joint : vector(real,8)

  // Joint motor is exactly the stored frame motor
  equation motor_joint == motor_frame
}

// Revolute joint in CGA (rotor about axis_rot).
joint RevoluteJoint_CGA {
  InOut q          : real
  InOut axis_rot   : vector(real,3) = (| 0, 1, 0 |)   // [e12,e13,e23]
  InOut motor_frame: vector(real,8)
  InOut motor_joint: vector(real,8)
  equation motor_joint == motorProduct(
    motor_frame,
    (| cos(0.5 * q),
       sin(0.5 * q) * axis_rot[0],
       sin(0.5 * q) * axis_rot[1],
       sin(0.5 * q) * axis_rot[2],
       0, 0, 0, 0 |)
  )
}

// Prismatic joint in CGA (translator along axis_lin).
joint PrismaticJoint_CGA {
  InOut q          : real
  InOut axis_lin   : vector(real,3) = (| 0, 0, 1 |)   // translation axis in R^3 (x,y,z)
  InOut motor_frame: vector(real,8)
  InOut motor_joint: vector(real,8)
  equation motor_joint == motorProduct(
    motor_frame,
    (| 1, 0, 0, 0,
       -0.5 * axis_lin[0] * q,
       -0.5 * axis_lin[1] * q,
       -0.5 * axis_lin[2] * q,
       0 |)
  )
}

endpackage
