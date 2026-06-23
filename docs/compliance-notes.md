# Compliance Notes — NIST 800-53 Crosswalk

This landing zone is built to make an ATO (Authority to Operate) easier by implementing common
baseline controls **as code**. The table below maps each module to the NIST 800-53 Rev. 5
controls it helps satisfy and points reviewers to the Terraform resource that provides the
implementation evidence. This is *implementation evidence*, not a full System Security Plan (SSP)
— but it's the kind of crosswalk an assessor or prime's ISSO wants to see.

> Profile target: roughly **FedRAMP Moderate / NIST 800-53 Moderate**. STIG-specific hardening
> of hosts lives in the separate [`compliance-as-code`](../../compliance-as-code) project.

## Module → control/resource crosswalk

| Module | Control | Terraform resource evidence | How the code satisfies the control |
|--------|---------|-----------------------------|------------------------------------|
| `remote-state` | SC-12 (cryptographic key establishment and management) | `modules/remote-state/main.tf`: `aws_kms_key.state`, `aws_kms_alias.state` | A customer-managed KMS key with rotation enabled protects Terraform state encryption keys instead of relying on unmanaged defaults. |
| `remote-state` | SC-28 (protection of information at rest) | `modules/remote-state/main.tf`: `aws_s3_bucket_server_side_encryption_configuration.state`, `aws_dynamodb_table.lock.server_side_encryption` | Terraform state objects and the DynamoDB lock table are encrypted at rest with the module CMK. |
| `remote-state` | AU-9 (protection of audit information) | `modules/remote-state/main.tf`: `aws_s3_bucket_versioning.state`, `aws_s3_bucket_public_access_block.state`, `aws_s3_bucket_policy.state` | Versioning, public-access blocking, and the TLS-only bucket policy protect state history that records infrastructure changes and may contain sensitive evidence. |
| `networking` | SC-7 (boundary protection) | `modules/networking/main.tf`: `aws_vpc.this`, `aws_subnet.public`, `aws_subnet.private`, `aws_internet_gateway.this`, `aws_nat_gateway.this` | The VPC, subnet tiers, internet gateway, and NAT gateways establish controlled network boundaries between public ingress paths and private workload subnets. |
| `networking` | AC-4 (information flow enforcement) | `modules/networking/main.tf`: `aws_default_security_group.this`, `aws_route_table.public`, `aws_route_table.private`, `aws_route.private_nat` | Empty default-security-group rules and explicit public/private route tables constrain how traffic can flow between workloads and external networks. |
| `networking` | AU-12 (audit record generation) | `modules/networking/main.tf`: `aws_flow_log.this`, `aws_cloudwatch_log_group.flow`, `aws_iam_role.flow`, `aws_iam_role_policy.flow` | VPC Flow Logs capture `ALL` traffic to an encrypted CloudWatch log group so network activity generates auditable records. |
| `iam-baseline` | AC-2 (account management) | `modules/iam-baseline/main.tf`: `aws_iam_account_password_policy.this`, `aws_iam_policy.permission_boundary`, `aws_iam_role.break_glass`, `aws_iam_role.auditor`, `aws_iam_role.cicd_deploy` | The module defines account-wide credential policy, named operational roles, and a boundary that prevents unmanaged IAM users and access keys. |
| `iam-baseline` | AC-6 (least privilege) | `modules/iam-baseline/main.tf`: `aws_iam_policy.permission_boundary`, `aws_iam_role_policy_attachment.auditor_readonly`, `aws_iam_role_policy_attachment.auditor_securityaudit` | Permission boundaries cap role privileges while the auditor role receives read-only and SecurityAudit access instead of administrative permissions. |
| `iam-baseline` | IA-2(1) (MFA for privileged accounts) | `modules/iam-baseline/main.tf`: `aws_iam_role.break_glass` | The break-glass role trust policy requires `aws:MultiFactorAuthPresent` and a bounded MFA age before privileged assumption is allowed. |
| `iam-baseline` | IA-5 (authenticator management) | `modules/iam-baseline/main.tf`: `aws_iam_account_password_policy.this`, `aws_iam_openid_connect_provider.github`, `aws_iam_role.cicd_deploy` | Strong password requirements and optional GitHub OIDC federation reduce reliance on reusable static credentials. |
| `logging` | AU-9 (protection of audit information) | `modules/logging/main.tf`: `aws_kms_key.log_archive`, `aws_s3_bucket_public_access_block.archive`, `aws_s3_bucket_server_side_encryption_configuration.archive` | Audit archives are encrypted with a customer-managed KMS key and blocked from public access. |
| `logging` | AU-11 (audit record retention) | `modules/logging/main.tf`: `aws_s3_bucket_versioning.archive`, `aws_s3_bucket_lifecycle_configuration.archive` | Versioning and lifecycle rules retain log objects for `var.log_retention_days` and transition them to Glacier for long-term retention. |
| `logging` | SC-28 (protection of information at rest) | `modules/logging/main.tf`: `aws_s3_bucket_server_side_encryption_configuration.archive`, `aws_kms_key.log_archive` | The log archive bucket enforces KMS-backed server-side encryption for stored audit evidence. |
| `org-guardrails` | AC-3 (access enforcement) | `modules/org-guardrails/main.tf`: `aws_organizations_policy.deny_root`, `aws_organizations_policy.no_public_s3`, `aws_organizations_policy_attachment.*` | Organization SCPs deny root-user actions and public-S3 changes across the target OUs before account-local IAM can allow them. |
| `org-guardrails` | CM-7 (least functionality) | `modules/org-guardrails/main.tf`: `aws_organizations_policy.region_lock`, `aws_organizations_policy.no_public_s3`, `aws_organizations_policy_attachment.*` | Region-lock and public-S3 SCPs reduce available functionality to approved regions and non-public storage configurations. |
| `org-guardrails` | SC-7 (boundary protection) | `modules/org-guardrails/main.tf`: `aws_organizations_policy.region_lock` | The region-lock SCP enforces geographic service boundaries by denying non-global actions outside `var.approved_regions`. |

