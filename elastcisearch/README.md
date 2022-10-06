#### Задание 1

Используя докер образ centos:7 как базовый и документацию по установке и запуску Elastcisearch:

* составьте Dockerfile-манифест для elasticsearch
* соберите docker-образ и сделайте push в ваш docker.io репозиторий
* запустите контейнер из получившегося образа и выполните запрос пути / c хост-машины

Требования к elasticsearch.yml:

* данные path должны сохраняться в /var/lib
* имя ноды должно быть netology_test

В ответе приведите:

* текст Dockerfile манифеста
* ссылку на образ в репозитории dockerhub
* ответ elasticsearch на запрос пути / в json виде

**Ответ:**

* Dockerfile:

```
FROM centos:7

MAINTAINER Vyacheslav <v@breus.pro>

RUN mkdir -p /var/lib/elasticsearch/config /var/lib/elasticsearch/logs /var/lib/elasticsearch/data /var/lib/elasticsearch/snapshots

RUN yum makecache && yum -y install wget perl-digest-sha

RUN cd /tmp && \
  wget https://fossies.org/linux/www/elasticsearch-8.4.3-linux-x86_64.tar.gz && \
  tar -xzf elasticsearch-8.4.3-linux-x86_64.tar.gz && \
  rm -f *.tar.gz* && \
  mv elasticsearch-8.4.3 /var/lib/elasticsearch && \
  groupadd -g 1000 elasticsearch && \
  useradd -m -u 1000 elasticsearch && \
  chown elasticsearch:elasticsearch -R /var/lib/elasticsearch

RUN wget -O /var/lib/elasticsearch/config/elasticsearch.yml https://raw.githubusercontent.com/v-breus/devops-netology-20/main/elastcisearch/src/elasticsearch.yml

RUN chmod -R 777 /var/lib/logs && \
    chmod -R 777 /var/lib/data

EXPOSE 9200 9300

CMD ["bash", "-c", "/var/lib/elasticsearch/bin/elasticsearch"]

```

