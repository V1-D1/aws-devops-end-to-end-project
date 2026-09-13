variable "aws_region" {
  description = "AWS region where the infrastructure will be created"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Name used for AWS resources"
  type        = string
  default     = "aws-devops-project"
}

variable "vpc_cidr" {
  description = "CIDR block for the project VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

