output "external_ip_0" {
  value = yandex_compute_instance.docker.network_interface.0.nat_ip_address
}
