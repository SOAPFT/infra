output "endpoint" {
  value = aws_db_instance.main.endpoint
}

output "id" {
  value = aws_db_instance.main.id
}

output "database_name" {
  value = aws_db_instance.main.db_name
}

output "port" {
  value = aws_db_instance.main.port
}

output "secret_arn" {
  value = aws_secretsmanager_secret.db_credentials.arn
}