# devops-netology-20
# Netology DevOps homeworks
___________________________________________________________________
# Terraform gitignore description
Далее в формате
строка# - содержимое строки 

описание правила
#
#2. - **/.terraform/*
Будет проигноприровано содержимое папки .terraform во всех возможных подпапках начиная от корня проекта. Сам каталог .terraform не игнорируется

#5. - *.tfstate
Игнорируются файлы с расширением .tfstate

#6. - *.tfstate.*
Игнорируются файлы с расширением, начинающимся на .tfstate. Пример - файл 05.06.2022.tfstate.log будет проигнорирован

#9. - crash.log
Будет проигнорирован файл crash.log

#10. - crash.*.log
Игнорируются все файлы с расширением .log, начинающиеся на crash. Пример - файл crash.tfstate.log будет проигнорирован

#16. - *.tfvars
Игнорируются все файлы с расширением .tfvars

#17. - *.tfvars.json
Игнорируются файлы по шаблону <любое_имя_файла>.tfvars.json

#21. - override.tf
Будет проигнорирован файл override.tf в папке /terraform и всех подпапках

#22. - override.tf.json
Будет проигнорирован файл override.tf.json в папке /terraform и всех подпапках

#23. - *_override.tf
Игнорируются файлы по шаблону <любой_набор_символов>_override.tf в папке /terraform и всех подпапках

#24. - *_override.tf.json
Игнорируются файлы по шаблону <любой_набор_символов>_override.tf.json в папке /terraform и всех подпапках. Пример - файл /terraform/test05.06.22/step1_override.tf.json

#33. - .terraformrc
Файл .terraformrc игнорируется в папке /terraform и всех подпапках

#34. - terraform.rc
Файл terraform.rc игнорируется в папке /terraform и всех подпапках

#38. - ignored_dir/
Исключается содержимое папки ignored_dir в корне

#39. - **/ignored_dir/
И всех папок ignored_dir во вложенных папках

#40. - !ignored_dir/*.sh
bash-скрипты в папках ignored_dir включаются в индекс
