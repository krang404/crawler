output "private_registry_id" {
  value = yandex_container_registry.private_registry.id
}
output "sa_private_registry_id" {
  value = yandex_iam_service_account.sa_private_registry.id
}
output "name_sa_private_registry" {
  value = yandex_iam_service_account.sa_private_registry.name
}
