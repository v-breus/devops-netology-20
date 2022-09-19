#### Задание 1

Используя docker поднимите инстанс PostgreSQL (версию 12) c 2 volume, в который будут складываться данные БД и бэкапы.

**Ответ:**

```
docker pull postgres:12
docker volume create vol1
docker volume create vol2
docker run -d --name postgres -e POSTGRES_PASSWORD=postgres -ti -p 3000:3000 -v vol1:/var/lib/postgresql/data -v vol2:/var/lib/postgresql/backup postgres:12
```
<img src="img\pic1.png">

#### Задание 2

В БД из задачи 1:

* создайте пользователя test-admin-user и БД test_db
* в БД test_db создайте таблицу orders и clients (спeцификация таблиц ниже)
* предоставьте привилегии на все операции пользователю test-admin-user на таблицы БД test_db
* создайте пользователя test-simple-user
* предоставьте пользователю test-simple-user права на SELECT/INSERT/UPDATE/DELETE данных таблиц БД test_db

Таблица orders:

* id (serial primary key)
* наименование (string)
* цена (integer)

Таблица clients:

* id (serial primary key)
* фамилия (string)
* страна проживания (string, index)
* заказ (foreign key orders)

**Ответ:**

Команды:

```
CREATE DATABASE test_db;
CREATE ROLE "test-admin-user" SUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT LOGIN;

CREATE TABLE orders 
(
id serial, 
name varchar(50), 
price int not null, 
PRIMARY KEY (id) 
);

CREATE TABLE clients 
(
	id integer PRIMARY KEY,
	lastname varchar(50),
	country varchar(50),
	orders integer,
	FOREIGN KEY (orders) REFERENCES orders (Id)
);

GRANT SELECT ON TABLE public.clients TO "test-simple-user";
GRANT INSERT ON TABLE public.clients TO "test-simple-user";
GRANT UPDATE ON TABLE public.clients TO "test-simple-user";
GRANT DELETE ON TABLE public.clients TO "test-simple-user";
GRANT SELECT ON TABLE public.orders TO "test-simple-user";
GRANT INSERT ON TABLE public.orders TO "test-simple-user";
GRANT UPDATE ON TABLE public.orders TO "test-simple-user";
GRANT DELETE ON TABLE public.orders TO "test-simple-user";
```

Итог:

```
postgres=# \l
                                      List of databases
   Name    |  Owner   | Encoding |  Collate   |   Ctype    |        Access privileges
-----------+----------+----------+------------+------------+---------------------------------
 postgres  | postgres | UTF8     | en_US.utf8 | en_US.utf8 |
 template0 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres                    +
           |          |          |            |            | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres                    +
           |          |          |            |            | postgres=CTc/postgres
 test_db   | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =Tc/postgres                   +
           |          |          |            |            | postgres=CTc/postgres          +
           |          |          |            |            | "test-simple-user"=CTc/postgres
(4 rows)


test_db=# \dt+
                      List of relations
 Schema |  Name   | Type  |  Owner   |  Size   | Description
--------+---------+-------+----------+---------+-------------
 public | clients | table | postgres | 0 bytes |
 public | orders  | table | postgres | 0 bytes |
(2 rows)


\du+
                                              List of roles
    Role name     |                         Attributes                         | Member of | Description
------------------+------------------------------------------------------------+-----------+-------------
 postgres         | Superuser, Create role, Create DB, Replication, Bypass RLS | {}        |
 test-admin-user  | Superuser, No inheritance                                  | {}        |
 test-simple-user | No inheritance                                             | {}        |


 SELECT * from information_schema.table_privileges WHERE grantee in ('test-admin-user', 'test-simple-user');
 grantor  |     grantee      | table_catalog | table_schema | table_name | privilege_type | is_grantable | with_hierarchy
----------+------------------+---------------+--------------+------------+----------------+--------------+----------------
 postgres | test-simple-user | test_db       | public       | orders     | INSERT         | NO           | NO
 postgres | test-simple-user | test_db       | public       | orders     | SELECT         | NO           | YES
 postgres | test-simple-user | test_db       | public       | orders     | UPDATE         | NO           | NO
 postgres | test-simple-user | test_db       | public       | orders     | DELETE         | NO           | NO
 postgres | test-simple-user | test_db       | public       | clients    | INSERT         | NO           | NO
 postgres | test-simple-user | test_db       | public       | clients    | SELECT         | NO           | YES
 postgres | test-simple-user | test_db       | public       | clients    | UPDATE         | NO           | NO
 postgres | test-simple-user | test_db       | public       | clients    | DELETE         | NO           | NO
(8 rows)
```

