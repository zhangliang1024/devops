#!/bin/bash

docker stop mysql && docker rm mysql

docker run -d \
    --name mysql \
    -p 3306:3306 \
    --restart always \
    -v ${PWD}/data:/var/lib/mysql \
    -v ${PWD}/conf:/etc/mysql/conf.d \
    -e MYSQL_ROOT_PASSWORD=123456 \
    --privileged=true \
    mysql:5.7

docker logs -f mysql
