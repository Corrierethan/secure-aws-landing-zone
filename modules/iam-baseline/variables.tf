variable "name_prefix" {
  description = "Prefix applied to all IAM resource names."
  type        = string
}

variable "allowed_actions" {
  description = "Actions permitted by the permission boundary. Scope down per workload."
  type        = list(string)
  default = [
    # Read-only EC2 — avoids granting destructive mutating actions (DeleteSecurityGroup, ModifyInstanceAttribute, etc.) by default.
    "ec2:Describe*",
    # Read-only S3 — callers must explicitly widen to Put/Delete if their workload needs it.
    "s3:Get*",
    "s3:List*",
    # Observability — roles need to write logs and metrics; full access is low-risk here.
    "logs:*",
    "cloudwatch:*",
    # Role assumption — required for any role that needs to assume another role (e.g. cross-account, CI/CD).
    "sts:AssumeRole",
    # Read-only IAM lookups — many SDKs/tools call GetRole or ListRoles at startup; write actions remain denied.
    "iam:Get*",
    "iam:List*"
  ]
}

variable "tags" {
  description = "Tags applied to all resources created by this module."
  type        = map(string)
  default     = {}
}
