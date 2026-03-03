#!/usr/bin/env python3
import argparse
import csv
import math
from pathlib import Path

import mujoco
import numpy as np


def constraint_jacobian(q, length):
    qA, qB, qC = q
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


def solve_velocity_constraint(q, dqA, length):
    G = constraint_jacobian(q, length)
    G_bc = G[:, 1:3]
    rhs = -G[:, 0] * dqA
    dqB, dqC = np.linalg.solve(G_bc, rhs)
    return float(dqB), float(dqC)


def main() -> int:
    parser = argparse.ArgumentParser(description="Run MuJoCo four-bar and log joint angles.")
    parser.add_argument("--xml", default="/home/arjunbadyal/RoboStar/physmod-physics-engine-private/Examples/ReferenceImplementations/FourBar/fourbar_mujoco.xml")
    parser.add_argument("--output", default="trajectory_mujoco_fourbar.csv")
    parser.add_argument("--duration", type=float, default=2.0)
    parser.add_argument("--dqA", type=float, default=3.0)
    parser.add_argument("--link-length", type=float, default=4.0)
    parser.add_argument("--integrator", choices=["euler", "rk4", "implicit", "implicitfast"])
    parser.add_argument("--iterations", type=int)
    args = parser.parse_args()

    xml_path = Path(args.xml)
    if not xml_path.exists():
        raise FileNotFoundError(f"MJCF not found: {xml_path}")

    model = mujoco.MjModel.from_xml_path(str(xml_path))
    data = mujoco.MjData(model)

    if args.integrator:
        integrator_map = {
            "euler": mujoco.mjtIntegrator.mjINT_EULER,
            "rk4": mujoco.mjtIntegrator.mjINT_RK4,
            "implicit": mujoco.mjtIntegrator.mjINT_IMPLICIT,
            "implicitfast": mujoco.mjtIntegrator.mjINT_IMPLICITFAST,
        }
        model.opt.integrator = integrator_map[args.integrator]

    if args.iterations is not None:
        model.opt.iterations = int(args.iterations)

    data.qpos[:] = model.qpos0
    q_init = data.qpos.copy()
    dqB, dqC = solve_velocity_constraint(q_init, args.dqA, args.link_length)
    data.qvel[:] = np.array([args.dqA, dqB, dqC], dtype=float)

    mujoco.mj_forward(model, data)

    dt = model.opt.timestep
    steps = int(round(args.duration / dt))

    output_path = Path(args.output)
    with output_path.open("w", newline="") as csvfile:
        writer = csv.writer(csvfile)
        writer.writerow(["time", "theta0", "theta1", "theta2"])

        for _ in range(steps):
            mujoco.mj_step(model, data)
            writer.writerow([data.time, data.qpos[0], data.qpos[1], data.qpos[2]])

    print(f"Wrote {output_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
