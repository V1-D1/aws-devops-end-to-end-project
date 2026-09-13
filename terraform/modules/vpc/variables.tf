
variable "project_name" {
  description = "Name used for AWS resources"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the project VPC"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
}