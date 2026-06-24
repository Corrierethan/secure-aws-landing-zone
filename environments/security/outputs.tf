output "log_archive_bucket_name" {
  description = "Centralized log archive bucket for the security account."
  value       = module.logging.log_archive_bucket_name
}

output "log_archive_bucket_arn" {
  description = "ARN of the log archive bucket."
  value       = module.logging.log_archive_bucket_arn
}

output "kms_key_arn" {
  description = "KMS key ARN encrypting the log archive."
  value       = module.logging.kms_key_arn
}
