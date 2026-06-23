# org-guardrails — Service Control Policies (SCPs)
# Issue 1.7 (Owner: Ethan). Preventive guardrails attached to OUs.
#
# Controls: AC-3 (access enforcement), CM-7 (least functionality).
#
# NOTE: SCPs require AWS Organizations with "all features" enabled and must be
#       applied from the management account.

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# Deny use of the root user for everything except a tiny allow-list.
resource "aws_organizations_policy" "deny_root" {
  name        = "${var.name_prefix}-deny-root"
  description = "Block root-user actions across member accounts."
  type        = "SERVICE_CONTROL_POLICY"
  content = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "DenyRootUser"
      Effect    = "Deny"
      Action    = "*"
      Resource  = "*"
      Condition = { StringLike = { "aws:PrincipalArn" = "arn:${var.partition}:iam::*:root" } }
    }]
  })
}

# Restrict activity to approved regions (helps with GovCloud / data residency).
resource "aws_organizations_policy" "region_lock" {
  name        = "${var.name_prefix}-region-lock"
  description = "Deny actions outside approved regions."
  type        = "SERVICE_CONTROL_POLICY"
  content = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "DenyOutsideApprovedRegions"
      Effect = "Deny"
      NotAction = [
        "iam:*", "organizations:*", "sts:*", "cloudfront:*",
        "route53:*", "support:*", "waf:*",
      ]
      Resource  = "*"
      Condition = { StringNotEquals = { "aws:RequestedRegion" = var.approved_regions } }
    }]
  })
}

# Block making S3 buckets/objects public.
resource "aws_organizations_policy" "no_public_s3" {
  name        = "${var.name_prefix}-no-public-s3"
  description = "Prevent disabling S3 public access blocks."
  type        = "SERVICE_CONTROL_POLICY"
  content = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid      = "DenyDisablingS3PublicAccessBlock"
      Effect   = "Deny"
      Action   = ["s3:PutAccountPublicAccessBlock", "s3:PutBucketPublicAccessBlock"]
      Resource = "*"
    }]
  })
}

# Attach each policy to the target OUs.
resource "aws_organizations_policy_attachment" "deny_root" {
  for_each  = toset(var.target_ou_ids)
  policy_id = aws_organizations_policy.deny_root.id
  target_id = each.value
}

resource "aws_organizations_policy_attachment" "region_lock" {
  for_each  = toset(var.target_ou_ids)
  policy_id = aws_organizations_policy.region_lock.id
  target_id = each.value
}

resource "aws_organizations_policy_attachment" "no_public_s3" {
  for_each  = toset(var.target_ou_ids)
  policy_id = aws_organizations_policy.no_public_s3.id
  target_id = each.value
}
