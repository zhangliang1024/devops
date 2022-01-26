#!/bin/bash

docker stop seata-server;
docker container rm seata-server;

docker run --name seata-server -it -d -p 8091:8091 \
-e SEATA_CONFIG_NAME=file:/root/seata/config/registry \
-e SEATA_IP=10.0.17.92 \
-v /opt/seata/config:/root/seata/config \
-v /opt/seata/config/libs/mysql-connector-java-8.0.21.jar:/root/seata/confg/libs/mysql-connector-java-8.0.21.jar \
--net=bridge --restart=always docker.io/seataio/seata-server:1.3.0

