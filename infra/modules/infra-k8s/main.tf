# data IAM
resource "aws_iam_user" "principal_user" {
  name = var.user_name
}

resource "aws_iam_policy" "ssm_access" {
  name        = "SSMParameterAccessForEKS"
  description = "Permite acesso a parâmetros SSM para AMI otimizada do EKS"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ssm:DescribeParameters"
        ]
        Resource = "*"
        Effect   = "Allow"
      },
      {
        Action = [
          "ssm:GetParameter"
        ]
        Resource = "arn:aws:ssm:*:*:parameter/aws/service/eks/optimized-ami/"
        Effect   = "Allow"
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "ssm_access" {
  user       = aws_iam_user.principal_user.name
  policy_arn = aws_iam_policy.ssm_access.arn
}

resource "aws_iam_user_policy_attachment" "iam_readonly" {
  user       = aws_iam_user.principal_user.name
  policy_arn = "arn:aws:iam::aws:policy/IAMReadOnlyAccess"
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

      # Adicionar o tipo de AMI para evitar a consulta ao SSM
      # ami_type = "AL2023_x86_64_STANDARD"

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

      principal_arn = aws_iam_user.principal_user.arn  # ARN do usuário IAM
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