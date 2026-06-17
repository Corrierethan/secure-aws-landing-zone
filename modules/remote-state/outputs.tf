output "state_bucket_name" {
  description = "Name of the S3 bucket holding Terraform state."
  value       = aws_s3_bucket.state.id
}

output "state_bucket_arn" {
  description = "ARN of the Terraform state bucket."
  value       = aws_s3_bucket.state.arn
}

output "lock_table_name" {
  description = "Name of the DynamoDB table used for state locking."
  value       = aws_dynamodb_table.lock.name
}

output "kms_key_arn" {
  description = "ARN of the KMS key encrypting Terraform state."
  value       = aws_kms_key.state.arn
}
