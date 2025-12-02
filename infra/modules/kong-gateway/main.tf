# 1. Instalação do Kong Gateway via Helm Chart
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

  depends_on = [
    var.wait_for_stabilization # FORÇA A ESPERA DE 120 SEGUNDOS
  ]
}