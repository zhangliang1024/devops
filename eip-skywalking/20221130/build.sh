#/bin/bash

# 基于kafka-fetcher来收集trace和metrics，基于zookeeper来保证高可用

docker stop oap && docker rm oap
docker run -d \
    --restart always \
    --name skywalking-oap \
    -p 11800:11800 \
    -p 12800:12800 \
    -e TZ=Asia/Shanghai \
    -e SW_STORAGE=elasticsearch \
    -e SW_STORAGE_ES_CLUSTER_NODES=140.246.154.99:9200 \
    -e SW_CLUSTER=zookeeper \
    -e SW_CLUSTER_ZK_HOST_PORT=140.246.154.99:2181 \
    -e SW_KAFKA_FETCHER=default \
    -e SW_KAFKA_FETCHER_SERVERS=140.246.154.99:9092 \
    -e SW_KAFKA_FETCHER_PARTITIONS_FACTOR=1 \
    apache/skywalking-oap-server:9.2.0


docker stop skywalking-ui && docker rm skywalking-ui
docker run -d \
    --name skywalking-ui \
    --restart always \
    -e TZ=Asia/Shanghai \
    -p 8090:8080 \
    --link oap:oap \
    -e SW_OAP_ADDRESS=http://oap:12800 \
    apache/skywalking-ui:9.2.0