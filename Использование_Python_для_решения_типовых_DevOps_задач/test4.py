#!/usr/bin/env python3

# Импорт модулей
import socket
import time
import datetime

# Переменные 
step = 1											# Номер попытки
pause = 1											# Таймаут между попытками
check = {'drive.google.com':'0.0.0.0', 'mail.google.com':'0.0.0.0', 'google.com':'0.0.0.0'}	# Проверяемые хосты
init=0

print('')
print('НАЧИНАЕМ ПРОВЕРКУ ХОСТОВ ')
print('') 											# Пустые строки для улучшения читабельности


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


