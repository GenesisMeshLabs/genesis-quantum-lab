# AUTHORIZED TESTING METHODOLOGY

---

## Core Principle

**All security testing occurs ONLY within authorized lab infrastructure.**

✅ **Permitted:** Lab accounts, sandbox workloads, controlled experiments  
❌ **Prohibited:** Production systems, external targets, unauthorized research

---

## Authorization Process

### Experiment Approval Form

Required for every test:

```
EXPERIMENT APPROVAL FORM
Date: [YYYY-MM-DD]
Experiment Name: [Title]
Owner: [Name, Email]
Duration: [Start] to [End]

OBJECTIVE
Purpose: [Why this test matters]
Expected Outcome: [Findings, detection rules, lessons learned]

SCOPE
Authorized Accounts: [List by ID]
Authorized Resources: [EC2, RDS, etc. by name]
Time Window: [When allowed to test]
Restrictions: [What's NOT allowed]

RISKS & MITIGATIONS
Risk 1: [Description]
  └─ Mitigation: [How to prevent/manage]

APPROVALS
[ ] Research Lead
[ ] Security Lead
[ ] Cloud Lead
[ ] Legal/Compliance
[ ] Project Sponsor

EVIDENCE TRACKING
S3 Bucket: [s3://...]
Retention: [7 years, immutable]
```

**Validity:** Test date/time and scope only. Authorization cannot be reused or extended without new approval.

---

## Testing Phases

### Phase 1: Reconnaissance (Authorized Lab Only)

**Allowed:**
- AWS API queries (describe-instances, list-roles, etc.)
- Port scanning within authorized VPC (10.0.0.0/16)
- Network topology analysis
- CloudTrail log review
- IAM permission simulation

**Prohibited:**
- Social engineering
- External IP scanning
- Targeting production systems
- Unauthorized network access

**Tools:** AWS CLI, nmap (restricted range), Cloud Mapper

### Phase 2: Vulnerability Discovery (Lab Only)

**Allowed:**
- Run vulnerability scanners (Nessus, Qualys)
- Exploit known CVEs in lab systems
- Test misconfigurations (public S3, open security groups)
- Fuzz APIs
- Password spray lab accounts

**Prohibited:**
- Exploit zero-days
- Extended system downtime
- Bypass audit controls

**Tools:** Burp Suite, OWASP ZAP, Metasploit (approved modules)

### Phase 3: Exploitation (Sandbox Account)

**Allowed:**
- Exploit identified vulnerabilities
- Gain shell access to lab systems
- Escalate privileges within lab
- Access lab databases
- Pivot between lab systems
- Steal lab credentials

**Prohibited:**
- Target production systems
- Real data exfiltration
- Bypass CloudTrail/Config logging

### Phase 4: Detection Validation

**Objective:** Validate that detection systems catch the attack

**Tests:**
- Did GuardDuty detect unauthorized access?
- Did CloudTrail log all suspicious API calls?
- Did VPC Flow Logs capture network anomalies?
- What was detection latency?

**Success:** Attack logged within 15 minutes, response procedures triggered

---

## Red Team vs. Blue Team Exercises

### Red Team (Attackers)

**Role:** Discover vulnerabilities and attack paths within authorized scope  
**Approved Techniques:** Privilege escalation, lateral movement, persistence (lab-only)  
**Output:** Attack report, exploitation techniques, impact assessment

### Blue Team (Defenders)

**Role:** Monitor, detect, and respond to red team activity  
**Activities:** 24/7 monitoring, alert generation, containment, communication  
**Output:** Detection metrics, response times, lessons learned

### Quarterly Exercise Schedule

**Typical Exercise (8 hours):**

```
09:00 - Red team authorization, briefing
09:15 - Reconnaissance begins
10:00 - Vulnerability identified
10:30 - Exploitation begins
11:00 - GuardDuty detection trigger
11:30 - Blue team alert
12:00 - Containment action
12:30 - Red team access cut
13:00 - Forensics and analysis
16:00 - Report generation
17:00 - Debrief and lessons learned
```

---

## Testing Scenarios

### Scenario 1: Leaked Credentials

**Objective:** Validate detection of compromised database credentials

**Test Steps:**
1. Obtain lab RDS credentials (intentionally leaked in test)
2. Connect to database from unexpected location
3. Query sensitive test data
4. Monitor detection (CloudTrail, VPC Flow Logs)

**Success Criteria:** Detection within 15 minutes, incident response triggered

### Scenario 2: Privilege Escalation

