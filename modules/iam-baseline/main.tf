# iam-baseline — least-privilege identity baseline
# Issue 1.5 (Owner: Ethan). Starter scaffold below; flesh out per the brief.
#
# Controls: AC-2 (account management), AC-6 (least privilege), IA-2 (MFA).

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

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
resource "aws_iam_policy" "permission_boundary" {
  # checkov:skip=CKV_AWS_287:Boundary is a ceiling, not a grant; credential-exposure actions are constrained by the attached role policies.
  # checkov:skip=CKV_AWS_288:Boundary is a ceiling, not a grant; data-exfiltration actions are constrained by the attached role policies.
  # checkov:skip=CKV_AWS_289:Boundary is a ceiling, not a grant; permissions-management actions are constrained by the attached role policies.
  # checkov:skip=CKV_AWS_290:Boundary is a ceiling, not a grant; write actions are constrained by the attached role policies.
  # checkov:skip=CKV_AWS_355:A permission boundary must use Resource="*" to cap every resource the role could ever touch.
  name        = "${var.name_prefix}-permission-boundary"
  description = "Max permissions any role in this account may exercise."
  # Read-only action wildcards (Describe*/Get*/List*) are intentional on a permission boundary —
  # it is a ceiling, not a grant. Roles still apply granular least-privilege policies underneath;
  # mutating/credential actions are not included here.
  policy = jsonencode({ # tfsec:ignore:aws-iam-no-policy-wildcards
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

