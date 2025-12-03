# Data Source para obter o Token de Autenticação do EKS
data "aws_eks_cluster_auth" "cluster_au" {
  name = var.cluster_name
}

# 5.5. Força uma pausa para o Control Plane do EKS estabilizar
resource "time_sleep" "wait_eks_for_stabilization" {
  # Espera 120 segundos (2 minutos) após a criação do cluster EKS
  create_duration = "120s"
}

# 1. Configuração do Provider Kubernetes
provider "kubernetes" {
  host                   = var.cluster_endpoint
  cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
  token                  = data.aws_eks_cluster_auth.cluster_au.token
}

# 2. Configuração do Provider Helm
provider "helm" {
  kubernetes = {
    host                   = var.cluster_endpoint
    cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
    token                  = data.aws_eks_cluster_auth.cluster_au.token
  }
}

# 3. Instalação do Kong Gateway via Helm Chart
resource "helm_release" "kong" {
  name       = "kong"
  repository = "https://charts.konghq.com"
  chart      = "kong"
  namespace  = "kong"
  create_namespace = true

  # Configuração do Kong Manager e do Banco de Dados (RDS )
  set = [
    # Configuração para o Proxy (Gateway)
    {
      name  = "proxy.type"
      value = "LoadBalancer"
    },
    # Configuração para o Kong Manager (GUI)
    {
      name  = "manager.enabled"
      value = "true"
    },
    {
      name  = "manager.type"
      value = "LoadBalancer" # Expor o Manager via LoadBalancer
    },
    # Configuração do Banco de Dados (Usando o RDS)
    {
      name  = "postgresql.enabled"
      value = "false" # Desabilita o PostgreSQL interno do Helm Chart
    },
    {
      name  = "env.database"
      value = "postgres"
    },
    {
      name  = "env.pg_host"
      value = var.rds_endpoint # Endpoint do seu RDS
    },
    {
      name  = "env.pg_user"
      value = var.rds_username # Usuário do seu RDS
    },
    {
      name  = "env.pg_password"
      value = var.rds_password # Senha do seu RDS
    },
    {
      name  = "env.pg_database"
      value = var.rds_database # Nome do DB do seu RDS
    }
  ]

  depends_on = [time_sleep.wait_eks_for_stabilization]
}