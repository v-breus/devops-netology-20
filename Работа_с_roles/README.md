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

