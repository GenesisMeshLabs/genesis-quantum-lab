# CLOUD INFRASTRUCTURE ARCHITECTURE

---

## Account Structure

```
Organization (meta-quantum-harvest)
├── Management Account — Billing, SCPs, guardrails
├── Security Account — Centralized logging, detection, evidence
├── Network Account — VPC, Transit Gateway, network controls
├── Research Account A — Experiment environment 1
├── Research Account B — Experiment environment 2
└── Sandbox Account — Intentionally vulnerable workloads (red team target)
```

---

## Network Design

### VPC Topology (per research account)

```
VPC (10.0.0.0/16)
├── Public: NAT Gateway, ALB (lab-only endpoints)
├── Private: EC2, RDS, Lambda (research workloads)
├── Inspection: Network Firewall (all traffic logged)
└── Management: Systems Manager, VPC endpoints
```

### Controls

- **Ingress:** ALB only (HTTP/HTTPS), WAF blocking, no direct SSH
- **Egress:** NAT Gateway (logged), VPC endpoints (no internet)
- **Cross-Account:** Transit Gateway hub (if needed), no direct peering

---

## Security Baseline

### Identity

- **IAM Identity Center** (centralized auth)
- **Roles:** Architect, Security Engineer, Researcher, Operations, Auditor
- **MFA Required** for all access
- **Session Duration:** 1 hour (max 4 hours)
- **Temporary Credentials** for all access (no long-lived API keys)

### Encryption

- **At Rest:** AES-256 (AWS KMS, organization-managed keys)
- **In Transit:** TLS 1.2+
- **Key Rotation:** Annual + manual on policy change

### Logging

```
All Activity → CloudTrail → S3 (Audit Bucket)
            ├── Immutable (Object Lock)
            ├── Encrypted (AWS KMS)
            └── 7-year retention
                ↓
            CloudWatch Logs
                ↓
            SIEM/Dashboard
```

### Monitoring

- **GuardDuty** — Continuous threat detection
- **Security Hub** — Consolidated findings
- **Config** — Configuration compliance
- **Custom Alerts** — Anomaly detection

---

## Service Approval

### Approved

- **Compute:** EC2, ECS/EKS, Lambda
- **Storage:** S3, EBS, EFS
- **Database:** RDS, DynamoDB, DocumentDB
- **Networking:** VPC, Security Groups, VPN
- **Security:** CloudTrail, KMS, Secrets Manager (mandatory)
- **Monitoring:** CloudWatch, GuardDuty, Config (mandatory)
- **Research:** Amazon Braket, SageMaker Notebooks, QuickSight

### Restricted (Approval Required)

- SageMaker, Bedrock, Rekognition, Comprehend
- QuickSight, Athena, Glue, EMR

### Prohibited

- Datasync, Transfer Family, AppStream

---

## Implementation Phases

### Phase 1: Foundation (Weeks 1–4)
- Create AWS Organization & accounts
- Apply Service Control Policies
- Set up IAM Identity Center
- Configure CloudTrail (all accounts)
- Deploy KMS keys

**Output:** Secure AWS foundation

### Phase 2: Lab Infrastructure (Weeks 5–8)
- Deploy VPC & network controls
- Configure GuardDuty, Security Hub
- Set up SIEM/CloudWatch dashboards
- Deploy VPC endpoints
- Test logging pipeline

**Output:** Operational research environment

### Phase 3: Lab Workloads (Weeks 9–12)
- Deploy synthetic applications
- Configure test databases
- Set up Braket quantum simulator
- Deploy SageMaker notebooks
- Validate security controls

**Output:** Research-ready lab

---

## Cost Estimates (Monthly)

| Service | Cost |
|---|---|
| VPC, NAT, ALB | €40–60 |
| EC2 compute | €500–700 |
| RDS database | €200–300 |
| S3, storage | €50–100 |
| Logging, monitoring | €100–150 |
| GuardDuty, Security Hub | €200–300 |
| KMS, Secrets Manager | €50–100 |
| **Total Monthly** | **€1,200–1,800** |

**Cost Controls:** Spot instances (40% savings), reserved instances (30% discount), intelligent tiering, resource cleanup

---

## Disaster Recovery

| Component | RTO | RPO |
|---|---|---|
| Audit logs | 0 min | 0 min (replicated) |
| Infrastructure | 1 hour | 0 (Infrastructure as Code) |
| Databases | 4 hours | 1 hour (daily backups) |
| Configs | 2 hours | 0 (Config snapshots) |

**Strategy:** Daily EBS snapshots, weekly cross-region replication, monthly DR drill

---

## Compliance

- **ISO 27001** — Information security management
- **NIST Framework** — Security baseline
- **SOC 2 Type II** — Service audit
- **Data Protection** — Data handling and retention

**Audit Trail:** CloudTrail (API), Config (resources), VPC Flow Logs (network), GuardDuty (threats)

---

## Deployment Checklist

- [ ] AWS Organization created
- [ ] Service Control Policies applied
- [ ] IAM Identity Center configured
- [ ] CloudTrail enabled (multi-region, multi-account)
- [ ] KMS keys created and tested
- [ ] S3 audit buckets with Object Lock
- [ ] VPC deployed with segmentation
- [ ] GuardDuty and Security Hub active
- [ ] Logging pipeline validated
- [ ] Access controls tested
- [ ] Backup/restore procedures validated
- [ ] Compliance baseline established
- [ ] Team trained on procedures

---

**See also:** 04-Security-Policy.md (policy standards), 05-Testing-Methodology.md (lab procedures)
