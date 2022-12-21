output "istio_bookinfo_resources" {
  value = "${ local.url_docs[*].docId }"
}

