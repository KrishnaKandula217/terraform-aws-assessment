terraform {
  required_version = ">= 1.6.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "terraform-state-bucket"
    key            = "assessment/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = var.common_tags
  }
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"

  vpc_cidr             = var.vpc_cidr
  environment          = var.environment
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  project_name         = var.project_name
}

# S3 Module for Application Logs
module "s3" {
  source = "./modules/s3"

  bucket_name  = "${var.project_name}-logs-${var.environment}-${data.aws_caller_identity.current.account_id}"
  environment  = var.environment
  project_name = var.project_name
}

# IAM Module
module "iam" {
  source = "./modules/iam"

  environment  = var.environment
  project_name = var.project_name
  s3_bucket_arn = module.s3.bucket_arn
}

# EC2 Module
module "ec2" {
  source = "./modules/ec2"

  environment          = var.environment
  project_name         = var.project_name
  subnet_id            = module.vpc.private_subnet_ids[0]
  vpc_id               = module.vpc.vpc_id
  instance_type        = var.ec2_instance_type
  iam_instance_profile = module.iam.instance_profile_name
  key_name             = var.ec2_key_name
}

# Data source to get current account ID
data "aws_caller_identity" "current" {}
