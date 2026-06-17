output "state_bucket_name" {
  description = "Terraform state bucket created for the landing zone."
  value       = module.remote_state.state_bucket_name
}

output "lock_table_name" {
  description = "DynamoDB lock table for Terraform state."
  value       = module.remote_state.lock_table_name
}
