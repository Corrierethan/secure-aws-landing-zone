# Security/audit account composition.
# Hosts the centralized log archive — no workloads run here.

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }

  # backend "s3" {
  #   bucket         = "ascent-lz-tfstate-<ACCOUNT_ID>"
  #   key            = "security/terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "ascent-lz-tfstate-lock"
  #   encrypt        = true
  # }
}

provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}

locals {
  common_tags = {
    Project     = "secure-aws-landing-zone"
    Environment = "security"
    ManagedBy   = "terraform"
    Owner       = "ascent-devops"
  }
}

module "logging" {
  source      = "../../modules/logging"
  name_prefix = "${var.name_prefix}-security"
  account_id  = data.aws_caller_identity.current.account_id
  tags        = local.common_tags
}
