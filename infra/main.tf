# 1. Criação da VPC e Subnets
module "vpc" {
  source = "./modules/vpc"

  vpc_name             = var.project_name
  vpc_cidr             = var.vpc_cidr
  azs                  = var.azs
}

# 2. Criação do Usuário IAM e Políticas de Acesso
module "iam-access" {
  source = "./modules/iam-access"

  user_name =  var.user_name

  depends_on = [module.vpc]
}

# 3. Criação do ECR
module "ecr" {
  source = "./modules/ecr"

  ecr_repository_name = var.project_name

  depends_on = [module.iam-access]
}

# 4. Criação do Cluster EKS
module "k8s" {
  source = "./modules/k8s"

  cluster_name        = var.project_name
  vpc_id              = module.vpc.vpc_id
  private_subnet_ids  = module.vpc.private_subnet_ids # Passa os IDs das Subnets Privadas
  principal_user_arn  = module.iam-access.user_arn
}

# 5. Criação do RDS
module "rds" {
  source = "./modules/rds"

  project_name          = var.project_name
  vpc_id                = module.vpc.vpc_id
  private_subnets_ids   = module.vpc.private_subnet_ids # Passa os IDs das Subnets Privadas
  eks_security_group_id = module.k8s.cluster_security_group_id # Passa o ID do Security Group do EKS para a regra de Ingress do RDS

  depends_on = [module.vpc, module.k8s]
}