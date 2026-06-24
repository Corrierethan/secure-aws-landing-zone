output "vpc_id" {
  description = "Prod VPC ID."
  value       = module.networking.vpc_id
}

output "private_subnet_ids" {
  description = "Private subnet IDs for workloads."
  value       = module.networking.private_subnet_ids
}

output "log_archive_bucket_name" {
  description = "Centralized log archive bucket for prod."
  value       = module.logging.log_archive_bucket_name
}
