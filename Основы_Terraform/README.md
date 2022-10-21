**ВСЕ ДЕЛАЛ НА ОБЛАКЕ ЯНДЕКС, ЗАДАНИЕ НА AWS, ПОЭТОМУ ЕСТЬ РАЗЛИЧИЯ**

#### Задание 1 (Вариант с Yandex.Cloud). 

Если в рамках предыдущего задания у вас уже есть аккаунт AWS, то давайте продолжим знакомство со взаимодействием терраформа и aws.

Создайте s3 бакет, iam роль и пользователя от которого будет работать терраформ. Можно создать отдельного пользователя, а можно использовать созданного в рамках предыдущего задания, просто добавьте ему необходимы права, как описано здесь.
Зарегистрируйте бэкэнд в терраформ проекте как описано по ссылке выше.

**Ответ:**

Используется ранее созданный сервисный аккаунт:

<img src="img\pic1.png">

#### Задание 2

1. Выполните terraform init:

* если был создан бэкэнд в S3, то терраформ создат файл стейтов в S3 и запись в таблице dynamodb.
* иначе будет создан локальный файл со стейтами.

<img src="img\pic2.png">


2. Создайте два воркспейса stage и prod.

```
terraform workspace new prod
terraform workspace new dev
terraform workspace new stage
```

<img src="img\pic3.png">

3. В уже созданный aws_instance добавьте зависимость типа инстанса от вокспейса, что бы в разных ворскспейсах использовались разные instance_type.
Добавим count. Для stage должен создаться один экземпляр ec2, а для prod два.

```
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

```

Вывод `terraform plan` - [count.log](https://github.com/v-breus/devops-netology-20/blob/d7ba4950126244810438cd51a8c89d9b67e0ea04/%D0%9E%D1%81%D0%BD%D0%BE%D0%B2%D1%8B_Terraform/src/count.log)

<img src="img\pic4.png">

Итог развертывания:

<img src="img\pic5.png">



4. Создайте рядом еще один aws_instance, но теперь определите их количество при помощи for_each, а не count.
Что бы при изменении типа инстанса не возникло ситуации, когда не будет ни одного инстанса добавьте параметр жизненного цикла create_before_destroy = true в один из рессурсов aws_instance.
При желании поэкспериментируйте с другими параметрами и ресурсами.

```
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
  id = toset([
    "1",
    "2",
  ])
}

resource "yandex_compute_instance" "vm-foreach" {
  for_each = local.id
  name = "vm-${each.key}-${terraform.workspace}"

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
}

```

Вывод `terraform plan` - [foreach.log](https://github.com/v-breus/devops-netology-20/blob/d7ba4950126244810438cd51a8c89d9b67e0ea04/%D0%9E%D1%81%D0%BD%D0%BE%D0%B2%D1%8B_Terraform/src/foreach.log)

<img src="img\pic6.png">

Итог развертывания:

<img src="img\pic7.png">


В виде результата работы пришлите:

Вывод команды `terraform workspace list`.

<img src="img\pic8.png">

Вывод команды `terraform plan` для воркспейса `prod`.

<img src="img\pic9.png">
<img src="img\pic10.png">

[prod_plan.log](https://github.com/v-breus/devops-netology-20/blob/d7ba4950126244810438cd51a8c89d9b67e0ea04/%D0%9E%D1%81%D0%BD%D0%BE%D0%B2%D1%8B_Terraform/src/prod_plan.log)