[Ссылка на образ докер](https://hub.docker.com/layers/vyacheslavbreus/devops-netology/elastic/images/sha256-f5e2fe457463a11e68335d56426f1ad17b3f97100ceb7866b77b26a38c180357?context=repo)

```
docker pull vyacheslavbreus/devops-netology:elastic
```

* Ответ elasticsearch на запрос пути / в json виде:

```
{
  "name" : "centos7.local",
  "cluster_name" : "vyacheslav_netology",
  "cluster_uuid" : "h3ejPKtnTgCXZaYpgCPrFw",
  "version" : {
    "number" : "8.4.3",
    "build_flavor" : "default",
    "build_type" : "tar",
    "build_hash" : "42f05b9372a9a4a470db3b52817899b99a76ee73",
    "build_date" : "2022-10-04T07:17:24.662462378Z",
    "build_snapshot" : false,
    "lucene_version" : "9.3.0",
    "minimum_wire_compatibility_version" : "7.17.0",
    "minimum_index_compatibility_version" : "7.0.0"
  },
  "tagline" : "You Know, for Search"
}
```

<img src="img\pic1.png">

#### Задание 2

* Ознакомьтесь с документацией и добавьте в elasticsearch 3 индекса, в соответствии со таблицей

| **Имя** | **Количество реплик** | **Количество шард** |
|---------|-----------------------|---------------------|
| ind-1   | 0                     | 1                   |
| ind-2   | 1                     | 2                   |
| ind-3   | 2                     | 4                   |


* Получите список индексов и их статусов, используя API и приведите в ответе на задание.
* Получите состояние кластера elasticsearch, используя API.
* Как вы думаете, почему часть индексов и кластер находится в состоянии yellow?
* Удалите все индексы.

**Важно**

При проектировании кластера elasticsearch нужно корректно рассчитывать количество реплик и шард, иначе возможна потеря данных индексов, вплоть до полной, при деградации системы.


**Ответ:**

* Добавление индексов

```
curl -X PUT "localhost:9200/ind-1?pretty" -H 'Content-Type: application/json' -d'
{
  "settings": {
    "number_of_shards": 1,
    "number_of_replicas": 0
  }
}
'

{
  "acknowledged" : true,
  "shards_acknowledged" : false,
  "index" : "ind-1"
}

curl -X PUT "localhost:9200/ind-2?pretty" -H 'Content-Type: application/json' -d'
{
  "settings": {
    "number_of_shards": 2,
    "number_of_replicas": 1
  }
}
'

{
  "acknowledged" : true,
  "shards_acknowledged" : false,
  "index" : "ind-2"
}

curl -X PUT "localhost:9200/ind-3?pretty" -H 'Content-Type: application/json' -d'
{
  "settings": {
    "number_of_shards": 4,
    "number_of_replicas": 2
  }
}
'

{
  "acknowledged" : true,
  "shards_acknowledged" : false,
  "index" : "ind-3"
}
```

* Список индексов:

```
curl -X GET 'http://localhost:9200/_cat/indices?v'
```

<img src="img\pic2.png">

* Статус кластера:

```
curl -XGET localhost:9200/_cluster/health/?pretty=true
```

<img src="img\pic3.png">

* Статус индексов:

```
http://localhost:9200/_cluster/health/ind-1?pretty' # в браузере
curl -X GET 'http://localhost:9200/_cluster/health/ind-2?pretty'
curl -X GET 'http://localhost:9200/_cluster/health/ind-3?pretty'

```

<img src="img\pic4.png">
<img src="img\pic5.png">

Индексы ind-2 и ind-3 имеют "желтый" статус, потому что для них указаны реплики, которые некуда копировать т.к. в кластере только одна нода.

* Удаление индексов:

```
curl -X DELETE 'http://localhost:9200/ind-1?pretty' 
{
  "acknowledged" : true
}
curl -X DELETE 'http://localhost:9200/ind-2?pretty' 
{
  "acknowledged" : true
}
curl -X DELETE 'http://localhost:9200/ind-3?pretty' 
{
  "acknowledged" : true
}
```

#### Задание 3

* Создайте директорию {путь до корневой директории с elasticsearch в образе}/snapshots.
* Используя API зарегистрируйте данную директорию как snapshot repository c именем netology_backup.
* Приведите в ответе запрос API и результат вызова API для создания репозитория.

**Ответ:**

* Создание репозитория для бэкапа:

```
curl -X POST localhost:9200/_snapshot/netology_backup?pretty -H 'Content-Type: application/json' -d'{"type": "fs", "settings": { "location":"/var/lib/elasticsearch/snapshots" }}'
```

<img src="img\pic6.png">

* Создание индекса test с 0 реплик и 1 шардом 

```
curl -X PUT "localhost:9200/test?pretty" -H 'Content-Type: application/json' -d'
{
  "settings": {
    "number_of_shards": 1,
    "number_of_replicas": 0
  }
}
'
curl -X GET 'http://localhost:9200/_cat/indices?v' 
```

<img src="img\pic7.png">

* Создание снапшота

```
curl -X PUT localhost:9200/_snapshot/netology_backup/elasticsearch?wait_for_completion=true
```

<img src="img\pic8.png">

* Удаление индекса test, создание индекса test2

```
curl -X DELETE 'http://localhost:9200/test?pretty'

curl -X PUT "localhost:9200/test2?pretty" -H 'Content-Type: application/json' -d'
{
  "settings": {
    "number_of_shards": 1,
    "number_of_replicas": 0
  }
}
'

curl -X GET 'http://localhost:9200/_cat/indices?v' 
```

<img src="img\pic9.png">

* Восстановление:

```
curl -X POST "localhost:9200/_snapshot/netology_backup/elasticsearch/_restore?pretty"
```

<img src="img\pic10.png">

