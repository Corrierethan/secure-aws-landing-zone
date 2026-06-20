# `prod` environment

Production workload account composition. **Issue 1.8 (Andy).**

## What goes here

This environment mirrors [`../nonprod`](../nonprod) but with production-grade settings. It wires
up the same three modules — `networking`, `iam-baseline`, and `logging` — with hardened defaults.

## Key differences from nonprod

| Setting | nonprod | prod |
|---|---|---|
| `single_nat_gateway` | `true` (cost saving) | `false` (one NAT per AZ for high availability) |
| `vpc_cidr` | `10.20.0.0/16` | `10.10.0.0/16` (dedicated, non-overlapping range) |
| `Environment` tag | `nonprod` | `prod` |
| Backend state key | `nonprod/terraform.tfstate` | `prod/terraform.tfstate` |

## Files to create

| File | Purpose |
|---|---|
| `main.tf` | Provider config, backend block, module calls for networking + iam-baseline + logging |
| `variables.tf` | `aws_region`, `name_prefix`, `vpc_cidr` with prod defaults |
| `outputs.tf` | Pass through VPC ID, subnet IDs, and log group name from module outputs |
| `terraform.tfvars.example` | Example values a user fills in before running `terraform apply` |

## How to deploy

```bash
cd environments/prod
terraform init        # configure the S3 backend
terraform plan        # review what will be created
terraform apply       # deploy
```

## Controls

Same as nonprod — SC-7, AC-4, AU-12 via networking; AC-2, AC-6, IA-2 via IAM; AU-2, AU-9 via
logging — but the HA NAT setup ensures boundary protection (SC-7) survives an AZ failure.
