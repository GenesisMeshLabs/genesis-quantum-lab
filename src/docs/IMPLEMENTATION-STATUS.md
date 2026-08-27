# Implementation Status

Tracks progress against the checklists in `02-Cloud-Infrastructure.md` and
the phased plan in `06-Roadmap.md`. Updated as code lands — this file is the
living source of truth for "what's actually built" vs. "what's still just a
proposal."

## Phase 1 — Foundation (Weeks 1–8)

| Item | Status | Where |
|---|---|---|
| AWS Organization & accounts | ✅ Code ready | `terraform/modules/organization` |
| Service Control Policies | ✅ Code ready | `terraform/modules/scp` |
| IAM Identity Center enabled | ⬜ Manual (console, one-time) | see note in `terraform/modules/identity-center/main.tf` |
| IAM Identity Center permission sets | ✅ Code ready (needs instance ARN after enablement) | `terraform/modules/identity-center` |
| MFA enforcement | ⬜ Manual (Identity Center console settings) | — |
| CloudTrail (multi-region, multi-account) | ✅ Code ready | `terraform/modules/logging` |
| KMS keys | ✅ Code ready | `terraform/modules/logging` |
| S3 audit bucket (Object Lock, 7yr) | ✅ Code ready | `terraform/modules/logging` |

## Phase 2 — Lab Infrastructure (Weeks 9–16)

| Item | Status | Where |
|---|---|---|
| VPC & subnet segmentation | ✅ Code ready | `terraform/modules/networking` |
| VPC Flow Logs | ✅ Code ready | `terraform/modules/networking` |
| VPC endpoints (S3/SSM/Secrets Manager) | ✅ Code ready | `terraform/modules/networking` |
| GuardDuty | ✅ Code ready | `terraform/modules/detection` |
| Security Hub (CIS + NIST 800-53) | ✅ Code ready | `terraform/modules/detection` |
| AWS Config + managed rules | ✅ Code ready | `terraform/modules/detection` |
| Alerting (SNS + EventBridge) | ✅ Code ready | `terraform/modules/detection` |
| Network Firewall (inspection tier) | ✅ Code ready | `terraform/modules/network-firewall` (domain allow-list, STRICT_ORDER stateful rule group, `aws:drop_strict` default; wired into `modules/networking` via `enable_network_firewall`, routes private-subnet egress through the inspection tier) |
| Synthetic web application | ✅ Built & tested locally | `app/web` |
| ECS Fargate deployment | ✅ Code ready (needs image pushed to ECR) | `app/infra` |
| Test database (RDS) | ✅ Code ready | `terraform/modules/database` (Postgres, encrypted, private-subnet only, RDS-managed Secrets Manager master credential, synthetic data only — wired into `envs/research` via `deploy_test_database`) |
| SIEM / CloudWatch dashboards | ✅ Code ready | `terraform/modules/dashboards` (CloudWatch dashboard from native metrics + Logs Insights: GuardDuty→EventBridge invocations in `envs/security`; VPC Flow Logs rejects, Network Firewall alerts, ALB/ECS/RDS metrics in `envs/research`) |

## Phase 3 — Research & Testing (Weeks 17–24)

| Item | Status | Where |
|---|---|---|
| Quantum algorithm demo (Module 1) | ✅ Built & verified | `research/quantum_demo` (Amazon Braket LocalSimulator, Grover's algorithm, 25%→100% amplification confirmed) |
| Cryptographic inventory (Module 3) | ✅ Built & verified | `research/crypto_inventory` (tested against this repo: 13 findings, 11 quantum-vulnerable) |
| Hybrid PQC key exchange (Module 2) | ✅ Built & verified | `research/pqc_hybrid` (real FIPS 203 ML-KEM-768 + X25519 hybrid, FIPS 204 ML-DSA-65 signatures — not simulated) |
| Migration roadmap (Module 4) | ⬜ Not started | depends on real inventory scan of production-adjacent systems |
| Red team / blue team scenarios | ⬜ Not started | depends on Phase 2 lab workloads being live |

## Phase 4 & 5 — Validation, Audit, Reporting

Not started — these depend on Phase 1–3 being deployed and running for a
period of time first (see `06-Roadmap.md`).

## What Terraform cannot do for you (manual prerequisites)

1. **Enable IAM Identity Center** once in the management account console
   (Organizations → Services → IAM Identity Center). AWS does not expose
   this as a Terraform resource. After enabling, copy the instance ARN and
   identity store ID into `envs/management/terraform.tfvars`.
2. **Configure MFA policy** on the Identity Center instance (Settings →
   Authentication) — also console/API-only today.
3. **Request AWS service quota increases** if you plan to run many parallel
   research accounts or GPU-backed workloads.
4. **Build and push the lab app image to ECR** before setting
   `deploy_lab_app = true` in `envs/research/terraform.tfvars`:
   ```bash
   cd app/web
   docker build -t mqh-lab-app .
   # tag + push to your ECR repo, then set container_image accordingly
   ```

## How to deploy (order matters)

1. `envs/management` — creates the Organization, OUs, accounts, SCPs.
2. Manually enable IAM Identity Center, then re-run `envs/management` with
   the instance ARN filled in to get permission sets.
3. `envs/security` — assume a role into the new Security account, deploy
   audit logging + detection.
4. `envs/research` — assume a role into each Research/Sandbox account,
   deploy networking (and optionally the lab app once the image is built).

See `scripts/bootstrap.sh` for a guarded `terraform plan/apply` wrapper and
`scripts/validate_deployment.sh` for a read-only check against the
Phase 1 deployment checklist in `02-Cloud-Infrastructure.md`.
