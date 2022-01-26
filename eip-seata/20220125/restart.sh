#!/bin/bash

docker run --name seata-server -d \
-e SEATA_IP=139.198.16.11 \
-e SEATA_PORT=8091 \
-v ${PWD}/conf/registry.conf:/seata-server/resources/registry.conf \
-v ${PWD}/logs:/root/logs \
--privileged=true \
-p 8091:8091 \
 seataio/seata-server:1.4.2