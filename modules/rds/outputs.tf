output "cluster_endpoint" {
  value = aws_rds_cluster.main.endpoint
}

output "cluster_reader_endpoint" {
  value = aws_rds_cluster.main.reader_endpoint
}

output "cluster_id" {
  value = aws_rds_cluster.main.id
}

output "database_name" {
  value = aws_rds_cluster.main.database_name
}

output "port" {
  value = aws_rds_cluster.main.port
}

output "secret_arn" {
  value = aws_secretsmanager_secret.db_credentials.arn
}