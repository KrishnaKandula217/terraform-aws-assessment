# Development Environment Configuration

environment = "dev"
aws_region  = "us-east-1"

# VPC Configuration
vpc_cidr             = "10.0.0.0/16"
availability_zones   = ["us-east-1a", "us-east-1b"]
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]

# EC2 Configuration
ec2_instance_type = "t3.medium"
ec2_key_name      = "devadmin-key" 

# Tags
common_tags = {
  Environment = "dev"
  ManagedBy   = "Terraform"
  Owner       = "DevOps"
  Project     = "TerraformAssessment"
  CostCenter  = "Development"
}
