output "capacity_provider_name" {
  value = aws_ecs_capacity_provider.ec2.name
}

output "autoscaling_group_arn" {
  value = aws_autoscaling_group.ec2_ecs.arn
}

output "launch_template_id" {
  value = aws_launch_template.ec2_ecs.id
}

output "security_group_id" {
  value = aws_security_group.ec2_ecs.id
}

output "instance_profile_name" {
  value = aws_iam_instance_profile.ec2_ecs_instance_profile.name
}