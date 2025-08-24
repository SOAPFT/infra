output "bastion_instance_id" {
  description = "ID of the bastion host EC2 instance"
  value       = aws_instance.bastion.id
}

output "bastion_public_ip" {
  description = "Public IP of the bastion host"
  value       = aws_eip.bastion.public_ip
}

output "bastion_security_group_id" {
  description = "Security group ID of the bastion host"
  value       = aws_security_group.bastion.id
}

output "ssh_command" {
  description = "SSH command to connect to bastion host"
  value       = "ssh -i ~/.ssh/your-key.pem ec2-user@${aws_eip.bastion.public_ip}"
}

output "port_forward_command" {
  description = "SSH port forwarding command for RDS access"
  value       = "ssh -i ~/.ssh/your-key.pem -L 5432:${var.rds_endpoint_host}:5432 ec2-user@${aws_eip.bastion.public_ip}"
}