terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.16.1"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.2.3"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.2.1"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }
  }
}

locals {
  istio_namespace = "istio-system"
  istio_version   = "1.16"
  istio_repo      = "https://raw.githubusercontent.com/istio/istio/release-"
  local_path      = "${path.root}/resources/"
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "default"
}

module "istio_cert_manager_module" {
  source = "./istio-cert-manager"

  istio_namespace = local.istio_namespace
  local_path      = local.local_path
  ingress_domain  = var.ingress_domain
}

module "istio_bookinfo_module" {
  source = "./istio-bookinfo"

  istio_version   = local.istio_version
  istio_repo      = local.istio_repo
  istio_namespace = local.istio_namespace
}

module "istio_addons_module" {
  source = "./istio-addons"

  istio_version   = local.istio_version
  istio_repo      = local.istio_repo
  local_path     = local.local_path
  ingress_domain  = var.ingress_domain
}

