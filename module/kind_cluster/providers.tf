terraform {
  required_providers {
    kind = {
      # https://registry.terraform.io/providers/tehcyx/kind/latest/docs/resources/cluster
      source  = "tehcyx/kind"
      version = "0.5.1"
    }
  }

#  required_version = ">= 1.0.0"
}