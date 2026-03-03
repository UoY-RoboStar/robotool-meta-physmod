#!/usr/bin/env python3
import argparse
import csv
import math
from pathlib import Path

import numpy as np
from pydrake.multibody.parsing import Parser
from pydrake.multibody.plant import AddMultibodyPlantSceneGraph, MultibodyPlant
from pydrake.multibody.tree import LinearBushingRollPitchYaw
from pydrake.systems.analysis import Simulator
from pydrake.systems.framework import DiagramBuilder


def constraint_jacobian(qA: float, qB: float, qC: float, length: float) -> np.ndarray:
    sA = math.sin(qA)
    cA = math.cos(qA)
    sAB = math.sin(qA + qB)
    cAB = math.cos(qA + qB)
    sC = math.sin(qC)
    cC = math.cos(qC)

    G = np.zeros((2, 3))
    G[0, 0] = -length * sA - length * sAB
    G[0, 1] = -length * sAB
    G[0, 2] = length * sC

    G[1, 0] = -length * cA - length * cAB
    G[1, 1] = -length * cAB
    G[1, 2] = length * cC
    return G


def solve_velocity_constraint(qA: float, qB: float, qC: float, dqA: float, length: float) -> tuple[float, float]:
    G = constraint_jacobian(qA, qB, qC, length)
    G_bc = G[:, 1:3]
    rhs = -G[:, 0] * dqA

    det = G_bc[0, 0] * G_bc[1, 1] - G_bc[0, 1] * G_bc[1, 0]
    if abs(det) < 1e-9:
        return 0.0, 0.0

    dqB = (rhs[0] * G_bc[1, 1] - rhs[1] * G_bc[0, 1]) / det
    dqC = (-rhs[0] * G_bc[1, 0] + rhs[1] * G_bc[0, 0]) / det
    return float(dqB), float(dqC)

def normalize_angle(angle: float) -> float:
    while angle > math.pi:
        angle -= 2.0 * math.pi
    while angle < -math.pi:
        angle += 2.0 * math.pi
    return angle


def unwrap_angle(angle: float, previous: float) -> float:
    delta = angle - previous
    while delta > math.pi:
        angle -= 2.0 * math.pi
        delta = angle - previous
    while delta < -math.pi:
        angle += 2.0 * math.pi
        delta = angle - previous
    return angle


def drake_to_reference(qA: float, qB: float, qC: float, length: float, ground: float) -> tuple[float, float, float]:
    # Drake uses x-left, z-up. Reference uses x-right, z-down.
    xAB_d = length * math.cos(qA)
    zAB_d = length * math.sin(qA)
    xBC_d = xAB_d + length * math.cos(qA + qB)
    zBC_d = zAB_d + length * math.sin(qA + qB)

    xAB = -xAB_d
    zAB = -zAB_d
    xBC = -xBC_d
    zBC = -zBC_d

    qA_ref = math.atan2(-zAB, xAB)

    vBx = xBC - xAB
    vBz = zBC - zAB
    qB_abs = math.atan2(-vBz, vBx)
    qB_ref = qB_abs - qA_ref

    vCx = xBC - ground
    vCz = zBC
    qC_ref = math.atan2(-vCz, vCx)

    return normalize_angle(qA_ref), normalize_angle(qB_ref), normalize_angle(qC_ref)


def main() -> int:
    parser = argparse.ArgumentParser(description="Run Drake four_bar and log joint angles.")
    parser.add_argument("--sdf", default="/home/arjunbadyal/PhysicsEngines/drake/examples/multibody/four_bar/four_bar.sdf")
    parser.add_argument("--output", default="trajectory_drake_fourbar.csv")
    parser.add_argument("--duration", type=float, default=2.0)
    parser.add_argument("--dt", type=float, default=0.001)
    parser.add_argument("--dqA", type=float, default=3.0)
    parser.add_argument("--link-length", type=float, default=4.0)
    parser.add_argument("--ground-length", type=float, default=2.0)
    parser.add_argument("--force-stiffness", type=float, default=30000.0)
    parser.add_argument("--force-damping", type=float, default=1500.0)
    parser.add_argument("--torque-stiffness", type=float, default=30000.0)
    parser.add_argument("--torque-damping", type=float, default=1500.0)
    args = parser.parse_args()

    sdf_path = Path(args.sdf)
    if not sdf_path.exists():
        raise FileNotFoundError(f"SDF not found: {sdf_path}")

    builder = DiagramBuilder()
    plant, _ = AddMultibodyPlantSceneGraph(builder, MultibodyPlant(0.0))
    Parser(plant).AddModels(str(sdf_path))

    frame_bc = plant.GetFrameByName("Bc_bushing")
    frame_cb = plant.GetFrameByName("Cb_bushing")

    force_stiffness = np.array([args.force_stiffness] * 3)
    force_damping = np.array([args.force_damping] * 3)
    torque_stiffness = np.array([args.torque_stiffness, args.torque_stiffness, 0.0])
    torque_damping = np.array([args.torque_damping, args.torque_damping, 0.0])

    plant.AddForceElement(
        LinearBushingRollPitchYaw(
            frame_bc,
            frame_cb,
            torque_stiffness,
            torque_damping,
            force_stiffness,
            force_damping,
        )
    )

    plant.Finalize()
    diagram = builder.Build()

    diagram_context = diagram.CreateDefaultContext()
    plant_context = plant.GetMyMutableContextFromRoot(diagram_context)

    plant.get_actuation_input_port().FixValue(plant_context, [0.0])

    joint_WA = plant.GetJointByName("joint_WA")
    joint_AB = plant.GetJointByName("joint_AB")
    joint_WC = plant.GetJointByName("joint_WC")

    qA = math.atan2(math.sqrt(15.0), 1.0)
    qB = math.pi - qA
    qC = qB

    joint_WA.set_angle(plant_context, qA)
    joint_AB.set_angle(plant_context, qB)
    joint_WC.set_angle(plant_context, qC)

    dqB, dqC = solve_velocity_constraint(qA, qB, qC, args.dqA, args.link_length)
    joint_WA.set_angular_rate(plant_context, args.dqA)
    joint_AB.set_angular_rate(plant_context, dqB)
    joint_WC.set_angular_rate(plant_context, dqC)

    simulator = Simulator(diagram, diagram_context)
    simulator.get_mutable_integrator().set_maximum_step_size(args.dt)
    simulator.Initialize()

    output_path = Path(args.output)
    with output_path.open("w", newline="") as csvfile:
        writer = csv.writer(csvfile)
        writer.writerow(["time", "theta0", "theta1", "theta2"])

        t = 0.0
        qA_ref, qB_ref, qC_ref = drake_to_reference(qA, qB, qC, args.link_length, args.ground_length)
        prev_ref = [qA_ref, qB_ref, qC_ref]
        writer.writerow([t, qA_ref, qB_ref, qC_ref])

        while t < args.duration:
            t = min(args.duration, t + args.dt)
            simulator.AdvanceTo(t)
            qA = joint_WA.get_angle(plant_context)
            qB = joint_AB.get_angle(plant_context)
            qC = joint_WC.get_angle(plant_context)
            qA_ref, qB_ref, qC_ref = drake_to_reference(qA, qB, qC, args.link_length, args.ground_length)
            qA_ref = unwrap_angle(qA_ref, prev_ref[0])
            qB_ref = unwrap_angle(qB_ref, prev_ref[1])
            qC_ref = unwrap_angle(qC_ref, prev_ref[2])
            prev_ref = [qA_ref, qB_ref, qC_ref]
            writer.writerow([t, qA_ref, qB_ref, qC_ref])

    print(f"Wrote {output_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
