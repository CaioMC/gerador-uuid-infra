# data IAM
data "aws_iam_user" "principal_user" {
  user_name = var.user_name
}

# Usando o módulo oficial da AWS para EKS
module "eks" {
  source = "terraform-aws-modules/eks/aws"
  version = "21.8.0"

  # Argumentos de configuração do cluster no nível superior (Sintaxe Antiga/Alternativa)
  name    = var.cluster_name
  kubernetes_version = "1.33" # Versão EKS

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids # O Control Plane e os Nodes devem ser lançados nas Subnets Privadas

  # Configuração do Node Group
  eks_managed_node_groups = {
    default = {
      name = "node-group-eks"
      instance_types = var.instance_type
      min_size = 1
      max_size = 3
      desired_size = 1

      # Os Nodes também usam as Subnets Privadas
      subnet_ids = var.private_subnet_ids
    }
  }

  # Instalação do Metrics Server como Addon (Nome de variável CORRETO)
  addons = {
    metrics-server = {
      resolve_conflicts = "OVERWRITE"
    }
  }

  # Configuração de Acesso
  access_entries = {
    infra_user = {

      principal_arn = data.aws_iam_user.principal_user.arn  # ARN do usuário IAM
      type = "STANDARD" # Tipo de acesso: STANDARD para usuários IAM

      access_policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }
}