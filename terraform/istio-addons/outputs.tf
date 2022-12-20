output "istio_addons_resources" {
  value = "${ local.docs[*].docId }"
}

output "istio_addons_gateway_resources" {
  value = "${ local.gateway_docs[*].docId }"
}
