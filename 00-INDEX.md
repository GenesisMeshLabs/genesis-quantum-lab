# META-QUANTUM-HARVEST: Complete Proposal

**Project:** meta-quantum-harvest  
**Purpose:** Secure cloud research platform for quantum computing and security research  
**Status:** Ready for stakeholder review

---

## Relation to Genesis Mesh

**meta-quantum-harvest is the next research phase of Genesis Mesh** — the sovereign trust, identity, and communication fabric for AI agents, edge systems, and distributed infrastructure that federates Network Authorities (e.g. MiraOS-NA, EPICAL-NA, USG) through recognition edges and treaties on the Sovereign Graph.

That federation model depends on classical public-key cryptography (RSA/ECDSA) to sign and verify recognition edges, NA identity attestations, and treaty records. Those same primitives are exactly what a sufficiently large quantum computer running Shor's algorithm would break — so before Genesis Mesh's trust fabric can be considered durable long-term infrastructure, its cryptographic foundations need to be tested against and eventually migrated toward NIST's post-quantum standards (FIPS 203/204/205).

This repository is where that research happens, in an isolated, lawful, lab-only AWS environment rather than against the live Genesis Mesh fabric:

- **Cryptographic inventory scanning** (`src/research/crypto_inventory`) — the same static-analysis technique Genesis Mesh's own NA signing code and treaty-record schemas will eventually need to be run against, to find every RSA/ECDSA/DH-based primitive that needs a PQC migration path.
- **Hybrid post-quantum key exchange** (`src/research/pqc_hybrid`) — real FIPS 203 ML-KEM-768 + classical X25519 hybrid key exchange, plus FIPS 204 ML-DSA-65 signatures, prototyping the exact pattern ("survive if either algorithm is broken") that recognition-edge signing would need if/when it's migrated.
- **Quantum algorithm demos** (`src/research/quantum_demo`) — hands-on, low-stakes familiarity with what quantum computers can and cannot currently do, so migration urgency is assessed from evidence rather than hype.
- **Hardened multi-account AWS reference architecture** (`src/terraform`) — the account segmentation, guardrails, immutable logging, and threat detection patterns here are also directly reusable for hardening the infrastructure behind the Sovereign Graph dashboard and other Genesis Mesh services.

In short: Genesis Mesh is the production trust fabric; meta-quantum-harvest is the sandboxed R&D arm validating what that fabric's cryptography needs to become.

---

## Documents (Read in Order)

1. **00-INDEX.md** ← You are here
2. **01-Executive-Summary.md** — Project overview, objectives, budget, timeline (START HERE)
3. **02-Cloud-Infrastructure.md** — Technical architecture and implementation
4. **03-Quantum-Computing-Framework.md** — Quantum research methodology and training
5. **04-Security-Policy.md** — Security standards, compliance, incident response
6. **05-Testing-Methodology.md** — Authorized testing framework and procedures
7. **06-Roadmap.md** — 12-month implementation plan
8. **07-Resource-Plan.md** — Budget, personnel, timeline
9. **08-Success-Metrics.md** — KPIs and measurement framework

---

## Quick Navigation by Role

**For Executives:**
→ Read: 01-Executive-Summary.md (15 min)  
→ Review: 06-Roadmap.md (10 min)  
→ Decide: Approve funding

**For Technical Teams:**
→ Read: 02-Cloud-Infrastructure.md (30 min)  
→ Review: Deployment checklist  
→ Implement: Follow architecture guide

**For Security/Compliance:**
→ Read: 04-Security-Policy.md (20 min)  
→ Review: Governance framework  
→ Establish: Security baselines

**For Researchers:**
→ Read: 03-Quantum-Computing-Framework.md (25 min)  
→ Review: 05-Testing-Methodology.md (20 min)  
→ Propose: Authorized experiments

---

## Project Summary

| Aspect | Detail |
|---|---|
| Name | meta-quantum-harvest |
| Purpose | Secure cloud research platform |
| Focus | Quantum computing, post-quantum cryptography, cloud security |
| Scope | Lab-only (no external targets) |
| Budget Y1 | €45–70K |
| Timeline | 12 months |
| Governance | Steering committee + security board |

---

## Core Principles

✅ **Authorized Only** — Lab infrastructure only  
✅ **Evidence-Based** — All activities logged  
✅ **Secure by Design** — Multi-layer security  
✅ **Transparent** — Clear governance & oversight  

---

Next: Read **01-Executive-Summary.md**
