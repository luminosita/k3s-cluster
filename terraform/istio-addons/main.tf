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

variable "istio_version" {
  type = string
}

variable "istio_repo" {
  type = string
}

locals {
  istio_addons_path        = "/samples/addons/"
  istio_addons_gateway     = "/samples/addons/"
  istio_addons_raw_path    = "${var.istio_repo}${var.istio_version}${local.istio_addons_path}"
  istio_addons_raw_gateway = "${var.istio_repo}${var.istio_version}${local.istio_addons_gateway}"
  istio_addons_manifests = [
    "grafana.yaml",
    "jaeger.yaml",
    "kiali.yaml",
    "prometheus.yaml"
  ]

  docs = flatten([
    for key in local.istio_addons_manifests : [
      for id, value in data.kubectl_file_documents.istio_addons_manifests[key].manifests : {
        docId   = "${key}=>${id}"
        content = value
      }
    ]
  ])

  gateway_docs = flatten([
    for key in local.istio_addons_manifests : [
      for id, value in data.kubectl_file_documents.istio_addons_gateway_manifests[key].manifests : {
        docId   = "${key}=>${id}"
        content = value
      }
    ]
  ])
}

data "http" "istio_addons_files" {
  for_each = toset(local.istio_addons_manifests)
  url      = "${local.istio_addons_raw_path}${each.value}"
}

data "http" "istio_addons_gateway_files" {
  for_each = toset(local.istio_addons_manifests)
  url      = "${local.istio_addons_raw_gateway}${each.value}"
}

data "kubectl_file_documents" "istio_addons_manifests" {
  for_each = toset(local.istio_addons_manifests)
  content  = data.http.istio_addons_files[each.key].response_body
}

data "kubectl_file_documents" "istio_addons_gateway_manifests" {
  for_each = toset(local.istio_addons_manifests)
  content  = data.http.istio_addons_gateway_files[each.key].response_body
}

resource "kubectl_manifest" "istio_addons_resources" {
  for_each  = { for doc in local.docs : doc.docId => doc.content }
  yaml_body = each.value
}

resource "kubectl_manifest" "istio_addons_gateway_resources" {
  for_each  = { for doc in local.gateway_docs : doc.docId => doc.content }
  yaml_body = each.value
}
