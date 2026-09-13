output "app_instance_id" {
  description = "EC2 instance ID of the application server"
  value       = module.app.instance_id
}

output "app_public_ip" {
  description = "Public IP of the application server"
  value       = module.app.public_ip
}

output "app_private_ip" {
  description = "Private IP of the application server"
  value       = module.app.private_ip
}

output "devops_instance_id" {
  description = "EC2 instance ID of the DevOps/Jenkins server"
  value       = module.devops.instance_id
}

output "devops_public_ip" {
  description = "Public IP of the DevOps/Jenkins server"
  value       = module.devops.public_ip
}

output "devops_private_ip" {
  description = "Private IP of the DevOps/Jenkins server"
  value       = module.devops.private_ip
}

output "monitoring_instance_id" {
  description = "EC2 instance ID of the monitoring server"
  value       = module.monitoring.instance_id
}

output "monitoring_public_ip" {
  description = "Public IP of the monitoring server"
  value       = module.monitoring.public_ip
}

output "monitoring_private_ip" {
  description = "Private IP of the monitoring server"
  value       = module.monitoring.private_ip
}