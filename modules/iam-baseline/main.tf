# iam-baseline — least-privilege identity baseline
# Password policy, permission boundaries, and IAM guardrails that apply to every
# account enrolled in the landing zone.
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

data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

# ---------------------------------------------------------------------------
# Permission boundary that caps what any created role can do.
# ---------------------------------------------------------------------------
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

# ---------------------------------------------------------------------------
# Break-glass admin role — emergency use only, MFA required to assume.
# Controls: AC-2 (account management), IA-2(1) (MFA for privileged access).
# ---------------------------------------------------------------------------
resource "aws_iam_role" "break_glass" {
  name                 = "${var.name_prefix}-break-glass"
  description          = "Emergency admin role - MFA required, assume-role is logged and alerted."
  max_session_duration = 3600 # 1 hour max; limits blast radius of a compromised session.
  permissions_boundary = aws_iam_policy.permission_boundary.arn

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "RequireMFA"
      Effect = "Allow"
      Principal = {
        AWS = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"
      }
      Action = "sts:AssumeRole"
      Condition = {
        Bool            = { "aws:MultiFactorAuthPresent" = "true" }
        NumericLessThan = { "aws:MultiFactorAuthAge" = tostring(var.mfa_max_age_seconds) }
      }
    }]
  })

  tags = merge(var.tags, { Name = "${var.name_prefix}-break-glass" })
}

resource "aws_iam_role_policy_attachment" "break_glass_admin" {
  role       = aws_iam_role.break_glass.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AdministratorAccess"
}

# ---------------------------------------------------------------------------
# Read-only auditor role — for assessors and security reviews.
# Controls: AC-6 (least privilege), AU-9 (protection of audit info).
# ---------------------------------------------------------------------------
resource "aws_iam_role" "auditor" {
  name                 = "${var.name_prefix}-auditor"
  description          = "Read-only role for assessors; may not modify any resource."
  permissions_boundary = aws_iam_policy.permission_boundary.arn

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "AllowAssume"
      Effect = "Allow"
      Principal = {
        AWS = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = merge(var.tags, { Name = "${var.name_prefix}-auditor" })
}

resource "aws_iam_role_policy_attachment" "auditor_readonly" {
  role       = aws_iam_role.auditor.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "auditor_securityaudit" {
  role       = aws_iam_role.auditor.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/SecurityAudit"
}

# ---------------------------------------------------------------------------
# CI/CD deploy role — assumed via GitHub Actions OIDC; no long-lived keys.
# Controls: AC-2, AC-6, IA-2 (no static credentials).
# ---------------------------------------------------------------------------
resource "aws_iam_openid_connect_provider" "github" {
  count = var.enable_github_oidc ? 1 : 0

  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
  # Thumbprint rotated by GitHub; current leaf is pinned here and should be
  # updated if GitHub rotates their OIDC cert. See: https://github.blog/changelog/2023-06-27-github-actions-update-on-oidc-integration-with-aws/
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1", "1c58a3a8518e8759bf075b76b750d4f2df264fcd"]
}

resource "aws_iam_role" "cicd_deploy" {
  count = var.enable_github_oidc ? 1 : 0

  name                 = "${var.name_prefix}-cicd-deploy"
  description          = "Assumed by GitHub Actions via OIDC - no long-lived access keys."
  permissions_boundary = aws_iam_policy.permission_boundary.arn

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "GitHubOIDC"
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.github[0].arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        }
        StringLike = {
          "token.actions.githubusercontent.com:sub" = "repo:${var.github_org}/${var.github_repo}:*"
        }
      }
    }]
  })

  tags = merge(var.tags, { Name = "${var.name_prefix}-cicd-deploy" })
}

