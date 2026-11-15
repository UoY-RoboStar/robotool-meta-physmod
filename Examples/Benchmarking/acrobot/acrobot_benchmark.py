"""Model, stepping and timing for the Python engines; mirrors acrobot_benchmark.h."""
import math
import sys
import time

import numpy as np

MASS = 1.0                        # kg, each link
LINK1_LENGTH = 1.0                # m
COM1 = 0.5                        # m from the shoulder
COM2 = 1.0                        # m from the elbow
INERTIA1 = (0.083, 0.083, 0.001)  # about the centre of mass
INERTIA2 = (0.333, 0.333, 0.001)
DAMPING = 0.1                     # N m s, each joint
GRAVITY = 9.81

START_ANGLE = 1.0                 # rad, both joints
STEP = 0.001                      # s
STEPS = 5000
ROW_EVERY = 10                    # steps per trajectory row

WARM_UP_CALLS = 100
TIMED_CALLS = 1000

def write_trajectory(acceleration, path):
    q, v = np.array([START_ANGLE, START_ANGLE]), np.zeros(2)
    with open(path, "w") as out:
        out.write("time,theta0,theta1,dtheta0,dtheta1\n")
        for step in range(STEPS + 1):
            if step % ROW_EVERY == 0:
                out.write(f"{step * STEP:.3f},{q[0]:.9f},{q[1]:.9f},{v[0]:.9f},{v[1]:.9f}\n")
            q, v = q + STEP * v, v + STEP * acceleration(q, v)


def write_timing(acceleration, name, path):
    """Times one forward-dynamics call at nine shoulder angles."""
    with open(path, "w") as out:
        out.write("engine,theta1,mean_time_us,std_time_us,min_time_us,max_time_us\n")
        for k in range(-4, 5):
            q, v = np.array([k * math.pi / 4.0, 0.0]), np.zeros(2)
            for _ in range(WARM_UP_CALLS):
                acceleration(q, v)
            times = np.empty(TIMED_CALLS)
            for call in range(TIMED_CALLS):
                start = time.perf_counter()
                acceleration(q, v)
                times[call] = (time.perf_counter() - start) * 1e6
            out.write(f"{name},{q[0]:.6f},{times.mean():.6f},{times.std():.6f},{times.min():.6f},{times.max():.6f}\n")
    print(f"{name}: timing written to {path}")


def run(name, acceleration, argv=None):
    argv = sys.argv if argv is None else argv
    if len(argv) == 3 and argv[1] == "trajectory":
        write_trajectory(acceleration, argv[2])
        return 0
    if len(argv) == 3 and argv[1] == "timing":
        write_timing(acceleration, name, argv[2])
        return 0
    print(f"usage: {argv[0]} <trajectory|timing> <out.csv>", file=sys.stderr)
    return 2
