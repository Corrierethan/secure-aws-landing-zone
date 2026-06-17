# Module: `iam-baseline`

Least-privilege identity baseline for an account. **Issue 1.5 (Ethan).** Starter scaffold —
extend per the checklist below.

## Build checklist (issue 1.5)

- [x] Strong account password policy
- [x] Reusable permission boundary policy
- [ ] Break-glass admin role (MFA required, alerting on assume)
- [ ] Read-only auditor role (for assessors)
- [ ] CI/CD deploy role via GitLab OIDC (no long-lived keys)
- [ ] Deny creation of IAM users / access keys (prefer roles + SSO)

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `name_prefix` | Prefix for IAM names | `string` | n/a |
| `allowed_actions` | Actions allowed by the boundary | `list(string)` | broad starter set |
| `tags` | Tags for all resources | `map(string)` | `{}` |

## Outputs

| Name | Description |
|------|-------------|
| `permission_boundary_arn` | Attach to every created role |

## Controls

NIST 800-53: **AC-2**, **AC-6**, **IA-2(1)** (MFA for privileged access).
