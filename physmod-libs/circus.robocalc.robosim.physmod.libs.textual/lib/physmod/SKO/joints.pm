// ===============================================
// package physmod::SKO::joints (Jain hinges + explicit across transforms)
// Conventions:
//   - Spatial motion vector order: [wx, wy, wz, vx, vy, vz]^T
//   - Across transform (predecessor -> successor):
//       XJ is Featherstone's joint spatial motion transform XJ(q)
// ===============================================

package physmod::SKO::joints

import physmod::math::*

// ---------------------- Revolute (1 DoF) ----------------------

joint Revolute_x{
  const H: vector(real,6) = (| 1,0,0, 0,0,0 |)
  InOut theta: real
  InOut XJ: matrix(real,6,6)

  // R_x(theta) expanded, r = 0
  equation XJ == [|
    1, 0, 0,   0, 0, 0;
    0, cos(theta), -sin(theta),   0, 0, 0;
    0, sin(theta),  cos(theta),   0, 0, 0;
    0, 0, 0,   1, 0, 0;
    0, 0, 0,   0, cos(theta), -sin(theta);
    0, 0, 0,   0, sin(theta),  cos(theta)
  |]
}

joint Revolute_y{
  const H: vector(real,6) = (| 0,1,0, 0,0,0 |)
  InOut theta: real
  InOut XJ: matrix(real,6,6)

  // R_y(theta) expanded, r = 0
  equation XJ == [|
     cos(theta), 0,  sin(theta),   0, 0, 0;
     0,      1,  0,       0, 0, 0;
    -sin(theta), 0,  cos(theta),   0, 0, 0;
     0,      0,  0,       cos(theta), 0,  sin(theta);
     0,      0,  0,       0,      1,  0;
     0,      0,  0,      -sin(theta), 0,  cos(theta)
  |]
}

joint Revolute_z{
  const H: vector(real,6) = (| 0,0,1, 0,0,0 |)
  InOut theta: real
  InOut XJ: matrix(real,6,6)

  // R_z(theta) expanded, r = 0
  equation XJ == [|
     cos(theta), -sin(theta), 0,   0, 0, 0;
     sin(theta),  cos(theta), 0,   0, 0, 0;
     0,       0,      1,   0, 0, 0;
     0,       0,      0,  cos(theta), -sin(theta), 0;
     0,       0,      0,  sin(theta),  cos(theta), 0;
     0,       0,      0,   0,       0,     1
  |]
}

// ---------------------- Prismatic (1 DoF) ----------------------

joint Prismatic_x{
  const H: vector(real,6) = (| 0,0,0, 1,0,0 |)
  InOut theta: real
  InOut XJ: matrix(real,6,6)

  // r = [theta,0,0]
  equation XJ == [|
    1, 0, 0,   0, 0, 0;
    0, 1, 0,   0, 0, 0;
    0, 0, 1,   0, 0, 0;
    0, 0, 0,   1, 0, 0;
    0, 0, theta,   0, 1, 0;
    0, -theta, 0,  0, 0, 1
  |]
}

joint Prismatic_y{
  const H: vector(real,6) = (| 0,0,0, 0,1,0 |)
  InOut theta: real
  InOut XJ: matrix(real,6,6)

  // r = [0,theta,0]
  equation XJ == [|
    1, 0, 0,   0, 0, 0;
    0, 1, 0,   0, 0, 0;
    0, 0, 1,   0, 0, 0;
    0, 0, -theta,  1, 0, 0;
    0, 0, 0,   0, 1, 0;
    theta, 0, 0,   0, 0, 1
  |]
}

joint Prismatic_z{
  const H: vector(real,6) = (| 0,0,0, 0,0,1 |)
  InOut theta: real
  InOut XJ: matrix(real,6,6)

  // r = [0,0,theta]
  equation XJ == [|
    1, 0, 0,   0, 0, 0;
    0, 1, 0,   0, 0, 0;
    0, 0, 1,   0, 0, 0;
    0, theta, 0,   1, 0, 0;
   -theta, 0, 0,   0, 1, 0;
    0, 0, 0,   0, 0, 1
  |]
}

// ---------------------- Helical (1 DoF, pitch h) ----------------------

joint Helical_x{
  const h: real
  const H: vector(real,6) = (| 1,0,0, h,0,0 |)
  InOut theta: real
  InOut XJ: matrix(real,6,6)

  // r = [h*theta, 0, 0], R = R_x(theta)
  equation XJ == [|
    1, 0, 0,   0, 0, 0;
    0, cos(theta), -sin(theta),   0, 0, 0;
    0, sin(theta),  cos(theta),   0, 0, 0;
    0, 0, 0,   1, 0, 0;
    0,  sin(theta)*h*theta,  cos(theta)*h*theta,   0, cos(theta), -sin(theta);
    0, -cos(theta)*h*theta,  sin(theta)*h*theta,   0, sin(theta),  cos(theta)
  |]
}

