pipeline {
    agent any
    environment {
        DOCKERHUB_USERNAME = 'siyuan06'
        IMG_NAME = 'cicd-demo'
        // 注意：这里我们使用 Groovy 的方式来生成时间戳
        IMG_TAG = "${new Date().format('yyyyMMdd_HHmm')}"
        IMG_FULL_NAME = "${DOCKERHUB_USERNAME}/${IMG_NAME}:v${BUILD_NUMBER}.${IMG_TAG}"    //上传和拉取的镜像名
    }
    stages {
        stage('Checkout SCM') {
            steps {
                // 拉取 GitHub 仓库代码
                checkout scm
            }
        }
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
                        sh "docker build -t ${IMG_FULL_NAME} . "
                        // 推送镜像
                        sh "docker push ${IMG_FULL_NAME}"
                        // 删除本地镜像
                        sh "docker rmi ${IMG_FULL_NAME}"
                        // 登出 Docker Hub
                        sh "docker logout"
                    }
                }
            }
        }
        stage('Modify Deployment') {
            steps {
                // 修改 deploy.yaml 的镜像标签
                sh 'sed -i "s#{{IMAGE_NAME}}#${IMG_FULL_NAME}#g" deploy.yaml'
                sh 'echo $?'
            }
        }
        stage('Deploy k8s') {
            steps {
                script {
                    withKubeConfig([credentialsId: "198dae6b-862b-4040-af38-0e0fb2715873",serverUrl: "https://172.31.7.19:6443"]) {
                        // set -x
                        echo "Image name  is : ${IMG_FULL_NAME}"
                        echo "${env.WORKSPACE}"  //当前jenkins job工作区目录
                        // echo "${FILE_NAME}"
                        echo '----------'
                        // 确认部署文件
                        sh "cat ${env.WORKSPACE}/deploy.yaml"
                        // 执行部署命令
                        sh "kubectl --kubeconfig=${env.KUBECONFIG} apply -f ${env.WORKSPACE}/deploy.yaml"
                    }
                }
            }
        }
    }
    post {
        success {
            // 如果流水线成功，执行以下步骤
            cleanWs() // 清理工作空间的 Jenkins 步骤
        }
        failure {
            echo "oh no"
            // 如果流水线失败，执行以下步骤
            // 通常这里会保留工作空间进行调试，或者发送通知等
        }
    }
}
