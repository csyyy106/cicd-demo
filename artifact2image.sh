#!/bin/bash
# -- 构建镜像并推送私有仓库 --
set -eu #如有报错或取不到变量情况停止执行

#声名常量
# IMG_REGISTRY="http://54.176.12.3:31676/" #镜像仓库
DOCKERHUB_USERNAME="siyuan06"
IMG_NAME="cicd-demo"
IMG_TAG=`date "+%Y%M%d_%H%M"`      #镜像标签，如 20201223_1351
# IMG_FULL_NAME="${IMG_REGISTRY}/${IMG_NAME}:${IMG_TAG}" #镜像上传与拉取的名称
IMG_FULL_NAME="${IMG_NAME}:${IMG_TAG}" #镜像上传与拉取的名称

#  使用 Jenkins 凭证
withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', usernameVariable: 'DOCKERHUB_USERNAME', passwordVariable: 'DOCKERHUB_PASSWORD')]) {
# 登录到 Docker Hub
docker login -u $DOCKERHUB_USERNAME -p $DOCKERHUB_PASSWORD
#  构建和推送镜像
docker build -t ${IMG_FULL_NAME} .
docker push ${DOCKERHUB_USERNAME}/my-image:my-tag
#删除本地镜像
docker rmi ${IMG_FULL_NAME}
# 登出 Docker Hub
sh "docker logout"



# #构建镜像
# docker build -t ${IMG_FULL_NAME} .

# #推送镜像
# docker push ${IMG_FULL_NAME}

# #删除本地镜像
# docker rmi ${IMG_FULL_NAME}

# #修改deploy.yaml的镜像标签
sed -i "s#{{IMAGE_NAME}}#${IMG_FULL_NAME}#g" deploy.yaml
