pipeline {
    agent any

    environment {
        VENV_PATH = '/opt/venv'
        PATH = "/opt/venv/bin:$PATH"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/SugumarSrinivasan/Python.git'
            }
        }

        stage('Test') {
            steps {
                dir('project'){
                echo 'Running tests...'
                sh '${VENV_PATH}/bin/python -m pytest tests/test_main.py'
                }
            }
        }

        stage('Deploy') {
            steps {
                dir('project') {
                    sh 'Deploying application...'
                    sh '${VENV_PATH}/bin/python app/main.py'
            }
        }
    }
    post {
        success {
            echo 'Build succeeded!'
        }
        failure {
            echo 'Build failed!'
        }
    }
}
