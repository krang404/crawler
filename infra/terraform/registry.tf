
data "yandex_iam_service_account" "srv_acc" {
  name = "srv-acc"
}

resource "yandex_container_registry" "registry" {
  name      = "test-registry"
  folder_id = var.folder_id
}

resource "yandex_container_registry_iam_binding" "puller" {
  registry_id = yandex_container_registry.registry.id
  role        = "container-registry.images.puller"
  members = [
    "serviceAccount:${data.yandex_iam_service_account.srv_acc.id}",
  ]
}

resource "yandex_container_registry_iam_binding" "pusher" {
  registry_id = yandex_container_registry.registry.id
  role        = "container-registry.images.pusher"
  members = [
    "serviceAccount:${data.yandex_iam_service_account.srv_acc.id}",
  ]
}
