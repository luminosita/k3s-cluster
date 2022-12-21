terraform {
  required_providers {
    local = {
      source = "hashicorp/local"
    }
    http = {
      source = "hashicorp/http"
    }
    kubectl = {
      source = "gavinbunney/kubectl"
    }
  }
}

locals {
  istio_addons_path        = "/samples/addons/"

  url_docs = module.utils_yaml_document_parser.parser_url_docs
  file_docs = module.utils_yaml_document_parser.parser_file_docs
}

module "utils_yaml_document_parser" {
  source = "../../utils/yaml_document_parser"

  parser_url_names = [
    "grafana.yaml",
    "jaeger.yaml",
    "kiali.yaml",
    "prometheus.yaml"
  ]

  parser_file_names = [
    "grafana-gateway.yaml",
    "tracing-gateway.yaml",
    "kiali-gateway.yaml",
    "prometheus-gateway.yaml"
  ]

  parser_url_path = "${var.istio_repo}${var.istio_version}${local.istio_addons_path}"
  parser_file_path = "${var.local_path}"
}

resource "kubectl_manifest" "istio_addons_resources" {
  for_each  = { for doc in local.url_docs : doc.docId => doc.content }
  yaml_body = each.value
}

resource "kubectl_manifest" "istio_addons_gateway_resources" {
  for_each  = { for doc in local.file_docs : doc.docId => doc.content }
  yaml_body = replace(each.value, "${"$"}{INGRESS_DOMAIN}", "${var.ingress_domain}")
}
