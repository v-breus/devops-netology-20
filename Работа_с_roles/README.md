# Домашнее задание к занятию "8.4 Работа с Roles"

## Подготовка к выполнению

Создайте два пустых публичных репозитория в любом своём проекте: vector-role и lighthouse-role.
Готово

Добавьте публичную часть своего ключа к своему профилю в github.
Готово

## Основная часть

Наша основная цель - разбить наш playbook на отдельные roles. Задача: сделать roles для clickhouse, vector и lighthouse и написать playbook для использования этих ролей. Ожидаемый результат: существуют три ваших репозитория: два с roles и один с playbook.

1. Создать в старой версии playbook файл `requirements.yml` и заполнить его следующим содержимым:

```
---
  - src: git@github.com:AlexeySetevoi/ansible-clickhouse.git
    scm: git
    version: "1.11.0"
    name: clickhouse
```
<p><img src="img\pic1.png">

 
2. При помощи ansible-galaxy скачать себе эту роль.
С предложенным вариантом выдавало ошибку доступа

<p><img src="img\err1.png">

Пришлось модифицировать первую строку файла `requirements.yml` до:
```
src: git+https://github.com/AlexeySetevoi/ansible-clickhouse.git
```
Результат без ошибок:

<p><img src="img\pic2.png">

3. Создать новый каталог с ролью при помощи `ansible-galaxy role init vector-role`.

<p><img src="img\pic3.png">

4. На основе tasks из старого playbook заполните новую role. Разнесите переменные между vars и default.

Добавил в роль:
 
```
---
- name: Get vector distrib
  ansible.builtin.get_url:
    url: "https://packages.timber.io/vector/{{ vector_version }}/{{ item }}-{{ vector_version }}-1.x86_64.rpm"
    dest: "./{{ item }}-{{ vector_version }}.rpm"
  loop: "{{ vector_packages }}"

- name: Install vector packages
  become: true
  ansible.builtin.yum:
    name: "{{ item }}-{{ vector_version }}.rpm"
  loop: "{{ vector_packages }}"
  notify: Start vector service
```

vars/main.yml:

```
---
vector_packages:
  - vector 
```

defaults/main.yml

```
---
vector_version: "0.9.2" 
```

5. Перенести нужные шаблоны конфигов в templates.

```
/root/Работа_с_roles/playbook/templates/nginx.conf.j2                                                                                                                                                              303/303               100%
server {
        listen 80 default_server;
#        listen [::]:80 default_server;
        root {{ lighthouse_dest }};

        # Add index.php to the list if you are using PHP
        index index.html;

        server_name _;

        location / {
                try_files $uri $uri/ =404;
        }
}
```

6. Описать в README.md параметры роли

[Vector](https://github.com/v-breus/netology-vector-role.git)

7. Повторите шаги 3-6 для lighthouse. Помните, что одна роль должна настраивать один продукт.

[Lighthouse](https://github.com/v-breus/netology-lighthouse-role.git)

8. Выложите все roles в репозитории. Проставьте тэги, используя семантическую нумерацию Добавьте roles в requirements.yml в playbook.

```
/root/Работа_с_roles/playbook/requirements.yml                                                                                                                                                                     363/363               100%
---
- src: git+https://github.com/AlexeySetevoi/ansible-clickhouse.git
  scm: git
  version: "1.11.0"
  name: clickhouse

- src: git+https://github.com/v-breus/netology-vector-role.git
  scm: git
#  version: "1.0.0"
  name: vector-role

- src: git+https://github.com/v-breus/netology-lighthouse-role.git
  scm: git
 # version: "1.0.1"
  name: lighthouse-role
```

9. Переработайте playbook на использование roles. Не забудьте про зависимости lighthouse и возможности совмещения roles с tasks

```
/root/Работа_с_roles/playbook/site.yml                                                                                                                                                                            1174/1174              100%
---
- name: Install Clickhouse
  hosts: clickhouse
  remote_user: root
  roles:
    - clickhouse

- name: Install Vector
  hosts: vector
  remote_user: root
  roles:
    - vector-role

- name: Install lighthouse
  tags: lighthouse
  hosts: lighthouse
  remote_user: root
  handlers:
    - name: Start nginx service
      become: true
      ansible.builtin.service:
        name: nginx
        state: restarted
  pre_tasks:
    - name: add repo
      become: true
      ansible.builtin.copy:
        dest: /etc/yum.repos.d/nginx.repo
        content: |
          [nginx-stable]
          name=nginx stable repo
          baseurl=http://nginx.org/packages/centos/$releasever/$basearch/
          gpgcheck=1
          enabled=1
          gpgkey=https://nginx.org/keys/nginx_signing.key
          module_hotfixes=true
    - name: Install nginx
      become: true
      ansible.builtin.package:
        name: nginx
        state: present
    - name: Create nginx config
      become: true
      ansible.builtin.template:
        src: nginx.conf.j2
        dest: /etc/nginx/conf.d/default.conf
        mode: "0644"
      notify: Start nginx service
  roles:
    - lighthouse-role
```

10. Выложите playbook в репозиторий, в ответ приведите ссылки на оба репозитория с roles и одну ссылку на репозиторий с playbook.

[Роль Vector](https://github.com/v-breus/netology-vector-role.git)

[Роль Lighthouse](https://github.com/v-breus/netology-lighthouse-role.git)

[Playbook](https://github.com/v-breus/devops-netology-20/tree/main/Работа_с_roles/playbook)

Результат выполнения плейбука

<p><img src="img\pic5.png">


