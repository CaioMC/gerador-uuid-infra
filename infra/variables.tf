variable "project_name" {
  type        = string
  default     = "gerador-uuid-core"
  description = "Nome do projeto"
}

variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "Região da AWS"
}

variable "azs" {
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
  description = "Lista de zonas de disponibilidade"
  validation {
    condition     = length(var.azs) == 3
    error_message = "Deve fornecer exatamente 3 AZs."
  }
}

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "CIDR da VPC"
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "Deve ser um CIDR válido."
  }
}

variable "user_name" {
  type        = string
  default     = "infra-user-project"
  description = "Nome do usuário"
}
