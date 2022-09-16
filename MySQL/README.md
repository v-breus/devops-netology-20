#### Задание 1

* Используя docker поднимите инстанс MySQL (версию 8). Данные БД сохраните в volume.
* Изучите бэкап БД и восстановитесь из него.
* Перейдите в управляющую консоль mysql внутри контейнера.
* Используя команду \h получите список управляющих команд.
* Найдите команду для выдачи статуса БД и приведите в ответе из ее вывода версию сервера БД.
* Подключитесь к восстановленной БД и получите список таблиц из этой БД.
* Приведите в ответе количество записей с price > 300.

**Ответ:**

```
docker pull mysql:8.0 # загружаем контейнер
docker volume create vol1 && docker volume create vol2 # создаем тома
docker run -d --name mysql -e MYSQL_ROOT_PASSWORD=mysql -ti -p 3306:3306 -v vol1:/etc/mysql/ -v vol2:/var/lib/mysql -v /root:/root mysql:8.0 # запускаем контейнер (папка /root смонтирована т.к.там дамп)
docker exec -it 382f08587687944f55f0660471ea8553fa810068dbf3a9718a85c4fcca0b94b7 bash # вошел в контейнер
mysql -uroot -pmysql # входим в консоль
\s # смотрим статус
create database test_db; # создаем пустую базу
mysql -u root -pmysql test_db < /root/test_dump.sql # импорт дампа
mysql -uroot -pmysql # входим в консоль
show databases; # список баз
use test_db; # выбор базы
show tables # список таблиц
select count(*) from orders where price >300; # количество записей в единственной таблице orders с price > 300
```

#### Задание 2

Создайте пользователя test в БД c паролем test-pass, используя:

* плагин авторизации mysql_native_password
* срок истечения пароля - 180 дней
* количество попыток авторизации - 3
* максимальное количество запросов в час - 100
* аттрибуты пользователя:
  Фамилия "Pretty"
  Имя "James"
  Предоставьте привилегии пользователю test на операции SELECT базы test_db.

Используя таблицу INFORMATION_SCHEMA.USER_ATTRIBUTES получите данные по пользователю test и приведите в ответе к задаче.

**Ответ:**

```
CREATE USER 'test'@'localhost'
IDENTIFIED WITH mysql_native_password BY 'test-pass' 
WITH MAX_QUERIES_PER_HOUR 100
PASSWORD EXPIRE INTERVAL 180 DAY
FAILED_LOGIN_ATTEMPTS 3
ATTRIBUTE '{"fname": "James", "lname": "Pretty"}'; # создание пользователя

GRANT SELECT ON test_db.* TO 'test'@'localhost'; # выдача прав

select * from information_schema.user_attributes where user='test'; # атрибуты

mysql> select * from information_schema.user_attributes where user='test';
+------+-----------+---------------------------------------+
| USER | HOST      | ATTRIBUTE                             |
+------+-----------+---------------------------------------+
| test | localhost | {"fname": "James", "lname": "Pretty"} |
+------+-----------+---------------------------------------+
1 row in set (0.00 sec)

```

#### Задание 3

* Установите профилирование SET profiling = 1. Изучите вывод профилирования команд SHOW PROFILES;.
* Исследуйте, какой engine используется в таблице БД test_db и приведите в ответе.
* Измените engine и приведите время выполнения и запрос на изменения из профайлера в ответе:
  на MyISAM
  на InnoDB

**Ответ:**

```
mysql> SELECT engine FROM information_schema.tables WHERE table_schema= 'test_db'; # используемый движок
+--------+
| ENGINE |
+--------+
| InnoDB |
+--------+
1 row in set (0.00 sec) 

mysql> alter table orders engine = myisam; # смена движка на myisam
Query OK, 5 rows affected (0.02 sec)
Records: 5  Duplicates: 0  Warnings: 0

mysql> alter table orders engine = innodb; # и обратно
Query OK, 5 rows affected (0.03 sec)
Records: 5  Duplicates: 0  Warnings: 0


mysql> show profiles; # запросы на смену заняли 0.01937725 и 0.02525950 с.
+----------+------------+----------------------------------------------------------------------------+
| Query_ID | Duration   | Query                                                                      |
+----------+------------+----------------------------------------------------------------------------+
|        1 | 0.00023375 | SELECT DATABASE()                                                          |
|        2 | 0.00022700 | SELECT DATABASE()                                                          |
|        3 | 0.00017875 | SET profiling=1                                                            |
|        4 | 0.00208000 | SELECT engine FROM information_schema.tables WHERE table_schema= 'test_db' |
|        5 | 0.01937725 | alter table orders engine = myisam                                         |
|        6 | 0.02525950 | alter table orders engine = innodb                                         |
+----------+------------+----------------------------------------------------------------------------+
6 rows in set, 1 warning (0.00 sec)

```

#### Задание 4

Изучите файл my.cnf в директории /etc/mysql.

Измените его согласно ТЗ (движок InnoDB):

* Скорость IO важнее сохранности данных
* Нужна компрессия таблиц для экономии места на диске
* Размер буффера с незакомиченными транзакциями 1 Мб
* Буффер кеширования 30% от ОЗУ
* Размер файла логов операций 100 Мб
Приведите в ответе измененный файл my.cnf.

**Ответ:**

```
[mysqld]
pid-file        = /var/run/mysqld/mysqld.pid
socket          = /var/run/mysqld/mysqld.sock
datadir         = /var/lib/mysql
secure-file-priv= NULL

# Custom config should go here
!includedir /etc/mysql/conf.d/

innodb_flush_method = O_DSYN # Скорость IO важнее сохранности данных
innodb_file_per_table = 1 # для сжатия
innodb_file_format = Barracuda # для сжатия
innodb_default_row_format=compressed # для сжатия
innodb_log_buffer_size = 1M # размер буффера с незакомиченными транзакциями
innodb_buffer_pool_size = 700M # кеш 30% от ОЗУ (всего у меня 2G) 
innodb_log_file_size = 100M # размер файла логов операций
```
