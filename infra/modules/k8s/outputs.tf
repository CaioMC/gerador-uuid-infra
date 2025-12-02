output "cluster_id" {
  description = "Nome do Cluster EKS"
  value       = aws_eks_cluster.eks_cluster.id
}

output "cluster_name" {
  description = "Nome do Cluster EKS"
  value       = aws_eks_cluster.eks_cluster.name
}

output "cluster_ca_certificate" {
  description = "Certificado CA do Cluster EKS"
  value = aws_eks_cluster.eks_cluster.certificate_authority[0].data
}

output "cluster_endpoint" {
  description = "Endpoint do Cluster EKS"
  value       = aws_eks_cluster.eks_cluster.endpoint
}

output "cluster_security_group_id" {
  description = "ID do Security Group do Control Plane do Cluster EKS"
  value       = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
}

output "node_security_group_id" {
  description = "ID do Security Group customizado dos nós EKS"
  value       = aws_security_group.eks_node_custom_sg.id
}

output "eks_cluster_role_arn" {
  description = "ARN da IAM Role do Cluster EKS"
  value       = aws_iam_role.eks_cluster_role.arn
}

output "eks_node_role_arn" {
  description = "ARN da IAM Role dos Nós EKS"
  value       = aws_iam_role.eks_node_role.arn
}