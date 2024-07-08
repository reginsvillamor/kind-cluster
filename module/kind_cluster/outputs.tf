#kubeconfig - The kubeconfig for the cluster after it is created
#client_certificate - Client certificate for authenticating to cluster.
#client_key - Client key for authenticating to cluster.
#cluster_ca_certificate - Client verifies the server certificate with this CA cert.
#endpoint - Kubernetes APIServer endpoint.

output "kubeconfig" {
  value = kind_cluster.default.kubeconfig
}

output "client_certificate" {
  value = kind_cluster.default.client_certificate
}

output "client_key" {
  value = kind_cluster.default.client_key
}

output "cluster_ca_certificate" {
  value = kind_cluster.default.cluster_ca_certificate
}

output "kubernetes_endpoint" {
  value = kind_cluster.default.endpoint
}