terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14"
    }
  }
  required_version = ">= 1.10.0"
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}


provider "kubectl" {
  apply_retry_count      = 5
  host                   = module.k8s.cluster_endpoint
  cluster_ca_certificate = base64decode(module.k8s.cluster_ca_certificate)
  load_config_file       = false
  token                  = module.kong-gateway.aws_eks_cluster_auth.token
}