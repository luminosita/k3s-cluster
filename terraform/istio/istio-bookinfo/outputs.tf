output "istio_bookinfo_resources" {
  value = "${ local.docs[*].docId }"
}

output "istio_bookinfo_gateway_resources" {
  value = "${ local.gateway_docs[*].docId }"
}