joint Helical_y{
  const h: real
  const H: vector(real,6) = (| 0,1,0, 0,h,0 |)
  InOut theta: real
  InOut XJ: matrix(real,6,6)

  // r = [0, h*theta, 0], R = R_y(theta)
  equation XJ == [|
     cos(theta), 0,  sin(theta),   0, 0, 0;
     0,      1,  0,       0, 0, 0;
    -sin(theta), 0,  cos(theta),   0, 0, 0;
     0,      0, -h*theta,     cos(theta), 0,  sin(theta);
     0,      0,  0,       0,      1,  0;
     h*theta*cos(theta), 0, h*theta*sin(theta),  -sin(theta), 0,  cos(theta)
  |]
}

joint Helical_z{
  const h: real
  const H: vector(real,6) = (| 0,0,1, 0,0,h |)
  InOut theta: real
  InOut XJ: matrix(real,6,6)

  // r = [0,0,h*theta], R = R_z(theta)
  equation XJ == [|
     cos(theta), -sin(theta), 0,   0, 0, 0;
     sin(theta),  cos(theta), 0,   0, 0, 0;
     0,       0,      1,   0, 0, 0;
     0,   h*theta*sin(theta), 0,  cos(theta), -sin(theta), 0;
   -h*theta*cos(theta), h*theta*sin(theta), 0,  sin(theta),  cos(theta), 0;
     0,       0,      0,   0, 0, 1
  |]
}

// ---------------------- Cylindrical (2 DoF) ----------------------

joint Cylindrical_x{
  const H: matrix(real,6,2) = (| 1,0; 0,0; 0,0; 0,1; 0,0; 0,0 |)
  InOut q1: real
  InOut q2: real
  InOut XJ: matrix(real,6,6)

  // r = [q2,0,0], R = R_x(q1)
  equation XJ == [|
    1, 0, 0,   0, 0, 0;
    0, cos(q1), -sin(q1),   0, 0, 0;
    0, sin(q1),  cos(q1),   0, 0, 0;
    0, 0, 0,   1, 0, 0;
    0,  sin(q1)*q2,  cos(q1)*q2,   0, cos(q1), -sin(q1);
    0, -cos(q1)*q2,  sin(q1)*q2,   0, sin(q1),  cos(q1)
  |]
}

joint Cylindrical_y{
  const H: matrix(real,6,2) = (| 0,0; 1,0; 0,0; 0,0; 0,1; 0,0 |)
  InOut q1: real
  InOut q2: real
  InOut XJ: matrix(real,6,6)

  // r = [0,q2,0], R = R_y(q1)
  equation XJ == [|
     cos(q1), 0,  sin(q1),   0, 0, 0;
     0,       1,  0,        0, 0, 0;
    -sin(q1), 0,  cos(q1),   0, 0, 0;
     0,       0, -q2,      cos(q1), 0,  sin(q1);
     0,       0,  0,        0,      1,  0;
     q2*cos(q1), 0, q2*sin(q1),  -sin(q1), 0,  cos(q1)
  |]
}

joint Cylindrical_z{
  const H: matrix(real,6,2) = (| 0,0; 0,0; 1,0; 0,0; 0,0; 0,1 |)
  InOut q1: real
  InOut q2: real
  InOut XJ: matrix(real,6,6)

  // r = [0,0,q2], R = R_z(q1)
  equation XJ == [|
     cos(q1), -sin(q1), 0,   0, 0, 0;
     sin(q1),  cos(q1), 0,   0, 0, 0;
     0,        0,       1,   0, 0, 0;
     0,    q2*sin(q1), 0,  cos(q1), -sin(q1), 0;
   -q2*cos(q1), q2*sin(q1), 0,  sin(q1),  cos(q1), 0;
     0,        0,       0,   0, 0, 1
  |]
}

// ---------------------- Spherical (3 DoF) ----------------------

