#!/usr/bin/env python3
"""
Grover's algorithm — educational amplitude-amplification demo.
Ref: 03-Quantum-Computing-Framework.md "Module 1: Quantum Algorithm
Simulations" and "Tools & Resources" (Amazon Braket is the only approved
quantum simulator per 02-Cloud-Infrastructure.md's Service Approval list).

WHAT THIS SHOWS:
  - How quantum superposition (Hadamard gates) spreads amplitude evenly
    across all basis states.
  - How an oracle can mark a "solution" state with a phase flip.
  - How the diffusion operator amplifies the marked state's probability.

WHAT THIS DOES NOT SHOW (see 03-Quantum-Computing-Framework.md "Research
Ethics & Boundaries" — Prohibited):
  - This does NOT break RSA, ECDSA, or any real encryption.
  - This is a 2-qubit toy search over 4 basis states, run on a *local*
    simulator (no real quantum hardware, no AWS account/cost required).
    Grover's algorithm has nothing to do with Shor's algorithm (which is
    what actually threatens RSA/ECDSA) — they are unrelated primitives.

Usage:
    pip install -r requirements.txt
    python grover_demo.py --target 11
"""
from __future__ import annotations

import argparse

from braket.circuits import Circuit
from braket.devices import LocalSimulator


def build_grover_circuit(target: str) -> Circuit:
    if len(target) != 2 or any(c not in "01" for c in target):
        raise ValueError("target must be a 2-bit string, e.g. '00', '01', '10', '11'")

    circ = Circuit()

    # 1. Superposition: equal amplitude across all 4 basis states.
    circ.h(0).h(1)

    # 2. Oracle: flip the phase of |target> only. We remap `target` to |11>
    #    with X gates, apply a controlled-Z (marks |11>), then undo the remap.
    flip_qubits = [i for i, bit in enumerate(target) if bit == "0"]
    for q in flip_qubits:
        circ.x(q)
    circ.cz(0, 1)
    for q in flip_qubits:
        circ.x(q)

    # 3. Diffusion operator: amplifies the marked state's amplitude.
    #    (H, X, controlled-Z, X, H on both qubits — inversion about the mean.)
    circ.h(0).h(1)
    circ.x(0).x(1)
    circ.cz(0, 1)
    circ.x(0).x(1)
    circ.h(0).h(1)

    return circ


def run(target: str, shots: int = 1000):
    circ = build_grover_circuit(target)
    device = LocalSimulator()  # no AWS account or cost — swap for a hosted
    # Amazon Braket device ARN (e.g. arn:aws:braket:::device/qpu/...) once
    # you're ready to run on real hardware, per 02-Cloud-Infrastructure.md's
    # Amazon Braket service approval.
    result = device.run(circ, shots=shots).result()
    counts = result.measurement_counts
    return circ, counts


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--target", default="11", help="2-bit target state to search for, e.g. 11")
    parser.add_argument("--shots", type=int, default=1000)
    args = parser.parse_args()

    circ, counts = run(args.target, args.shots)

    print(circ)
    print()
    print(f"Target state: |{args.target}>")
    print("Measurement counts (out of {} shots):".format(args.shots))
    for state, count in sorted(counts.items(), key=lambda kv: -kv[1]):
        marker = "  <-- amplified target" if state == args.target else ""
        print(f"  |{state}>: {count} ({100 * count / args.shots:.1f}%){marker}")

    target_prob = counts.get(args.target, 0) / args.shots
    print()
    print(f"Classical random guessing baseline: 25.0% chance of hitting the target.")
    print(f"After 1 Grover iteration: {target_prob * 100:.1f}% measured probability.")
    print("This demonstrates amplitude amplification only — it does not decrypt anything.")


if __name__ == "__main__":
    main()
