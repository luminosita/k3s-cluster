output "istio-addons-resources" {
  value = "${module.istio-addons-module != []?module.istio-addons-module[0].istio_addons_resources:[]}"
}

output "istio-addons-gateway-resources" {
  value = "${module.istio-addons-module != []?module.istio-addons-module[0].istio_addons_gateway_resources:[]}"
}

output "istio-bookinfo-resources" {
  value = "${module.istio-bookinfo-module != []?module.istio-bookinfo-module[0].istio_bookinfo_resources:[]}"
}

output "istio-cert-manager-resources" {
  value = "${module.istio-cert-manager-module != []?module.istio-cert-manager-module[0].istio_cert_manager_resources:[] }"
}

output "dashboard-resources" {
  value = "${module.k8s-dashboard != []?module.k8s-dashboard[0].dashboard_resources:[] }"
}

output "dashboard-gateway-resources" {
  value = "${module.k8s-dashboard != []?module.k8s-dashboard[0].dashboard_gateway_resources:[] }"
}
