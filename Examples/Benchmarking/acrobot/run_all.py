#!/usr/bin/env python3
"""Runs every available engine of the Acrobot benchmark and compares their trajectories.

Usage: run_all.py --build <cmake build folder> [--results <folder>]
                  [--python-drake <python>] [--python-mujoco <python>] [--python-pinocchio <python>]

A C++ engine runs if its program is in the build folder; a Python engine runs if its interpreter is given.
"""
import argparse
import csv
import subprocess
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
CPP_ENGINES = ("sko", "rbdl", "robcogen", "gafro")
PYTHON_ENGINES = ("drake", "mujoco", "pinocchio")


def commands(args):
    """The command that starts each available engine, by name."""
    found = {}
    for name in CPP_ENGINES:
        program = Path(args.build) / f"engine_{name}"
        if program.exists():
            found[name] = [str(program)]
    for name in PYTHON_ENGINES:
        python = getattr(args, f"python_{name}")
        if python:
            found[name] = [python, str(HERE / f"engine_{name}.py")]
    return found


def rows(path):
    with open(path) as f:
        return [[float(value) for value in row] for row in list(csv.reader(f))[1:]]


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--build", required=True)
    parser.add_argument("--results", default=str(HERE / "results"))
    for name in PYTHON_ENGINES:
        parser.add_argument(f"--python-{name}")
    args = parser.parse_args()

    results = Path(args.results)
    results.mkdir(parents=True, exist_ok=True)
    engines = commands(args)
    if not engines:
        print("no engine found", file=sys.stderr)
        return 1

    failed = []
    for name, command in engines.items():
        if subprocess.run(command + ["trajectory", str(results / f"trajectory_{name}.csv")], cwd=HERE).returncode != 0:
            failed.append(f"{name} trajectory")
        if subprocess.run(command + ["timing", str(results / f"timing_{name}.csv")], cwd=HERE).returncode != 0:
            failed.append(f"{name} timing")

    names = [name for name in engines if not any(entry.startswith(name + " ") for entry in failed)]
    print(f"\nLargest difference from {names[0]} in any angle or rate over the 5 s:")
    first = rows(results / f"trajectory_{names[0]}.csv")
    for name in names[1:]:
        other = rows(results / f"trajectory_{name}.csv")
        worst = max(abs(a - b) for row_a, row_b in zip(first, other) for a, b in zip(row_a, row_b))
        print(f"{name.ljust(12)}{worst:10.3e}")

    print("\nMean time of one forward-dynamics call, microseconds (mean over the nine shoulder angles):")
    for name in names:
        means = [float(row["mean_time_us"]) for row in csv.DictReader(open(results / f"timing_{name}.csv"))]
        print(f"{name.ljust(12)}{sum(means) / len(means):10.3f}")

    if failed:
        print("\nfailed: " + ", ".join(failed), file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
