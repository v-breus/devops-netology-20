#!/usr/bin/env python3

import os
import sys

cmd = sys.argv[1]

if len(sys.argv)>=2:
    cmd = sys.argv[1]
bash_command = ["cd "+cmd, "git status"]

print('\033[31m')
result_os = os.popen(' && '.join(bash_command)).read()
#is_change = False
for result in result_os.split('\n'):
    if result.find('fatal') != -1:
        print('\033[31m Каталог \033[1m '+cmd+'\033[0m\033[31m не является GIT репозиторием\033[0m')    
    if result.find('modified') != -1:
        prepare_result = result.replace('\tmodified: ', '')
# добавил замену всех оставшихся пробелов в строке для удобства вывода
        prepare_result = prepare_result.replace(' ', '') 
        print(cmd+prepare_result)
#        break
print('\033[0m')
