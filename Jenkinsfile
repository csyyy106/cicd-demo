pipeline {
    agent any
    environment {
        DOCKERHUB_USERNAME = 'siyuan06'
        IMG_NAME = 'cicd-demo'
        // 注意：这里我们使用 Groovy 的方式来生成时间戳
        IMG_TAG = "${new Date().format('yyyyMMdd_HHmm')}"
        IMG_FULL_NAME = "${IMG_NAME}:${IMG_TAG}"
    }
    stages {
        stage('Build Artifact') {
            steps {
                sh label: 'maven building', script: '/usr/local/apache-maven-3.9.6/bin/mvn clean package -DskipTests'
            }
        }
        stage('Build and Push Image') {
            steps {
                script {
                    // 使用 Jenkins 凭证
                    withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', usernameVariable: 'DOCKERHUB_USERNAME', passwordVariable: 'DOCKERHUB_PASSWORD')]) {
                        // 登录到 Docker Hub
                        sh "docker login -u $DOCKERHUB_USERNAME -p $DOCKERHUB_PASSWORD"
                        // 构建镜像
                        sh "docker build -t ${DOCKERHUB_USERNAME}/${IMG_NAME}:${IMG_TAG} ."
                        // 推送镜像
                        sh "docker push ${DOCKERHUB_USERNAME}/${IMG_NAME}:${IMG_TAG}"
                        // 删除本地镜像
                        sh "docker rmi ${DOCKERHUB_USERNAME}/${IMG_NAME}:${IMG_TAG}"
                        // 登出 Docker Hub
                        sh "docker logout"
                    }
                }
            }
        }
        stage('Modify Deployment') {
            steps {
                // 修改 deploy.yaml 的镜像标签
                sh "sed -i 's#{{IMAGE_NAME}}#${DOCKERHUB_USERNAME}/${IMG_NAME}:${IMG_TAG}#g' deploy.yaml"
            }
        }
        stage('Deploy k8s') {
            steps {
                sh label: 'deploy image to k8s', script: '/bin/bash deploy2k8s.sh'
            }
        }
    }
    post {
        success {
            // 成功清理工作空间，失败保留现场
            cleanWs()
        }
    }
}
