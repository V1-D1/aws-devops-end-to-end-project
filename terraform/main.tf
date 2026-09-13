data "aws_ami" "ubuntu" {
  most_recent = true

  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

module "vpc" {
  source             = "./modules/vpc"
  project_name       = var.project_name
  vpc_cidr           = var.vpc_cidr
  public_subnet_cidr = var.public_subnet_cidr
}


module "security" {
  source = "./modules/security"

  project_name = var.project_name
  vpc_id       = module.vpc.vpc_id
}

module "app" {
  source = "./modules/ec2"

  project_name      = var.project_name
  instance_name     = "app"
  ami_id            = data.aws_ami.ubuntu.id
  instance_type     = "t3.micro"
  subnet_id         = module.vpc.public_subnet_id
  security_group_id = module.security.security_group_id
  key_name          = aws_key_pair.project_key.key_name
}

module "devops" {
  source = "./modules/ec2"

  project_name      = var.project_name
  instance_name     = "devops"
  ami_id            = data.aws_ami.ubuntu.id
  instance_type     = "t3.medium"
  subnet_id         = module.vpc.public_subnet_id
  security_group_id = module.security.security_group_id
  key_name          = aws_key_pair.project_key.key_name
}

module "monitoring" {
  source = "./modules/ec2"

  project_name      = var.project_name
  instance_name     = "monitoring"
  ami_id            = data.aws_ami.ubuntu.id
  instance_type     = "t3.micro"
  subnet_id         = module.vpc.public_subnet_id
  security_group_id = module.security.security_group_id
  key_name          = aws_key_pair.project_key.key_name
}