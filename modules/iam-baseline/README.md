# Module: `iam-baseline`

Least-privilege identity baseline for an account.

## What's included

- Strong account password policy
- Reusable permission boundary policy
- Break-glass admin role (MFA required, session capped at 1 hour)
- Read-only auditor role (for assessors)
- CI/CD deploy role via GitHub Actions OIDC (no long-lived keys)
- Deny creation of IAM users / access keys (prefer roles + SSO)

## Usage

```hcl
module "iam_baseline" {
  source      = "../../modules/iam-baseline"
  name_prefix = "ascent-nonprod"
  tags        = { Environment = "nonprod" }

  # Optional: tighten the boundary beyond the read-only default.
  allowed_actions = [
    "ec2:Describe*",
    "s3:Get*", "s3:List*",
    "logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents",
    "cloudwatch:PutMetricData",
    "sts:AssumeRole",
    "iam:Get*", "iam:List*",
  ]

  # Enable the GitHub Actions OIDC trust for this account.
  enable_github_oidc = true
  github_org         = "MyOrg"
  github_repo        = "my-infra-repo"
}

# Attach the boundary to every role you create in the same account.
resource "aws_iam_role" "example" {
  name                 = "my-workload-role"
  permissions_boundary = module.iam_baseline.permission_boundary_arn
  assume_role_policy   = data.aws_iam_policy_document.example_trust.json
}
```

### Assuming the break-glass role (emergency only)

```bash
aws sts assume-role \
  --role-arn "$(terraform output -raw break_glass_role_arn)" \
  --role-session-name "break-glass-$(date +%Y%m%d%H%M)" \
  --serial-number "arn:aws:iam::ACCOUNT_ID:mfa/your-mfa-device" \
  --token-code "123456" \
  --duration-seconds 3600
```

All assume-role calls are logged in CloudTrail. Wire the break-glass role to an SNS alert
so any assumption triggers an immediate notification.

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `name_prefix` | Prefix for IAM names | `string` | n/a |
| `allowed_actions` | Actions allowed by the boundary | `list(string)` | read-only starter set |
| `mfa_max_age_seconds` | Max MFA age for break-glass assume | `number` | `3600` |
| `enable_github_oidc` | Create GitHub OIDC provider + deploy role | `bool` | `false` |
| `github_org` | GitHub org name for OIDC trust scope | `string` | `""` |
| `github_repo` | GitHub repo name for OIDC trust scope | `string` | `""` |
| `tags` | Tags for all resources | `map(string)` | `{}` |

## Outputs

| Name | Description |
|------|-------------|
| `permission_boundary_arn` | Attach to every created role |
| `break_glass_role_arn` | Emergency admin role ARN (MFA required) |
| `auditor_role_arn` | Read-only assessor role ARN |
| `cicd_deploy_role_arn` | GitHub Actions OIDC deploy role ARN |

## Controls

NIST 800-53: **AC-2**, **AC-6**, **IA-2(1)** (MFA for privileged access).
