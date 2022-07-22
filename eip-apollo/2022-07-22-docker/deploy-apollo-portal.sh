#!/bin/bash

version=$1

if [ -n "$1" ] ;then
    echo "第一个参数为docker镜像版本，当前值是：$1"
else
    echo "请输入一个docker镜像版本参数，例如: sh deploy-apollo-portal.sh 1.7.0"
    exit 1;
fi

docker pull apolloconfig/apollo-portal:${version}

docker stop apollo-portal && docker rm apollo-portal

docker run -d --restart always \
     --name apollo-portal \
     -p 8070:8070 \
     -e SPRING_DATASOURCE_URL="jdbc:mysql://172.16.2.72:3306/apolloportaldb?characterEncoding=utf8" \
     -e SPRING_DATASOURCE_USERNAME=root \
     -e SPRING_DATASOURCE_PASSWORD=8KXw^!4moO5k \
     -e APOLLO_PORTAL_ENVS=dev,pro \
     -e DEV_META=http://172.16.2.127:8080 \
     -e PRO_META=http://172.16.2.137:8080 \
     -v /opt/logs:/opt/logs  \
     apolloconfig/apollo-portal:${version}

docker logs -f apollo-portal
