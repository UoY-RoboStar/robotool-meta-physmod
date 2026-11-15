#!/usr/bin/env python3
"""Run the Acrobot in Drake and log its dynamics and link frames.

The model is the Acrobot: Link1 (1 kg, 1 m) hangs from the shoulder at z = -0.2, Link2 (1 kg, 2 m)
from the elbow at z = -1.2, both hinged about x, gravity along -z. Index 0 is the shoulder, 1 the elbow.
The frames B1 and B2 sit at the shoulder and the elbow, written row by row as 4x4 world transforms.
"""
import argparse
import csv
from pathlib import Path

import numpy as np
from pydrake.math import RigidTransform
from pydrake.multibody.plant import MultibodyPlant
from pydrake.multibody.tree import FixedOffsetFrame, RevoluteJoint, RotationalInertia, SpatialInertia
from pydrake.systems.analysis import Simulator
from pydrake.systems.framework import DiagramBuilder

SHOULDER_Z = -0.2
LINK1_LENGTH = 1.0
LINK2_LENGTH = 2.0
DEFAULT_DIR = (Path(__file__).resolve().parents[4] / "physmod-testdata" / "circus.robocalc.robosim.physmod.testdata"
               / "testdata" / "integration" / "T5" / "Acrobot" / "SKO" / "standalone_visualisation")


def build(damping):
    plant = MultibodyPlant(0.0)
    link1 = plant.AddRigidBody("Link1", SpatialInertia.MakeFromCentralInertia(
        1.0, [0, 0, -LINK1_LENGTH / 2], RotationalInertia(0.083, 0.083, 0.001)))
    link2 = plant.AddRigidBody("Link2", SpatialInertia.MakeFromCentralInertia(
        1.0, [0, 0, -LINK2_LENGTH / 2], RotationalInertia(0.333, 0.333, 0.001)))
    shoulder = plant.AddFrame(FixedOffsetFrame("shoulder", plant.world_frame(), RigidTransform([0, 0, SHOULDER_Z])))
    elbow = plant.AddFrame(FixedOffsetFrame("elbow", link1.body_frame(), RigidTransform([0, 0, -LINK1_LENGTH])))
    joints = (
        plant.AddJoint(RevoluteJoint("ShoulderJoint", shoulder, link1.body_frame(), [1, 0, 0], damping=damping)),
        plant.AddJoint(RevoluteJoint("ElbowJoint", elbow, link2.body_frame(), [1, 0, 0], damping=damping)),
    )
    plant.Finalize()
    return plant, (link1, link2), joints


def main() -> int:
    parser = argparse.ArgumentParser(description="Run the Drake Acrobot and log dynamics and link frames.")
    parser.add_argument("--output-dir", default=str(DEFAULT_DIR))
    parser.add_argument("--duration", type=float, default=5.0)
    parser.add_argument("--dt", type=float, default=0.001)
    parser.add_argument("--theta", type=float, nargs=2, default=[1.0, 1.0])
    parser.add_argument("--damping", type=float, default=0.1)
    args = parser.parse_args()

    plant, links, joints = build(args.damping)
    builder = DiagramBuilder()
    builder.AddSystem(plant)
    diagram = builder.Build()
    diagram_context = diagram.CreateDefaultContext()
    context = plant.GetMyMutableContextFromRoot(diagram_context)
    for joint, angle in zip(joints, args.theta):
        joint.set_angle(context, angle)

    simulator = Simulator(diagram, diagram_context)
    simulator.get_mutable_integrator().set_maximum_step_size(args.dt)
    simulator.get_mutable_integrator().set_target_accuracy(1e-10)
    simulator.Initialize()

    out = Path(args.output_dir)
    steps = int(round(args.duration / args.dt))
    with (out / "dynamics_drake.csv").open("w", newline="") as dyn_file, \
            (out / "poses_drake.csv").open("w", newline="") as pose_file:
        dyn, poses = csv.writer(dyn_file), csv.writer(pose_file)
        dyn.writerow(["time", "theta0", "theta1", "dtheta0", "dtheta1", "M00", "M01", "M10", "M11",
                      "Cv0", "Cv1", "taug0", "taug1", "vdot0", "vdot1"])
        poses.writerow(["time"] + [f"B{b}_{i}" for b in (1, 2) for i in range(16)])
        for step in range(steps + 1):
            t = step * args.dt
            simulator.AdvanceTo(t)
            q, v = plant.GetPositions(context), plant.GetVelocities(context)
            M = plant.CalcMassMatrix(context)
            Cv = plant.CalcBiasTerm(context)
            taug = plant.CalcGravityGeneralizedForces(context)
            vdot = np.linalg.solve(M, taug - Cv - args.damping * v)
            dyn.writerow([f"{x:.9f}" for x in (t, *q, *v, *M.ravel(), *Cv, *taug, *vdot)])
            frames = [plant.EvalBodyPoseInWorld(context, link).GetAsMatrix4().ravel() for link in links]
            poses.writerow([f"{x:.9f}" for x in (t, *frames[0], *frames[1])])
    print(f"Wrote {out / 'dynamics_drake.csv'} and {out / 'poses_drake.csv'}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
