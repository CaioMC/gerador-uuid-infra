output "ecr_repository_url" {
  description = "URL completa do repositório ECR"
  value       = aws_ecr_repository.gerador_uuid_core.repository_url
}

output "ecr_repository_name" {
  description = "Nome do repositório ECR"
  value       = aws_ecr_repository.gerador_uuid_core.name
}