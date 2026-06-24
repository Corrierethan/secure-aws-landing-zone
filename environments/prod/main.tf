# Production workload account composition.
# Same modules as nonprod but with HA networking and a dedicated CIDR.

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
  #   key            = "prod/terraform.tfstate"
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
    Environment = "prod"
    ManagedBy   = "terraform"
    Owner       = "ascent-devops"
  }
}

module "networking" {
  source             = "../../modules/networking"
  name_prefix        = "${var.name_prefix}-prod"
  vpc_cidr           = var.vpc_cidr
  az_count           = 3
  single_nat_gateway = false # per-AZ NAT for high availability
  tags               = local.common_tags
}

module "iam_baseline" {
  source      = "../../modules/iam-baseline"
  name_prefix = "${var.name_prefix}-prod"
  tags        = local.common_tags
}

module "logging" {
  source      = "../../modules/logging"
  name_prefix = "${var.name_prefix}-prod"
  account_id  = data.aws_caller_identity.current.account_id
  tags        = local.common_tags
}
