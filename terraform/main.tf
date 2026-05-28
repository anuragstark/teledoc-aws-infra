# ============================================
# TeleDoc — Terraform Main Configuration
# ============================================
# Provider: AWS (ap-south-1 Mumbai)
# Backend: S3 (remote state)
# ============================================

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # S3 Backend for Remote State with DynamoDB Locking
  # S3 bucket and DynamoDB table already created manually by user
  backend "s3" {
    bucket         = "teledoc-terraform-backend"
    key            = "teledoc/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    dynamodb_table = "terraform-lock"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "TeleDoc"
      Environment = "production"
      ManagedBy   = "Terraform"
    }
  }
}