## Control family coverage summary

| Family | Covered by | Status |
|--------|------------|--------|
| **AC** (Access Control) | `iam-baseline`, `networking`, `org-guardrails` | Partial — account, route/security-group, and organization guardrails are in place. |
| **AU** (Audit & Accountability) | `remote-state`, `networking`, `logging` | Partial — state/log protection and VPC flow logs are in place; organization CloudTrail and Config remain future work. |
| **CM** (Configuration Management) | `org-guardrails`, Terraform modules, CI gates | Partial — SCPs and IaC review gates support baseline configuration enforcement. |
| **IA** (Identification & Authentication) | `iam-baseline` | Partial — password policy, MFA-gated break-glass access, and optional OIDC are in place. |
| **SC** (System & Communications Protection) | `remote-state`, `networking`, `logging`, `org-guardrails` | Partial — encryption, network boundaries, and region boundaries are implemented. |

## GovCloud partition notes

- Modules that build ARNs use `data.aws_partition.current.partition` or `var.partition`, so IAM,
  KMS, and Organizations policies render `arn:aws-us-gov:...` in GovCloud instead of commercial
  `arn:aws:...` (`remote-state`, `networking`, `iam-baseline`, and `org-guardrails`).
- Region controls change by input rather than code fork: set `var.approved_regions` to GovCloud
  regions such as `us-gov-west-1` and `us-gov-east-1` for the `org-guardrails` region-lock SCP.
- Service principals that are region-qualified, such as CloudWatch Logs KMS use in `networking`,
  are composed from `data.aws_region.current.name`; validate the rendered principal in each
  GovCloud region before production use.
- The current `logging` module creates the protected archive bucket but does not yet declare
  `aws_cloudtrail` or AWS Config resources; those service integrations must be checked for
  GovCloud availability and partition-specific delivery behavior when added.

## Gaps / future work

- Organization CloudTrail with log file validation.
- AWS Config conformance pack for the Moderate baseline.
- S3 Object Lock (WORM) on the log archive for AU-9 tamper resistance.
- GovCloud validation pass using `aws-us-gov` partition and approved GovCloud regions.

## How CI supports compliance

Every merge request runs `terraform fmt`, `terraform validate`, `tflint`, `tfsec`, and `checkov`,
which flag formatting drift, invalid Terraform, insecure configurations, and permissive resource
patterns **before** they merge — continuous configuration assurance that maps to **CM-6** and
**CA-7** (continuous monitoring). This document also supports **CA-2** by identifying which
implemented resources provide evidence for each mapped control.
