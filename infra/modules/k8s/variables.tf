variable "cluster_name" {}

variable "vpc_id" {}

variable "private_subnet_ids" {}

variable "instance_type" {
  type        = list(string)
  default     = ["t3.small"]
  description = "Tipo de instância EC2"
}

variable "principal_user_arn" {}