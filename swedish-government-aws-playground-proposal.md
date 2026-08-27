# AWS Playground for Post-Quantum Security Research

## Purpose

This document proposes a lawful, isolated AWS-based playground for researching post-quantum security risks, defensive controls, and cloud incident response patterns. The project is intended for Swedish public-sector review, education, and controlled experimentation. It does not target third-party infrastructure, intercept real user traffic, bypass production systems, or test against companies without written authorization.

## Executive Summary

The project replaces offensive testing against real platforms with a controlled cyber range hosted on AWS. The range simulates modern internet-scale architecture, encrypted service traffic, identity flows, telemetry, and incident response workflows. Researchers can safely study how quantum-relevant cryptographic risks, weak key management, misconfigured services, and cloud detection gaps would affect a representative environment.

The result is a repeatable environment for:

- Training teams on cloud security and incident response.
- Evaluating post-quantum cryptography migration strategies.
- Testing detection and logging coverage.
- Demonstrating risk scenarios without harming real services or users.
- Producing evidence-based recommendations for Swedish public-sector systems.

## What This Is Not

This project is not an attack platform. It must not be used for:

- Intercepting or decrypting real third-party traffic.
- Targeting named companies, agencies, citizens, or production systems.
- Harvesting credentials, tokens, keys, or personal data.
- Deploying malware or bypass payloads.
- Running vulnerability research outside a signed authorization boundary.

All experiments occur inside accounts, networks, services, and datasets owned or explicitly approved for the project.

## Proposed Solution

Build an AWS cyber playground with three layers:

1. **Simulated Application Layer**

   A realistic but synthetic application stack that represents public-facing services:

   - Web frontend.
   - API services.
   - Authentication flow.
   - Internal service-to-service traffic.
   - Synthetic user records.
   - Synthetic logs and telemetry.

2. **Security Research Layer**

   Controlled research modules for defensive testing:

   - TLS posture analysis against lab-owned endpoints.
   - Cryptographic inventory and key lifecycle analysis.
   - Post-quantum readiness assessment.
   - AWS IAM and least-privilege validation.
   - Logging, monitoring, and alert-response exercises.
   - Safe attack simulation using approved tools inside the lab only.

3. **Governance and Evidence Layer**

   A reporting layer that produces artifacts suitable for leadership and government stakeholders:

   - Risk register.
   - Experiment approvals.
   - Test results.
   - Control mappings.
   - Incident timelines.
   - Remediation recommendations.

## AWS Reference Architecture

The playground should be deployed into a dedicated AWS organization or isolated account structure:

- **Management account:** billing, guardrails, central policy.
- **Security account:** centralized logging, detection, evidence storage.
- **Research account:** temporary experiment environments.
- **Sandbox account:** intentionally vulnerable lab workloads.

Core services:

- **AWS Organizations** and **Service Control Policies** for guardrails.
- **IAM Identity Center** for human access.
- **Amazon VPC** with segmented public, private, and inspection subnets.
- **AWS CloudTrail**, **AWS Config**, **GuardDuty**, **Security Hub**, and **Detective** for telemetry.
- **Amazon S3** with Object Lock for immutable evidence.
- **AWS KMS** for key management and cryptographic policy testing.
- **Amazon CloudWatch** and **OpenSearch** for logs and dashboards.
- **AWS Lambda**, **ECS**, or **EKS** for deployable lab workloads.
- **AWS Systems Manager** for controlled access without open administrative ports.
- **Amazon Braket** only for educational quantum algorithm demonstrations, not real-world decryption claims.

## Post-Quantum Research Scope

The project should focus on defensive readiness:

- Inventory where cryptography is used.
- Identify systems dependent on RSA, ECC, TLS, signing certificates, JWTs, and long-lived secrets.
- Model "harvest now, decrypt later" risk using synthetic encrypted datasets.
- Compare classical TLS configurations with post-quantum or hybrid key-exchange options where available.
- Document migration paths to post-quantum cryptographic standards when supported by vendors and libraries.

