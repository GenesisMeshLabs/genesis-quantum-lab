# QUANTUM COMPUTING RESEARCH FRAMEWORK

---

## Quantum Threat Timeline

| Period | Quantum Status | Cryptographic Risk | Action |
|---|---|---|---|
| 2026–2028 | Early systems (100–1000 qubits) | Theoretical threat | Begin assessment |
| 2028–2032 | NIST standards finalized, pilot systems | Medium threat | Deploy hybrid crypto |
| 2032–2040 | Fault-tolerant systems (millions of qubits) | Acute threat | Full migration complete |

---

## What Quantum Threatens

### Vulnerable (Shor's Algorithm)

- **RSA-2048** — Breakable by large quantum computer
- **ECDSA-256** — Breakable by large quantum computer
- **Diffie-Hellman key exchange** — Vulnerable
- **Digital signatures on RSA** — Vulnerable

**Timeline:** 3–5 years with mature quantum computer (not yet available)

### Safe (Grover's Algorithm)

- **AES-256** — Still secure (requires 2^128 operations)
- **SHA-3 hash functions** — Still secure
- **TLS 1.3 encryption** — Safe if key exchange replaced

---

## Post-Quantum Standards (NIST 2024)

### FIPS 203: Key Encapsulation (ML-KEM)

- **Standard:** ML-KEM (Kyber)
- **Mechanism:** Lattice-based key exchange
- **Performance:** 1000× faster than RSA
- **Use:** TLS key exchange, SSH

**Lab Exercise:** Hybrid TLS handshake (RSA + ML-KEM)

### FIPS 204: Digital Signature (ML-DSA)

- **Standard:** ML-DSA (Dilithium)
- **Use:** Code signing, certificates, JWT signing
- **Performance:** Comparable to RSA

**Lab Exercise:** Hybrid certificates (RSA + ML-DSA signatures)

### FIPS 205: Hash-Based Signatures (SLH-DSA)

- **Standard:** SPHINCS+
- **Use:** Long-term document signing
- **Performance:** Larger signatures (4K bytes)

---

## Research Modules

### Module 1: Quantum Algorithm Simulations

**Educational Demonstrations (No Real Decryption):**

```python
# Grover's Algorithm (Educational)
# Shows probability amplification concept
# Does NOT break real encryption

circuit.h(qubit_range)        # Superposition
apply_oracle(circuit)         # Mark solution
apply_diffusion(circuit)      # Amplify
result = measure(circuit)     # Extract answer
```

**What This Shows:**
- How quantum superposition works
- How amplitude amplification increases solution probability
- Why quantum computers useful for search

**What This Does NOT Show:**
- Practical breaking of real RSA or ECDSA
- Actual decryption of intercepted traffic
- Real quantum computer capabilities

### Module 2: Post-Quantum Cryptography Testing

```python
# Hybrid Key Exchange (ML-KEM + RSA)

# Classical: RSA-2048 key exchange
rsa_pubkey, rsa_privkey = rsa.generate_keypair(2048)

# Post-Quantum: ML-KEM key exchange
mlkem = ML_KEM_768()
mlkem_pubkey, mlkem_privkey = mlkem.generate_keypair()

# Hybrid: Both contribute to shared secret
hybrid_secret = combine(rsa_secret, mlkem_secret)

# Result: If either algorithm broken, session survives with other
print("Hybrid Protection: YES")
```

### Module 3: Cryptographic Inventory

Automated scan of all cryptographic assets in lab:

```
Inventory Results:
├── TLS Certificates: 45 (RSA-2048 → Hybrid by 2027)
├── JWT Signing: 12 (HMAC → Post-quantum by 2028)
├── Database Keys: 8 (AES-256 → Safe)
├── API Keys: 156 (Rotate, PQ-agnostic)
└── Risk Register: 65 items (prioritized for migration)
```

### Module 4: Migration Planning

**Phase 1 (2027):** Hybrid algorithms (RSA + ML-KEM)  
**Phase 2 (2028):** Post-quantum signatures (ML-DSA)  
**Phase 3 (2029):** Full transition (no RSA)  

**Cost/Effort:**
- Certificate authority upgrade: €50–100K
- Application updates: 200–400 hours
- Testing and validation: 100–200 hours
- Rollout period: 18–24 months

---

## Training Curriculum

### Level 1: Foundations (2 days)

- Quantum computing basics (qubits, superposition, entanglement)
- Quantum threats to RSA/ECDSA (Shor's algorithm overview)
- Post-quantum cryptography concepts
- NIST standards landscape
- Timeline and readiness assessment

### Level 2: Post-Quantum Algorithms (3 days)

- ML-KEM (key encapsulation mechanism)
- ML-DSA (digital signature algorithm)
- Performance characteristics and trade-offs
- Hybrid deployment strategies
- Implementation approaches

### Level 3: Lab Exercises (4 days)

- Deploy Braket quantum simulator
- Run Grover/Shor algorithm simulations
- Inventory cryptography in lab systems
- Test hybrid key exchange implementation
- Plan migration roadmap for lab systems

### Level 4: Research & Publication (ongoing)

- Design novel post-quantum protocols
- Contribute to standards feedback
- Publish findings and recommendations
- Present at security conferences
- Mentor other organizations

---

## Research Ethics & Boundaries

### Permitted ✅

- Quantum algorithm simulations using Braket/Qiskit
- Performance testing of post-quantum algorithms
- Cryptographic inventory of lab systems
- Migration planning and cost-benefit analysis
- Academic research and peer-reviewed publication

### Prohibited ❌

- Claiming practical quantum decryption of real TLS
- Testing against production systems
- Misrepresenting simulation results as real quantum capability
- Publishing algorithms that enable attacks on external systems

---

## Expected Findings

### Quantum Research Report (Month 4)

**Contents:**
- Quantum threat assessment for organization
- Post-quantum readiness checklist
- Cryptographic inventory (current state)
- Hybrid deployment timeline
- Recommended algorithm selection
- Cost-benefit analysis
- Vendor roadmap tracking

### Training Materials (Month 6)

- Curriculum modules (levels 1–4)
- Lab exercise guides
- Braket simulator examples
- Cryptographic inventory tool (automated scanning)
- Migration planning templates

---

## Tools & Resources

**Educational Simulators:**
- Amazon Braket (hosted quantum simulator)
- Qiskit (IBM open source quantum framework)
- Cirq (Google quantum framework)

**Post-Quantum Libraries:**
- liboqs (OpenQuantumSafe ML-KEM implementation)
- crystals-dilithium (ML-DSA reference)
- sphincsplus (SLH-DSA reference)

**Standards & References:**
- NIST Post-Quantum Cryptography project (https://csrc.nist.gov/projects/post-quantum-cryptography/)
- FIPS 203, 204, 205 (finalized August 2024)
- Open Quantum Safe project (https://openquantumsafe.org/)

---

**See also:** 06-Roadmap.md (implementation timeline), 05-Testing-Methodology.md (authorized lab procedures)
