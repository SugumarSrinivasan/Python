pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/SugumarSrinivasan/Jenkins.git'
            }
        }

        stage('Install Dependencies') {
            steps {
                echo 'Installing dependencies...'
                sh 'pip3 install -r requirements.txt'
            }
        }

        stage('Test') {
            steps {
                echo 'Running tests...'
                sh 'pytest tests/test_main.py'
            }
        }

        stage('Deploy') {
            steps {
                echo 'Simulating deployment step...'
                // Add deployment logic here (e.g., copy files, call scripts, etc.)
                sh 'echo "Deploying application..."'
                sh 'python3 app/main.py'
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
