pipeline {
    agent any

    environment {
        VENV_PATH = './venv'
        PATH = "./venv/bin:$PATH"
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
                    sh '''#!/bin/bash
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
                sh 'python -m pytest tests/test_main.py'
                }
            }
        }
        stage('Scan') {
            steps {
                dir('project') {
                    sh '''#!/bin/bash
                        echo "Running Pylint..."
                        pylint $(find . -name "*.py") || true
                    '''
                }
            }
        }

        stage('Publish') {
            steps {
                withCredentials([string(credentialsId: 'github_global', variable: 'github_global')]) {
                    script {
                        def tagName = "v1.0.${env.BUILD_NUMBER}"
                        def releaseName = "Release ${tagName}"
                        def repo = "SugumarSrinivasan/Python"
                        def artifactPath = "project/dist/app.zip" // Change this to your artifact path
        
                        sh """
                        echo "Creating release ${tagName} on GitHub..."
        
                        # Create a new release
                        curl -s -X POST https://api.github.com/repos/${repo}/releases \\
                            -H "Authorization: token ${GH_TOKEN}" \\
                            -H "Content-Type: application/json" \\
                            -d '{
                                "tag_name": "${tagName}",
                                "target_commitish": "main",
                                "name": "${releaseName}",
                                "body": "Automated release from Jenkins",
                                "draft": false,
                                "prerelease": false
                            }' > release.json
        
                        # Extract the upload URL from the release JSON
                        upload_url=\$(cat release.json | python3 -c "import sys, json; print(json.load(sys.stdin)['upload_url'].split('{')[0])")
        
                        echo "Uploading artifact ${artifactPath}..."
                        curl -s -X POST "\${upload_url}?name=\$(basename ${artifactPath})" \\
                            -H "Authorization: token ${GH_TOKEN}" \\
                            -H "Content-Type: application/zip" \\
                            --data-binary @${artifactPath}
                        """
                    }
                }
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
                dir('project') {
                    sh '''#!/bin/bash
                        python app/main.py
                        echo "Application deployed successfully!"
                    '''
                }
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
