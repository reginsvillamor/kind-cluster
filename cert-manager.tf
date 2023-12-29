module "cert_manager" {
  source = "./module/cert_manager"

  depends_on = [module.kind_cluster]
}
