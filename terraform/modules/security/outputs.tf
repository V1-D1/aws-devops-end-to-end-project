output "security_group_id" {
  description = "ID of the DevOps security group"
  value       = aws_security_group.devops_sg.id
}