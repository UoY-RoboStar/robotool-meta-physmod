#!/usr/bin/env python3
"""Pinocchio forward dynamics (articulated-body algorithm)."""
import numpy as np
import pinocchio as pin

import acrobot_benchmark as acrobot

model = pin.Model()
shoulder = model.addJoint(0, pin.JointModelRX(), pin.SE3.Identity(), "ShoulderJoint")
model.appendBodyToJoint(
    shoulder, pin.Inertia(acrobot.MASS, np.array([0.0, 0.0, -acrobot.COM1]), np.diag(acrobot.INERTIA1)), pin.SE3.Identity())
elbow = model.addJoint(
    shoulder, pin.JointModelRX(), pin.SE3(np.eye(3), np.array([0.0, 0.0, -acrobot.LINK1_LENGTH])), "ElbowJoint")
model.appendBodyToJoint(
    elbow, pin.Inertia(acrobot.MASS, np.array([0.0, 0.0, -acrobot.COM2]), np.diag(acrobot.INERTIA2)), pin.SE3.Identity())
model.gravity.linear = np.array([0.0, 0.0, -acrobot.GRAVITY])
data = model.createData()


def acceleration(q, v):
    return np.array(pin.aba(model, data, q, v, -acrobot.DAMPING * v))


if __name__ == "__main__":
    raise SystemExit(acrobot.run("pinocchio", acceleration))
