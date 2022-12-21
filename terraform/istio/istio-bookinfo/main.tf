terraform {
  required_providers {
    http = {
      source = "hashicorp/http"
    }
    kubectl = {
      source = "gavinbunney/kubectl"
    }
  }
}

locals {
  istio_bookinfo_namespace   = "istio-bookinfo"

  url_docs = module.utils_yaml_document_parser.parser_url_docs
}

module "utils_yaml_document_parser" {
  source = "../../utils/yaml_document_parser"

  parser_url_names = [
    "/samples/bookinfo/platform/kube/bookinfo.yaml",
    "/samples/bookinfo/networking/bookinfo-gateway.yaml"
  ]

  parser_url_path = "${var.istio_repo}${var.istio_version}"
}

resource "kubernetes_namespace" "istio_bookinfo_namespace" {
  metadata {
    labels = {
      istio-injection = "enabled"
    }

    name = local.istio_bookinfo_namespace
  }
}

resource "kubectl_manifest" "istio_bookinfo_resources" {
  for_each           = { for doc in local.url_docs : doc.docId => doc.content }

  yaml_body          = each.value
  override_namespace = kubernetes_namespace.istio_bookinfo_namespace.metadata[0].name
}
