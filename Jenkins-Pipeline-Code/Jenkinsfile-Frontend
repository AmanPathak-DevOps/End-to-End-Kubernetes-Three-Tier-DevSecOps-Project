pipeline {
    agent any 
    tools {
        jdk 'jdk'
        nodejs 'nodejs'
    }
    environment  {
        SCANNER_HOME=tool 'sonar-scanner'
        AWS_ACCOUNT_ID = credentials('ACCOUNT_ID')
        AWS_ECR_REPO_NAME = credentials('ECR_REPO1')
        AWS_DEFAULT_REGION = 'us-east-1'
        REPOSITORY_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/"
    }
    stages {
        stage('Cleaning Workspace') {
            steps {
                cleanWs()
            }
        }
        stage('Checkout from Git') {
            steps {
                git credentialsId: 'GITHUB', url: 'https://github.com/AmanPathak-DevOps/End-to-End-Kubernetes-Three-Tier-DevSecOps-Project.git'
            }
        }
        stage('Sonarqube Analysis') {
            steps {
                dir('Application-Code/frontend') {
                    withSonarQubeEnv('sonar-server') {
                        sh ''' $SCANNER_HOME/bin/sonar-scanner \
                        -Dsonar.projectName=three-tier-frontend \
                        -Dsonar.projectKey=three-tier-frontend '''
                    }
                }
            }
        }
        stage('Quality Check') {
            steps {
                script {
                    waitForQualityGate abortPipeline: false, credentialsId: 'sonar-token' 
                }
            }
        }
        stage('OWASP Dependency-Check Scan') {
            steps {
                dir('Application-Code/frontend') {
                    dependencyCheck additionalArguments: '--scan ./ --disableYarnAudit --disableNodeAudit', odcInstallation: 'DP-Check'
                    dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
                }
            }
        }
        stage('Trivy File Scan') {
            steps {
                dir('Application-Code/frontend') {
                    sh 'trivy fs . > trivyfs.txt'
                }
            }
        }
        stage("Docker Image Build") {
            steps {
                script {
                    dir('Application-Code/frontend') {
                            sh 'docker system prune -f'
                            sh 'docker container prune -f'
                            sh 'docker build -t ${AWS_ECR_REPO_NAME} .'
                    }
                }
            }
        }
        stage("ECR Image Pushing") {
            steps {
                script {
                        sh 'aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${REPOSITORY_URI}'
                        sh 'docker tag ${AWS_ECR_REPO_NAME} ${REPOSITORY_URI}${AWS_ECR_REPO_NAME}:${BUILD_NUMBER}'
                        sh 'docker push ${REPOSITORY_URI}${AWS_ECR_REPO_NAME}:${BUILD_NUMBER}'
                }
            }
        }
        stage("TRIVY Image Scan") {
            steps {
                sh 'trivy image ${REPOSITORY_URI}${AWS_ECR_REPO_NAME}:${BUILD_NUMBER} > trivyimage.txt' 
            }
        }
        stage('Checkout Code') {
            steps {
                git credentialsId: 'GITHUB', url: 'https://github.com/AmanPathak-DevOps/End-to-End-Kubernetes-Three-Tier-DevSecOps-Project.git'
            }
        }
        stage('Update Deployment file') {
            environment {
                GIT_REPO_NAME = "End-to-End-Kubernetes-Three-Tier-DevSecOps-Project"
                GIT_USER_NAME = "AmanPathak-DevOps"
            }
            steps {
                dir('Kubernetes-Manifests-file/Frontend') {
                    withCredentials([string(credentialsId: 'github', variable: 'GITHUB_TOKEN')]) {
                        sh '''
                            git config user.email "aman07pathak@gmail.com"
                            git config user.name "AmanPathak-DevOps"
                            BUILD_NUMBER=${BUILD_NUMBER}
                            echo $BUILD_NUMBER
                            imageTag=$(grep -oP '(?<=frontend:)[^ ]+' deployment.yaml)
                            echo $imageTag
                            sed -i "s/${AWS_ECR_REPO_NAME}:${imageTag}/${AWS_ECR_REPO_NAME}:${BUILD_NUMBER}/" deployment.yaml
                            git add deployment.yaml
                            git commit -m "Update deployment Image to version \${BUILD_NUMBER}"
                            git push https://${GITHUB_TOKEN}@github.com/${GIT_USER_NAME}/${GIT_REPO_NAME} HEAD:master
                        '''
                    }
                }
            }
        }
    }
}