Any quantum demonstrations should be clearly labeled as educational simulations. They should not claim practical decryption of modern internet traffic using current quantum hardware.

## Authorized Experiment Examples

The following exercises are suitable for the playground:

- Capture packet traces only from lab-owned endpoints and analyze TLS configuration.
- Generate synthetic encrypted traffic, archive it, and assess future decryption risk models.
- Rotate compromised lab keys and measure recovery time.
- Simulate leaked lab tokens and validate detection rules.
- Test whether CloudTrail, GuardDuty, and SIEM pipelines detect suspicious activity.
- Run tabletop incident response exercises with generated evidence.
- Validate IAM policies using least-privilege tests.

## Prohibited Experiment Examples

The following are out of scope:

- Man-in-the-middle testing against third-party users or services.
- Attempts to recover private keys from public internet services.
- Credential stuffing, token theft, memory scraping, or malware payloads.
- Tests against Meta, Google, Apple, Microsoft, Amazon, TikTok, or any other company without written authorization.
- Publication of bypass methods that enable unauthorized access.

## Governance Model

Every experiment should require:

- Written objective.
- Named owner.
- Scope statement.
- Approved AWS accounts and resources.
- Start and end date.
- Data classification.
- Safety controls.
- Evidence retention plan.
- Review and sign-off.

Recommended roles:

- **Project Sponsor:** owns public-sector value and funding.
- **Security Lead:** approves test scope and safety controls.
- **Cloud Platform Lead:** owns AWS architecture and guardrails.
- **Research Lead:** designs experiments.
- **Legal/Ethics Reviewer:** validates authorization and data handling.
- **Incident Commander:** coordinates simulated response exercises.

## Data Protection

The playground should avoid personal data by default. Where realistic data is needed, use synthetic datasets. If real data is ever introduced, the project must complete a data protection review before use.

Controls:

- No production citizen data.
- No third-party credentials.
- Synthetic identities only.
- Encryption at rest and in transit.
- Short-lived access.
- Immutable audit logs.
- Data retention limits.

## Deliverables

The project can produce:

- AWS reference architecture.
- Infrastructure-as-code templates.
- Security guardrail policy set.
- Post-quantum readiness checklist.
- Lab exercise catalog.
- Detection engineering test cases.
- Incident response playbooks.
- Executive report for Swedish public-sector stakeholders.

## Suggested Roadmap

### Phase 1: Framing and Approval

- Define stakeholders and legal boundary.
- Approve research charter.
- Define success criteria.
- Select AWS account structure.

### Phase 2: Secure Foundation

- Create isolated AWS accounts.
- Configure identity, logging, guardrails, and evidence storage.
- Deploy baseline network architecture.

### Phase 3: Lab Workloads

- Deploy synthetic web application and APIs.
- Add synthetic identity and traffic generation.
- Add telemetry dashboards.

### Phase 4: Research Modules

- Add cryptographic inventory tests.
- Add post-quantum readiness exercises.
- Add detection and response simulations.

### Phase 5: Reporting

- Produce government-facing report.
- Summarize risks, mitigations, and policy implications.
- Package reusable templates and training material.

## Success Criteria

The project is successful when:

- All testing is confined to authorized lab infrastructure.
- No real users, companies, or production systems are targeted.
- Experiments are repeatable and auditable.
- Findings map to concrete public-sector security improvements.
- The project produces practical migration and resilience guidance.

## One-Page Message for Stakeholders

We propose an AWS-hosted cyber playground for Swedish public-sector security research. The environment safely simulates modern cloud systems and quantum-relevant cryptographic risks without targeting real companies or citizens. It enables controlled experimentation, training, detection validation, and post-quantum migration planning. The expected outcome is stronger cloud resilience, better incident response readiness, and a practical evidence base for future security policy and procurement decisions.
