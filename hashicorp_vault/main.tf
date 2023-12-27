resource "kubernetes_namespace" "vault" {
  metadata {
    name = var.vault_namespace
  }
}

resource "helm_release" "vault" {
  name       = "vault"
  namespace  = kubernetes_namespace.vault.metadata.0.name
  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault"
  version    = "0.27.0"

  values = [file("hashicorp_vault/values.yaml")]

}

resource "vault_mount" "secret" {
  path        = "custom-secret" # NOTE: 'secret/' path default in 'development' mode
  type        = "kv"
  options     = { version = "2" }
  description = "KV Version 2 secret engine mount"

  depends_on = [helm_release.vault]
}

resource "vault_kv_secret_v2" "secret" {
  mount               = vault_mount.secret.path
  name                = "database/config"
  cas                 = 1
  delete_all_versions = true
  data_json           = jsonencode({ username = "zap", password = "bar" })
}

# resource "kubernetes_secret" "vault_db_reader" {
#   metadata {
#     name = "vault-db-reader"
#     namespace = "httpd"
#     annotations = {
#       "kubernetes.io/service-account.name" = kubernetes_service_account.vault_db_reader.metadata.0.name
#     } 
#   }
#   type                           = "kubernetes.io/service-account-token"
#   wait_for_service_account_token = true
# }

# resource "kubernetes_service_account" "vault_db_reader" {
#   metadata {
#     name      = "vault-db-reader"
#     namespace = "httpd"
#   }
#   secret {
#     name = "vault-db-reader"
#   }
# }

resource "vault_auth_backend" "kubernetes" {
  type = "kubernetes"
}

resource "vault_kubernetes_auth_backend_config" "kubernetes" {
  backend         = vault_auth_backend.kubernetes.path
  kubernetes_host = var.kubernetes_host
}

resource "vault_policy" "db_read_policy" {
  depends_on = [vault_kv_secret_v2.secret]

  name   = "vault-db-reader"
  policy = <<EOT
    path "${vault_kv_secret_v2.secret.path}" {
      capabilities = ["read"]
    }
  EOT
}

resource "vault_kubernetes_auth_backend_role" "service_reader_role" {
  role_name                        = "vault-db-reader"
  backend                          = vault_auth_backend.kubernetes.path
  bound_service_account_names      = ["vault-db-reader"]
  bound_service_account_namespaces = ["default", "httpd"]
  token_policies                   = [vault_policy.db_read_policy.name]
  token_ttl                        = var.token_ttl
}
