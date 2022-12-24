terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
    }
    kubectl = {
      source = "gavinbunney/kubectl"
    }
  }
}

locals {
  dash_namespace = "kubernetes-dashboard"
  dash_path = "/aio/deploy/"
  local_path = "${path.module}/resources/"

  url_docs = module.utils_yaml_document_parser.parser_url_docs
  file_docs = module.utils_yaml_document_parser.parser_file_docs
}

module "utils_yaml_document_parser" {
  source = "../../utils/yaml_document_parser"

  parser_url_names = [
    "recommended.yaml"
  ]

  parser_file_names = [
    "dashboard-gateway.yaml",
    "dashboard-rbac.yaml"
  ]

  parser_url_path = "${var.dash_repo}${var.dash_version}${local.dash_path}"
  parser_file_path = "${local.local_path}"
}

resource "kubernetes_labels" "kubernetes_dashboard_namespace_istio_injection" {
  api_version = "v1"
  kind        = "Namespace"

  metadata {
    name = "${local.dash_namespace}"
  }

  labels = {
    istio-injection = "enabled"
  }
}

resource "kubectl_manifest" "dash_resources" {
  for_each  = { for doc in local.url_docs : doc.docId => doc.content }

  yaml_body = each.value
}

resource "kubectl_manifest" "dash_gateway_resources" {
  for_each  = { for doc in local.file_docs : doc.docId => doc.content }
  yaml_body = replace(each.value, "${"$"}{INGRESS_DOMAIN}", "${var.ingress_domain}")
}



