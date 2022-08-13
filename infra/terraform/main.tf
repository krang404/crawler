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

provider "yandex" {
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = var.zone
  service_account_key_file = var.service_account_key_file
}

module "test_registry" {
  source = "./modules/test_registry"
}
module "private_registry" {
  source = "./modules/private_registry"
}
module "test_host" {
  source                    = "./modules/test_host"
  id_of_test_registry       = module.test_registry.test_registry_id
  id_of_private_registry    = module.private_registry.private_registry_id
  id_of_sa_test_registry    = module.test_registry.sa_test_registry_id
  id_of_sa_private_registry = module.private_registry.sa_private_registry_id
  name_sa_test_registry     = module.test_registry.name_sa_test_registry
  name_sa_private_registry  = module.private_registry.name_sa_private_registry
}
