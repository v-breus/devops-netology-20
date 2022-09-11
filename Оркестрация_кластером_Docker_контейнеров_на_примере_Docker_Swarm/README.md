#### Задание 1

Дайте письменные ответы на следующие вопросы:

* В чём отличие режимов работы сервисов в Docker Swarm кластере: replication и global?
* Какой алгоритм выбора лидера используется в Docker Swarm кластере?
* Что такое Overlay Network?

**Ответ:**

* В режиме global сервис запускается на всех нодах, один контейнер на ноду. В режиме replication, то указывается количество копий для каждого сервиса.
* В Swarm нода-лидер выбирается на основе консенсуса. Ноды с ролью "менеджер" периодически обращаются к лидеру и, в случае если текущий лидер не ответил в пределах таймаута, роль лидера передается первой ответившей на запрос ноде-менеджеру.
* Overlay Network - "техническая" сеть кластера, служащая для взаимодействия контейнеров на разных нодах.

#### Задание 2

Создать ваш первый Docker Swarm кластер в Яндекс.Облаке. 

**Ответ:**

<img src="img\pic1.png">

#### Задание 3

Создать ваш первый, готовый к боевой эксплуатации кластер мониторинга, состоящий из стека микросервисов.

**Ответ:**

<img src="img\pic2.png">

#### Задание 4

Выполнить на лидере Docker Swarm кластера команду (указанную ниже) и дать письменное описание её функционала, что она делает и зачем она нужна:

```
# см.документацию: https://docs.docker.com/engine/swarm/swarm_manager_locking/
docker swarm update --autolock=true
```

**Ответ:**

Трафик между нодами шифруется. Данная команда включает блокировку кластера при перезагрузке ноды или выходе из сеанса. На экране при этом отображается ключ, сгенерированный на момент блокировки.

```
[root@node01 centos]# docker swarm update --autolock=true
Swarm updated.
To unlock a swarm manager after it restarts, run the `docker swarm unlock`
command and provide the following key:

    SWMKEY-1-bdfv9BOtPyJ+gb6UmkBTYz5Kf16JZ3t4R3+p4TI73Ac

Please remember to store this key in a password manager, since without it you
will not be able to restart the manager.
[root@node01 centos]# reboot
Connection to 62.84.113.249 closed by remote host.
Connection to 62.84.113.249 closed.
root@ubuntu:~/src/terraform# ssh centos@62.84.113.249
[centos@node01 ~]$ sudo -s
[root@node01 centos]# docker node ls
Error response from daemon: Swarm is encrypted and needs to be unlocked before it can be used. Please use "docker swarm unlock" to unlock it.
[root@node01 centos]# docker swarm unlock
Please enter unlock key:
```

<img src="img\pic3.png">

