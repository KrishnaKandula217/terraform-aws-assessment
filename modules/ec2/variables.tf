# EC2 Module Variables

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where EC2 will be deployed"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID where EC2 will be deployed"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "iam_instance_profile" {
  description = "IAM instance profile name"
  type        = string
}

variable "key_name" {
  description = "EC2 key pair name"
  type        = string
  default     = ""
}
