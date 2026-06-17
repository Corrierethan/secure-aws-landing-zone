variable "name_prefix" {
  description = "Prefix applied to all resource names (e.g. \"ascent-prod\")."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC. Must be large enough for the subnet carving (/16 recommended)."
  type        = string
  default     = "10.0.0.0/16"
}

variable "az_count" {
  description = "Number of Availability Zones to span (capped at what the region offers)."
  type        = number
  default     = 3
}

variable "single_nat_gateway" {
  description = "Use a single NAT gateway (cheaper, non-HA) instead of one per AZ. Set true only for dev."
  type        = bool
  default     = false
}

variable "flow_log_retention_days" {
  description = "Retention period for VPC Flow Log CloudWatch logs."
  type        = number
  default     = 365
}

variable "tags" {
  description = "Tags applied to all resources created by this module."
  type        = map(string)
  default     = {}
}
