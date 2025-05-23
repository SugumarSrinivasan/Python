pipeline {
    agent any

    environment {
        VENV_PATH = '/opt/venv'
        PATH = "/opt/venv/bin:$PATH"
    }
    
    options {
        buildDiscarder(logRotator(
            numToKeepStr: '3', 
            artifactNumToKeepStr: '3'
        ))
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/SugumarSrinivasan/Python.git'
            }
        }

        stage('Build') {          
            steps {
                script {
                    sh '''
                    pip install --upgrade pip
                    if [ ! -d "${VENV_PATH}" ]; then
                        python3 -m venv ${VENV_PATH}
                        source ${VENV_PATH}/bin/activate
                        pip install -r requirements.txt
                    else
                        source ${VENV_PATH}/bin/activate
                        pip install --upgrade -r requirements.txt
                    fi
                    '''
                }  
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

        stage('Publish') {
            steps {
                echo 'Publishing artifacts to Artifactory...'  
                // Insert Artifactory publish command here
            }
        }   
        stage('DEVDeploy') {
            steps {
                script {
                    def userInput = input(
                        id: 'DeployApproval', message: 'Deploy to DEV?', ok: 'Approve',
                        parameters: [
                            string(name: 'Deployer', defaultValue: '', description: 'Enter your name'),
                            choice(name: 'Environment', choices: ['DEV', 'QA', 'PROD'], description: 'Choose environment')
                        ]
                    )
                    echo "Approved by: ${userInput['Deployer']} for environment: ${userInput['Environment']}"
                }                
                echo 'Deploying the application...'
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
