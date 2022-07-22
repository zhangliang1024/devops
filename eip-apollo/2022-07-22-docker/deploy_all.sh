#!/bin/bash

version=$1

if [ -n "$1" ] ;then
    echo "第一个参数为docker镜像版本，当前值是：$1"
else
    echo "请输入一个docker镜像版本参数，例如: sh delopy_all.sh 1.7.0"
    exit 1;
fi


docker pull apolloconfig/apollo-configservice:${version}
docker pull apolloconfig/apollo-adminservice:${version}
docker pull apolloconfig/apollo-portal:${version}

docker stop apollo-configservice && docker rm apollo-configservice
docker stop apollo-adminservice && docker rm apollo-adminservice
docker stop apollo-portal && docker rm apollo-portal

echo "start apollo-configservice"
docker run -d --restart always \
     --name apollo-configservice \
     -p 8080:8080 \
     -e SPRING_DATASOURCE_URL="jdbc:mysql://172.16.2.72:3306/apolloconfigdb9085?characterEncoding=utf8" \
     -e SPRING_DATASOURCE_USERNAME=root \
     -e SPRING_DATASOURCE_PASSWORD=8KXw^!4moO5k \
     -e EUREKA.INSTANCE.IP-ADDRESS=172.16.2.137 \
     -v /opt/logs/:/opt/logs \
     apolloconfig/apollo-configservice:${version}


echo "start apollo-adminservice"
docker run -d --restart always \
     --name apollo-adminservice \
     -p 8090:8090 \
     -e SPRING_DATASOURCE_URL="jdbc:mysql://172.16.2.72:3306/apolloconfigdb9085?characterEncoding=utf8" \
     -e SPRING_DATASOURCE_USERNAME=root \
     -e SPRING_DATASOURCE_PASSWORD=8KXw^!4moO5k \
     -e EUREKA.INSTANCE.IP-ADDRESS=172.16.2.137 \
     -v /opt/logs:/opt/logs  \
     apolloconfig/apollo-adminservice:${version}


echo "start apollo-portal"
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