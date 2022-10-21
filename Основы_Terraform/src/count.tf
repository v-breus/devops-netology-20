terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version =  ">= 0.13"
}

provider yandex {
  token     = "<token>"
  cloud_id  = "<cloud_id>"
  folder_id = "<folder_id>"
  zone      = "ru-central1-a"
}

resource yandex_compute_image ubu-img {
  name          = "ubuntu-20-04-lts-v20210908"
  source_image  = "fd81hgrcv6lsnkremf32"
}

resource "yandex_vpc_network" "net" {
  name = "net"
}

resource "yandex_vpc_subnet" "subnet" {
  name           = "subnet"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.net.id
  v4_cidr_blocks = ["10.0.0.0/24"]
}

locals {
  instance = {
  stage = 1
  prod = 2
  }
}

resource "yandex_compute_instance" "vm-count" {
  name = "vm-${count.index}-${terraform.workspace}"

  resources {
    cores  = "2"
    memory = "2"
  }

  boot_disk {
    initialize_params {
      image_id = "${yandex_compute_image.ubu-img.id}"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet.id
    nat       = true
  }

  metadata = {
    "ssh-keys" = <<EOT
    vyacheslav:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDUf70nlaGDk5h6h5mGCUaT3UJg3s/enmUMIef0ODHw/9Tt1uTNl2QUfu8xnm4c+KNvjjBPI0LwsvWN/3k/zOhqzlzz055y9NYtpc/xIPM6f6vvGWfQQaHsL7Z5OrfvCVv5TWfZTMGQlB10j/LR8hX0Y4s3Ql5n2CG6d/mZgyEUOEAWZijHh+Qm6iMTtE8e8SFqk4jJv6KRiQJU7yUXSFYv/d3ycDu7xATjUT+bCbYJdZpdkG4l5i82uIogsz7zZIcs8oplGruoKjf7vXm7d8P6G5bRtQGSpEs+fKPfsU9bktrsbKzKBHgqA1VQV2D20H++aB8nQ6qV+L7jPm/RyKCKvDpbo8mNnRYuJA9DvbCH9OSJY3c6m+bSlqDTxGZgweHZ06Nk2Qs5Q8Znaeo+qcscudVvoEI6/kpXQC41q1rHi80sVHs98hUSfmUF7tmi5GUuvj1Eu+L6490KoYVGNdirWwSkTfCsVfO0TbRYSQlBdy+/j7zt0O8t7+BKr7Ykhok=
    EOT
  }

  count = local.instance[terraform.workspace]
}
