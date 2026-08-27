# Threat Model: Harvest-Now-Decrypt-Later

This document replaces an earlier `init.md` that framed this threat as an
operational attack playbook against a named real company. That framing was
wrong for this project: everything in this repo is scoped to lab-only,
synthetic, authorized research (`01-Executive-Summary.md` "Scope &
Boundaries", `04-Security-Policy.md`, `05-Testing-Methodology.md`). This
version describes the same underlying threat generically, as motivation for
the mitigations already built here — it does not target, and must never be
used to target, any real organization's live traffic or infrastructure.

## The attack pattern

"Harvest now, decrypt later" (HNDL) does not require a working quantum
computer today:

1. **Harvest** — an adversary with a network vantage point (an ISP, a
   state-level actor, a compromised intermediary) records encrypted traffic
   now — TLS handshakes, VPN sessions, signed records — and stores the
   ciphertext indefinitely. This step is classical and already possible; no
   quantum hardware is involved.
2. **Wait** — the ciphertext sits in storage for years, until a
   cryptographically-relevant quantum computer exists.
3. **Decrypt** — once such a machine exists, Shor's algorithm recovers the
   private keys behind the RSA/ECDSA/DH key exchanges used at capture time,
   and the historical traffic is retroactively decrypted.

The exposure is entirely in the **key-exchange and signature layer**
(RSA, ECDSA, Diffie-Hellman) — see `03-Quantum-Computing-Framework.md`
"What Quantum Threatens". Symmetric primitives (AES-256, SHA-3) are not at
risk from this pattern; Grover's algorithm only weakens them quadratically,
which key-length already accounts for.

## Why this matters for Genesis Mesh

Genesis Mesh's Sovereign Graph signs recognition edges, NA identity
attestations, and treaty records with classical public-key cryptography
(see `00-INDEX.md` "Relation to Genesis Mesh"). Any such record signed or
exchanged today is exposed to HNDL: if an adversary harvests it now, a
future quantum computer could forge or repudiate it retroactively. That is
the concrete reason this repo's PQC migration research exists — the
migration needs to happen *before* long-lived signed records are broken,
not after.

## What this repo does about it (not to it)

Rather than describing an intercept, everything below evaluates and
hardens **our own lab systems**, which is the only in-scope target
(`05-Testing-Methodology.md`):

- `research/crypto_inventory` — scans this repo's own Terraform/config for
  RSA/ECDSA/DH usage that would need a PQC migration path, producing a
  prioritized risk register instead of a target list.
- `research/pqc_hybrid` — implements the actual mitigation: a hybrid
  X25519 + FIPS 203 ML-KEM-768 key exchange and FIPS 204 ML-DSA-65
  signatures, so a session or record survives even if one of the two
  algorithms is later broken. This is the pattern recognition-edge signing
  would adopt.
- `research/quantum_demo` — demonstrates amplitude amplification (Grover)
  on a local simulator for education, explicitly documented as unrelated
  to breaking RSA/ECDSA (that needs Shor's algorithm and hardware that does
  not yet exist).
- Module 4 (migration planning, `06-Roadmap.md` Week 19–20) turns the
  inventory findings into a phased hybrid → post-quantum-only rollout
  timeline.

## Boundaries

- No interception of real, third-party, or production traffic — ever, for
  any company.
- No code in this repo is authorized to run against systems outside the
  isolated lab AWS accounts described in `02-Cloud-Infrastructure.md`.
- Findings are inventory/simulation results against synthetic or
  self-owned lab data only, never claims of having decrypted real traffic.

**See also:** `03-Quantum-Computing-Framework.md` (algorithm detail),
`00-INDEX.md` (Genesis Mesh relation), `IMPLEMENTATION-STATUS.md` (build
status of the modules referenced above).
