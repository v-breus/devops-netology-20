#### Задание 1 (Вариант с Yandex.Cloud). Регистрация в ЯО и знакомство с основами (необязательно, но крайне желательно).

1. Подробная инструкция на русском языке содержится [здесь](https://cloud.yandex.ru/docs/solutions/infrastructure-management/terraform-quickstart).
2. Обратите внимание на период бесплатного использования после регистрации аккаунта.
3. Используйте раздел "Подготовьте облако к работе" для регистрации аккаунта. Далее раздел "Настройте провайдер" для подготовки базового терраформ конфига.
4. Воспользуйтесь [инструкцией](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs) на сайте терраформа, что бы не указывать авторизационный токен в коде, а терраформ провайдер брал его из переменных окружений.

**Ответ:**

Не указывать переменные непосредственно в коде main.tf  можно так:

1. Как и указано в [документации](https://cloud.yandex.ru/docs/tutorials/infrastructure-management/terraform-quickstart#prepare-plan), создал авторизационный ключ:

```
yc iam key create \
  --service-account-id <идентификатор_сервисного_аккаунта> \
  --folder-name <имя_каталога_с_сервисным_аккаунтом> \
  --output key.json
```

2. Создал профиль:

```
yc config profile create <имя_профиля>
```

3. Создал конфигурацию профиля и проинициализировал переменные окружения:

```
yc config set service-account-key key.json
yc config set cloud-id <идентификатор_облака>
yc config set folder-id <идентификатор_каталога> 

export YC_TOKEN=$(yc iam create-token)
export YC_CLOUD_ID=$(yc config get cloud-id)
export YC_FOLDER_ID=$(yc config get folder-id) 
```

Соответственно, в файле main.tf теперь можно писать просто

```
provider yandex {
  token     = "$(yc iam create-token)"
  cloud_id  = "$(yc config get cloud-id)"
  folder_id = "$(yc config get folder-id)"
  zone      = "ru-central1-a"
```



#### Задание 2

1. В каталоге terraform вашего основного репозитория, который был создан в начале курсе, создайте файл `main.tf` и `versions.tf`.

2. Зарегистрируйте провайдер
- для [aws](https://registry.terraform.io/providers/hashicorp/aws/latest/docs). В файл `main.tf` добавьте блок provider, а в `versions.tf` блок terraform с вложенным блоком `required_providers`. Укажите любой выбранный вами регион внутри блока provider.
- либо для [yandex.cloud](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs). Подробную инструкцию можно найти [здесь](https://cloud.yandex.ru/docs/solutions/infrastructure-management/terraform-quickstart).
3. **Внимание!** В гит репозиторий нельзя пушить ваши личные ключи доступа к аккаунту. Поэтому в предыдущем задании мы указывали их в виде переменных окружения.
4. В файле `main.tf` воспользуйтесь блоком data `aws_ami` для поиска ami образа последнего Ubuntu.
5. В файле `main.tf` создайте ресурс
- либо [ec2 instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance). Постарайтесь указать как можно больше параметров для его определения. Минимальный набор параметров указан в первом блоке Example Usage, но желательно, указать большее количество параметров.
- либо [yandex_compute_image](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/compute_image).
6. Также в случае использования aws:
Добавьте data-блоки `aws_caller_identity` и `aws_region`.
В файл `outputs.tf` поместить блоки output с данными об используемых в данный момент:
- AWS account ID,
- AWS user ID,
- AWS регион, который используется в данный момент,
- Приватный IP ec2 инстансы,
- Идентификатор подсети в которой создан инстанс.
7. Если вы выполнили первый пункт, то добейтесь того, что бы команда terraform plan выполнялась без ошибок.

В качестве результата задания предоставьте:

1. Ответ на вопрос: при помощи какого инструмента (из разобранных на прошлом занятии) можно создать свой образ ami?
2. Ссылку на репозиторий с исходной конфигурацией терраформа.

**Ответ:**

1. Собственный образ можно сделать Packer'ом
2. Ссылка на файлы terraform:

* [main.tf](https://raw.githubusercontent.com/v-breus/devops-netology-20/6d074b166149e8438fe4b6417987107f7c5cd13c/%D0%9E%D0%B1%D0%BB%D0%B0%D1%87%D0%BD%D1%8B%D0%B5_%D0%BF%D1%80%D0%BE%D0%B2%D0%B0%D0%B9%D0%B4%D0%B5%D1%80%D1%8B_%D0%B8_%D1%81%D0%B8%D0%BD%D1%82%D0%B0%D0%BA%D1%81%D0%B8%D1%81_Terraform/src/terraform/main.tf)
* [vms.tf](https://raw.githubusercontent.com/v-breus/devops-netology-20/6d074b166149e8438fe4b6417987107f7c5cd13c/%D0%9E%D0%B1%D0%BB%D0%B0%D1%87%D0%BD%D1%8B%D0%B5_%D0%BF%D1%80%D0%BE%D0%B2%D0%B0%D0%B9%D0%B4%D0%B5%D1%80%D1%8B_%D0%B8_%D1%81%D0%B8%D0%BD%D1%82%D0%B0%D0%BA%D1%81%D0%B8%D1%81_Terraform/src/terraform/vms.tf)

Результат билда:

<img src="img\pic1.png">
<img src="img\pic2.png">