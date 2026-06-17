output "policy_ids" {
  description = "IDs of the SCPs created by this module."
  value = {
    deny_root    = aws_organizations_policy.deny_root.id
    region_lock  = aws_organizations_policy.region_lock.id
    no_public_s3 = aws_organizations_policy.no_public_s3.id
  }
}
