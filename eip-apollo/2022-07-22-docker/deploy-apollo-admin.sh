#!/bin/bash

version=$1

if [ -n "$1" ] ;then
    echo "第一个参数为docker镜像版本，当前值是：$1"
else
    echo "请输入一个docker镜像版本参数，例如: sh deploy-apollo-admin.sh 1.7.0"
    exit 1;
fi

docker pull apolloconfig/apollo-adminservice:${version}

docker stop apollo-adminservice && docker rm apollo-adminservice

docker run -d --restart always \
     --name apollo-adminservice \
     -p 8090:8090 \
     -e SPRING_DATASOURCE_URL="jdbc:mysql://172.16.2.72:3306/apolloconfigdb9085?characterEncoding=utf8" \
     -e SPRING_DATASOURCE_USERNAME=root \
     -e SPRING_DATASOURCE_PASSWORD=8KXw^!4moO5k \
     -e EUREKA.INSTANCE.IP-ADDRESS=172.16.2.137 \
     -v /opt/logs:/opt/logs  \
     apolloconfig/apollo-adminservice:${version}

docker logs -f apollo-adminservice

