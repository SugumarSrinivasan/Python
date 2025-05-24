pipeline {
    agent any

    environment {
        VENV_PATH = './project/venv'
        PATH = "./project/venv/bin:$PATH"
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
                sh '''#!/bin/bash
                ./venv/bin/python -m pytest --cov=app tests/ --cov-report=html
                '''
                }
            }
        }

        stage('Scan') {
            steps {
                dir('project') {
                    sh '''#!/bin/bash
                        echo "Running Pylint..."
                        ./venv/bin/python -m pylint app tests --output-format=json > pylint-report.json || true
                        ./venv/bin/pylint-json2html -f json -o pylint-report.html pylint-report.json
                    '''
                }
            }
        }

        stage('Package') {
            steps {
                dir('project') {
                    sh '''#!/bin/bash
                    cp ../requirements.txt .
                    mkdir -p dist
                    zip -r dist/app.zip app tests requirements.txt Dockerfile Jenkinsfile README.md
                    '''
                    archiveArtifacts artifacts: 'dist/app.zip', fingerprint: true
                }
            }
        }

        stage('Publish') {
            steps {
                withCredentials([string(credentialsId: 'GITHUB_TOKEN', variable: 'GH_TOKEN')]) {
                    script {
                        def tagName = "v1.0.${env.BUILD_NUMBER}"
                        def releaseName = "Release ${tagName}"
                        def repo = "SugumarSrinivasan/Python"
                        def artifactPath = "project/dist/app.zip" // Change this to your artifact path

                        sh """#!/bin/bash
                        set -e
                        echo "Creating release ${tagName} on GitHub..."
                        
                        release_response=\$(curl -s -w "%{http_code}" -o release.json -X POST https://api.github.com/repos/${repo}/releases \\
                            -H "Authorization: token ${GH_TOKEN}" \\
                            -H "Content-Type: application/json" \\
                            -d '{
                                "tag_name": "${tagName}",
                                "target_commitish": "main",
                                "name": "${releaseName}",
                                "body": "Automated release from Jenkins",
                                "draft": false,
                                "prerelease": false
                            }')
                        
                        if [ "\$release_response" -ne 201 ]; then
                            echo "Failed to create GitHub release. Status code: \$release_response"
                            cat release.json
                            exit 1
                        fi
                        
                        upload_url=\$(cat release.json | python3 -c "import sys, json; print(json.load(sys.stdin)['upload_url'].split('{')[0])")
                        
                        echo "Uploading artifact ${artifactPath}..."
                        upload_response=\$(curl -s -w "%{http_code}" -o upload_result.json -X POST "\${upload_url}?name=\$(basename ${artifactPath})" \\
                            -H "Authorization: token ${GH_TOKEN}" \\
                            -H "Content-Type: application/zip" \\
                            --data-binary @${artifactPath})
                        
                        if [ "\$upload_response" -ne 201 ]; then
                            echo "Artifact upload failed with code \$upload_response"
                            cat upload_result.json
                            exit 1
                        fi
                        
                        echo "Artifact uploaded successfully."
                        """
                    }
                }
            }
        }
        stage('DEVDeploy') {
            steps {
                withCredentials([string(credentialsId: 'GITHUB_TOKEN', variable: 'GH_TOKEN')]) {
                    script {
                        def userInput = input(
                            id: 'DeployApproval', message: 'Deploy to DEV?', ok: 'Approve',
                            parameters: [
                                string(name: 'Deployer', defaultValue: '', description: 'Enter your name'),
                                choice(name: 'Environment', choices: ['DEV', 'QA', 'PROD'], description: 'Choose environment')
                            ]
                        )
                        echo "Approved by: ${userInput['Deployer']} for environment: ${userInput['Environment']}"
        
                        def repo = "SugumarSrinivasan/Python"
                        def artifactName = "app.zip"
        
                        sh """#!/bin/bash
                        set -e
                        echo "Fetching latest release info from GitHub..."
                        curl -s -H "Authorization: token ${GH_TOKEN}" \\
                             https://api.github.com/repos/${repo}/releases/latest > latest_release.json
        
                        asset_url=\$(python3 -c "import sys, json; data=json.load(open('latest_release.json')); assets=data.get('assets', []); urls=[a['browser_download_url'] for a in assets if a['name'] == '${artifactName}']; print(urls[0] if urls else sys.exit('ERROR: Artifact ${artifactName} not found in latest release.'))")
        
                        echo "Downloading artifact from: \$asset_url"
                        curl -L -H "Authorization: token ${GH_TOKEN}" -o ${artifactName} "\$asset_url"
        
                        echo "Unzipping artifact..."
                        rm -rf deployed_app && mkdir deployed_app
                        unzip -o ${artifactName} -d deployed_app
        
                        echo "Running application..."
                        cd deployed_app
                        
                        # Set up and activate virtual environment
                        python3 -m venv venv
                        source venv/bin/activate
                        
                        # Install dependencies
                        pip install -r requirements.txt

                        # Run the application
                        python app/main.py
                        """
                    }
                }
            }
        }
    }
    post {
        always {
            archiveArtifacts artifacts: 'project/htmlcov/**', fingerprint: true
            archiveArtifacts artifacts: 'project/pylint-report.html', fingerprint: true
            dir('project') {
                publishHTML([
                    reportDir: 'htmlcov',
                    reportFiles: 'index.html',
                    reportName: 'Code Coverage Report',
                    keepAll: true,
                    allowMissing: false
                ])
                publishHTML([
                    reportDir: '.',
                    reportFiles: 'pylint-report.html',
                    reportName: 'Pylint Report',
                    keepAll: true,
                    allowMissing: false
                ])                
            cleanWs()
            } 
        }      
        success {
            echo 'Build succeeded!'
        }
        failure {
            echo 'Build failed!'
        }   
    }
}
