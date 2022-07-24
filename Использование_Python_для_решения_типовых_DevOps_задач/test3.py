#!/usr/bin/env python3

import os
import sys							# Импорт модуля sys

cmd = sys.argv[1]						# Добавление директории как аргумента
bash_command = ["cd "+cmd, "git status"]
result = os.popen(' && '.join(bash_command)).read()
#is_change = False  						# Лишняя проверка
for result in result.split('\n'):
    if result.find('modified') != -1:
        prepare_result = result.replace('\tmodified:   ', '')
        print(prepare_result)
#        break 							# Закомментировал т.к. с этой опцией скрипт прерывается после первого вхождения
