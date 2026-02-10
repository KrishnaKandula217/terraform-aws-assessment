# Production Environment Configuration

environment = "prod"
aws_region  = "us-east-1"

# VPC Configuration
vpc_cidr             = "10.0.0.0/16"
availability_zones   = ["us-east-1a", "us-east-1b"]
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]

# EC2 Configuration
ec2_instance_type = "t3.large" # Larger instance for prod
ec2_key_name      = "prodadmin-key"

# Tags
common_tags = {
  Environment = "prod"
  ManagedBy   = "Terraform"
  Owner       = "DevOps"
  Project     = "TerraformAssessment"
  CostCenter  = "Production"
}
