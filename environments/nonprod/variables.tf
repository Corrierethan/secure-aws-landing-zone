variable "aws_region" {
  description = "Region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "name_prefix" {
  description = "Prefix applied to all resource names."
  type        = string
  default     = "ascent-lz"
}

variable "vpc_cidr" {
  description = "CIDR block for the non-prod VPC."
  type        = string
  default     = "10.20.0.0/16"
}
