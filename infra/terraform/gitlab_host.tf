resource "yandex_compute_instance" "docker" {
  count                     = var.instance_count
  name                      = "gitlab-host-${count.index}"
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
