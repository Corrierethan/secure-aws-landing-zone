# logging — centralized audit logging
# Issue 1.6 (Owner: Andy). Starter scaffold; flesh out org-trail + Config per brief.
#
# Controls: AU-2 (event logging), AU-9 (protection of audit info),
#           AU-11 (audit record retention).

# Versioned, encrypted, access-blocked S3 archive for logs.
resource "aws_s3_bucket" "archive" {
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
      sse_algorithm = "aws:kms"
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
    transition {
      days          = 90
      storage_class = "GLACIER"
    }
    expiration {
      days = var.log_retention_days
    }
  }
}

# TODO(1.6): organization-wide CloudTrail (multi-region, log file validation on)
#            writing to this bucket, and an AWS Config recorder + delivery channel.
