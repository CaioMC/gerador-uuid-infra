variable "project_name" {}

variable "vpc_id" {}

variable "private_subnets_ids" {}

variable "eks_security_group_id" {}

## RDS Config Variables ##
variable "rds_db_name" { default = "postgres" }

variable "aws_rds_engine" { default = "postgres" }

variable "aws_rds_engine_version" { default = "16.6" }

variable "aws_rds_instance_class" { default = "db.t4g.micro" }

variable "rds_allocated_storage" {
  description = "Armazenamento em GB (Free Tier tipicamente até 20GB)"
  default     = 20
}

variable "password" { default = "gerador123" }