<img src="img\pic2.png">

#### Задание 3

Используя SQL синтаксис - наполните таблицы

**Ответ:**

Команды:

```
insert into orders VALUES (1, 'Шоколад', 10), (2, 'Принтер', 3000), (3, 'Книга', 500), (4, 'Монитор', 7000), (5, 'Гитара', 4000);
insert into clients VALUES (1, 'Иванов Иван Иванович', 'USA'), (2, 'Петров Петр Петрович', 'Canada'), (3, 'Иоганн Себастьян Бах', 'Japan'), (4, 'Ронни Джеймс Дио', 'Russia'), (5, 'Ritchie Blackmore', 'Russia');
select count (*) from orders;
select count (*) from clients;
```

<img src="img\pic3.png">

#### Задание 4

* Часть пользователей из таблицы clients решили оформить заказы из таблицы orders. Используя foreign keys свяжите записи из таблиц, согласно таблице. Приведите SQL-запросы для выполнения данных операций.
* Приведите SQL-запрос для выдачи всех пользователей, которые совершили заказ, а также вывод данного запроса.

**Ответ:**

Команды:

```
update  clients set orders = 3 where id = 1;
update  clients set orders = 4 where id = 2;
update  clients set orders = 5 where id = 3;
SELECT * from clients WHERE orders is NOT NULL;
```

<img src="img\pic4.png">

#### Задание 5

* Получите полную информацию по выполнению запроса выдачи всех пользователей из задачи 4 (используя директиву EXPLAIN).
* Приведите получившийся результат и объясните что значат полученные значения.

**Ответ:**

Команда и результат:

```
EXPLAIN SELECT * from clients WHERE orders is NOT NULL;
                         QUERY PLAN
------------------------------------------------------------
 Seq Scan on clients  (cost=0.00..13.00 rows=298 width=244)
   Filter: (orders IS NOT NULL)
(2 rows)

```
<img src="img\pic5.png">

Объяснение:

Команда сканирует 298 строк базы (показано стрелкой) и применяет к итогу фильтр "orders is not null". Не особенно эффективно, лучше сначала сформировать индекс:

```
CREATE INDEX ON clients(orders);
```
Тогда обработка потребует сканирования уже только 5 строк (показано стрелкой)

<img src="img\pic6.jpg">


#### Задание 6

* Создайте бэкап БД test_db и поместите его в volume, предназначенный для бэкапов (см. Задачу 1).
* Остановите контейнер с PostgreSQL (но не удаляйте volumes).
* Поднимите новый пустой контейнер с PostgreSQL.
* Восстановите БД test_db в новом контейнере.
* Приведите список операций, который вы применяли для бэкапа данных и восстановления.

**Ответ:**

```
pg_dump -U postgres test_db > /var/lib/postgresql/backup/test_db.dump  # создание бэкапа
docker stop c9f7145b2b2f # остановка контейнера
docker volume create vol3 # создание третьего, "пустого" тома
docker run -d --name postgres2 -e POSTGRES_PASSWORD=postgres -ti -p 3000:3000 -v vol3:/var/lib/postgresql/data -v vol2:/var/lib/postgresql/backup postgres:12  # запуск второго контейнера на пустом томе и томе с бэкапом
docker exec -it e6e000741994 bash # вход в него

psql -U postgres
CREATE DATABASE test_db; # создание пустой базы

\q
psql -U postgres test_db < /var/lib/postgresql/backup/test_db.dump # импорт бэкапа
```
