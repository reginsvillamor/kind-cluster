module "postgres" {
  source = "./module/postgres"

  depends_on = [ module.kind_cluster ]
}