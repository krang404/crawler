output "test_registry_id" {
  value = yandex_container_registry.test_registry.id
}
output "sa_test_registry_id" {
  value = yandex_iam_service_account.sa_test_registry.id
}
output "name_sa_test_registry" {
  value = yandex_iam_service_account.sa_test_registry.name
}
