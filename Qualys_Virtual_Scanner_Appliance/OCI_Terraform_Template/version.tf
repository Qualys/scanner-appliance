terraform {
  required_version = ">= 1.9.2"

  required_providers {
    oci = {
      source  = "hashicorp/oci"
      version = "~> 6.37.0"
    }
  }
}