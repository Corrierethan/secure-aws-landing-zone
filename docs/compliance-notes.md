# Compliance Notes — NIST 800-53 Crosswalk

This landing zone is built to make an ATO (Authority to Operate) easier by implementing common
baseline controls **as code**. The table below maps each module to the NIST 800-53 Rev. 5
control families it helps satisfy. This is *implementation evidence*, not a full System Security
Plan (SSP) — but it's the kind of crosswalk an assessor or prime's ISSO wants to see.

> Profile target: roughly **FedRAMP Moderate / NIST 800-53 Moderate**. STIG-specific hardening
> of hosts lives in the separate [`compliance-as-code`](../../compliance-as-code) project.

## Module → control mapping

| Module | Controls | How it's implemented |
|--------|----------|----------------------|
| `remote-state` | SC-12, SC-28, AU-9 | KMS-encrypted, versioned, TLS-only state bucket + locked DynamoDB; protects state that can contain sensitive values. |
| `networking` | SC-7, AC-4, AU-12 | VPC boundary, segmented public/private subnets, emptied default SG, NAT egress control, ALL-traffic flow logs to retained CloudWatch. |
| `iam-baseline` | AC-2, AC-6, IA-2(1) | Strong password policy, permission boundaries, deny IAM user/key creation (roles + MFA + OIDC instead). |
| `logging` | AU-2, AU-9, AU-11 | Versioned/encrypted/public-blocked log archive, long retention, Glacier tiering; org CloudTrail + Config (in progress). |
| `org-guardrails` | AC-3, CM-7 | SCPs: deny root, region lock, block public S3 — preventive, org-wide enforcement. |

## Control family coverage summary

| Family | Covered by | Status |
|--------|------------|--------|
| **AC** (Access Control) | iam-baseline, org-guardrails, networking | Partial — boundary + SCPs in place |
| **AU** (Audit & Accountability) | networking (flow logs), logging | Partial — archive in place, org trail pending (1.6) |
| **CM** (Configuration Management) | org-guardrails, all IaC + CI gates | Partial |
| **IA** (Identification & Auth) | iam-baseline | Partial — MFA policy, OIDC role pending (1.5) |
| **SC** (System & Comms Protection) | networking, remote-state | Partial |

## Gaps / future work

- [ ] Organization CloudTrail with log file validation (issue 1.6).
- [ ] AWS Config conformance pack for the Moderate baseline (issue 1.6).
- [ ] Break-glass + auditor + CI OIDC roles (issue 1.5).
- [ ] S3 Object Lock (WORM) on the log archive for AU-9 tamper resistance.
- [ ] GovCloud validation pass (partition/region variables already in place).

## How CI supports compliance

Every merge request runs `tfsec` and `checkov`, which flag insecure configurations (public
buckets, unencrypted resources, permissive security groups) **before** they merge — continuous
configuration assurance that maps to **CM-6** and **CA-7** (continuous monitoring).
