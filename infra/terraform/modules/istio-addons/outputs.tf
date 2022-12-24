output "istio_addons_resources" {
  value = "${ local.url_docs[*].docId }"
}

output "istio_addons_gateway_resources" {
  value = "${ local.file_docs[*].docId }"
}
