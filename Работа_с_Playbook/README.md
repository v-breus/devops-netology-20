# Домашнее задание к занятию "2. Работа с Playbook"

## Подготовка к выполнению

1. (Необязательно) Изучите, что такое [clickhouse](https://www.youtube.com/watch?v=fjTNS2zkeBs) и [vector](https://www.youtube.com/watch?v=CgEhyffisLY)
2. Создайте свой собственный (или используйте старый) публичный репозиторий на github с произвольным именем.
3. Скачайте [playbook](./playbook/) из репозитория с домашним заданием и перенесите его в свой репозиторий.
4. Подготовьте хосты в соответствии с группами из предподготовленного playbook.

## Основная часть

1. Приготовьте свой собственный inventory файл `prod.yml`.
2. Допишите playbook: нужно сделать ещё один play, который устанавливает и настраивает [vector](https://vector.dev).
Добавил

```
- name: Install Vector
  hosts: vector
  handlers:
    - name: Start Vector service
      become: true
      ansible.builtin.service:
        name: vector
        state: restarted
  tasks:
    - name: Vector | Download packages
      ansible.builtin.get_url:
        url: "{{ vector_url }}"
        dest: "./vector-{{ vector_version }}-1.x86_64.rpm"
    - name: Vector | Install packages
      become: true
      ansible.builtin.yum:
        name: "./vector-{{ vector_version }}-1.x86_64.rpm"
        disable_gpg_check: true
    - name: Vector | Apply template
      become: true
      ansible.builtin.template:
        src: vector.yml.j2
        dest: "{{ vector_config_dir }}/vector.yml"
        mode: "0644"
        owner: "{{ ansible_user_id }}"
        group: "{{ ansible_user_gid }}"
    - name: Vector | change systemd unit
      become: true
      ansible.builtin.template:
        src: vector.service.j2
        dest: /usr/lib/systemd/system/vector.service
        mode: "0644"
        owner: "{{ ansible_user_id }}"
        group: "{{ ansible_user_gid }}"
        backup: true
      notify: Start Vector service`
```

3. При создании tasks рекомендую использовать модули: `get_url`, `template`, `unarchive`, `file`.
4. Tasks должны: скачать нужной версии дистрибутив, выполнить распаковку в выбранную директорию, установить vector.
5. Запустите `ansible-lint site.yml` и исправьте ошибки, если они есть.

Ошибок нет
<p><img src="img\pic1.png">

6. Попробуйте запустить playbook на этом окружении с флагом `--check`.

Выдает ошибку, полагаю потому, что службы еще нет
<p><img src="img\pic2.png">

7. Запустите playbook на `prod.yml` окружении с флагом `--diff`. Убедитесь, что изменения на системе произведены.

<p><img src="img\pic3.png">

8. Повторно запустите playbook с флагом `--diff` и убедитесь, что playbook идемпотентен

<p><img src="img\pic4.png">

9. Подготовьте README.md файл по своему playbook. В нём должно быть описано: что делает playbook, какие у него есть параметры и теги.

``` 
---
- name: Install Clickhouse
  hosts: clickhouse
  handlers:
    - name: Start clickhouse service
      become: true
      ansible.builtin.service:
        name: clickhouse-server
        state: restarted
  tasks:
    - name: Install clickhouse-common
      tags: cinst
      ansible.builtin.yum:
          name: https://packages.clickhouse.com/rpm/stable/clickhouse-common-static-{{ clickhouse_version }}.x86_64.rpm # ставим пакет
          state: present
    - name: Install clickhouse-server
      ansible.builtin.yum:
          name: https://packages.clickhouse.com/rpm/stable/clickhouse-server-{{ clickhouse_version }}.x86_64.rpm # ставим пакет
          state: present
    - name: Install clickhouse-client
      ansible.builtin.yum:
          name: https://packages.clickhouse.com/rpm/stable/clickhouse-client-{{ clickhouse_version }}.x86_64.rpm # ставим пакет
          state: present
      notify: Start clickhouse service # вызываем хендлер
    - name: Reload clickhouse service # почему-то через хендлер у меня не срабатывал рестарт и фейлилось создание базы данных, пришлось добавить задачу на "отдельный" рестарт
      tags: cr # здесь и далее - тег использовал для отладки задачи, запуска вида "ansible-playbook -i inventory/prod.yml site.yml -t <тег>
      systemd:
        name: clickhouse-server
        state: restarted
    - name: Create database # создаем БД
      ansible.builtin.command: "clickhouse-client -q 'create database logs;'" 
      register: create_db
      failed_when: create_db.rc != 0 and create_db.rc !=82
      changed_when: create_db.rc == 0

- name: Install Vector
  hosts: vector
  handlers:
    - name: Start Vector service
      become: true
      ansible.builtin.service:
        name: vector
        state: restarted
  tasks:
    - name: Vector | Download packages # скачиваем Вектор
      tags: vdl
      ansible.builtin.get_url:
        url: "{{ vector_url }}"
        dest: "./vector-{{ vector_version }}-1.x86_64.rpm"
    - name: Vector | Install packages # ставим его
      tags: vinst
      become: true
      ansible.builtin.yum:
        name: "./vector-{{ vector_version }}-1.x86_64.rpm"
        disable_gpg_check: true
    - name: Vector | Apply template # копируем конфиг из шаблона
      tags: vtpl
      become: true
      ansible.builtin.template:
        src: vector.yml.j2
        dest: "{{ vector_config_dir }}/vector.yml"
        mode: "0644"
        owner: "{{ ansible_user_id }}"
        group: "{{ ansible_user_gid }}"
    - name: Vector | change systemd unit # создаем юнит для управления через systemctl
      tags: vserv
      become: true
      ansible.builtin.template:
        src: vector.service.j2
        dest: /usr/lib/systemd/system/vector.service
        mode: "0644"
        owner: "{{ ansible_user_id }}"
        group: "{{ ansible_user_gid }}"
        backup: true
      notify: Start Vector service` # стартуем сервис
```

10. Готовый playbook выложите в свой репозиторий, поставьте тег `08-ansible-02-playbook` на фиксирующий коммит, в ответ предоставьте ссылку на него.

---

### Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
