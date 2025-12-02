# main.tf (Raiz)

output "kong_manager_endpoint" {
  description = "Endpoint do Kong Manager (GUI)"
  value       = module.kong-gateway.kong_manager_endpoint
}

output "kong_proxy_endpoint" {
  description = "Endpoint do Kong Proxy (Gateway)"
  value       = module.kong-gateway.kong_proxy_endpoint
}