module "vault" {
  source = "./hashicorp_vault"

  kubernetes_host = "https://${module.ingress_nginx.kubernetes_service_host}:443"
  vault_namespace = var.vault_namespace
}
