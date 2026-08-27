# RESOURCE PLAN & BUDGET

---

## Personnel Requirements

### Year 1 (Full Team)

| Role | Count | Monthly | Annual | Responsibilities |
|---|---|---|---|---|
| Cloud Platform Lead | 1 | €6K–8K | €72–96K | AWS architecture, account management, guardrails |
| Security Engineer | 1 | €5K–7K | €60–84K | Detection, incident response, testing |
| Quantum Researcher | 1 | €4K–6K | €48–72K | Research design, training, reporting |
| Security Operations | 0.5 | €2K–3K | €24–36K | Monitoring, log management, compliance |
| Project Manager | 0.5 | €3K–4K | €36–48K | Coordination, reporting, stakeholder management |
| **Total Personnel** | **4 FTE** | **€20–28K** | **€240–336K** |

### Year 2+ (Reduced Team)

| Role | Count | Responsibilities |
|---|---|---|
| Cloud Platform Lead | 1 | Ongoing management, optimization |
| Security Engineer | 0.5 | Detection tuning, incident response |
| Operations | 1 | Monitoring, maintenance, procedures |
| **Total** | **2.5 FTE** | **€120–180K/year** |

---

## Infrastructure Costs

### Year 1 (Startup + Operations)

| Service | Monthly | Annual | Notes |
|---|---|---|---|
| VPC, NAT, ALB | €40–60 | €480–720 | Networking baseline |
| EC2 compute | €500–700 | €6,000–8,400 | Research workloads, Braket |
| RDS database | €200–300 | €2,400–3,600 | Test databases |
| S3, storage | €50–100 | €600–1,200 | Audit logs, snapshots, archives |
| Logging/Monitoring | €100–150 | €1,200–1,800 | CloudTrail, CloudWatch, Config |
| GuardDuty, Security Hub | €200–300 | €2,400–3,600 | Threat detection |
| KMS, Secrets Manager | €50–100 | €600–1,200 | Encryption, key management |
| Data transfer | €20–40 | €240–480 | Cross-region replication |
| **Total Infrastructure** | **€1,160–1,750** | **€13,920–20,700** |

### Year 2+ (Operational)

**Monthly:** €1,000–1,500 (mature state, optimized costs)  
**Annual:** €12,000–18,000

---

## Software & Services

### Licenses (One-Time & Annual)

| Software | Cost | Frequency | Purpose |
|---|---|---|---|
| Nessus Pro | €2,000 | Annual | Vulnerability scanning |
| Burp Suite Pro | €500 | Annual | Web app testing |
| Qualys | €3,000 | Annual | Compliance scanning |
| AWS Professional Services | €10,000–20,000 | One-time | Migration planning consultation |
| Third-party Audit (SOC 2) | €5,000–10,000 | Annual | Security audit |
| **Total Year 1** | **€20,500–35,500** |

---

## Training & Development

### Curriculum Development

| Item | Cost | Timeline |
|---|---|---|
| Training content creation | €5,000–10,000 | Months 5–6 |
| Instructor certification | €2,000–5,000 | Month 7 |
| Lab exercise guides | €3,000–5,000 | Months 5–6 |
| **Total Training** | **€10,000–20,000** |

---

## Budget Summary

### Year 1 Total Investment

| Category | Cost |
|---|---|
| Personnel | €240–336K |
| Infrastructure | €14–21K |
| Software/Services | €21–36K |
| Training/Development | €10–20K |
| Contingency (10%) | €29–41K |
| **Total Year 1** | **€314–454K** |

**Typical Range:** €350–400K (mid-point estimate)

### Year 2+ Annual Operating Cost

| Category | Cost |
|---|---|
| Personnel | €120–180K |
| Infrastructure | €12–18K |
| Software/Services | €10–15K |
| Training/Maintenance | €5–10K |
| Contingency (10%) | €15–22K |
| **Total Year 2+** | **€162–245K/year** |

**Typical Range:** €180–220K (mid-point estimate)

---

## Procurement Timeline

### Phase 1: Immediate (Week 1)
- **Action:** Approve budget, hire cloud lead
- **Cost:** €5–8K (recruitment)

