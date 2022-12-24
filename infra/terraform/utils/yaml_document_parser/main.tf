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
  url_docs = flatten([
    for key in var.parser_url_names : [
      for id, value in data.kubectl_file_documents.parser_url_manifests[key].manifests : {
        docId   = "${key}=>${id}"
        content = value
      }
      if contains(var.url_filter, tostring("${key}=>${id}")) != true
    ]
  ])

  file_docs = flatten([
    for key in var.parser_file_names : [
      for id, value in data.kubectl_file_documents.parser_file_names[key].manifests : {
        docId   = "${key}=>${id}"
        content = value
      }
      if contains(var.file_filter, tostring("${key}=>${id}")) != true
  ]
  ])
}

data "http" "parser_urls" {
  for_each = toset(var.parser_url_names)
  url      = "${var.parser_url_path}${each.value}"
}

data "local_file" "parser_files" {
  for_each = toset(var.parser_file_names)
  filename = "${var.parser_file_path}${each.value}"
}

data "kubectl_file_documents" "parser_url_manifests" {
  for_each = toset(var.parser_url_names)
  content  = data.http.parser_urls[each.key].response_body
}

data "kubectl_file_documents" "parser_file_names" {
  for_each = toset(var.parser_file_names)
  content  = data.local_file.parser_files[each.key].content
}

