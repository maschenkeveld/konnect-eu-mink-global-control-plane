terraform {
  required_providers {
    konnect = {
      source = "kong/konnect"
      version = "2.10.0"
    }
    konnect-beta = {
      source  = "kong/konnect-beta"
      version = "0.8.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "3.0.0"
    }
    time = {
      source  = "hashicorp/time"
    }
  }
}

provider "konnect" {
  personal_access_token = var.KPAT
  server_url            = "https://${var.konnect_region}.api.konghq.com"
}

provider "konnect-beta" {
  personal_access_token = var.KPAT
  server_url            = "https://${var.konnect_region}.api.konghq.com"
}

provider "vault" {
  address = "https://vault.pve-1.schenkeveld.io:8200"
  token   = "${var.HCV_ROOT_TOKEN}"
}