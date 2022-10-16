resource "yandex_compute_instance" "default" {
  name = "vm1"

  resources {
    cores  = 2 # vCPU
    memory = 2 # RAM
  }

  boot_disk {
    initialize_params {
      image_id = "fd8ingbofbh3j5h7i8ll" # ОС (Ubuntu, 22.04 LTS)
    }
  }

  network_interface {
    subnet_id = "e9b67eavrqferuif5f1k"
    nat = true # DHCP
  }

  metadata = {
    "ssh-keys" = <<EOT
    vyacheslav:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDUf70nlaGDk5h6h5mGCUaT3UJg3s/enmUMIef0ODHw/9Tt1uTNl2QUfu8xnm4c+KNvjjBPI0LwsvWN/3k/zOhqzlzz055y9NYtpc/xIPM6f6vvGWfQQaHsL7Z5OrfvCVv5TWfZTMGQlB10j/LR8hX0Y4s3Ql5n2CG6d/mZgyEUOEAWZijHh+Qm6iMTtE8e8SFqk4jJv6KRiQJU7yUXSFYv/d3ycDu7xATjUT+bCbYJdZpdkG4l5i82uIogsz7zZIcs8oplGruoKjf7vXm7d8P6G5bRtQGSpEs+fKPfsU9bktrsbKzKBHgqA1VQV2D20H++aB8nQ6qV+L7jPm/RyKCKvDpbo8mNnRYuJA9DvbCH9OSJY3c6m+bSlqDTxGZgweHZ06Nk2Qs5Q8Znaeo+qcscudVvoEI6/kpXQC41q1rHi80sVHs98hUSfmUF7tmi5GUuvj1Eu+L6490KoYVGNdirWwSkTfCsVfO0TbRYSQlBdy+/j7zt0O8t7+BKr7Ykhok=
    EOT
  }
}