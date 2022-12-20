terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.16.1"
    }
    http = {
      source = "hashicorp/http"
      version = "3.2.1"
    }
    kubectl = {
      source = "gavinbunney/kubectl"
      version = "1.14.0"
    }
  }
}

locals {
  istio_version  = "1.16"
  istio_repo     = "https://raw.githubusercontent.com/istio/istio/release-"
  emisia_repo    = "https://raw.githubusercontent.com/mnikita/setup-cluster-k3s/main/resources/"
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "default"
}

module "istio_bookinfo_module" {
  source  = "./istio-bookinfo"

  istio_version = local.istio_version
  istio_repo = local.istio_repo
}

module "istio_addons_module" {
  source  = "./istio-addons"

  istio_version = local.istio_version
  istio_repo = local.istio_repo
  emisia_repo = local.emisia_repo
}
