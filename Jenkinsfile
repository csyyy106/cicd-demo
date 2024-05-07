pipeline {
    agent any
    environment {
        DOCKERHUB_USERNAME = 'siyuan06'
        IMG_NAME = 'cicd-demo'
        // 注意：这里我们使用 Groovy 的方式来生成时间戳
        IMG_TAG = "${new Date().format('yyyyMMdd_HHmm')}"
        IMG_FULL_NAME = "${DOCKERHUB_USERNAME}/${IMG_NAME}:v${BUILD_NUMBER}.${IMG_TAG}"    //上传和拉取的镜像名
        
        // PROJECT_NAME = "cicd-demo"
        // UPLOAD_DIR = "/rj/k8s/apps/${env.PROJECT_NAME}"
        // FILE_NAME = "${env.UPLOAD_DIR}/deploy.yaml"
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
                        sh "kubectl get nodes"
                        echo "Image name to be used: ${IMG_FULL_NAME}"
                        // echo "${FILE_NAME}"
                        echo '----------'
                        echo "${env.WORKSPACE}"
                        // echo "cat ${FILE_NAME}"
                        sh "cat ${env.WORKSPACE}/deploy.yaml"
                        // 确保部署文件目录存在
                        // sh "mkdir -p ${env.UPLOAD_DIR}"
                        // 假设 deploy.yaml 已经在正确的位置或是在前一个步骤中被创建或复制到这个位置
                        // 执行部署命令
                        // sh "kubectl --kubeconfig=${env.KUBECONFIG} apply -f ${env.WORKSPACE}/deploy.yaml"
                    }
                }
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
