#!/usr/bin/env python3
"""
Hybrid post-quantum key exchange & signatures — Phase 3 Research Module 2/4.
Ref: 03-Quantum-Computing-Framework.md "Module 2: Post-Quantum Cryptography
Testing" and "Post-Quantum Standards (NIST 2024)".

Implements real, standards-compliant primitives (not a simulation):
  - FIPS 203 ML-KEM-768 (Kyber)  — key encapsulation, via `kyber-py`
  - FIPS 204 ML-DSA-65 (Dilithium) — digital signatures, via `dilithium-py`
  - Classical X25519 ECDH, via `cryptography`

Hybrid key exchange combines a classical ECDH shared secret with an ML-KEM
shared secret through HKDF, matching the "Result: If either algorithm
broken, session survives with other" property described in the framework
doc. This is the recommended Phase 1 (2027) migration step from
03-Quantum-Computing-Framework.md "Module 4: Migration Planning".

Usage:
    pip install -r requirements.txt
    python hybrid_kem_demo.py
"""
from __future__ import annotations

import hashlib

from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.asymmetric.x25519 import X25519PrivateKey
from cryptography.hazmat.primitives.kdf.hkdf import HKDF
from dilithium_py.ml_dsa import ML_DSA_65
from kyber_py.ml_kem import ML_KEM_768


def classical_ecdh() -> tuple[bytes, bytes, bytes]:
    """Simulates two parties (Alice/Bob) doing classical X25519 ECDH.
    Returns (alice_secret, bob_secret, description) — both should match."""
    alice_priv = X25519PrivateKey.generate()
    bob_priv = X25519PrivateKey.generate()

    alice_shared = alice_priv.exchange(bob_priv.public_key())
    bob_shared = bob_priv.exchange(alice_priv.public_key())
    return alice_shared, bob_shared, "X25519 (classical, Shor-vulnerable)"


def ml_kem_exchange() -> tuple[bytes, bytes, bytes]:
    """Alice generates an ML-KEM-768 keypair; Bob encapsulates a shared
    secret against Alice's public key; Alice decapsulates it. Both should
    match, and neither classical nor quantum adversaries can derive it
    without Alice's private key (Kyber's security relies on lattice
    problems believed hard even for quantum computers)."""
    alice_ek, alice_dk = ML_KEM_768.keygen()
    bob_shared, ciphertext = ML_KEM_768.encaps(alice_ek)
    alice_shared = ML_KEM_768.decaps(alice_dk, ciphertext)
    return alice_shared, bob_shared, "ML-KEM-768 / FIPS 203 (post-quantum)"


def combine_hybrid(classical_secret: bytes, pq_secret: bytes) -> bytes:
    """HKDF-combine both secrets into one session key. Session remains
    secure as long as at least ONE of the two algorithms remains unbroken —
    the hybrid-deployment property called for in the framework doc."""
    hkdf = HKDF(algorithm=hashes.SHA384(), length=32, salt=None, info=b"meta-quantum-harvest hybrid v1")
    return hkdf.derive(classical_secret + pq_secret)


def ml_dsa_signature_demo(message: bytes) -> bool:
    """FIPS 204 ML-DSA-65 (Dilithium) signature — the recommended
    replacement for RSA/ECDSA code signing and JWT signing per
    03-Quantum-Computing-Framework.md 'FIPS 204'."""
    public_key, secret_key = ML_DSA_65.keygen()
    signature = ML_DSA_65.sign(secret_key, message)
    return ML_DSA_65.verify(public_key, message, signature)


def main():
    print("=== Classical ECDH (X25519) ===")
    a_classical, b_classical, classical_label = classical_ecdh()
    print(f"  {classical_label}")
    print(f"  Shared secrets match: {a_classical == b_classical} ({len(a_classical)} bytes)")

    print("\n=== Post-Quantum KEM (ML-KEM-768 / Kyber) ===")
    a_pq, b_pq, pq_label = ml_kem_exchange()
    print(f"  {pq_label}")
    print(f"  Shared secrets match: {a_pq == b_pq} ({len(a_pq)} bytes)")

    print("\n=== Hybrid combination (HKDF over both secrets) ===")
    hybrid_alice = combine_hybrid(a_classical, a_pq)
    hybrid_bob = combine_hybrid(b_classical, b_pq)
    print(f"  Hybrid session keys match: {hybrid_alice == hybrid_bob}")
    print(f"  Hybrid session key (sha256 fingerprint): {hashlib.sha256(hybrid_alice).hexdigest()}")
    print("  Protection: if X25519 OR ML-KEM-768 is broken, the other still protects the session.")

    print("\n=== Post-Quantum signatures (ML-DSA-65 / Dilithium) ===")
    verified = ml_dsa_signature_demo(b"meta-quantum-harvest lab artifact")
    print(f"  Signature verified: {verified}")

    print("\nNote: this exercises real NIST-standardized primitives on synthetic")
    print("session data only. It performs no interception of real traffic and")
    print("makes no claim about breaking any deployed cryptography — see")
    print("03-Quantum-Computing-Framework.md 'Research Ethics & Boundaries'.")


if __name__ == "__main__":
    main()
