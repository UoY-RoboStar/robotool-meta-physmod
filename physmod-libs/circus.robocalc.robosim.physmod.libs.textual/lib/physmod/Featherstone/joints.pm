// Featherstone-style joint library (spatial vector formulation)
// Notation follows Roy Featherstone, "Rigid Body Dynamics Algorithms":
//   - Joint coordinate: q, qd, qdd, tau
//   - Joint transform: XJ(q)  (spatial motion transform, 6x6)
//   - Motion subspace: S      (6x1)
//   - Joint velocity:  vJ = S*qd
//   - Joint acceleration bias: cJ (for standard 1-DoF Rx/Ry/Rz/Px/Py/Pz joints, cJ = 0)
//
// NOTE: XJ uses the *body-coordinate* (i.e., coordinate-transform) convention consistent with
// Featherstone's spatial transforms (rotation blocks use E = R^T).
//
// SPDX-License-Identifier: MPL-2.0

package physmod::Featherstone::joints

import physmod::math::*
import physmod::init::*
import physmod::utility::*

// --- Revolute joints ---------------------------------------------------------

joint RevoluteJoint_X {
    InOut q   : real
    InOut qd  : real
    InOut qdd : real
    InOut tau : real

    // X_T is the joint-dependent spatial motion transform (Featherstone: XJ(q))
    InOut X_T : matrix(real,6,6)
    InOut XJ : matrix(real,6,6)
    InOut vJ : vector(real,6)
    InOut cJ : vector(real,6)

    // Motion subspace (constant for 1-DoF joints)
    const S : vector(real,6) = (| 1, 0, 0, 0, 0, 0 |)

    // X_T = XrotX(q) with rotation blocks using E = R_x(q)^T
    equation X_T == [| 1, 0,      0,      0, 0,      0;
                0, cos(q), sin(q),  0, 0,      0;
                0, -sin(q), cos(q), 0, 0,      0;
                0, 0,      0,      1, 0,      0;
                0, 0,      0,      0, cos(q), sin(q);
                0, 0,      0,      0, -sin(q), cos(q) |]

    // Alias for compatibility with codegen naming
    equation XJ == X_T

    equation vJ == S * qd
    equation cJ == (| 0, 0, 0, 0, 0, 0 |)
end

joint RevoluteJoint_Y {
    InOut q   : real
    InOut qd  : real
    InOut qdd : real
    InOut tau : real

    InOut X_T : matrix(real,6,6)
    InOut XJ : matrix(real,6,6)
    InOut vJ : vector(real,6)
    InOut cJ : vector(real,6)

    const S : vector(real,6) = (| 0, 1, 0, 0, 0, 0 |)

    // X_T = XrotY(q), with E = R_y(q)^T
    equation X_T == [| cos(q), 0, -sin(q), 0, 0, 0;
                0,      1, 0,       0, 0, 0;
                sin(q), 0, cos(q),  0, 0, 0;
                0,      0, 0,       cos(q), 0, -sin(q);
                0,      0, 0,       0,      1, 0;
                0,      0, 0,       sin(q), 0, cos(q) |]

    equation XJ == X_T

    equation vJ == S * qd
    equation cJ == (| 0, 0, 0, 0, 0, 0 |)
end

joint RevoluteJoint_Z {
    InOut q   : real
    InOut qd  : real
    InOut qdd : real
    InOut tau : real

    InOut X_T : matrix(real,6,6)
    InOut XJ : matrix(real,6,6)
    InOut vJ : vector(real,6)
    InOut cJ : vector(real,6)

    const S : vector(real,6) = (| 0, 0, 1, 0, 0, 0 |)

    // X_T = XrotZ(q), with E = R_z(q)^T
    equation X_T == [| cos(q), sin(q), 0, 0, 0, 0;
               -sin(q), cos(q), 0, 0, 0, 0;
                0,      0,      1, 0, 0, 0;
                0,      0,      0, cos(q), sin(q), 0;
                0,      0,      0,-sin(q), cos(q), 0;
                0,      0,      0, 0,      0,      1 |]

    equation XJ == X_T

    equation vJ == S * qd
    equation cJ == (| 0, 0, 0, 0, 0, 0 |)
end

// --- Prismatic joints --------------------------------------------------------

joint PrismaticJoint_X {
    InOut q   : real
    InOut qd  : real
    InOut qdd : real
    InOut tau : real

    InOut X_T : matrix(real,6,6)
    InOut XJ : matrix(real,6,6)
    InOut vJ : vector(real,6)
    InOut cJ : vector(real,6)

    const S : vector(real,6) = (| 0, 0, 0, 1, 0, 0 |)

    // X_T = Xtrans([q,0,0]) = [[I,0],[-(r×), I]], r=[q,0,0]
    equation X_T == [| 1, 0, 0, 0, 0, 0;
                0, 1, 0, 0, 0, 0;
                0, 0, 1, 0, 0, 0;
                0, 0, 0, 1, 0, 0;
                0, 0, q, 0, 1, 0;
                0, -q,0, 0, 0, 1 |]

    equation XJ == X_T

    equation vJ == S * qd
    equation cJ == (| 0, 0, 0, 0, 0, 0 |)
end

joint PrismaticJoint_Y {
    InOut q   : real
    InOut qd  : real
    InOut qdd : real
    InOut tau : real

    InOut X_T : matrix(real,6,6)
    InOut XJ : matrix(real,6,6)
    InOut vJ : vector(real,6)
    InOut cJ : vector(real,6)

    const S : vector(real,6) = (| 0, 0, 0, 0, 1, 0 |)

    // X_T = Xtrans([0,q,0]), r=[0,q,0]
    equation X_T == [| 1, 0, 0, 0, 0, 0;
                0, 1, 0, 0, 0, 0;
                0, 0, 1, 0, 0, 0;
                0, 0, -q,1, 0, 0;
                0, 0, 0, 0, 1, 0;
                q, 0, 0, 0, 0, 1 |]

    equation XJ == X_T

    equation vJ == S * qd
    equation cJ == (| 0, 0, 0, 0, 0, 0 |)
end

joint PrismaticJoint_Z {
    InOut q   : real
    InOut qd  : real
    InOut qdd : real
    InOut tau : real

    InOut X_T : matrix(real,6,6)
    InOut XJ : matrix(real,6,6)
    InOut vJ : vector(real,6)
    InOut cJ : vector(real,6)

    const S : vector(real,6) = (| 0, 0, 0, 0, 0, 1 |)

    // X_T = Xtrans([0,0,q]), r=[0,0,q]
    equation X_T == [| 1, 0, 0, 0, 0, 0;
                0, 1, 0, 0, 0, 0;
                0, 0, 1, 0, 0, 0;
                0, q, 0, 1, 0, 0;
               -q, 0, 0, 0, 1, 0;
                0, 0, 0, 0, 0, 1 |]

    equation XJ == X_T

    equation vJ == S * qd
    equation cJ == (| 0, 0, 0, 0, 0, 0 |)
end
// --- Negative-axis variants (convenience) -----------------------------------
// These are equivalent to using the positive-axis joint with -q, but keep the model
// notation explicit when a joint axis is declared negative in the p-model.

joint RevoluteJoint_X_neg {
    InOut q   : real
    InOut qd  : real
    InOut qdd : real
    InOut tau : real

    InOut X_T : matrix(real,6,6)
    InOut XJ : matrix(real,6,6)
    InOut vJ : vector(real,6)
    InOut cJ : vector(real,6)

    const S : vector(real,6) = (| -1, 0, 0, 0, 0, 0 |)

    // X_T = XrotX(-q) => E = R_x(-q)^T = R_x(q)
    equation X_T == [| 1, 0,      0,       0, 0,      0;
                0, cos(q), -sin(q),  0, 0,      0;
                0, sin(q), cos(q),   0, 0,      0;
                0, 0,      0,       1, 0,      0;
                0, 0,      0,       0, cos(q), -sin(q);
                0, 0,      0,       0, sin(q), cos(q) |]

    equation XJ == X_T

    equation vJ == S * qd
    equation cJ == (| 0, 0, 0, 0, 0, 0 |)
end

joint RevoluteJoint_Y_neg {
    InOut q   : real
    InOut qd  : real
    InOut qdd : real
    InOut tau : real

    InOut X_T : matrix(real,6,6)
    InOut XJ : matrix(real,6,6)
    InOut vJ : vector(real,6)
    InOut cJ : vector(real,6)

    const S : vector(real,6) = (| 0, -1, 0, 0, 0, 0 |)

    // X_T = XrotY(-q)
    equation X_T == [| cos(q), 0, sin(q),  0, 0, 0;
                0,      1, 0,       0, 0, 0;
               -sin(q), 0, cos(q),  0, 0, 0;
                0,      0, 0,       cos(q), 0, sin(q);
                0,      0, 0,       0,      1, 0;
                0,      0, 0,      -sin(q), 0, cos(q) |]

    equation XJ == X_T

    equation vJ == S * qd
    equation cJ == (| 0, 0, 0, 0, 0, 0 |)
end

joint RevoluteJoint_Z_neg {
    InOut q   : real
    InOut qd  : real
    InOut qdd : real
    InOut tau : real

    InOut X_T : matrix(real,6,6)
    InOut XJ : matrix(real,6,6)
    InOut vJ : vector(real,6)
    InOut cJ : vector(real,6)

    const S : vector(real,6) = (| 0, 0, -1, 0, 0, 0 |)

    // X_T = XrotZ(-q)
    equation X_T == [| cos(q), -sin(q), 0, 0, 0, 0;
                sin(q), cos(q),  0, 0, 0, 0;
                0,      0,       1, 0, 0, 0;
                0,      0,       0, cos(q), -sin(q), 0;
                0,      0,       0, sin(q), cos(q),  0;
                0,      0,       0, 0,      0,       1 |]

    equation XJ == X_T

    equation vJ == S * qd
    equation cJ == (| 0, 0, 0, 0, 0, 0 |)
end

joint PrismaticJoint_X_neg {
    InOut q   : real
    InOut qd  : real
    InOut qdd : real
    InOut tau : real

    InOut X_T : matrix(real,6,6)
    InOut XJ : matrix(real,6,6)
    InOut vJ : vector(real,6)
    InOut cJ : vector(real,6)

    const S : vector(real,6) = (| 0, 0, 0, -1, 0, 0 |)

    // X_T = Xtrans([-q,0,0])
    equation X_T == [| 1, 0, 0, 0, 0, 0;
                0, 1, 0, 0, 0, 0;
                0, 0, 1, 0, 0, 0;
                0, 0, 0, 1, 0, 0;
                0, 0, -q,0, 1, 0;
                0, q,  0, 0, 0, 1 |]

    equation XJ == X_T

    equation vJ == S * qd
    equation cJ == (| 0, 0, 0, 0, 0, 0 |)
end

joint PrismaticJoint_Y_neg {
    InOut q   : real
    InOut qd  : real
    InOut qdd : real
    InOut tau : real

    InOut X_T : matrix(real,6,6)
    InOut XJ : matrix(real,6,6)
    InOut vJ : vector(real,6)
    InOut cJ : vector(real,6)

    const S : vector(real,6) = (| 0, 0, 0, 0, -1, 0 |)

    // X_T = Xtrans([0,-q,0])
    equation X_T == [| 1, 0, 0, 0, 0, 0;
                0, 1, 0, 0, 0, 0;
                0, 0, 1, 0, 0, 0;
                0, 0, q, 1, 0, 0;
                0, 0, 0, 0, 1, 0;
               -q, 0, 0, 0, 0, 1 |]

    equation XJ == X_T

    equation vJ == S * qd
    equation cJ == (| 0, 0, 0, 0, 0, 0 |)
end

joint PrismaticJoint_Z_neg {
    InOut q   : real
    InOut qd  : real
    InOut qdd : real
    InOut tau : real

    InOut X_T : matrix(real,6,6)
    InOut XJ : matrix(real,6,6)
    InOut vJ : vector(real,6)
    InOut cJ : vector(real,6)

    const S : vector(real,6) = (| 0, 0, 0, 0, 0, -1 |)

    // X_T = Xtrans([0,0,-q])
    equation X_T == [| 1, 0, 0, 0, 0, 0;
                0, 1, 0, 0, 0, 0;
                0, 0, 1, 0, 0, 0;
                0, -q,0, 1, 0, 0;
                q, 0, 0, 0, 1, 0;
                0, 0, 0, 0, 0, 1 |]

    equation XJ == X_T

    equation vJ == S * qd
    equation cJ == (| 0, 0, 0, 0, 0, 0 |)
end
