#!/bin/bash

docker stop seata-server;
docker container rm seata-server;

docker run --name seata-server -d -p 8091:8091 -v /opt/seata/config/file.conf:/seata-server/resources/file.conf -v /opt/seata/config/registry.conf:/seata-server/resources/registry.conf -v /opt/seata/config/logs:/root/logs seataio/seata-server
