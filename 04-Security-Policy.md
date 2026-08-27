# SECURITY POLICY & GOVERNANCE

---

## Data Classification

| Level | Sensitivity | Handling |
|---|---|---|
| **Public** | No risk if disclosed | Standard encryption |
| **Internal** | Moderate | Encryption + access control |
| **Restricted** | High (PII, health data) | Strong encryption + audit logging |
| **Classified** | State secrets (if applicable) | HSM + compartmented access |

---

## Mandatory Controls

### Identity & Access

- **Centralized Identity** — AWS IAM Identity Center (federation with corporate identity)
- **MFA Required** — All human access (FIDO2 or TOTP)
- **Temporary Credentials** — No long-lived API keys (STS only)
- **Least Privilege** — Each role minimal permissions needed
- **Session Timeout** — 1 hour (max 4 hours for sensitive operations)
- **Break Glass** — Emergency admin access (logged, audited)

### Encryption

- **At Rest:** AES-256 (AWS KMS, organization-managed keys)
- **In Transit:** TLS 1.2+ (TLS 1.3 preferred)
- **Key Rotation:** Annual + manual on policy change
- **Hardware Backed:** HSM for classified systems (if applicable)

### Logging & Monitoring

- **CloudTrail** — All API calls (multi-region, immutable)
- **VPC Flow Logs** — All network activity
- **GuardDuty** — Continuous threat detection
- **Config** — Configuration compliance tracking
- **Retention** — Minimum 7 years (immutable storage)

### Incident Response

| Severity | Detection SLA | Response SLA |
|---|---|---|
| CRITICAL | 15 min | 30 min |
| HIGH | 30 min | 2 hours |
| MEDIUM | 4 hours | 8 hours |
| LOW | 24 hours | 5 business days |

**Escalation Chain:**
```
Detection → On-Call (15 min)
         → Incident Commander (30 min)
         → Cloud Lead + Security Lead (45 min)
         → Legal/Compliance (1 hour)
         → Project Sponsor (2 hours if CRITICAL)
```

---

## Data Handling

### Collection

- **Synthetic Data Preferred** — Lab uses generated test data, not real data
- **If Real Data Needed** — Data Protection Impact Assessment (DPIA) required before import
- **Personal Data Prohibited** — No citizen, employee, or customer data in lab
- **Third-Party Data** — Explicit written agreement before import

### Processing

- **Lab-Only** — Data never leaves authorized accounts
- **Encryption Mandatory** — All data at rest encrypted
- **Access Logging** — All access logged to immutable audit trail
- **Retention** — Data deleted after experiment (documented, verified)

### Deletion

- **Expiration Date** — Each dataset has documented retention period
- **Cryptographic Erasure** — Data overwritten at OS level
- **Verification** — Integrity check confirms deletion
- **Compliance Review** — Legal confirms deletion before verification

---

## Incident Response Procedures

### Detection

**Automated:**
- GuardDuty findings → Email alert to on-call
- Config violations → SNS notification
- CloudWatch anomalies → PagerDuty escalation

**Manual:**
- Security team review of logs (daily)
- Quarterly configuration audit
- Annual penetration testing

### Investigation

1. **Isolation** — Quarantine affected resource (security group/network ACL)
2. **Snapshot** — Capture system state (EBS snapshot, memory dump if possible)
3. **Logs** — Export CloudTrail, VPC Flow Logs, application logs
4. **Forensics** — Analyze evidence in isolated sandbox account
5. **Timeline** — Build attack timeline from logs
6. **Impact** — Determine what attacker accessed/modified

### Remediation

1. **Eradication** — Remove attacker access (revoke credentials, patch vulnerability)
2. **Recovery** — Restore from clean backups if needed
3. **Verification** — Confirm attacker cannot re-enter (test with red team if appropriate)
4. **Hardening** — Implement controls to prevent recurrence

### Communication

- **Internal** — Brief security team and project lead immediately
- **External** — Prepare incident report (if disclosure required)
- **Timeline** — 72-hour disclosure if personal data involved
- **Stakeholders** — Notify steering committee (quarterly review)

---

## Compliance Frameworks

### Mapped Standards

| Framework | Requirement | Mapping |
|---|---|---|
| ISO 27001 | Access Control | IAM Identity Center + MFA |
| ISO 27001 | Encryption | AES-256 (KMS) + TLS 1.2+ |
| ISO 27001 | Audit Logging | CloudTrail + immutable S3 |
| ISO 27001 | Incident Response | Documented procedures, drills |
| NIST CSF | Identify | Asset inventory, Config tracking |
| NIST CSF | Protect | IAM, encryption, network segmentation |
| NIST CSF | Detect | GuardDuty, Security Hub, monitoring |
| NIST CSF | Respond | Incident playbooks, escalation procedures |
| Data Protection | Personal Data | Synthetic data only, DPIA required |
| Data Protection | Right to Audit | Cloud provider audit trails available |

---

## Governance Roles

### Steering Committee (Quarterly)

**Members:** Project Sponsor, CTO/Security Lead, Legal, Finance  
**Authority:** Budget, strategic decisions, risk escalation  
**Frequency:** Quarterly

### Security Board (Monthly)

**Members:** Security Lead, Cloud Lead, Compliance Officer  
**Authority:** Policy decisions, test authorization, incident review  
**Frequency:** Monthly

### Architecture Review (Weekly)

**Members:** Cloud Architect, Tech Leads, Security Engineer  
**Authority:** Design approval, technical feasibility, resource allocation  
**Frequency:** Weekly

---

## Policy Review Cycle

- **Quarterly:** Threat landscape update, tool updates
- **Semi-annually:** Compliance assessment, control effectiveness
- **Annually:** Full policy review, standards update
- **As-needed:** Incident-driven updates

---

## Compliance Checklist

- [ ] All workloads in authorized accounts only
- [ ] CloudTrail enabled (multi-region)
- [ ] Encryption at rest (AES-256, KMS)
- [ ] TLS 1.2+ for all traffic
- [ ] IAM Identity Center configured
- [ ] MFA enabled for all users
- [ ] GuardDuty active
- [ ] Network segmentation implemented
- [ ] Annual audit scheduled
- [ ] Incident response procedures documented
- [ ] Training completed (all staff)
- [ ] Data handling policy acknowledged

---

**See also:** 02-Cloud-Infrastructure.md (technical controls), 05-Testing-Methodology.md (authorized testing), 06-Roadmap.md (implementation timeline)
