## meta-quantum-harvest Project

---

## Relation to Genesis Mesh

**meta-quantum-harvest is the next research phase of Genesis Mesh** — the
sovereign trust, identity, and communication fabric for AI agents, edge
systems, and distributed infrastructure that federates Network Authorities
through recognition edges and treaties on the Sovereign Graph.

That federation model relies on classical public-key cryptography
(RSA/ECDSA) to sign and verify recognition edges, NA identity attestations,
and treaty records — exactly what a sufficiently large quantum computer
running Shor's algorithm would break. This repository is the isolated,
lab-only environment where the post-quantum migration path for that trust
fabric is researched and validated (cryptographic inventory scanning,
hybrid PQC key exchange, and a hardened multi-account AWS reference
architecture reusable for the Sovereign Graph infrastructure) before it's
proposed for the live fabric. See `00-INDEX.md` for the full breakdown and
`src/docs/THREAT-MODEL.md` for the specific threat this work addresses.

---

## The Need

Organizations face emerging threats from quantum computing to current cryptography (RSA, ECDSA). Simultaneously, NIST has standardized post-quantum algorithms (ML-KEM, ML-DSA) beginning 2024. Preparation requires:

- Understanding quantum threats through hands-on research
- Evaluating post-quantum cryptographic alternatives  
- Building in-house cloud security and incident response expertise
- Conducting controlled security research

**meta-quantum-harvest** delivers all four through a single integrated platform.

---

## What We're Building

A secure, isolated cloud research environment enabling:

1. **Quantum Computing Education** — Understand quantum algorithms and threats (via simulators)
2. **Cryptographic Evaluation** — Test post-quantum standards and develop migration plans
3. **Security Research** — Authorized penetration testing and attack simulations
4. **Detection Engineering** — Develop and validate threat detection rules
5. **Incident Response Training** — Tabletop exercises and response validation

---

## Scope & Boundaries

### Included ✅
- Secure multi-account cloud infrastructure
- Quantum simulator (educational demonstrations)
- Post-quantum cryptography testing
- Security policy and governance
- Authorized testing methodology
- Team training and certification
- Final recommendations

### Not Included ❌
- Production system testing
- External organization targeting
- Real quantum computer access
- Unauthorized research
