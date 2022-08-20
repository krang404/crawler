terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.35"
    }
    null = {
      source  = "hashicorp/null"
      version = "= 3.1.1"
    }
  }
  required_version = ">= 1.00"
}

resource "yandex_iam_service_account" "sa_test_registry" {
  name        = "sa-test-registry"
  description = "Service account for test registry"
  folder_id   = var.folder_id
}

resource "yandex_container_registry_iam_binding" "test_puller" {
  registry_id = yandex_container_registry.test_registry.id
  role        = "container-registry.images.puller"
  members = [
    "serviceAccount:${yandex_iam_service_account.sa_test_registry.id}",
  ]
}

resource "yandex_container_registry_iam_binding" "test_pusher" {
  registry_id = yandex_container_registry.test_registry.id
  role        = "container-registry.images.pusher"
  members = [
    "serviceAccount:${yandex_iam_service_account.sa_test_registry.id}",
  ]
}

resource "yandex_container_registry" "test_registry" {
  name      = "test-registry"
  folder_id = var.folder_id
}
