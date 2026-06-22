output "permission_boundary_arn" {
  description = "ARN of the permission boundary policy to attach to all created roles."
  value       = aws_iam_policy.permission_boundary.arn
}

output "break_glass_role_arn" {
  description = "ARN of the emergency break-glass admin role (MFA required to assume)."
  value       = aws_iam_role.break_glass.arn
}

output "auditor_role_arn" {
  description = "ARN of the read-only auditor role."
  value       = aws_iam_role.auditor.arn
}

output "cicd_deploy_role_arn" {
  description = "ARN of the GitHub Actions OIDC deploy role. Empty string when enable_github_oidc = false."
  value       = var.enable_github_oidc ? aws_iam_role.cicd_deploy[0].arn : ""
}
