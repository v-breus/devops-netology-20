# Домашнее задание к занятию "10.Jenkins"

## Подготовка к выполнению

1. Создать 2 VM: для jenkins-master и jenkins-agent.
2. Установить jenkins при помощи playbook'a.
3. Запустить и проверить работоспособность.

<img src="img\pic1.png">

4. Сделать первоначальную настройку.

<img src="img\pic2.png">


## Основная часть

1. Сделать Freestyle Job, который будет запускать `molecule test` из любого вашего репозитория с ролью.

<img src="img\pic3.png">

2. Сделать Declarative Pipeline Job, который будет запускать `molecule test` из любого вашего репозитория с ролью.

```
pipeline {
    agent any 

    stages {
        stage('prepare_node') {
            steps {
                sh 'git clone https://github.com/v-breus/netology-vector-role.git'
                sh 'pip install molecule'
                sh 'cd netology-vector-role/tasks'
                sh 'molecule init scenario default'
            }
        }
        stage('run_test') {
            steps {
                sh 'molecule test site.yml'
            }
        }
        
    }
}
```

3. Перенести Declarative Pipeline в репозиторий в файл `Jenkinsfile`.


4. Создать Multibranch Pipeline на запуск `Jenkinsfile` из репозитория.
5. Создать Scripted Pipeline, наполнить его скриптом из [pipeline](https://github.com/netology-code/mnt-homeworks/blob/MNT-video/09-ci-04-jenkins/pipeline).
6. Внести необходимые изменения, чтобы Pipeline запускал `ansible-playbook` без флагов `--check --diff`, если не установлен параметр при запуске джобы (prod_run = True), по умолчанию параметр имеет значение False и запускает прогон с флагами `--check --diff`.
7. Проверить работоспособность, исправить ошибки, исправленный Pipeline вложить в репозиторий в файл `ScriptedJenkinsfile`.
8. Отправить ссылку на репозиторий с ролью и Declarative Pipeline и Scripted Pipeline.

