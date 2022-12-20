//output "istio_addons_resources" {
//  value = "${module.istio_addons_module.istio_addons_resources}"
//}

//output "istio_addons_gateway_resources" {
//  value = "${module.istio_addons_module.istio_addons_gateway_resources}"
//}

output "istio_bookinfo_resources" {
  value = "${module.istio_bookinfo_module.istio_bookinfo_resources}"
}

output "istio_bookinfo_gateway_resources" {
  value = "${module.istio_bookinfo_module.istio_bookinfo_gateway_resources}"
}
