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
  dash_version    = "v2.6.1"
  dash_repo       = "https://raw.githubusercontent.com/kubernetes/dashboard/"

  modules = [
    for moduleName in split(",", var.module) : trimspace(moduleName)
  ]
}

output "modules" {
  value = local.modules
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "default"
}

module "istio-cert-manager-module" {
  source = "./modules/istio-cert-manager"

  count = contains(local.modules, "istio-cert-manager") ? 1 : 0

  istio_namespace = local.istio_namespace
  ingress_domain  = var.ingress_domain
}

module "istio-bookinfo-module" {
  source = "./modules/istio-bookinfo"

  count = contains(local.modules, "istio-bookinfo") ? 1 : 0

  istio_version   = local.istio_version
  istio_repo      = local.istio_repo
  istio_namespace = local.istio_namespace
}

module "istio-addons-module" {
  source = "./modules/istio-addons"

  count = contains(local.modules, "istio-addons") ? 1 : 0

  istio_version  = local.istio_version
  istio_repo     = local.istio_repo
  ingress_domain = var.ingress_domain
}

module "k8s-dashboard" {
  source = "./modules/k8s-dashboard"

  count = contains(local.modules, "k8s-dashboard") ? 1 : 0

  dash_version   = local.dash_version
  dash_repo      = local.dash_repo
  ingress_domain = var.ingress_domain
}
