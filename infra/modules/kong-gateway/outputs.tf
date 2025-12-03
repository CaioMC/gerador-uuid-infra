output "aws_eks_cluster_auth" {
  description = "AWS EKS Cluster Authentication Token"
  value = data.aws_eks_cluster_auth.cluster_au
}