output "user_name" {
  description = "Nome do usuário IAM criado"
  value       = aws_iam_user.principal_user.name
}

output "user_arn" {
  description = "ARN do usuário IAM criado"
  value       = aws_iam_user.principal_user.arn
}

output "ssm_policy_arn" {
  description = "ARN da política SSM criada"
  value       = aws_iam_policy.ssm_access.arn
}