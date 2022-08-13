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

resource "yandex_compute_instance" "docker" {
  # count                     = var.instance_count
  name                      = "gitlab-host"
  allow_stopping_for_update = true
  labels = {
    tags = "gitlab-host"
  }
  resources {
    cores  = 2
    memory = 8
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id
      type     = "network-hdd"
      size     = 50
    }
  }

  network_interface {
    # Указан id подсети default-ru-central1-a
    subnet_id = var.subnet_id
    nat       = true
  }

  scheduling_policy {
    preemptible = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.public_key_path)}"
  }
}

resource "null_resource" "inventory" {
  triggers = {
    name : yandex_compute_instance.docker.name
    random : "5"
  }
  provisioner "local-exec" {
    command = "./yc_register_script.sh ${var.name_sa_test_registry} ${var.id_of_private_registry} ${var.name_sa_private_registry}"
  }

  provisioner "local-exec" {
    command = "./ansible_inventory.sh ${yandex_compute_instance.docker.network_interface.0.nat_ip_address}"
  }
  depends_on = [
    yandex_compute_instance.docker
  ]
}
