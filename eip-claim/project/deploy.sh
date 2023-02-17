#!/bin/bash
# @date: 2020-09-22
# @author: ms
# Notes: Deploy Project
NAME=claim-auprocess

# 镜像中项目的端口
PROJECT_PORT="8107"
# 发布的容器端口
CONTAINER_PORT="8107"

HOST_IP=$(/sbin/ifconfig -a|grep inet|grep -v 172.*.0.1|grep -v inet6|awk '{print $2}'|tr -d "addr:" | awk 'NR==1{print $1}')

RESOURCES="-c 512 -m 1024M --memory-reservation 500M"
DATA_PATH="-v /jydata/log:/jydata/log"

VERSION=$1
ENV=$2
if [ -n "$1" ] ;then
    echo "第一个参数为docker镜像版本，当前值是：$1"
else
    echo "请输入一个docker镜像版本参数，例如: sh pull_and_run.sh uat uat"
    exit 1;
fi

if [ -n "$2" ] ;then
    echo "第二个参数为环境变量，当前值是：$2"
else
    echo "请输入二个环境变量参数，例如: sh pull_and_run.sh uat uat"
    exit 1;
fi

KILL_CONTAINER_PID() {
   doconps=$(docker ps -f name=$NAME -q)
   if [ x"$doconps" != x ]; then
        docker rm -f $doconps
   fi
   docker rm -f $NAME
}

KILL_IMAGE_PID() {
   doimageps=$(docker images |grep $NAME|awk '{print $3}')
   if [ x"$doimageps" != x ]; then
        docker rmi -f $doimageps
   fi
}

DEPLOY_PROJECT()
{
    # 删掉docker容器进程
    KILL_CONTAINER_PID

        # 删除docker镜像进程
    #KILL_IMAGE_PID

        #pull the image and start container
        #docker login 10.0.17.92:80 -u zhaoyang -p Harbor123
        #docker pull 10.0.17.92:80/hn/$NAME:$VERSION
        #docker tag 10.0.17.92:80/hn/$NAME:$VERSION $NAME:$VERSION
        #docker rmi 10.0.17.92:80/hn/$NAME:$VERSION
        docker run -e ACTIVE="-Dspring.profiles.active=$ENV -Deureka.instance.ipAddress=$HOST_IP -Deureka.instance.instance-id=$HOST_IP:$PROJECT_PORT  -Deureka.checkGrayVersion=false" $RESOURCES $DATA_PATH -d -p $CONTAINER_PORT:$PROJECT_PORT --name $NAME $NAME:$VERSION
}

DEPLOY_PROJECT