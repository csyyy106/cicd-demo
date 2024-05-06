pipeline {
    agent any
    environment {
        DOCKERHUB_USERNAME = 'siyuan06'
        IMG_NAME = 'cicd-demo'
        // 注意：这里我们使用 Groovy 的方式来生成时间戳   // 定义常量，这些可以在整个 pipeline 中使用
        IMG_TAG = "${new Date().format('yyyyMMdd_HHmm')}"
        IMG_FULL_NAME = "${IMG_NAME}:${IMG_TAG}"
        
        PROJECT_NAME = "cicd-demo"
        UPLOAD_DIR = "/rj/k8s/apps/${env.PROJECT_NAME}"
        FILE_NAME = "${env.UPLOAD_DIR}/deploy.yaml"
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
                // sh "sed -i 's#{{IMAGE_NAME}}#${DOCKERHUB_USERNAME}/${IMG_NAME}:${IMG_TAG}#g' ${env.FILE_NAME}"
            }
        }
        stage('Deploy k8s') {
            steps {
                script {
                    // 使用 withCredentials 绑定凭证
                    // withCredentials([file(credentialsId: '198dae6b-862b-4040-af38-0e0fb2715873', variable: 'KUBECONFIG')]) {
                    // withCredentials([certificate(credentialsId: '198dae6b-862b-4040-af38-0e0fb2715873', keystoreVariable: 'KEYSTORE_PATH', passwordVariable: 'KEYSTORE_PASSWORD')]) {
                    withKubeConfig([credentialsId: "198dae6b-862b-4040-af38-0e0fb2715873",serverUrl: "https://172.31.7.19:6443"]) {
                        sh "kubectl get nodes"
                        echo "csy_in"
                                                                                                             // 使用证书进行操作，如设置环境变量等
                        // 确保部署文件目录存在
                        sh "mkdir -p ${env.UPLOAD_DIR}"
                        // 假设 deploy.yaml 已经在正确的位置或是在前一个步骤中被创建或复制到这个位置
                        // 执行部署命令
                        sh 'echo $KEYSTORE_PATH'
                        sh "kubectl --kubeconfig=${env.KUBECONFIG} apply -f ${env.FILE_NAME}"
                    }
                }
            }
        }
    }
    // post {
    //     success {
    //         // 成功清理工作空间，失败保留现场
    //         cleanWs()
    //     }
    // }
}
