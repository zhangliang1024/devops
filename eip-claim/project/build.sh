#!/bin/bash
# @date: 2020-09-22
# @author: ms
# Notes: Deploy Project
NAME=claim-auprocess

case "$1" in
    -h|--help|?)
    echo "Usage: 1st arg:docker version name"
    echo "1st arg e.g. : uat/test/1.0.1"
    exit 0
;;
esac

VERSION=$1
if [ -n "$1" ] ;then
    echo "第一个参数为docker镜像版本，当前值是：$1"
else
    echo "请输入一个docker镜像版本参数，例如: sh build.sh uat"
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

BUILD_IMAGE_AND_PUSH()
{
    # 删掉docker容器进程
    KILL_CONTAINER_PID

        # 删除docker镜像进程
    KILL_IMAGE_PID

        #pull the image and start container
        docker build -t $NAME:$VERSION .

        #docker tag $NAME:$VERSION 10.0.17.92:80/hn/$NAME:$VERSION

        #docker push 10.0.17.92:80/hn/$NAME:$VERSION

        #docker rmi 10.0.17.92:80/hn/$NAME:$VERSION
}

BUILD_IMAGE_AND_PUSH