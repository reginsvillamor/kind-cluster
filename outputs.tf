output "kubernetes_endpoint" {
  value = module.kind_cluster.kubernetes_endpoint
}

output "kubernetes_service_host" {
  value = module.ingress_nginx.kubernetes_service_host
}
