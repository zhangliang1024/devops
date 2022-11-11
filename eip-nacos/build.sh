#!/bin/bash

docker stop nacos && docker rm nacos

docker run -d \
    --name nacos \
    -p 8848:8848 \
    -e MODE=standalone \
    -e SPRING_DATASOURCE_PLATFORM=mysql \
    -e MYSQL_SERVICE_HOST=192.168.1.193 \
    -e MYSQL_SERVICE_PORT=3306 \
    -e MYSQL_SERVICE_DB_NAME=nacos \
    -e MYSQL_SERVICE_USER=root \
    -e MYSQL_SERVICE_PASSWORD=123456 \
    nacos/nacos-server:latest

docker logs -f nacos