joint Spherical{
  const H: matrix(real,6,3) = (| 1,0,0; 0,1,0; 0,0,1; 0,0,0; 0,0,0; 0,0,0 |)
  InOut q1: real
  InOut q2: real
  InOut q3: real
  InOut XJ: matrix(real,6,6)

  // R = Rz(q1)*Ry(q2)*Rx(q3) (ZYX order)
  equation XJ == [|
    cos(q1)*cos(q2),  cos(q1)*sin(q2)*sin(q3)-sin(q1)*cos(q3),  cos(q1)*sin(q2)*cos(q3)+sin(q1)*sin(q3),   0, 0, 0;
    sin(q1)*cos(q2),  sin(q1)*sin(q2)*sin(q3)+cos(q1)*cos(q3),  sin(q1)*sin(q2)*cos(q3)-cos(q1)*sin(q3),   0, 0, 0;
    -sin(q2),         cos(q2)*sin(q3),                         cos(q2)*cos(q3),                            0, 0, 0;
    0, 0, 0,  cos(q1)*cos(q2),  cos(q1)*sin(q2)*sin(q3)-sin(q1)*cos(q3),  cos(q1)*sin(q2)*cos(q3)+sin(q1)*sin(q3);
    0, 0, 0,  sin(q1)*cos(q2),  sin(q1)*sin(q2)*sin(q3)+cos(q1)*cos(q3),  sin(q1)*sin(q2)*cos(q3)-cos(q1)*sin(q3);
    0, 0, 0,  -sin(q2),         cos(q2)*sin(q3),                         cos(q2)*cos(q3)
  |]
}

// ---------------------- Universal (2 DoF) ----------------------
// Two perpendicular rotary axes. Explicit R for three variants.

joint Universal_xy{
  InOut q1: real
  InOut q2: real
  InOut H: matrix(real,6,2)
  InOut XJ: matrix(real,6,6)

  // H columns: [ex;0] and [R_x(q1)*ey; 0] - depends on q1
  equation H == (| 1, 0; 0, cos(q1); 0, -sin(q1); 0, 0; 0, 0; 0, 0 |)

  // R = R_x(q1) * R_y(q2) expanded
  equation XJ == [|
     cos(q2), 0,  sin(q2),   0, 0, 0;
     sin(q1)*sin(q2),  cos(q1),  -sin(q1)*cos(q2),   0, 0, 0;
    -cos(q1)*sin(q2),  sin(q1),   cos(q1)*cos(q2),   0, 0, 0;
     0, 0, 0,  cos(q2), 0,  sin(q2);
     0, 0, 0,  sin(q1)*sin(q2),  cos(q1),  -sin(q1)*cos(q2);
     0, 0, 0, -cos(q1)*sin(q2),  sin(q1),   cos(q1)*cos(q2)
  |]
}

joint Universal_yz{
  InOut q1: real
  InOut q2: real
  InOut H: matrix(real,6,2)
  InOut XJ: matrix(real,6,6)

  // H columns: [ey;0] and [R_y(q1)*ez; 0] - depends on q1
  equation H == (| 0, sin(q1); 1, 0; 0, cos(q1); 0, 0; 0, 0; 0, 0 |)

  // R = R_y(q1) * R_z(q2) expanded
  equation XJ == [|
     cos(q1)*cos(q2),  -cos(q1)*sin(q2),  sin(q1),   0, 0, 0;
     sin(q2),           cos(q2),          0,        0, 0, 0;
    -sin(q1)*cos(q2),   sin(q1)*sin(q2),  cos(q1),   0, 0, 0;
     0, 0, 0,  cos(q1)*cos(q2),  -cos(q1)*sin(q2),  sin(q1);
     0, 0, 0,  sin(q2),           cos(q2),          0;
     0, 0, 0, -sin(q1)*cos(q2),   sin(q1)*sin(q2),  cos(q1)
  |]
}

joint Universal_zx{
  InOut q1: real
  InOut q2: real
  InOut H: matrix(real,6,2)
  InOut XJ: matrix(real,6,6)

  // H columns: [ez;0] and [R_z(q1)*ex; 0] - depends on q1
  equation H == (| 0, cos(q1); 0, sin(q1); 1, 0; 0, 0; 0, 0; 0, 0 |)

  // R = R_z(q1) * R_x(q2) expanded
  equation XJ == [|
     cos(q1),  -sin(q1)*cos(q2),  sin(q1)*sin(q2),   0, 0, 0;
     sin(q1),   cos(q1)*cos(q2), -cos(q1)*sin(q2),   0, 0, 0;
     0,         sin(q2),          cos(q2),           0, 0, 0;
     0, 0, 0,  cos(q1),  -sin(q1)*cos(q2),  sin(q1)*sin(q2);
     0, 0, 0,  sin(q1),   cos(q1)*cos(q2), -cos(q1)*sin(q2);
     0, 0, 0,  0,         sin(q2),          cos(q2)
  |]
}

endpackage
