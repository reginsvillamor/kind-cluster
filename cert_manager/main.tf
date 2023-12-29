resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  namespace        = var.namespace
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = "1.13.3"
  create_namespace = true
  set {
    name  = "installCRDs"
    value = "true"
  }
}
