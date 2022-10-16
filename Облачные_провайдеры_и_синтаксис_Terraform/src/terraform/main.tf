terraform {
  required_providers {
    yandex = {
      source = "terraform-registry.storage.yandexcloud.net/yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider yandex {
  token     = "$(yc iam create-token)"
  cloud_id  = "$(yc config get cloud-id)"
  folder_id = "$(yc config get folder-id)"
  zone      = "ru-central1-a"
}