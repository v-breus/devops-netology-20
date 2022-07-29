#!/usr/bin/env python3

import os

bash_command = ["cd /vagrant/devops-netology-20/Использование\ Python\ для\ решения\ типовых\ DevOps\ задач/", "git status"]
result = os.popen(' && '.join(bash_command)).read()
#is_change = False  # Лишняя проверка
for result in result.split('\n'):
    if result.find('modified') != -1:
        prepare_result = result.replace('\tmodified:   ', '')
        print(prepare_result)
#        break # Закомментировал т.к. с этой опцией скрипт прерывается после первого вхождения
