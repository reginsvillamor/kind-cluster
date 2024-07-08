resource "helm_release" "vault" {
  name             = "vault"
  namespace        = var.vault_namespace
  repository       = "https://helm.releases.hashicorp.com"
  chart            = "vault"
  version          = "0.28.0"
  create_namespace = true

  values = [file("${path.module}/values.yaml")]
}

resource "null_resource" "wait_for_vault" {
  triggers = {
    key = uuid()
  }

  provisioner "local-exec" {
    command = <<EOF
      printf "\nWaiting for vault...\n"

      kubectl --kubeconfig ~/.kind_kube/config wait --namespace ${var.vault_namespace} \
        --for=condition=ready pod \
        --selector=app.kubernetes.io/instance=vault \
        --timeout=90s 
    EOF
  }

  depends_on = [helm_release.vault]
}

resource "vault_mount" "internal" {
  path        = "internal"
  type        = "kv"
  options     = { version = "2" }
  description = "KV Version 2 secret engine mount"

  depends_on = [vault_auth_backend.kubernetes]
}

resource "vault_kv_secret_v2" "secret" {
  mount               = vault_mount.internal.path
  name                = "database/config"
  cas                 = 1
  delete_all_versions = true
  data_json           = jsonencode({ username = "zap", password = "bar" })
}

resource "vault_auth_backend" "kubernetes" {
  type = "kubernetes"

  depends_on = [null_resource.wait_for_vault]
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
