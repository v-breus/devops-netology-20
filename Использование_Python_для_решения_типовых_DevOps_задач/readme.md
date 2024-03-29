## Обязательная задача 1

Есть скрипт:
```python
#!/usr/bin/env python3
a = 1
b = '2'
c = a + b
```

### Вопросы:
| Вопрос  | Ответ                                                                                                                                |
| ------------- |--------------------------------------------------------------------------------------------------------------------------------------|
| Какое значение будет присвоено переменной `c`?  | Никакое т.к. система не смогла определить тип переменной.<br/>Ошибка "TypeError: unsupported operand type(s) for +: 'int' and 'str'" |
| Как получить для переменной `c` значение 12?  | a = '1'<br/>b = '2'                                                                                                                   |
| Как получить для переменной `c` значение 3?  | a = 1<br/>b = 2                                                                                                                                  |

## Обязательная задача 2
Мы устроились на работу в компанию, где раньше уже был DevOps Engineer. Он написал скрипт, позволяющий узнать, какие файлы модифицированы в репозитории, относительно локальных изменений. Этим скриптом недовольно начальство, потому что в его выводе есть не все изменённые файлы, а также непонятен полный путь к директории, где они находятся. Как можно доработать скрипт ниже, чтобы он исполнял требования вашего руководителя?

```python
#!/usr/bin/env python3

import os

bash_command = ["cd ~/netology/sysadm-homeworks", "git status"]
result_os = os.popen(' && '.join(bash_command)).read()
is_change = False
for result in result_os.split('\n'):
    if result.find('modified') != -1:
        prepare_result = result.replace('\tmodified:   ', '')
        print(prepare_result)
        break
```

### Ваш скрипт:
```python
#!/usr/bin/env python3

import os

bash_command = ["cd /vagrant/devops-netology-20/Использование_Python_для_решения_типовых_DevOps_задач/", "git status"]
result = os.popen(' && '.join(bash_command)).read()
#is_change = False  # Лишняя проверка
for result in result.split('\n'):
    if result.find('modified') != -1:
        prepare_result = result.replace('\tmodified:   ', '')
        print(prepare_result)
#        break # Закомментировал т.к. с этой опцией скрипт прерывается после первого вхождения

```

### Вывод скрипта при запуске при тестировании:
```
root@test1:/vagrant/devops-netology-20/Использование_Python_для_решения_типовых_DevOps_задач# echo "message 3" >> test.file
root@test1:/vagrant/devops-netology-20/Использование_Python_для_решения_типовых_DevOps_задач# ./test.py
test.file

```
<p><img src="img\pic1.png">

## Обязательная задача 3
1. Доработать скрипт выше так, чтобы он мог проверять не только локальный репозиторий в текущей директории, а также умел воспринимать путь к репозиторию, который мы передаём как входной параметр. Мы точно знаем, что начальство коварное и будет проверять работу этого скрипта в директориях, которые не являются локальными репозиториями.

### Ваш скрипт:
```python
#!/usr/bin/env python3

import os
import sys                                                      # Импорт модуля sys

cmd = sys.argv[1]                                               # Добавление директории как аргумента
bash_command = ["cd "+cmd, "git status"]
result = os.popen(' && '.join(bash_command)).read()
#is_change = False                                              # Лишняя проверка
for result in result.split('\n'):
    if result.find('modified') != -1:
        prepare_result = result.replace('\tmodified:   ', '')
        print(prepare_result)
#        break                                                  # Закомментировал т.к. с этой опцией скрипт прерывается после первого вхождения

```

### Вывод скрипта при запуске при тестировании:
```
root@test1:/vagrant/devops-netology-20/Использование_Python_для_решения_типовых_DevOps_задач# echo "message 4" >> test.file
root@test1:/vagrant/devops-netology-20/Использование_Python_для_решения_типовых_DevOps_задач# ./test.py /vagrant/devops-netology-20/
test.file
root@test1:/vagrant/devops-netology-20/Использование_Python_для_решения_типовых_DevOps_задач#
root@test1:/vagrant/devops-netology-20/Использование_Python_для_решения_типовых_DevOps_задач#
root@test1:/vagrant/devops-netology-20/Использование_Python_для_решения_типовых_DevOps_задач# ./test3.py /vagrant/empty_dir/
fatal: not a git repository (or any parent up to mount point /)
Stopping at filesystem boundary (GIT_DISCOVERY_ACROSS_FILESYSTEM not set).

```

## Обязательная задача 4
1. Наша команда разрабатывает несколько веб-сервисов, доступных по http. Мы точно знаем, что на их стенде нет никакой балансировки, кластеризации, за DNS прячется конкретный IP сервера, где установлен сервис. Проблема в том, что отдел, занимающийся нашей инфраструктурой очень часто меняет нам сервера, поэтому IP меняются примерно раз в неделю, при этом сервисы сохраняют за собой DNS имена. Это бы совсем никого не беспокоило, если бы несколько раз сервера не уезжали в такой сегмент сети нашей компании, который недоступен для разработчиков. Мы хотим написать скрипт, который опрашивает веб-сервисы, получает их IP, выводит информацию в стандартный вывод в виде: <URL сервиса> - <его IP>. Также, должна быть реализована возможность проверки текущего IP сервиса c его IP из предыдущей проверки. Если проверка будет провалена - оповестить об этом в стандартный вывод сообщением: [ERROR] <URL сервиса> IP mismatch: <старый IP> <Новый IP>. Будем считать, что наша разработка реализовала сервисы: `drive.google.com`, `mail.google.com`, `google.com`.

### Ваш скрипт:
```python
#!/usr/bin/env python3

# Импорт модулей
import socket
import time
import datetime

# Переменные
step = 1                                                                                        # Номер попытки
pause = 1                                                                                       # Таймаут между попытками
check = {'drive.google.com':'0.0.0.0', 'mail.google.com':'0.0.0.0', 'google.com':'0.0.0.0'}     # Проверяемые хосты
init=0

print('')
print('НАЧИНАЕМ ПРОВЕРКУ ХОСТОВ ')
print('')                                                                                       # Пустые строки для улучшения читабельности


while 1==1:
  for host in check:
    ip = socket.gethostbyname(host)
    if ip != check[host]:
      if step==1 and init !=1:
        print(str(datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")) +' ВНИМАНИЕ! у сервиса ' + str(host) +' сменился IP. Было - ' +check[host]+', стало - '+ip)
      check[host]=ip
# счетчик попыток, чтобы скрипт не зацикливался
  step+=1
  if step >= 10:
    break
  time.sleep(pause)
```

### Вывод скрипта при запуске при тестировании:
```
root@test1:/vagrant/devops-netology-20/Использование_Python_для_решения_типовых_DevOps_задач# ./test4.py

НАЧИНАЕМ ПРОВЕРКУ ХОСТОВ

2022-07-29 16:22:34 ВНИМАНИЕ! у сервиса drive.google.com сменился IP. Было - 0.0.0.0, стало - 64.233.165.194
2022-07-29 16:22:34 ВНИМАНИЕ! у сервиса mail.google.com сменился IP. Было - 0.0.0.0, стало - 64.233.165.17
2022-07-29 16:22:34 ВНИМАНИЕ! у сервиса google.com сменился IP. Было - 0.0.0.0, стало - 108.177.14.102

```
<p><img src="img\pic2.png">