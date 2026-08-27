#!/usr/bin/env python3
"""
Cryptographic inventory scanner — Phase 3 Research Module 3.
Ref: 03-Quantum-Computing-Framework.md "Module 3: Cryptographic Inventory",
     04-Security-Policy.md (data classification / audit trail).

Purpose (defensive only): walk a directory tree that you own or are
authorized to assess (e.g. a checked-out copy of your own lab systems) and
build a risk register of cryptographic assets that would be affected by a
future "harvest now, decrypt later" quantum attack against RSA/ECDSA/DH —
per the quantum threat timeline in 03-Quantum-Computing-Framework.md. This
performs no network access, exploitation, or decryption; it only reads and
classifies files you point it at.

Usage:
    python scan_inventory.py /path/to/lab/checkout --out inventory-report.json

Detects:
  - X.509 certificates (.pem/.crt/.cer) -> key algorithm + size via `cryptography`
  - PEM/DER private/public key files -> key algorithm + size
  - Source-code crypto usage patterns (RSA/ECDSA/DH key generation, JWT
    signing algorithms, TLS config hints) via lightweight static regex scan
"""
from __future__ import annotations

import argparse
import json
import re
import sys
from dataclasses import asdict, dataclass, field
from datetime import datetime, timezone
from pathlib import Path

try:
    from cryptography import x509
    from cryptography.hazmat.backends import default_backend
    from cryptography.hazmat.primitives import serialization
    from cryptography.hazmat.primitives.asymmetric import dsa, ec, rsa
except ImportError:  # pragma: no cover
    print("Install dependencies first: pip install -r requirements.txt", file=sys.stderr)
    raise

CERT_EXTENSIONS = {".pem", ".crt", ".cer", ".cert"}
KEY_EXTENSIONS = {".pem", ".key", ".pk8", ".der"}

# Quantum risk per 03-Quantum-Computing-Framework.md:
#  - RSA / ECDSA / DH key exchange & signatures -> broken by Shor's algorithm
#  - AES / SHA-3 (symmetric) -> unaffected, safe
SHOR_VULNERABLE_ALGOS = {"RSA", "ECDSA", "EC", "DSA", "DH"}

CODE_PATTERNS = [
    ("rsa_keygen", re.compile(r"rsa\.generate_private_key|RSA\.generate\(|generateKeyPair.*RSA", re.I)),
    ("ecdsa_keygen", re.compile(r"ec\.generate_private_key|ECDSA|SigningKey\.generate", re.I)),
    ("dh_keyexchange", re.compile(r"dh\.generate_parameters|DiffieHellman", re.I)),
    ("jwt_hs_rs", re.compile(r"algorithm\s*=\s*[\"'](HS256|HS384|HS512|RS256|RS384|RS512|ES256)[\"']", re.I)),
    ("tls_min_version", re.compile(r"TLSv1(_0|_1)?\b|ssl\.PROTOCOL_TLSv1\b", re.I)),
    ("hardcoded_secret", re.compile(r"(api[_-]?key|secret|password)\s*=\s*[\"'][^\"']{8,}[\"']", re.I)),
]

CODE_EXTENSIONS = {".py", ".js", ".ts", ".go", ".java", ".rb", ".php", ".yaml", ".yml", ".json", ".tf"}


@dataclass
class Finding:
    path: str
    kind: str  # "certificate" | "key" | "code_pattern"
    algorithm: str | None = None
    key_size: int | None = None
    quantum_vulnerable: bool = False
    detail: str = ""
    recommended_action: str = ""


@dataclass
class InventoryReport:
    generated_at: str
    scanned_root: str
    findings: list = field(default_factory=list)
    summary: dict = field(default_factory=dict)


def classify_public_key(pubkey) -> tuple[str, int | None]:
    if isinstance(pubkey, rsa.RSAPublicKey):
        return "RSA", pubkey.key_size
    if isinstance(pubkey, ec.EllipticCurvePublicKey):
        return "ECDSA", pubkey.key_size
    if isinstance(pubkey, dsa.DSAPublicKey):
        return "DSA", pubkey.key_size
    return type(pubkey).__name__, None


def recommendation_for(algorithm: str) -> str:
    if algorithm in SHOR_VULNERABLE_ALGOS:
        return "Migrate to hybrid classical+PQC (ML-KEM for exchange, ML-DSA for signatures) per 03-Quantum-Computing-Framework.md Module 4"
    return "No action required (Grover-resistant symmetric primitive)"