### Phase 2: Month 1–2 (Week 3)
- **Action:** Hire remaining team (security engineer, researcher)
- **Cost:** €10–15K (recruitment, onboarding)

### Phase 3: Month 2–3 (Week 9)
- **Action:** Procure security audit vendor
- **Cost:** €5–10K (paid upfront)

### Phase 4: Month 3–4 (Week 17)
- **Action:** Software licenses (Nessus, Burp, Qualys)
- **Cost:** €5–8K (annual subscriptions)

### Phase 5: Ongoing (Each Month)
- **Action:** AWS infrastructure costs
- **Cost:** €1,200–1,800/month (automated billing)

---

## Cost Controls & Optimization

### Infrastructure Optimization

**Spot Instances**
- Use Spot EC2 for batch workloads
- Savings: 40–60% vs. on-demand
- Applies to: Research compute, temporary testing
- Expected monthly savings: €100–200

**Reserved Instances**
- Baseline compute (always-on workloads)
- Savings: 30% vs. on-demand
- 1-year commitment recommended
- Expected monthly savings: €150–200

**Automated Cleanup**
- Terminate non-research EC2 instances after experiments
- Delete unused EBS snapshots after 30 days
- Archive S3 objects to Glacier after 90 days
- Expected monthly savings: €50–100

**Capacity Planning**
- Right-size RDS instances (not overprovisioned)
- Use RDS Auto Scaling for variable workloads
- Turn off non-production workloads outside business hours
- Expected monthly savings: €100–150

### Total Potential Monthly Savings: €400–650 (30% reduction)

---

## Budget Approval Process

### Steering Committee Gate (Month 1)

Approval required for:
- [ ] Year 1 budget (€314–454K)
- [ ] Personnel hiring
- [ ] AWS account provisioning
- [ ] Procurement plan

### Monthly Tracking (Months 2–12)

- Budget variance report (actual vs. forecast)
- Cost optimization review
- Forecasting and adjustments
- Steering committee notification of significant variances (>10%)

### Annual Review (Month 13)

- Full year actuals vs. budget
- Lessons learned
- Year 2 budget proposal
- Optimization recommendations

---

## ROI Analysis

### Investment (Year 1)

**Direct Cost:** €350–400K  
**Opportunity Cost (if built externally):** €500K–1M  
**Total First-Year Investment:** €350–400K

### Returns

**Avoided Incident Costs:**
- Prevented breach: €100K–€1M saved (reduced risk)
- Avoided ransomware: €500K–€5M saved (preparedness)
- Faster incident response: €50K–€200K saved (improved SLA)

**Operational Benefits:**
- In-house expertise (vs. expensive consultants): €200–400K/year
- Reduced cryptographic obsolescence risk: €1–5M avoided
- Training ROI: One certification worth €10–20K per person

**Strategic Benefits:**
- Security-first culture (immeasurable)
- Competitive advantage (immeasurable)
- Regulatory compliance (reduces audit costs)

### ROI Timeline

| Year | Investment | Returns | Net |
|---|---|---|---|
| Year 1 | €350–400K | €100–300K | -€200–250K |
| Year 2 | €180–220K | €300–600K | +€120–420K |
| Year 3 | €180–220K | €300–600K | +€120–420K |
| **3-Year Total** | **€710–840K** | **€700–1,500K** | **-€10K to +€790K** |

**ROI Payback:** 1.5–2 years (if incident prevented)

---

## Headcount Growth

### Year 1 Plan

- Month 1: Cloud Lead hired
- Month 1–2: Security Engineer, Researcher, PM hired
- Month 6: Trainers added (contract basis)

**Peak:** 4 FTE + 0.5 FTE contractors

### Year 2 Plan

- Core team maintained (3 FTE)
- Operations specialist added (0.5 FTE permanent)
- Training/support rotated (0.5 FTE part-time)

**Baseline:** 2.5–3 FTE

---

**See also:** 06-Roadmap.md (timeline), 08-Success-Metrics.md (measurement framework)
