## Обязательная задача 1
Мы выгрузили JSON, который получили через API запрос к нашему сервису:
```
    { "info" : "Sample JSON output from our service\t",
        "elements" :[
            { "name" : "first",
            "type" : "server",
            "ip" : 7175 
            }
            { "name" : "second",
            "type" : "proxy",
            "ip : 71.78.22.43
            }
        ]
    }
```
  Нужно найти и исправить все ошибки, которые допускает наш сервис

**ОТВЕТ**
```
    { "info" : "Sample JSON output from our service\t",
        "elements" :[
            { "name" : "first",
            "type" : "server",
            "ip" : 7175                 # Странный IP хотя с точки зрения синтаксиса это и не ошибка 
            }
            { "name" : "second",
            "type" : "proxy",
            "ip" : "71.78.22.43"        # Не хватало кавычек
            }
        ]
    }
```

## Обязательная задача 2
В прошлый рабочий день мы создавали скрипт, позволяющий опрашивать веб-сервисы и получать их IP. К уже реализованному функционалу нам нужно добавить возможность записи JSON и YAML файлов, описывающих наши сервисы. Формат записи JSON по одному сервису: `{ "имя сервиса" : "его IP"}`. Формат записи YAML по одному сервису: `- имя сервиса: его IP`. Если в момент исполнения скрипта меняется IP у сервиса - он должен так же поменяться в yml и json файле.

### Ваш скрипт:
```python
#!/usr/bin/env python3

# Импорт модулей
import socket
import time
import datetime
import json
import yaml

# Переменные
step = 1                                                                                        # Номер попытки
pause = 1                                                                                       # Таймаут между попытками
check = {'drive.google.com':'0.0.0.0', 'mail.google.com':'0.0.0.0', 'google.com':'0.0.0.0'}     # Проверяемые хосты
init=0
output = "/home/vagrant/output/"                                                                # путь к файлам json/yaml

print('')
print('НАЧИНАЕМ ПРОВЕРКУ ХОСТОВ ')
print('')                                                                                       # Пустые строки для улучшения читабельности


while True:
  for host in check:
    originalip: str = check[host]
    ip = socket.gethostbyname(host)
    if ip != check[host]:
      if step==1 and init !=1:
        print(str(datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")) +' ВНИМАНИЕ! у сервиса ' + str(host) +' сменился IP. Было - ' +check[host]+', стало - '+ip)
        # json
        with open(output+host+".json",'w') as jsonfile:
          json_data = json.dumps({host:ip})
          jsonfile.write(json_data)
          print(str(json_data))
        # yaml
        with open(output+host+".yaml",'w') as yamlfile:
          yaml_data = yaml.dump([{host:ip}])
          yamlfile.write(yaml_data)
          print(str(yaml_data))
      check[host]=ip
# счетчик попыток, чтобы скрипт не зацикливался
  step+=1
  if step >= 10:
    break
  time.sleep(pause)
```

### Вывод скрипта при запуске при тестировании:
```
НАЧИНАЕМ ПРОВЕРКУ ХОСТОВ

2022-08-02 15:09:13 ВНИМАНИЕ! у сервиса drive.google.com сменился IP. Было - 0.0.0.0, стало - 142.250.186.142
{"drive.google.com": "142.250.186.142"}
- drive.google.com: 142.250.186.142

2022-08-02 15:09:13 ВНИМАНИЕ! у сервиса mail.google.com сменился IP. Было - 0.0.0.0, стало - 142.250.186.165
{"mail.google.com": "142.250.186.165"}
- mail.google.com: 142.250.186.165

2022-08-02 15:09:13 ВНИМАНИЕ! у сервиса google.com сменился IP. Было - 0.0.0.0, стало - 142.250.186.142
{"google.com": "142.250.186.142"}
- google.com: 142.250.186.142

```

### json-файл(ы), который(е) записал ваш скрипт:
```json
root@test1:/home/vagrant# ls output | grep json
drive.google.com.json
google.com.json
mail.google.com.json

root@test1:/home/vagrant# cat output/drive.google.com.json
{"drive.google.com": "142.250.186.142"}
 
root@test1:/home/vagrant# cat output/mail.google.com.json
{"mail.google.com": "142.250.186.165"}

root@test1:/home/vagrant# cat output/google.com.json
{"google.com": "142.250.186.142"}
```

### yml-файл(ы), который(е) записал ваш скрипт:
```yaml
root@test1:/home/vagrant# ls output | grep yaml
drive.google.com.yaml
google.com.yaml
mail.google.com.yaml

root@test1:/home/vagrant# cat output/drive.google.com.yaml
- drive.google.com: 142.250.186.142

root@test1:/home/vagrant# cat output/mail.google.com.yaml
- mail.google.com: 142.250.186.165

root@test1:/home/vagrant# cat output/google.com.yaml
- google.com: 142.250.186.142
```
