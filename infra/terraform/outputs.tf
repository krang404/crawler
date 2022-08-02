output "external_ip_0" {
  value = yandex_compute_instance.docker[0].network_interface.0.nat_ip_address
}
output "registry_id" {
  value = yandex_container_registry.registry.id
}
