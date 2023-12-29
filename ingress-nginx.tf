module "ingress_nginx" {
  source = "./module/ingress_nginx"

  ingress_nginx_helm_version = var.ingress_nginx_helm_version
  ingress_nginx_namespace = var.ingress_nginx_namespace

  depends_on = [ module.kind_cluster ]
}