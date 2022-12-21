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
  dash_namespace = "kubernetes-dashboard"
  dash_version = "v2.6.1"
  dash_repo = "https://raw.githubusercontent.com/kubernetes/dashboard/"
  dash_path = "/aio/deploy/"
  local_path = "${path.root}/resources/"

  url_docs = module.utils_yaml_document_parser.parser_url_docs
  file_docs = module.utils_yaml_document_parser.parser_file_docs
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "default"
}

module "utils_yaml_document_parser" {
  source = "../utils/yaml_document_parser"

  parser_url_names = [
    "recommended.yaml"
  ]

  parser_file_names = [
    "dashboard-gateway.yaml",
    "dashboard-rbac.yaml"
  ]

  parser_url_path = "${local.dash_repo}${local.dash_version}${local.dash_path}"
  parser_file_path = "${local.local_path}"

  url_filter = [
      "recommended.yaml=>/api/v1/namespaces/kubernetes-dashboard"
    ]
}

resource "kubectl_manifest" "dash_resources" {
  for_each  = { for doc in local.url_docs : doc.docId => doc.content }

  yaml_body = each.value
}

resource "kubectl_manifest" "dash_gateway_resources" {
  for_each  = { for doc in local.file_docs : doc.docId => doc.content }
  yaml_body = replace(each.value, "${"$"}{INGRESS_DOMAIN}", "${var.ingress_domain}")

  override_namespace = kubernetes_namespace.kubernetes_dashboard_namespace.metadata[0].name
}

resource "kubernetes_namespace" "kubernetes_dashboard_namespace" {
  metadata {
    labels = {
      istio-injection = "enabled"
    }

    name = "${local.dash_namespace}"
  }
}


