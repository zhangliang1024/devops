#!/bin/bash

docker stop kfk-offset-monitor && docker rm kfk-offset-monitor

docker run -d \
    --name kfk-offset-monitor \
    -p 8081:8080 \
    -e ZK_HOSTS=192.168.1.193:2181 \
    -e KAFKA_BROKERS=192.168.1.193:9092 \
    -e REFRESH_SECENDS=10 \
    -e RETAIN_DAYS=2 \
    junxy/kafkaoffsetmonitor

docker logs -f kfk-offset-monitor