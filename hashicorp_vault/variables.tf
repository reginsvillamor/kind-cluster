variable "vault_namespace" {
  type        = string
  description = "The vault namespace to use."
  nullable    = false
}

variable "kubernetes_host" {
  type        = string
  description = "Kubernetes server."
  nullable    = false
}

variable "token_ttl" {
  type        = string
  description = "Role lease"
  default     = "86400"
}
