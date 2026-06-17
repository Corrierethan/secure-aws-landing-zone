output "log_archive_bucket_name" {
  description = "Name of the centralized log archive bucket."
  value       = aws_s3_bucket.archive.id
}

output "log_archive_bucket_arn" {
  description = "ARN of the centralized log archive bucket."
  value       = aws_s3_bucket.archive.arn
}
