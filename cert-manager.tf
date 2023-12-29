module "cert_manager" {
  source = "./cert_manager"

  depends_on = [module.kind_cluster]
}