**Objective:** Detect unauthorized role assumption

**Test Steps:**
1. Start as regular researcher IAM user
2. Attempt to assume higher-privilege role
3. Create new IAM user with admin permissions
4. Execute privileged API calls

**Success Criteria:** CloudTrail logs all API calls, Config detects policy changes, alert generated

### Scenario 3: Data Exfiltration

**Objective:** Detect unusual data access patterns

**Test Steps:**
1. Download large S3 objects (simulating data theft)
2. Monitor egress volume
3. Check for network anomalies

**Success Criteria:** VPC Flow Logs capture unusual egress, CloudWatch metric triggers

---

## Tools & Technologies

### Approved

| Category | Tools | License |
|---|---|---|
| Vulnerability Scanning | Nessus, Qualys | Commercial |
| Web App Testing | Burp Suite, OWASP ZAP | Commercial/OSS |
| Network Scanning | Nmap | OSS |
| Exploitation | Metasploit | OSS |
| Forensics | Volatility, Sleuthkit | OSS |
| Cryptanalysis | Hashcat, John | OSS |

### Tool Review

**For custom or new tools:**
1. Submit tool + source code to security lead
2. Risk assessment (capabilities, blast radius)
3. Security review (malware scan, code review)
4. Sandbox testing (does it work as intended?)
5. Approval decision

---

## Evidence & Chain of Custody

### Evidence Preservation

```
S3 Bucket: playground-evidence-[account-id]
└── Experiment: exp-0001-privilege-escalation
    ├── cloudtrail-events/ (signed, immutable)
    ├── vpcflowlogs/ (captured traffic)
    ├── guardduty-findings/ (threat detections)
    ├── ec2-snapshots/ (system state)
    ├── application-logs/ (app activity)
    └── report/ (findings, timeline, recommendations)
```

### Requirements

- [ ] Collected by authorized personnel only
- [ ] Timestamp and signature on all evidence
- [ ] Tamper-proof storage (S3 Object Lock)
- [ ] Access logged to immutable audit trail
- [ ] Integrity verified (cryptographic hash)
- [ ] Legal review completed before external sharing

---

## Incident Procedures During Testing

### If System Unavailable

1. Red team immediately stops testing
2. Notify incident commander
3. Assess system health and impact
4. Restore from EBS snapshot if needed
5. Document impact duration
6. Post-incident review: Why did it happen?

### If Unauthorized Access Detected

1. **STOP** all testing immediately
2. Notify legal and cloud lead
3. Assess scope of unauthorized access
4. Revoke all credentials used in test
5. Brief project sponsor
6. Investigation and remediation
7. **Test authorization cancelled**

---

## Documentation Requirements

### Pre-Test

- Test plan (objectives, scope, success criteria)
- Authorization form (signed approvals)
- Tool justification (why each tool needed)
- Risk assessment (what could go wrong)
- Baseline configuration (current system state)

### During-Test

- Attack timeline (every significant action)
- Tool execution log (commands, outputs)
- Evidence snapshots (screenshots, configs)
- Incident log (anomalies, unexpected findings)

### Post-Test

- Findings report (vulnerabilities discovered)
- Attack summary (how compromise achieved)
- Detection report (what was detected, when)
- Remediation plan (fixes for vulnerabilities)
- Lessons learned (training opportunities)

---

## Compliance & Audit

### Independent Review

Sample 20% of experiments (random selection):
- Review authorization documentation
- Verify testing stayed within scope
- Check evidence integrity
- Assess detection effectiveness

### Annual Metrics

| Metric | Target | Purpose |
|---|---|---|
| Tests completed | 12/year | Activity level |
| Vulnerabilities found | ≥20/year | Productivity |
| Detection rate | ≥80% | Effectiveness |
| False positives | <10% | Accuracy |
| Mean time to detect | <30 min | Responsiveness |

---

## Checklist Before Testing

- [ ] Authorization form signed by all approvers
- [ ] Test plan reviewed and approved
- [ ] EBS snapshots and RDS backups created
- [ ] Incident response team briefed
- [ ] Monitoring tools active (GuardDuty, CloudWatch)
- [ ] Evidence S3 bucket prepared
- [ ] Legal has no objections
- [ ] Test window scheduled
- [ ] Tools tested and approved
- [ ] Team trained on procedures
- [ ] Break-glass procedure documented
- [ ] Stakeholder notifications sent

---

**See also:** 04-Security-Policy.md (incident response procedures), 06-Roadmap.md (research timeline)
