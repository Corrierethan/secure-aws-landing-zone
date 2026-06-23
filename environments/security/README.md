# `security` environment

Security/audit account composition.

## What goes here

This is the **centralized audit account** — it doesn't run workloads. Its job is to collect and
protect log evidence from every other account in the organization.

## What it wires up

| Module | Role in this environment |
|---|---|
| `logging` | Org-wide CloudTrail trail landing here; S3 log archive bucket with versioning + Object Lock (WORM) |
| (future) Config aggregator | Receives AWS Config snapshots from all member accounts |

## Key settings

| Setting | Value |
|---|---|
| Backend state key | `security/terraform.tfstate` |
| `Environment` tag | `security` |
| `name_prefix` | `ascent-lz-security` |

## Files

| File | Purpose |
|---|---|
| `main.tf` | Provider config, backend block, logging module call configured as the org-wide target |
| `variables.tf` | `aws_region`, `name_prefix`, org-level inputs (org trail ARN, member account IDs) |
| `outputs.tf` | Log archive bucket name/ARN, Config aggregator ARN |
| `terraform.tfvars.example` | Example values for the security account |

## Deploy order

This environment should be deployed **after** the management account (which creates the org and
OUs), so that member accounts can deliver CloudTrail and Config data here.

```bash
cd environments/security
terraform init
terraform plan
terraform apply
```

## Controls

AU-2, AU-9, AU-11 (centralized audit collection and protection), SC-28 (encryption at rest on
the log archive).
