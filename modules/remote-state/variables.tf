variable "name_prefix" {
  description = "Prefix applied to all resource names (e.g. \"ascent-lz\")."
  type        = string
}

variable "account_id" {
  description = "AWS account ID, appended to the state bucket name for global uniqueness."
  type        = string
}

variable "tags" {
  description = "Tags applied to all resources created by this module."
  type        = map(string)
  default     = {}
}
