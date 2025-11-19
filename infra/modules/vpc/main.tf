locals {
  # Subnets públicas
  public_subnets_cidr = [
    cidrsubnet(var.vpc_cidr, 4, 0),
    cidrsubnet(var.vpc_cidr, 4, 1),
    cidrsubnet(var.vpc_cidr, 4, 2)
  ]

  # Subnets privadas
  private_subnets_cidr = [
    cidrsubnet(var.vpc_cidr, 4, 3),
    cidrsubnet(var.vpc_cidr, 4, 4),
    cidrsubnet(var.vpc_cidr, 4, 5)
  ]
}

# Usando o módulo oficial da AWS para VPC
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.9.0"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = var.azs
  public_subnets  = local.public_subnets_cidr
  private_subnets = local.private_subnets_cidr

  enable_dns_support   = true
  enable_dns_hostnames = true
  enable_nat_gateway = true
  single_nat_gateway = true # Cria apenas 1 NAT Gateway para simplificar

  # Tags para o EKS Controller descobrir as subnets
  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  tags = {
    Terraform = "true"
  }
}