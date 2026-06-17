output "permission_boundary_arn" {
  description = "ARN of the permission boundary policy to attach to all created roles."
  value       = aws_iam_policy.permission_boundary.arn
}
