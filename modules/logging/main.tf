# logging — centralized audit logging
# Versioned, KMS-encrypted S3 log archive with lifecycle policy. Designed as the
# landing target for an organization CloudTrail and AWS Config.
#
# Controls: AU-2 (event logging), AU-9 (protection of audit info),
#           AU-11 (audit record retention).

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

resource "aws_kms_key" "log_archive" {
  description             = "KMS key for log archive bucket encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "EnableAccountAdmin"
        Effect    = "Allow"
        Principal = { AWS = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root" }
        Action    = "kms:*"
        Resource  = "*"
      }
    ]
  })

  tags = merge(var.tags, { Name = "${var.name_prefix}-log-archive" })
}

resource "aws_kms_alias" "log_archive" {
  name          = "alias/${var.name_prefix}-log-archive"
  target_key_id = aws_kms_key.log_archive.key_id
}

# Versioned, encrypted, access-blocked S3 archive for logs.
resource "aws_s3_bucket" "archive" {
  # checkov:skip=CKV_AWS_18:This IS the log-archive bucket; pointing access logging at itself would recurse. Access logs land here.
  # checkov:skip=CKV_AWS_144:Single-region by design for this reference LZ; cross-region replication is out of scope (tracked separately).
  # checkov:skip=CKV2_AWS_62:Event notifications add no value for a write-once log archive and are intentionally omitted.
  bucket = "${var.name_prefix}-log-archive-${var.account_id}"
  tags   = merge(var.tags, { Name = "${var.name_prefix}-log-archive" })
}

resource "aws_s3_bucket_versioning" "archive" {
  bucket = aws_s3_bucket.archive.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "archive" {
  bucket = aws_s3_bucket.archive.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.log_archive.arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "archive" {
  bucket                  = aws_s3_bucket.archive.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Object Lock-style retention via lifecycle (extend with true Object Lock for WORM).
resource "aws_s3_bucket_lifecycle_configuration" "archive" {
  bucket = aws_s3_bucket.archive.id
  rule {
    id     = "retain-logs"
    status = "Enabled"
    filter {}
    # Clean up failed multipart uploads so partial objects don't linger (CKV_AWS_300).
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
    transition {
      days          = 90
      storage_class = "GLACIER"
    }
    expiration {
      days = var.log_retention_days
    }
  }
}

# Organization-wide CloudTrail (multi-region, log file validation enabled) and
# an AWS Config recorder + delivery channel can be wired to this bucket.
