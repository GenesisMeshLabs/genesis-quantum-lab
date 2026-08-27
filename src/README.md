# meta-quantum-harvest — implementation

This directory turns the proposal in the repository root (start at
[`00-INDEX.md`](../00-INDEX.md), full plan in
[`swedish-government-aws-playground-proposal.md`](../swedish-government-aws-playground-proposal.md))
into working code: Terraform for the AWS foundation, a synthetic lab
application, and the Phase 3 research modules. Everything here targets the
"lab-only, no external targets" scope defined in the proposal — see that
document's "What This Is Not" and "Prohibited Experiment Examples" sections
before running anything against a real AWS account.

## Layout

```
src/
├── terraform/
│   ├── modules/
│   │   ├── organization/     Phase 1 — AWS Organization, OUs, member accounts
│   │   ├── scp/               Phase 1 — Service Control Policy guardrails
│   │   ├── logging/            Phase 1 — immutable audit trail (CloudTrail → S3 Object Lock)
│   │   ├── identity-center/    Phase 1 — IAM Identity Center permission sets
│   │   ├── networking/         Phase 2 — segmented VPC per research/sandbox account
│   │   └── detection/          Phase 2 — GuardDuty, Security Hub, Config, alerting
│   └── envs/
│       ├── management/         apply first, from the Organization's management account
│       ├── security/            apply second, into the new Security member account
│       └── research/            apply per Research/Sandbox account
├── app/
│   ├── web/                    Phase 2/3 — synthetic lab web app (Flask, Faker-generated data)
│   └── infra/                  Phase 2/3 — ECS Fargate + ALB deployment for app/web
├── research/
│   ├── crypto_inventory/       Phase 3 Module 3 — cryptographic risk-register scanner
│   ├── quantum_demo/           Phase 3 Module 1 — Grover's algorithm demo (Amazon Braket)
│   └── pqc_hybrid/             Phase 3 Module 2/4 — hybrid ML-KEM/ML-DSA + X25519 demo
├── scripts/
│   ├── bootstrap.sh             guarded terraform init/plan/apply wrapper
│   └── validate_deployment.sh   read-only check against the Phase 1 checklist
└── docs/
    └── IMPLEMENTATION-STATUS.md  what's built vs. still manual/pending, and deploy order
```

## Quick start

**Everything here is code — nothing is deployed automatically.** See
[`docs/IMPLEMENTATION-STATUS.md`](docs/IMPLEMENTATION-STATUS.md) for the
exact deploy order, manual prerequisites (IAM Identity Center must be
enabled once via the console — Terraform can't do that part), and what's
still unbuilt.

```bash
# 1. AWS foundation (org/accounts/guardrails/logging) — read-only preview
cd terraform/envs/management
cp terraform.tfvars.example terraform.tfvars   # fill in your email domain etc.
terraform init && terraform plan

# 2. Try the synthetic lab app locally (no AWS needed)
cd ../../../app/web
pip install -r requirements.txt
python app.py   # open http://localhost:8080

# 3. Run a research module (no AWS needed, no cost)
cd ../../research/quantum_demo
pip install -r requirements.txt
python grover_demo.py --target 11
```

## Design principles carried over from the proposal

- **Synthetic data only** — the lab app generates all "users" with `Faker`;
  no real personal data is ever read or stored (`04-Security-Policy.md`).
- **Lab-only blast radius** — the Sandbox OU gets an extra SCP
  (`terraform/modules/scp/policies/sandbox-isolation.json`) blocking VPC
  peering/Transit Gateway attachments and open SSH, so intentionally
  vulnerable workloads can't reach anything outside the Sandbox account.
- **Everything logged, nothing deleted by default** — CloudTrail is
  multi-region/multi-account with Object Lock in COMPLIANCE mode; GuardDuty
  findings page out over SNS.
- **No real quantum decryption claims** — `research/quantum_demo` explicitly
  documents that Grover's algorithm demo has nothing to do with breaking
  RSA/ECDSA (that would require Shor's algorithm and hardware that doesn't
  exist yet); see `03-Quantum-Computing-Framework.md`.
