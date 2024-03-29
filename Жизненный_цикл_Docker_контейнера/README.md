#### Задание 1

Сценарий выполнения задачи:

Создайте свой репозиторий на https://hub.docker.com;
выберете любой образ, который содержит веб-сервер Nginx;
создайте свой fork образа;
реализуйте функциональность: запуск веб-сервера в фоне с индекс-страницей, содержащей HTML-код ниже:

```
<html>
<head>
Hey, Netology
</head>
<body>
<h1>I’m DevOps Engineer Vyacheslav!</h1>
</body>
</html>
```
Опубликуйте созданный форк в своем репозитории и предоставьте ответ в виде ссылки на https://hub.docker.com/username_repo.


**Ответ:**

Мне показалось нерациональным жестко "хардкодить" страницу внутри образа, поэтому сделал так:

```
RUN rm /usr/share/nginx/html/*
# COPY /src/index.html /usr/share/nginx/html  # commented cause non-racional
```
И соответственно, запускается докер командой

```
docker run -v /home/vagrant/html:/usr/share/nginx/html --name task1 -d --network host vyacheslavbreus/devops-netology:5.3.1
```
Подразумевается, что индексный файл в /home/vagrant/html

[Ссылка на репозиторий](https://hub.docker.com/r/vyacheslavbreus/devops-netology/tags)

docker pull vyacheslavbreus/devops-netology:5.3.1

#### Задание 2

Посмотрите на сценарий ниже и ответьте на вопрос: "Подходит ли в этом сценарии использование Docker контейнеров или лучше подойдет виртуальная машина, физическая машина? Может быть возможны разные варианты?"

Детально опишите и обоснуйте свой выбор.

--

Сценарий:

* Высоконагруженное монолитное java веб-приложение;
* Nodejs веб-приложение;
* Мобильное приложение c версиями для Android и iOS;
* Шина данных на базе Apache Kafka;
* Elasticsearch кластер для реализации логирования продуктивного веб-приложения - три ноды elasticsearch, два logstash и две ноды kibana;
* Мониторинг-стек на базе Prometheus и Grafana;
* MongoDB, как основное хранилище данных для java-приложения;
* Gitlab сервер для реализации CI/CD процессов и приватный (закрытый) Docker Registry.

**Ответ:**

* Высоконагруженное монолитное java веб-приложение

На мой взгляд, лучший выбор - dedicated сервер. Контейнеризация не подходит в принципе т.к. приложение монолитное (не разбить на микросервисы), и даже VDS не очень подойдет т.к. приложение с высокой нагрузкой.

* Nodejs веб-приложение

Т.к. веб-приложение, можно завернуть в docker

* Мобильное приложение c версиями для Android и iOS

Смотря какой сценарий использования. Если только положить apk/ipk для небольшой команды, то можно в докер на вебсервер (само файловое хранилище с приложениями должно быть persistent volume) и раздавать с него. Если нужно как-то использовать/тестировать, то VDS с установленным эмулятором (графический рабочий стол в докер не впихнуть). Если продакшн, то может и вовсе дедик, зависит от нагрузки и точных задач.

* Шина данных на базе Apache Kafka;

Я не работал с Apache Kafka. Судя по тому, что нагуглил - это связующее звено между разными контейнерами микросервисов, сборщик логов итп. Поэтому - контейнеризация и докер

* Elasticsearch кластер для реализации логирования продуктивного веб-приложения - три ноды elasticsearch, два logstash и две ноды kibana;

Elasticsearch - на отдельную VDS (нужно резервирование и отказоустойчивость), logstash и kibana можно в контейнеры (особых требований нет)

* Мониторинг-стек на базе Prometheus и Grafana;

Так как по сути оба сервиса - только сборщики данных и ничего важного не хранят - можно оставить в контейнерах

* MongoDB, как основное хранилище данных для java-приложения;

Лучше всего VDS (железный сервер оправдан только в случае высокой нагрузки, а в контейнерах хранить базы данных все же не стоит, это другая крайность)

* Gitlab сервер для реализации CI/CD процессов и приватный (закрытый) Docker Registry.

Gitlab можно в докер (по сути хранения данныз нет, лишь процессы CI/CD), а для реестра хватит VDS (нагрузки особо нет) 

#### Задание 3

* Запустите первый контейнер из образа centos c любым тэгом в фоновом режиме, подключив папку /data из текущей рабочей директории на хостовой машине в /data контейнера;
* Запустите второй контейнер из образа debian в фоновом режиме, подключив папку /data из текущей рабочей директории на хостовой машине в /data контейнера;
* Подключитесь к первому контейнеру с помощью docker exec и создайте текстовый файл любого содержания в /data;
* Добавьте еще один файл в папку /data на хостовой машине;
* Подключитесь во второй контейнер и отобразите листинг и содержание файлов в /data контейнера.

**Ответ:**

Хост-машина:

```
root@devops:/home/vagrant/build# echo "blah-blah-blah" > /data/file-from-hostmachine

```

Centos:

```
root@devops:/home/vagrant# docker run -it -v /data:/data centos
root@34cc0f62a37e /]# ping google.com > /data/ping-from-centos.txt

```

Ubuntu:

```
root@devops:/home/vagrant# docker run -it -v /data:/data ubuntu
root@aef0c2833dc5:/# ls /data
file-from-hostmachine  ping-from-centos.txt
root@aef0c2833dc5:/# cat /data/file-from-hostmachine
blah-blah-blah
root@aef0c2833dc5:/#
root@aef0c2833dc5:/#
root@aef0c2833dc5:/# tail -n 5 /data/ping-from-centos.txt
64 bytes from ams15s48-in-f14.1e100.net (142.251.39.110): icmp_seq=186 ttl=117 time=64.6 ms
64 bytes from ams15s48-in-f14.1e100.net (142.251.39.110): icmp_seq=187 ttl=117 time=64.10 ms
64 bytes from ams15s48-in-f14.1e100.net (142.251.39.110): icmp_seq=188 ttl=117 time=65.2 ms
64 bytes from ams15s48-in-f14.1e100.net (142.251.39.110): icmp_seq=189 ttl=117 time=69.9 ms
64 bytes from ams15s48-in-f14.1e100.net (142.251.39.110): icmp_seq=190 ttl=117 time=64.6 ms
root@aef0c2833dc5:/#

```


#### Задание 4

Воспроизвести практическую часть лекции самостоятельно.

Соберите Docker образ с Ansible, загрузите на Docker Hub и пришлите ссылку вместе с остальными ответами к задачам.

**Ответ:**
[Ссылка на репозиторий](https://hub.docker.com/r/vyacheslavbreus/devops-netology/tags)

docker pull vyacheslavbreus/devops-netology:5.4-ansible

<img src="img\pic2.png">
