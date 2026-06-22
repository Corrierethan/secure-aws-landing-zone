variable "name_prefix" {
  description = "Prefix applied to all IAM resource names."
  type        = string
}

variable "allowed_actions" {
  description = "Actions permitted by the permission boundary. Scope down per workload."
  type        = list(string)
  default     = ["ec2:*", "s3:*", "logs:*", "cloudwatch:*"]
}

variable "tags" {
  description = "Tags applied to all resources created by this module."
  type        = map(string)
  default     = {}
}

variable "mfa_max_age_seconds" {
  description = "Maximum age (seconds) of MFA authentication allowed for the break-glass role."
  type        = number
  default     = 3600 # 1 hour
}

variable "enable_github_oidc" {
  description = "Create the GitHub Actions OIDC provider and CI/CD deploy role."
  type        = bool
  default     = false
}

variable "github_org" {
  description = "GitHub organisation name, used to scope the OIDC trust policy."
  type        = string
  default     = ""
}

variable "github_repo" {
  description = "GitHub repository name (without the org prefix), used to scope the OIDC trust policy."
  type        = string
  default     = ""
}
