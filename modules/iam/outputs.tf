output "ecs_task_execution_role_arn" {
  value = aws_iam_role.ecs_task_execution_role.arn
}

output "ecs_task_role_arn" {
  value = aws_iam_role.ecs_task_role.arn
}

output "github_actions_role_arn" {
  value = var.enable_github_actions ? aws_iam_role.github_actions[0].arn : null
}