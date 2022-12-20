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
  istio_bookinfo_namespace   = "istio-bookinfo"
  istio_bookinfo_path        = "/samples/bookinfo/platform/kube/bookinfo.yaml"
  istio_bookinfo_gateway     = "/samples/bookinfo/networking/bookinfo-gateway.yaml"
  istio_bookinfo_raw_path    = "${var.istio_repo}${var.istio_version}${local.istio_bookinfo_path}"
  istio_bookinfo_raw_gateway = "${var.istio_repo}${var.istio_version}${local.istio_bookinfo_gateway}"

  docs = flatten([
    for id, value in data.kubectl_file_documents.istio_bookinfo_manifests.manifests : {
      docId   = id
      content = value
    }
  ])

  gateway_docs = flatten([
    for id, value in data.kubectl_file_documents.istio_bookinfo_gateway_manifests.manifests : {
      docId   = id
      content = value
    }
  ])

  ingressgateway_ip = kubernetes_service.istio-ingressgateway.status.0.load_balancer.0.ingress.0.ip
}

data "http" "istio_bookinfo_file" {
  url = local.istio_bookinfo_raw_path
}

data "http" "istio_bookinfo_gateway_file" {
  url = local.istio_bookinfo_raw_gateway
}

data "kubectl_file_documents" "istio_bookinfo_manifests" {
  content = data.http.istio_bookinfo_file.response_body
}

data "kubectl_file_documents" "istio_bookinfo_gateway_manifests" {
  content = data.http.istio_bookinfo_gateway_file.response_body
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
  for_each           = data.kubectl_file_documents.istio_bookinfo_manifests.manifests
  yaml_body          = each.value
  override_namespace = kubernetes_namespace.istio_bookinfo_namespace.metadata[0].name
}

resource "kubectl_manifest" "istio_bookinfo_gateway_resources" {
  for_each           = data.kubectl_file_documents.istio_bookinfo_gateway_manifests.manifests
  yaml_body          = each.value
  override_namespace = kubernetes_namespace.istio_bookinfo_namespace.metadata[0].name
}
