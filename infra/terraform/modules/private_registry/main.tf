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

resource "yandex_iam_service_account" "sa_private_registry" {
  name        = "pusher"
  description = "Service account for private registry"
  folder_id   = var.folder_id
}


resource "yandex_container_registry_iam_binding" "private_puller" {
  registry_id = yandex_container_registry.private_registry.id
  role        = "container-registry.images.puller"
  members = [
    "serviceAccount:${yandex_iam_service_account.sa_private_registry.id}",
  ]
}

resource "yandex_container_registry_iam_binding" "private_pusher" {
  registry_id = yandex_container_registry.private_registry.id
  role        = "container-registry.images.pusher"
  members = [
    "serviceAccount:${yandex_iam_service_account.sa_private_registry.id}",
  ]
}

resource "yandex_container_registry" "private_registry" {
  name      = "private-registry"
  folder_id = var.folder_id

  provisioner "local-exec" {
    when    = destroy
    command = "./yc_delete_profile.sh"
  }
}
