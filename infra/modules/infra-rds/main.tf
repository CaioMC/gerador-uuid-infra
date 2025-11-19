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
  name                    = "rds-pw-${var.project_name}"
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

# Criação explícita do DB Subnet Group (Necessário para RDS em VPCs não-default)
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group-${var.project_name}"
  subnet_ids = var.private_subnets_ids
  description = "DB Subnet Group for RDS instance"
}

# 3.2. Instância RDS (Recurso nativo)
resource "aws_db_instance" "rds_instance" {
  identifier              = "db-${var.project_name}"
  engine                  = var.aws_rds_engine
  engine_version          = var.aws_rds_engine_version
  instance_class          = var.aws_rds_instance_class
  allocated_storage       = var.rds_allocated_storage
  db_name                 = var.rds_db_name
  username                = jsondecode(aws_secretsmanager_secret_version.secret_password_postgres.secret_string)["username"]
  password                = jsondecode(aws_secretsmanager_secret_version.secret_password_postgres.secret_string)["password"]

  # Referências aos recursos criados
  parameter_group_name    = aws_db_parameter_group.db_parameter_group.name
  db_subnet_group_name    = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.rds.id]

  # Configurações de Alta Disponibilidade e Acesso
  multi_az                = true
  publicly_accessible     = false # Boa prática: RDS não deve ser público
  skip_final_snapshot     = true  # Para ambientes de desenvolvimento/teste

  # Tags
  tags = {
    Name        = "db-${var.project_name}"
    Environment = "dev"
  }
}