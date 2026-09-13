resource "aws_key_pair" "project_key" {
  key_name   = "${var.project_name}-key"
  public_key = file(pathexpand("~/.ssh/aws-devops-project-key.pub"))
}