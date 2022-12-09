# Домашнее задание к занятию "3. Использование Yandex Cloud"

## Подготовка к выполнению

1. Подготовьте в Yandex Cloud три хоста: для `clickhouse`, для `vector` и для `lighthouse`.

Ссылка на репозиторий LightHouse: https://github.com/VKCOM/lighthouse

## Основная часть

1. Допишите playbook: нужно сделать ещё один play, который устанавливает и настраивает lighthouse.

```
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
  tasks:
    - name: Clone lighthouse
      become: true
      ansible.builtin.git:
      repo: "{{ lighthouse_git }}"
      dest: "{{ lighthouse_dest }}"
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
    - name: Nginx apply template
      become: true
      ansible.builtin.template:
        src: nginx.conf.j2
        dest: /etc/nginx/conf.d/default.conf
        mode: "0644"
      notify: Start nginx service
    - name: Check git present
      become: true
      ansible.builtin.package:
      name: git
      state: present
```

2. При создании tasks рекомендую использовать модули: `get_url`, `template`, `yum`, `apt`.
3. Tasks должны: скачать статику lighthouse, установить nginx или любой другой webserver, настроить его конфиг для открытия lighthouse, запустить webserver.
4. Приготовьте свой собственный inventory файл `prod.yml`.

```
---
clickhouse:
  hosts:
    clickhouse-01:
      ansible_host: <IP>

vector:
  hosts:
    vector-01:
      ansible_host: <IP>

lighthouse:
  hosts:
    lighthouse-01:
      ansible_host: <IP>
```

5. Запустите `ansible-lint site.yml` и исправьте ошибки, если они есть.

После правки синтаксиса (забыл про вложенность в site.yml) ошибок нет:
<p><img src="img\pic1.png">

6. Попробуйте запустить playbook на этом окружении с флагом `--check`.

Службы еще нет, поэтому ошибка нормальна 

<p><img src="img\pic2.png">

7. Запустите playbook на `prod.yml` окружении с флагом `--diff`. Убедитесь, что изменения на системе произведены.



8. Повторно запустите playbook с флагом `--diff` и убедитесь, что playbook идемпотентен.
9. Подготовьте README.md файл по своему playbook. В нём должно быть описано: что делает playbook, какие у него есть параметры и теги.
10. Готовый playbook выложите в свой репозиторий, поставьте тег `08-ansible-03-yandex` на фиксирующий коммит, в ответ предоставьте ссылку на него.

---

### Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
