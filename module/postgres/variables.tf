variable "postgresql_helm_version" {
  type        = string
  description = "The postgresql chart version."
  default     = "14.3.3"
}

variable "postgresql_namespace" {
  type        = string
  description = "The postgresql namespace (it will be created if needed)."
  default     = "postgresql"
}