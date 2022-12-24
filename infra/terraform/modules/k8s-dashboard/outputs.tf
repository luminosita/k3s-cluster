output "dashboard_resources" {
  value = "${ local.url_docs[*].docId }"
}

output "dashboard_gateway_resources" {
  value = "${ local.file_docs[*].docId }"
}
