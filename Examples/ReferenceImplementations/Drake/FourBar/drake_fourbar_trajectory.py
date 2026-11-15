#!/usr/bin/env python3
"""Run the four-bar in Drake and log its joint angles.

The model is the one in MuJoCo/FourBar/fourbar_mujoco.xml: three 4 m links of 20 kg hinged about y,
pivots 2 m apart, the coupler's tip pinned to the rocker's tip. Angles and rates use
that file's convention (a link along +x at angle 0, +z up, gravity along -z).
"""
import argparse
import csv
import math
from pathlib import Path

import numpy as np
from pydrake.math import RigidTransform
from pydrake.multibody.plant import DiscreteContactApproximation, MultibodyPlant
from pydrake.multibody.tree import FixedOffsetFrame, RevoluteJoint, RotationalInertia, SpatialInertia
from pydrake.systems.analysis import Simulator
from pydrake.systems.framework import DiagramBuilder

LINK_LENGTH = 4.0
GROUND_LENGTH = 2.0
MASS = 20.0
CENTRAL_INERTIA = (0.0833333333, 26.6666666667, 26.6666666667)


def constraint_jacobian(q, length):
    qA, qB, qC = q
    return np.array([
        [-length * math.sin(qA) - length * math.sin(qA + qB), -length * math.sin(qA + qB), length * math.sin(qC)],
        [-length * math.cos(qA) - length * math.cos(qA + qB), -length * math.cos(qA + qB), length * math.cos(qC)],
    ])


def solve_velocity_constraint(q, dqA, length):
    G = constraint_jacobian(q, length)
    dqB, dqC = np.linalg.solve(G[:, 1:3], -G[:, 0] * dqA)
    return float(dqB), float(dqC)


def main() -> int:
    parser = argparse.ArgumentParser(description="Run the Drake four-bar and log joint angles.")
    parser.add_argument("--output", default=str(Path(__file__).with_name("trajectory_drake_fourbar.csv")))
    parser.add_argument("--duration", type=float, default=2.0)
    parser.add_argument("--dt", type=float, default=0.001)
    parser.add_argument("--dqA", type=float, default=3.0)
    args = parser.parse_args()

    plant = MultibodyPlant(time_step=args.dt)
    plant.set_discrete_contact_approximation(DiscreteContactApproximation.kSap)
    inertia = SpatialInertia.MakeFromCentralInertia(
        MASS, [LINK_LENGTH / 2, 0, 0], RotationalInertia(*CENTRAL_INERTIA))
    link_a = plant.AddRigidBody("linkA", inertia)
    link_b = plant.AddRigidBody("linkB", inertia)
    link_c = plant.AddRigidBody("linkC", inertia)
    elbow = plant.AddFrame(FixedOffsetFrame("elbow", link_a.body_frame(), RigidTransform([LINK_LENGTH, 0, 0])))
    right_pivot = plant.AddFrame(
        FixedOffsetFrame("right_pivot", plant.world_frame(), RigidTransform([GROUND_LENGTH, 0, 0])))
    joint_wa = plant.AddJoint(RevoluteJoint("joint_WA", plant.world_frame(), link_a.body_frame(), [0, 1, 0]))
    joint_ab = plant.AddJoint(RevoluteJoint("joint_AB", elbow, link_b.body_frame(), [0, 1, 0]))
    joint_wc = plant.AddJoint(RevoluteJoint("joint_WC", right_pivot, link_c.body_frame(), [0, 1, 0]))
    plant.AddBallConstraint(link_b, [LINK_LENGTH, 0, 0], link_c, [LINK_LENGTH, 0, 0])
    plant.Finalize()

    builder = DiagramBuilder()
    builder.AddSystem(plant)
    diagram = builder.Build()
    diagram_context = diagram.CreateDefaultContext()
    plant_context = plant.GetMyMutableContextFromRoot(diagram_context)

    q = (math.acos(-0.25), -math.acos(-0.25), math.acos(0.25))
    dqB, dqC = solve_velocity_constraint(q, args.dqA, LINK_LENGTH)
    joints = (joint_wa, joint_ab, joint_wc)
    for joint, angle, rate in zip(joints, q, (args.dqA, dqB, dqC)):
        joint.set_angle(plant_context, angle)
        joint.set_angular_rate(plant_context, rate)

    simulator = Simulator(diagram, diagram_context)
    simulator.Initialize()
    steps = int(round(args.duration / args.dt))
    with Path(args.output).open("w", newline="") as csvfile:
        writer = csv.writer(csvfile)
        writer.writerow(["time", "theta0", "theta1", "theta2"])
        writer.writerow([0.0] + [joint.get_angle(plant_context) for joint in joints])
        for step in range(1, steps + 1):
            simulator.AdvanceTo(step * args.dt)
            writer.writerow([step * args.dt] + [joint.get_angle(plant_context) for joint in joints])
    print(f"Wrote {args.output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
