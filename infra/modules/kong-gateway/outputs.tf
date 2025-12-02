# Data Source para ler o serviço do Kong Manager
data "kubernetes_service" "kong_manager_service" {
  metadata {
    name      = "kong-kong-manager"
    namespace = "kong"
  }
}

# Data Source para ler o serviço do Kong Proxy
data "kubernetes_service" "kong_proxy_service" {
  metadata {
    name      = "kong-kong-proxy"
    namespace = "kong"
  }
}

output "kong_manager_endpoint" {
  description = "Endpoint do Kong Manager (GUI)"
  value       = data.kubernetes_service.kong_manager_service.status[0].load_balancer[0].ingress[0].hostname
}

output "kong_proxy_endpoint" {
  description = "Endpoint do Kong Proxy (Gateway)"
  value       = data.kubernetes_service.kong_proxy_service.status[0].load_balancer[0].ingress[0].hostname
}