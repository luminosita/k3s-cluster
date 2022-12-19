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

variable istio_version {
  type = string
}

variable istio_repo {
  type = string
}

locals {
  istio_bookinfo_namespace = "istio-bookinfo"
  istio_bookinfo_path     = "/samples/bookinfo/platform/kube/bookinfo.yaml"
  istio_bookinfo_raw_path = "${var.istio_repo}${var.istio_version}${local.istio_bookinfo_path}"

  docs = flatten([
    for id, value in data.kubectl_file_documents.istio_bookinfo_manifests.manifests : {
      docId   = id
      content = value
    }
  ])
}

data "http" "istio_bookinfo_file" {
  url = local.istio_bookinfo_raw_path
}

data "kubectl_file_documents" "istio_bookinfo_manifests" {
  content = data.http.istio_bookinfo_file.response_body
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
