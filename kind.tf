module "kind_cluster" {
  source = "./kind_cluster"

  kind_cluster_name = var.kind_cluster_name
  kind_cluster_config_path = var.kind_cluster_config_path
}