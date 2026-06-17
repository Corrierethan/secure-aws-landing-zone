# Management account composition.
# Step 1: apply -target=module.remote_state with LOCAL state.
# Step 2: uncomment the backend block, `terraform init -migrate-state`, apply the rest.

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
  #   key            = "management/terraform.tfstate"
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
    Environment = "management"
    ManagedBy   = "terraform"
    Owner       = "ascent-devops"
  }
}

module "remote_state" {
  source      = "../../modules/remote-state"
  name_prefix = var.name_prefix
  account_id  = data.aws_caller_identity.current.account_id
  tags        = local.common_tags
}

# Guardrails are applied from the management account once the org/OUs exist.
# module "guardrails" {
#   source           = "../../modules/org-guardrails"
#   name_prefix      = var.name_prefix
#   partition        = var.partition
#   approved_regions = var.approved_regions
#   target_ou_ids    = var.target_ou_ids
# }
