output "vpc_id" {
  description = "ID da VPC criada"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs das subnets públicas"
  value       = module.vpc.public_subnets
}

output "private_subnet_ids" {
  description = "IDs das subnets privadas"
  value       = module.vpc.private_subnets
}

output "internet_gateway_id" {
  description = "O ID do Internet Gateway criado pelo módulo VPC."
  value       = module.vpc.igw_id
}

output "nat_gateway_ids" {
  description = "IDs dos NAT Gateways"
  value       = module.vpc.natgw_ids
}