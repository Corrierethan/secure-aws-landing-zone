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
