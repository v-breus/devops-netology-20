#### Задание 1

Используя docker поднимите инстанс PostgreSQL (версию 13). Данные БД сохраните в volume.
Подключитесь к БД PostgreSQL используя psql.
Воспользуйтесь командой \? для вывода подсказки по имеющимся в psql управляющим командам.
Найдите и приведите управляющие команды для:

* вывода списка БД
* подключения к БД
* вывода списка таблиц
* вывода описания содержимого таблиц
* выхода из psql

**Ответ:**

```
wget https://raw.githubusercontent.com/netology-code/virt-homeworks/virt-11/06-db-04-postgresql/test_data/test_dump.sql # скачиваем дамп БД
docker pull postgres:13.8 # скачиваем образ
docker volume create vol1 # том для БД
docker run -d --name postgres -e POSTGRES_PASSWORD=postgres -ti -p 3000:3000 -v vol1:/var/lib/postgresql/data -v /root:/root postgres:13.8 # запускаем контейнер (папка /root смонтирована т.к.там дамп)
docker exec -it postgres bash # логинимся в контейнер
psql -U postgres # входим в консоль postgres
\l # список баз
\c <DB_name> # подключение к конкретной базе
\dt[S+] # список таблиц
\dt[S+] <table_name> # описание содержимого
\q # выход
```
<img src="img\pic1.png">
<img src="img\pic2.png">
<img src="img\pic3.png">


#### Задание 2

* Используя psql создайте БД test_database.
* Изучите бэкап БД.
* Восстановите бэкап БД в test_database.
* Перейдите в управляющую консоль psql внутри контейнера.
* Подключитесь к восстановленной БД и проведите операцию ANALYZE для сбора статистики по таблице.
* Используя таблицу pg_stats, найдите столбец таблицы orders с наибольшим средним значением размера элементов в байтах. Приведите в ответе команду, которую вы использовали для вычисления и полученный результат.

**Ответ:**

```
create database test_database # создаю пустую базу
psql -U postgres test_database < /root/test_dump.sql # восстанавливаю дамп
analyze verbose orders; # статистика, из которой видно, что таблица ORDERS содержит 8 строк
select avg_width from pg_stats where tablename='orders' order by avg_width desc; # выборка столбцов таблицы orders с сортировкой по размеру  
```

<img src="img\pic4.png">

#### Задание 3

Архитектор и администратор БД выяснили, что ваша таблица orders разрослась до невиданных размеров и поиск по ней занимает долгое время. Вам, как успешному выпускнику курсов DevOps в нетологии предложили провести разбиение таблицы на 2 (шардировать на orders_1 - price>499 и orders_2 - price<=499).
Предложите SQL-транзакцию для проведения данной операции.
Можно ли было изначально исключить "ручное" разбиение при проектировании таблицы orders?

**Ответ:**

Текущую таблицу изменить уже нельзя (если и можно, то я не нашел как, буду признателен если подскажете). Нашел вариант решения этой задачи через переименование и копирование данных в новую таблицу:  

```
BEGIN; # начало транзакции
ALTER TABLE orders RENAME TO old_orders; # переименовал таблицу orders в old_orders 

CREATE TABLE orders AS table old_orders WITH NO DATA; # создал таблицу orders со структурой, аналогичной old_orders, но без данных

CREATE TABLE orders_high (
    CHECK (price > 499)
) INHERITS (orders);  # создал таблицу orders_high с проверкой по столбцу price (попадают значения больше 499)

CREATE TABLE orders_low (
    CHECK (price <= 499)
) INHERITS (orders); # создал таблицу orders_low с проверкой по столбцу price (попадают значения меньше или равно 499)

CREATE RULE orders_high_insert AS
ON INSERT TO orders WHERE
    (price > 499)
DO INSTEAD
    INSERT INTO orders_high VALUES (NEW.*); # создание правила "если заказ с ценой > 499, то вместо таблицы ORDERS транзакция INSERT идет в таблицу orders_high)"
       
CREATE RULE orders_low_insert AS
ON INSERT TO orders WHERE
    (price <= 499)
DO INSTEAD
    INSERT INTO orders_low VALUES (NEW.*); # создание правила "если заказ с ценой <= 499, то вместо таблицы ORDERS транзакция INSERT идет в таблицу orders_low)"
    
INSERT INTO orders
SELECT * FROM old_orders; # перенос всех данных из таблицы old_orders в таблицу orders
COMMIT; # запись транзакции
```
<img src="img\pic5.png">
<img src="img\pic6.png">

Изначально можно было бы добавить директиву PARTITION BY RANGE (price) в команду создания таблицы orders, а также добавить создание таблиц orders_high и orders_low:
```
CREATE TABLE orders (
    id integer NOT NULL,
    title character varying(80) NOT NULL,
    price integer DEFAULT 0
) PARTITION BY RANGE (price);

CREATE TABLE orders_high PARTITION OF orders
    FOR VALUES GREATER THAN ('499');

CREATE TABLE orders_low PARTITION OF orders
    FOR VALUES FROM ('0') TO ('499');
```
Вид "поправленного" дампа и результат его восстановления на скриншотах ниже: 

<img src="img\pic7.png">
<img src="img\pic8.png">

#### Задание 4

Используя утилиту pg_dump создайте бекап БД test_database.
Как бы вы доработали бэкап-файл, чтобы добавить уникальность значения столбца title для таблиц test_database?

**Ответ:**

```
pg_dump -U postgres test_database > /root/test_database_mod.sql --verbose  # бэкап
```

Касательно доработки дампа - нужно добавить директиву UNIQUE к строке title character varying(80) NOT NULL

<img src="img\pic9.png">
