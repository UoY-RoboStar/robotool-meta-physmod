#!/usr/bin/env python3
import argparse
import csv
import math
from pathlib import Path


def _find_idx(header, candidates):
    for name in candidates:
        if name in header:
            return header.index(name)
    return None


def _require_idx(header, candidates, label):
    idx = _find_idx(header, candidates)
    if idx is None:
        raise ValueError(f"Missing column for {label}. Tried: {candidates}. Header: {header}")
    return idx


def read_trajectory(path):
    path = Path(path)
    with path.open(newline="") as f:
        rows = list(csv.reader(f))
    if not rows:
        raise ValueError(f"Empty trajectory file: {path}")

    header = [h.strip() for h in rows[0]]
    t_idx = _require_idx(header, ["time", "t"], "time")
    q0_idx = _require_idx(header, ["q0", "theta0"], "q0")
    q1_idx = _require_idx(header, ["q1", "theta1"], "q1")
    dq0_idx = _require_idx(header, ["dq0", "dtheta0", "d_theta0"], "dq0")
    dq1_idx = _require_idx(header, ["dq1", "dtheta1", "d_theta1"], "dq1")

    data = []
    for row in rows[1:]:
        if not row or all(not cell.strip() for cell in row):
            continue
        try:
            t = float(row[t_idx])
            q0 = float(row[q0_idx])
            q1 = float(row[q1_idx])
            dq0 = float(row[dq0_idx])
            dq1 = float(row[dq1_idx])
        except (ValueError, IndexError):
            continue
        data.append((t, q0, q1, dq0, dq1))

    if not data:
        raise ValueError(f"No numeric data found in: {path}")
    return data


def apply_mapping(row, order, signs):
    t, q0, q1, dq0, dq1 = row
    if order == "reverse":
        q0, q1 = q1, q0
        dq0, dq1 = dq1, dq0
    q0 *= signs[0]
    q1 *= signs[1]
    dq0 *= signs[0]
    dq1 *= signs[1]
    return (t, q0, q1, dq0, dq1)


def max_abs_diff(feather, sko, order, signs):
    count = min(len(feather), len(sko))
    max_diff = 0.0
    for i in range(count):
        _, fq0, fq1, fdq0, fdq1 = feather[i]
        _, sq0, sq1, sdq0, sdq1 = apply_mapping(sko[i], order, signs)
        max_diff = max(
            max_diff,
            abs(fq0 - sq0),
            abs(fq1 - sq1),
            abs(fdq0 - sdq0),
            abs(fdq1 - sdq1),
        )
    return max_diff


def parse_signs(signs_str, dof):
    parts = [p.strip() for p in signs_str.split(",") if p.strip()]
    if not parts:
        raise ValueError("Empty --signs value")
    signs = [int(p) for p in parts]
    if len(signs) == 1:
        signs = signs * dof
    if len(signs) != dof:
        raise ValueError(f"Expected {dof} sign values, got {len(signs)}: {signs}")
    for s in signs:
        if s not in (-1, 1):
            raise ValueError(f"Sign values must be -1 or 1, got {s}")
    return signs


def main():
    script_dir = Path(__file__).resolve().parent
    default_feather = script_dir / "build" / "trajectory.csv"
    default_sko = script_dir.parent / "Acrobot" / "build" / "trajectory.csv"

    parser = argparse.ArgumentParser(
        description="Compare Featherstone vs SKO acrobot trajectories and write a diff CSV."
    )
    parser.add_argument("--featherstone", default=str(default_feather),
                        help="Path to Featherstone trajectory.csv")
    parser.add_argument("--sko", default=str(default_sko),
                        help="Path to SKO trajectory.csv")
    parser.add_argument("--out", default="trajectory_diff.csv",
                        help="Output diff CSV filename (written next to Featherstone trajectory)")
    parser.add_argument("--order", choices=["auto", "identity", "reverse"], default="auto",
                        help="Ordering mapping for SKO -> Featherstone")
    parser.add_argument("--signs", default="1,1",
                        help="Comma-separated sign flips to apply to SKO (e.g., 1,-1)")

    args = parser.parse_args()

    feather = read_trajectory(args.featherstone)
    sko = read_trajectory(args.sko)
    dof = 2
    signs = parse_signs(args.signs, dof)

    if args.order == "auto":
        identity_diff = max_abs_diff(feather, sko, "identity", signs)
        reverse_diff = max_abs_diff(feather, sko, "reverse", signs)
        order = "identity" if identity_diff <= reverse_diff else "reverse"
        best = min(identity_diff, reverse_diff)
        print(f"auto order: identity max |Δ|={identity_diff:.6f}, "
              f"reverse max |Δ|={reverse_diff:.6f} -> using {order} (best={best:.6f})")
    else:
        order = args.order

    count = min(len(feather), len(sko))
    out_path = Path(args.featherstone).resolve().parent / args.out
    with out_path.open("w", newline="") as f:
        writer = csv.writer(f)
        writer.writerow([
            "time_feather", "time_sko",
            "f_q0", "f_q1", "f_dq0", "f_dq1",
            "sko_q0", "sko_q1", "sko_dq0", "sko_dq1",
            "d_q0", "d_q1", "d_dq0", "d_dq1",
        ])
        max_diff = 0.0
        for i in range(count):
            ft, fq0, fq1, fdq0, fdq1 = feather[i]
            st, sq0, sq1, sdq0, sdq1 = apply_mapping(sko[i], order, signs)
            d_q0 = fq0 - sq0
            d_q1 = fq1 - sq1
            d_dq0 = fdq0 - sdq0
            d_dq1 = fdq1 - sdq1
            max_diff = max(max_diff, abs(d_q0), abs(d_q1), abs(d_dq0), abs(d_dq1))
            writer.writerow([ft, st, fq0, fq1, fdq0, fdq1, sq0, sq1, sdq0, sdq1,
                             d_q0, d_q1, d_dq0, d_dq1])

    print(f"Wrote diff CSV: {out_path} (rows={count}, max |Δ|={max_diff:.6f}, order={order}, signs={signs})")


if __name__ == "__main__":
    main()
