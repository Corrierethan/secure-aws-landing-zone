# Module: `logging`

Centralized audit logging archive. **Issue 1.6 (Andy).** Starter scaffold — extend with the
org CloudTrail and AWS Config recorder per the checklist.

## Build checklist (issue 1.6)

- [x] Versioned, KMS-encrypted, public-access-blocked log archive bucket
- [x] Lifecycle: transition to Glacier + long retention (~7 yr)
- [ ] Organization CloudTrail (multi-region, log file validation enabled)
- [ ] AWS Config recorder + delivery channel writing to the archive
- [ ] S3 Object Lock (WORM) for tamper-evident retention

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `name_prefix` | Prefix for resource names | `string` | n/a |
| `account_id` | AWS account ID (bucket name suffix) | `string` | n/a |
| `log_retention_days` | Days before log expiration | `number` | `2555` |
| `tags` | Tags for all resources | `map(string)` | `{}` |

## Outputs

| Name | Description |
|------|-------------|
| `log_archive_bucket_name` | Log archive bucket name |
| `log_archive_bucket_arn` | Log archive bucket ARN |

## Controls

NIST 800-53: **AU-2**, **AU-9**, **AU-11**.