def scan_certificate(path: Path) -> Finding | None:
    try:
        data = path.read_bytes()
        cert = None
        for loader in (x509.load_pem_x509_certificate, x509.load_der_x509_certificate):
            try:
                cert = loader(data, default_backend())
                break
            except Exception:
                continue
        if cert is None:
            return None
        algo, size = classify_public_key(cert.public_key())
        vulnerable = algo in SHOR_VULNERABLE_ALGOS
        return Finding(
            path=str(path),
            kind="certificate",
            algorithm=algo,
            key_size=size,
            quantum_vulnerable=vulnerable,
            detail=f"subject={cert.subject.rfc4514_string()}, not_after={cert.not_valid_after_utc.isoformat()}",
            recommended_action=recommendation_for(algo),
        )
    except Exception:
        return None


def scan_key_file(path: Path) -> Finding | None:
    try:
        data = path.read_bytes()
        for loader_name, loader in (
            ("pem_private", serialization.load_pem_private_key),
            ("der_private", serialization.load_der_private_key),
        ):
            try:
                key = loader(data, password=None, backend=default_backend())
                algo, size = classify_public_key(key.public_key())
                vulnerable = algo in SHOR_VULNERABLE_ALGOS
                return Finding(
                    path=str(path),
                    kind="key",
                    algorithm=algo,
                    key_size=size,
                    quantum_vulnerable=vulnerable,
                    detail=f"loader={loader_name}",
                    recommended_action=recommendation_for(algo),
                )
            except Exception:
                continue
        for loader_name, loader in (
            ("pem_public", serialization.load_pem_public_key),
            ("der_public", serialization.load_der_public_key),
        ):
            try:
                pubkey = loader(data, backend=default_backend())
                algo, size = classify_public_key(pubkey)
                vulnerable = algo in SHOR_VULNERABLE_ALGOS
                return Finding(
                    path=str(path),
                    kind="key",
                    algorithm=algo,
                    key_size=size,
                    quantum_vulnerable=vulnerable,
                    detail=f"loader={loader_name}",
                    recommended_action=recommendation_for(algo),
                )
            except Exception:
                continue
    except Exception:
        return None
    return None


def scan_code_file(path: Path) -> list[Finding]:
    findings = []
    try:
        text = path.read_text(errors="ignore")
    except Exception:
        return findings
    for label, pattern in CODE_PATTERNS:
        for match in pattern.finditer(text):
            line_no = text.count("\n", 0, match.start()) + 1
            findings.append(
                Finding(
                    path=f"{path}:{line_no}",
                    kind="code_pattern",
                    algorithm=label,
                    quantum_vulnerable=label in ("rsa_keygen", "ecdsa_keygen", "dh_keyexchange"),
                    detail=match.group(0)[:120],
                    recommended_action=(
                        "Review for PQC migration path"
                        if label in ("rsa_keygen", "ecdsa_keygen", "dh_keyexchange", "jwt_hs_rs")
                        else "Review for hardening (TLS min version / hardcoded secret)"
                    ),
                )
            )
    return findings


def run_scan(root: Path) -> InventoryReport:
    findings: list[Finding] = []
    for p in root.rglob("*"):
        if not p.is_file():
            continue
        suffix = p.suffix.lower()
        if suffix in CERT_EXTENSIONS:
            f = scan_certificate(p)
            if f:
                findings.append(f)
                continue
        if suffix in KEY_EXTENSIONS:
            f = scan_key_file(p)
            if f:
                findings.append(f)
                continue
        if suffix in CODE_EXTENSIONS:
            findings.extend(scan_code_file(p))

    vulnerable_count = sum(1 for f in findings if f.quantum_vulnerable)
    by_algo: dict[str, int] = {}
    for f in findings:
        key = f.algorithm or "unknown"
        by_algo[key] = by_algo.get(key, 0) + 1

    return InventoryReport(
        generated_at=datetime.now(timezone.utc).isoformat(),
        scanned_root=str(root),
        findings=[asdict(f) for f in findings],
        summary={
            "total_findings": len(findings),
            "quantum_vulnerable_findings": vulnerable_count,
            "by_algorithm_or_pattern": by_algo,
        },
    )


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("root", type=Path, help="Directory to scan (must be authorized lab infrastructure you own).")
    parser.add_argument("--out", type=Path, default=Path("inventory-report.json"), help="Output JSON report path.")
    args = parser.parse_args()

    if not args.root.exists():
        print(f"Path does not exist: {args.root}", file=sys.stderr)
        sys.exit(1)

    report = run_scan(args.root)
    args.out.write_text(json.dumps(asdict(report), indent=2))

    print(f"Scanned: {report.scanned_root}")
    print(f"Total findings: {report.summary['total_findings']}")
    print(f"Quantum-vulnerable (Shor-breakable) findings: {report.summary['quantum_vulnerable_findings']}")
    print(f"By algorithm/pattern: {report.summary['by_algorithm_or_pattern']}")
    print(f"Full report written to: {args.out}")


if __name__ == "__main__":
    main()
