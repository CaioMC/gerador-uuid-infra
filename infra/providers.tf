terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  required_version = ">= 1.10.0"
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}

# Data Source para obter o Token de Autenticação do EKS
data "aws_eks_cluster_auth" "cluster_auth" {
  name = module.k8s.cluster_name

  depends_on = [
    module.k8s
  ]
}

# 1. Configuração do Provider Kubernetes
provider "kubernetes" {
  host                   = module.k8s.cluster_endpoint
  cluster_ca_certificate = base64decode(module.k8s.cluster_ca_certificate)
  token                  = data.aws_eks_cluster_auth.cluster_auth.token
}

# 2. Configuração do Provider Helm
provider "helm" {
  kubernetes = {
    host                   = module.k8s.cluster_endpoint
    cluster_ca_certificate = base64decode(module.k8s.cluster_ca_certificate)
    token                  = data.aws_eks_cluster_auth.cluster_auth.token
  }
}