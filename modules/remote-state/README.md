# Module: `remote-state`

Bootstraps the Terraform backend: an encrypted, versioned, TLS-only S3 bucket for state plus a
DynamoDB table for locking, with a dedicated KMS key.

## Why it exists

Terraform needs somewhere to store state *before* you have a backend — a classic chicken-and-egg
problem. Apply this module once with local state, then migrate the backend to the bucket it
created (`terraform init -migrate-state`).

## Usage

```hcl
module "remote_state" {
  source      = "../../modules/remote-state"
  name_prefix = "ascent-lz"
  account_id  = data.aws_caller_identity.current.account_id
  tags        = local.common_tags
}
```

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `name_prefix` | Prefix for all resource names | `string` | n/a |
| `account_id` | AWS account ID (appended to bucket name) | `string` | n/a |
| `tags` | Tags applied to all resources | `map(string)` | `{}` |

## Outputs

| Name | Description |
|------|-------------|
| `state_bucket_name` | S3 bucket name for state |
| `state_bucket_arn` | S3 bucket ARN |
| `lock_table_name` | DynamoDB lock table name |
| `kms_key_arn` | KMS key ARN encrypting state |

## Controls

NIST 800-53: **SC-12**, **SC-28** (encryption at rest), **AU-9** (protecting state that may
contain sensitive values).
