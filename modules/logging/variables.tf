variable "name_prefix" {
  description = "Prefix applied to all logging resource names."
  type        = string
}

variable "account_id" {
  description = "AWS account ID, appended to the log archive bucket name."
  type        = string
}

variable "log_retention_days" {
  description = "Number of days to retain archived logs before expiration."
  type        = number
  default     = 2555 # ~7 years
}

variable "tags" {
  description = "Tags applied to all resources created by this module."
  type        = map(string)
  default     = {}
}
