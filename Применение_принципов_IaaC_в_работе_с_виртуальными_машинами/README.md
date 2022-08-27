#### Задание 1

* Опишите своими словами основные преимущества применения на практике IaaC паттернов.
* Какой из принципов IaaC является основополагающим?

**Ответ:**

_Преимущества применения принципов IaaC_
1. Легкая масштабируемость
2. Единообразие всех сред, устранение "человеческого фактора" при развертывании
3. Ускорение развертывания узлов сети
4. Некоторое снижение требований к квалификации членов команды (условно - достаточно иметь один раз корректно написанный шаблон развертывания и обучить членов команды его разворачивать)

_Основополагающий принцип IaaC_ - идемпотентность, все узлы, развернутые по одному шаблону, имеют одинаковую конфигурацию и вследствие этого одинаково работают.

#### Задание 2

* Чем Ansible выгодно отличается от других систем управление конфигурациями?
* Какой, на ваш взгляд, метод работы систем конфигурации более надёжный push или pull?

**Ответ:**

На мой взгляд, основных выгодных отличий у Ansible три - не требует устанавливать никакой дополнительный софт (хватает SSH + Python), идемпотентность "по умолчанию" (если, например, изменение уже выполнено, не будет повторной попытки установки, шаг сразу перейдет в состояние "ОК") и относительно понятный yaml-подобный синтаксис шаблонов.
Что касается методов работы, то наверное push-модель все же лучше т.к. при "отправке" конфигураций со стороны управляющего сервера сразу понятно, куда удалось залить, а куда нет. При pull-модели на сервере видно только кто запросил конфигурацию, и поэтому нужно каким-то образом инвентаризировать сами узлы сети отдельно.

#### Задание 3

Установить на личный компьютер:

* VirtualBox
* Vagrant
* Ansible

Приложить вывод команд установленных версий каждой из программ, оформленный в markdown.

**Ответ:**

```
bva@pc ~
$ vagrant -v
Vagrant 2.2.19

bva@pc ~
$ VBoxManage -v
6.1.34r150636

bva@pc ~
$ ansible --version
ansible 2.8.4
  config file = /etc/ansible/ansible.cfg
  configured module search path = ['/home/bva/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python3.7/site-packages/ansible
  executable location = /usr/bin/ansible
  python version = 3.7.12 (default, Nov 23 2021, 18:58:07) [GCC 11.2.0]


```

#### Задание 4

**Ответ:**

```
$ vagrant ssh
Welcome to Ubuntu 20.04.4 LTS (GNU/Linux 5.4.0-110-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

 System information disabled due to load higher than 2.0


This system is built by the Bento project by Chef Software
More information can be found at https://github.com/chef/bento
vagrant@vagrant:~$ docker ps
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
vagrant@vagrant:~$

```
