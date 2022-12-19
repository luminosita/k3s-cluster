output "istio_bookinfo_resources" {
  value = "${ local.docs[*].docId }"
}
