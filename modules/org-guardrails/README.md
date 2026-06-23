# Module: `org-guardrails`

Preventive **Service Control Policies (SCPs)** attached to Organizational Units. **Issue 1.7
(Ethan).** Applied from the management account; requires AWS Organizations with all features.

## Guardrails included

- **deny-root** — blocks root-user actions in member accounts.
- **region-lock** — denies activity outside approved regions (supports GovCloud/data residency).
- **no-public-s3** — prevents turning off S3 public access blocks.

> Extend with: deny disabling CloudTrail/Config, deny leaving the org, require IMDSv2, etc.

## Usage

```hcl
module "guardrails" {
  source           = "../../modules/org-guardrails"
  name_prefix      = "ascent-lz"
  partition        = "aws"            # or "aws-us-gov"
  approved_regions = ["us-east-1"]    # or ["us-gov-west-1"]
  target_ou_ids    = [aws_organizations_organizational_unit.workloads.id]
}
```

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `name_prefix` | Prefix for SCP names | `string` | n/a |
| `partition` | `aws` or `aws-us-gov` | `string` | `"aws"` |
| `approved_regions` | Permitted regions | `list(string)` | `["us-east-1","us-west-2"]` |
| `target_ou_ids` | OUs to attach SCPs to | `list(string)` | n/a |

## Outputs

| Name | Description |
|------|-------------|
| `policy_ids` | Map of created SCP IDs |

## Controls

NIST 800-53: **AC-3** (access enforcement), **CM-7** (least functionality).
