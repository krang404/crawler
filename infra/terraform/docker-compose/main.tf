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

module "vpc" {
  source = "./modules/vpc"
}

module "test_host" {
  source                 = "./modules/test_host"
  id_of_test_registry    = module.test_registry.test_registry_id
  id_of_sa_test_registry = module.test_registry.sa_test_registry_id
  name_sa_test_registry  = module.test_registry.name_sa_test_registry
  subnet_id              = module.vpc.yandex_vpc_subnet_id
}
