output "rds_endpoint" {
  description = "Endpoint da instância RDS"
  value       = aws_db_instance.rds_instance.address
}

output "rds_port" {
  description = "Porta da instância RDS"
  value       = aws_db_instance.rds_instance.port
}

output "rds_db_name" {
  description = "Nome do banco de dados"
  value       = aws_db_instance.rds_instance.db_name
}

output "rds_username" {
  description = "Nome de usuário do banco de dados"
  value       = aws_db_instance.rds_instance.username
}

output "rds_security_group_id" {
  description = "ID do Security Group do RDS"
  value       = aws_security_group.rds.id
}