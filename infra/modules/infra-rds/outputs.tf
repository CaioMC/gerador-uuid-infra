output "rds_endpoint" {
  description = "Endpoint da instância RDS"
  value       = module.rds.db_instance_endpoint
}

output "rds_security_group_id" {
  description = "ID do Security Group do RDS"
  value       = aws_security_group.rds.id
}