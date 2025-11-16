output "cluster_id" {
  description = "ID do cluster EKS"
  value       = module.eks.cluster_id
}

output "cluster_endpoint" {
  description = "Endpoint do cluster EKS"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "ID do Security Group do cluster EKS"
  value       = module.eks.cluster_security_group_id
}

output "oidc_provider_arn" {
  description = "ARN do provedor OIDC para IRSA"
  value       = module.eks.oidc_provider_arn
}
