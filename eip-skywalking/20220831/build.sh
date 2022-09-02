#!/bin/bash

docker stop oap && docker rm oap

docker run --name oap \
        --restart=always -d \
        -e TZ=Asia/Shanghai \
        -p 12800:12800 \
        -p 11800:11800 \
        --link elasticsearch:elasticsearch \
        -e SW_STORAGE=elasticsearch7 \
        -e SW_STORAGE_ES_CLUSTER_NODES=elasticsearch:9200 \
        apache/skywalking-oap-server:8.7.0-es7

docker stop skywalking-ui && docker rm skywalking-ui

docker run --name skywalking-ui \
        --restart always -d \
        -e TZ=Asia/Shanghai \
        -p 8090:8080 \
        --link oap:oap \
        -e SW_OAP_ADDRESS=http://oap:12800 \
        apache/skywalking-ui:8.7.0