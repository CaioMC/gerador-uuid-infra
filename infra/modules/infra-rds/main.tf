# 3.1. Security Group para o RDS
resource "aws_security_group" "rds" {

  name        = "rds-${var.project_name}"
  description = "Permite acesso ao RDS apenas do EKS"
  vpc_id      = var.vpc_id

  # Regra de Entrada (Ingress) - A CHAVE DA SEGURANÇA
  ingress {
    description = "Acesso do EKS"
    from_port   = 5432 # Porta do PostgreSQL (exemplo)
    to_port     = 5432
    protocol    = "tcp"
    # Referencia o Security Group do EKS como fonte
    security_groups = [var.eks_security_group_id]
  }

  # Regra de Saída (Egress) - Permite que o RDS faça chamadas externas (ex:para atualizações)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Secrets Manager para armazenar as credenciais do PostgreSQL
resource "aws_secretsmanager_secret" "secret_user_postgres" {
  name                    = "rds-password-${var.project_name}"
  description             = "Credenciais do banco PostgreSQL RDS"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "secret_password_postgres" {
  secret_id = aws_secretsmanager_secret.secret_user_postgres.id
  secret_string = jsonencode({
    username = "postgres"
    password = var.password
  })
}

resource "aws_db_parameter_group" "db_parameter_group" {
  name        = "db-rds-${var.aws_rds_engine}-16"
  family      = var.db_parameter_group_family
  description = "RDS cluster parameter group"
}

# 3.2. Instância RDS
module "rds" {

  source                    = "terraform-aws-modules/rds/aws"
  version                   = "~> 5.0"
  identifier                = "db-${var.project_name}"
  engine                    = var.aws_rds_engine
  engine_version            = var.aws_rds_engine_version
  instance_class            = var.aws_rds_instance_class
  allocated_storage         = var.rds_allocated_storage
  parameter_group_name      = aws_db_parameter_group.db_parameter_group.name
  db_name                   = var.rds_db_name
  username                  = jsondecode(aws_secretsmanager_secret_version.secret_password_postgres.secret_string)["username"]
  password                  = jsondecode(aws_secretsmanager_secret_version.secret_password_postgres.secret_string)["password"]

  # Subnet Group deve usar as Subnets Privadas
  vpc_security_group_ids = [aws_security_group.rds.id]
  subnet_ids             = var.private_subnets_ids
  multi_az               = true

  # Desativa a criação automática do grupo de parâmetros
  create_db_parameter_group = false
}
