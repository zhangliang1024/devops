#!/bin/bash

docker stop seata-server;
docker container rm seata-server;

docker run --name seata-server -it -d -p 8091:8091 \
-e SEATA_CONFIG_NAME=file:/root/seata/config/registry \
-e SEATA_IP=124.70.91.124 \
-e SEATA_PORT=8091 \
-e SERVER_NODE=2 \
-e TZ="Asia/Shanghai" \
-v /opt/logs/seata/8091:/root/logs/seata \
-v /opt/seata/config:/root/seata/config \
-v /opt/seata/config/libs/mysql-connector-java-8.0.21.jar:/root/seata/confg/libs/mysql-connector-java-8.0.21.jar \
--net=bridge --restart=always docker.io/seataio/seata-server:1.3.0