# Module: `networking`

A hardened, multi-AZ VPC: public/private subnets across N AZs, NAT egress, VPC Flow Logs to
CloudWatch, and a stripped default security group (deny-all baseline).

## Usage

```hcl
module "networking" {
  source             = "../../modules/networking"
  name_prefix        = "ascent-prod"
  vpc_cidr           = "10.10.0.0/16"
  az_count           = 3
  single_nat_gateway = false   # true only for dev to save cost
  tags               = local.common_tags
}
```

## Design notes

- **No auto-assigned public IPs** — even public subnets require explicit ENI association.
- **Default SG is emptied** so nothing relies on the permissive default.
- **Flow logs capture ALL traffic** to a retained CloudWatch log group (audit evidence).
- **NAT per AZ** by default for HA; flip `single_nat_gateway` for cheap dev environments.

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `name_prefix` | Prefix for resource names | `string` | n/a |
| `vpc_cidr` | VPC CIDR block | `string` | `"10.0.0.0/16"` |
| `az_count` | Number of AZs to span | `number` | `3` |
| `single_nat_gateway` | One NAT instead of per-AZ (dev only) | `bool` | `false` |
| `flow_log_retention_days` | Flow log retention | `number` | `365` |
| `tags` | Tags for all resources | `map(string)` | `{}` |

## Outputs

| Name | Description |
|------|-------------|
| `vpc_id` | VPC ID |
| `vpc_cidr` | VPC CIDR |
| `public_subnet_ids` | Public subnet IDs |
| `private_subnet_ids` | Private subnet IDs |
| `nat_gateway_ids` | NAT gateway IDs |
| `flow_log_group_name` | Flow log CloudWatch group |

## Controls

NIST 800-53: **SC-7** (boundary protection), **AC-4** (information flow), **AU-12** (flow logs).
