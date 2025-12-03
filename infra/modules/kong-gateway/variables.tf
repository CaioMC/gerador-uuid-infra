variable "cluster_id" {
    description = "ID do cluster EKS"
}

variable "cluster_name" {
  description = "Nome do cluster EKS"
  type        = string
}

variable "cluster_endpoint" {
  description = "Endpoint da API do cluster EKS"
  type        = string
}

variable "cluster_ca_certificate" {
  description = "Certificado CA do cluster EKS (base64 encoded)"
  type        = string
}

# Variáveis do RDS (NOVAS)
variable "rds_endpoint" {
  description = "Endpoint do RDS PostgreSQL"
  type        = string
}

variable "rds_username" {
  description = "Usuário do RDS"
  type        = string
}

variable "rds_password" {
  description = "Senha do RDS"
  type        = string
}

variable "rds_database" {
  description = "Nome do banco de dados do RDS"
  type        = string
}