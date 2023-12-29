output "kubernetes_service_host" {
  value = data.local_file.kubernetes_service_host.content
}