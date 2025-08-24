output "ecr_repository_url" {
  value       = module.ecr.repository_url
  description = "ECR repository URL"
}

output "alb_dns_name" {
  value       = module.ecs.alb_dns_name
  description = "ALB DNS name"
}

output "cloudfront_domain_name" {
  value       = module.s3_cloudfront.cloudfront_distribution_domain_name
  description = "CloudFront distribution domain name"
}

output "s3_bucket_name" {
  value       = module.s3_cloudfront.s3_bucket_name
  description = "S3 bucket name for uploads"
}

output "rds_endpoint" {
  value       = module.rds.endpoint
  description = "RDS endpoint"
}

output "database_secret_arn" {
  value       = module.rds.secret_arn
  description = "Database credentials secret ARN"
  sensitive   = true
}

output "ecs_cluster_name" {
  value       = module.ecs.cluster_name
  description = "ECS cluster name"
}

output "ecs_service_name" {
  value       = module.ecs.service_name
  description = "ECS service name"
}

output "bastion_public_ip" {
  value       = var.enable_bastion ? module.bastion[0].bastion_public_ip : null
  description = "Bastion host public IP"
}

output "bastion_ssh_command" {
  value       = var.enable_bastion ? module.bastion[0].ssh_command : null
  description = "SSH command to connect to bastion host"
}

output "rds_port_forward_command" {
  value       = var.enable_bastion ? module.bastion[0].port_forward_command : null
  description = "SSH port forwarding command for RDS access"
}