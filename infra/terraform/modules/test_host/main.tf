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
    local = {
      source  = "hashicorp/local"
      version = "= 2.2.2"
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
    command = "./yc_register_script.sh ${yandex_compute_instance.docker.id} ${var.id_of_sa_test_registry}"
  }

  provisioner "local-exec" {
    command = "./ansible_inventory.sh ${yandex_compute_instance.docker.network_interface.0.nat_ip_address}"
  }
  depends_on = [
    yandex_compute_instance.docker
  ]
}

resource "local_file" "ansible_vars" {
  content  = <<-DOC
    #Varible generated by applying terraform configuration in  crawler/infra/terraform/config

    YOUR_VM_IP: ${yandex_compute_instance.docker.network_interface.0.nat_ip_address}
    YA_REGISTRY: ${var.id_of_test_registry}
    DOC
  filename = "../ansible/variable.yml"
}
