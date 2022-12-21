terraform {
  required_providers {
    local = {
      source = "hashicorp/local"
    }
    kubectl = {
      source = "gavinbunney/kubectl"
    }
  }
}

locals {
  docs = module.utils_yaml_document_parser.parser_file_docs
}

module "utils_yaml_document_parser" {
  source = "../../utils/yaml_document_parser"

  parser_file_names = [ "istio-cert-issuer.yaml" ]

  parser_file_path = "${var.local_path}"
}

resource "kubectl_manifest" "cert_manager_clusterissuer" {
  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: selfsigned-issuer
spec:
  selfSigned: {}
  YAML
}

resource "kubectl_manifest" "istio_cert_manager_resources" {
  for_each           = { for doc in local.docs : doc.docId => doc.content }

  yaml_body          = replace(each.value, "${"$"}{INGRESS_DOMAIN}", "${var.ingress_domain}")
  override_namespace = var.istio_namespace
}

