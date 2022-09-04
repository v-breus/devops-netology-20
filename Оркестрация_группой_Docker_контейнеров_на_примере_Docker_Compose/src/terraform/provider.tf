# Provider
terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

provider "yandex" {
  service_account_key_file = "key.json"
  cloud_id  = "b1gioaimo03lc4qdqtpo"
  folder_id = "b1gudgg279i5hiheqadk"
}
