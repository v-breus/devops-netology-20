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


while 1==1:
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
