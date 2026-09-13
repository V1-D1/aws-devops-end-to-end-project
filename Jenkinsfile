pipeline {
    agent any

    tools {
        jdk 'jdk21'
        nodejs 'node20'
    }

    environment {
        SCANNER_HOME = tool 'sonar-scanner'
        DOCKER_IMAGE = 'vdhilpe007/swiggy:latest'
    }

    stages {

        stage('Clean Workspace') {
            steps {
                cleanWs()
            }
        }

        stage('Checkout from Git') {
            steps {
                git branch: 'master',
                    url: 'https://github.com/smita1988/project-swiggy.git'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonar-server') {
                    sh '''
                        $SCANNER_HOME/bin/sonar-scanner \
                          -Dsonar.projectKey=Swiggy \
                          -Dsonar.projectName=Swiggy \
                          -Dsonar.sources=.
                    '''
                }
            }
        }

        stage('Quality Gate') {
            steps {
                script {
                    timeout(time: 2, unit: 'MINUTES') {
                        waitForQualityGate abortPipeline: true
                    }
                }
            }
        }

        stage('Install Dependencies') {
            steps {
                sh 'npm install'
            }
        }

        stage('Trivy Filesystem Scan') {
            steps {
                sh 'trivy fs . --exit-code 0 --severity HIGH,CRITICAL -f table -o trivy-fs-report.txt'

                archiveArtifacts artifacts: 'trivy-fs-report.txt',
                    allowEmptyArchive: true
            }
        }

        stage('Docker Build & Push') {
            steps {
                script {
                    withDockerRegistry(
                        credentialsId: 'docker-creds',
                        toolName: 'docker'
                    ) {
                        sh '''
                            docker build -t swiggy .
                            docker tag swiggy $DOCKER_IMAGE
                            docker push $DOCKER_IMAGE
                        '''
                    }
                }
            }
        }

        stage('Trivy Image Scan') {
            steps {
                sh 'trivy image $DOCKER_IMAGE --exit-code 0 --severity HIGH,CRITICAL -f table -o trivy-image-report.txt'

                archiveArtifacts artifacts: 'trivy-image-report.txt',
                    allowEmptyArchive: true
            }
        }

        stage('Deploy to App EC2') {
            steps {
                withCredentials([
                    sshUserPrivateKey(
                        credentialsId: 'app-ssh',
                        keyFileVariable: 'SSH_KEY',
                        usernameVariable: 'SSH_USER'
                    )
                ]) {
                    sh '''
                        ssh -o StrictHostKeyChecking=no \
                            -i "$SSH_KEY" \
                            "$SSH_USER"@10.0.1.181 \
                            "docker pull $DOCKER_IMAGE && \
                             docker rm -f swiggy || true; \
                             docker run -d --name swiggy -p 3000:3000 $DOCKER_IMAGE"
                    '''
                }
            }
        }
    }

    post {
        always {
            echo 'Pipeline execution completed!'
        }

        failure {
            echo 'Pipeline failed. Check logs for details.'
        }

        success {
            echo 'Swiggy application deployed successfully!'
        }
    }
}