pipeline {
    agent any 

    stages {
        stage('prepare_node') {
            steps {
                git 'https://github.com/v-breus/netology-vector-role.git'
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