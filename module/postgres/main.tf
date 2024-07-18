resource "helm_release" "postgresql" {
  name  = "postgresql"
  repository = "https://charts.bitnami.com/bitnami"
  chart = "postgresql"
  version    = var.postgresql_helm_version

  namespace        = var.postgresql_namespace
  create_namespace = true

  values = [file("${path.module}/values.yaml")]
}