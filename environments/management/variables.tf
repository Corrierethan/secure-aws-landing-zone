variable "aws_region" {
  description = "Region to deploy into. Commercial example: us-east-1. GovCloud: us-gov-west-1."
  type        = string
  default     = "us-east-1"
}

variable "partition" {
  description = "AWS ARN partition: \"aws\" or \"aws-us-gov\"."
  type        = string
  default     = "aws"
}

variable "name_prefix" {
  description = "Prefix applied to all resource names."
  type        = string
  default     = "ascent-lz"
}

variable "approved_regions" {
  description = "Regions permitted by the region-lock SCP."
  type        = list(string)
  default     = ["us-east-1"]
}

variable "target_ou_ids" {
  description = "OU IDs to attach guardrail SCPs to (populate once the org exists)."
  type        = list(string)
  default     = []
}
