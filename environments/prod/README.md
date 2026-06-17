# `prod` environment — placeholder

Production workload account composition. **Issue 1.8 (Andy).**

Mirror [`../nonprod`](../nonprod) but with production hardening:

- `single_nat_gateway = false` (NAT per AZ for HA)
- Tighter `iam-baseline` `allowed_actions`
- Dedicated `vpc_cidr` (e.g. `10.10.0.0/16`)
- Backend `key = "prod/terraform.tfstate"`

Copy the four files from `../nonprod`, adjust the values above, and update `common_tags`
`Environment = "prod"`.
