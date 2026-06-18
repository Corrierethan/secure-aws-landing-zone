variable "name_prefix" {
  description = "Prefix applied to all SCP names."
  type        = string
}

variable "partition" {
  description = "AWS ARN partition: \"aws\" (commercial) or \"aws-us-gov\" (GovCloud)."
  type        = string
  default     = "aws"
}

variable "approved_regions" {
  description = "Regions where activity is permitted (e.g. [\"us-east-1\"] or GovCloud regions)."
  type        = list(string)
  default     = ["us-east-1", "us-west-2"]
}

variable "target_ou_ids" {
  description = "Organizational Unit IDs to attach the guardrail SCPs to."
  type        = list(string)
}
