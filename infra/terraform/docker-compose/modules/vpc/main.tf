terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.35"
    }
  }
  required_version = ">= 1.00"
}


resource "yandex_vpc_network" "gitlab_network" {
  name = "gitlab-network"
}

resource "yandex_vpc_subnet" "gitlab_subnet" {
  name           = "gitlab-subnet"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.gitlab_network.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}
