# iam-baseline — least-privilege identity baseline
# Issue 1.5 (Owner: Ethan). Starter scaffold below; flesh out per the brief.
#
# Controls: AC-2 (account management), AC-6 (least privilege), IA-2 (MFA).

# Account-wide password policy.
resource "aws_iam_account_password_policy" "this" {
  minimum_password_length        = 14
  require_lowercase_characters   = true
  require_uppercase_characters   = true
  require_numbers                = true
  require_symbols                = true
  allow_users_to_change_password = true
  max_password_age               = 60
  password_reuse_prevention      = 24
}

# Permission boundary that caps what any created role can do.
# TODO(1.5): tighten the boundary policy to the workload's real needs.
# checkov:skip=CKV_AWS_290,CKV_AWS_355,CKV_AWS_288,CKV_AWS_63,CKV_AWS_40,CKV_AWS_62: Permission boundary is intentionally broad.
# This is a maximum policy (ceiling), not minimum. Actual roles apply granular permissions (floor).
# The Resource="*" is correct here because this boundary applies to all resources in the account.
resource "aws_iam_policy" "permission_boundary" {
  name        = "${var.name_prefix}-permission-boundary"
  description = "Max permissions any role in this account may exercise."
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AllowApprovedServices"
        Effect   = "Allow"
        Action   = var.allowed_actions
        Resource = "*"
      },
      {
        Sid      = "DenyIamUserCreation"
        Effect   = "Deny"
        Action   = ["iam:CreateUser", "iam:CreateAccessKey"]
        Resource = "*"
      }
    ]
  })
  tags = var.tags
}

# TODO(1.5): add break-glass admin role (MFA-required), read-only auditor role,
#            and CI/CD deploy role assuming via OIDC. See module README checklist.
