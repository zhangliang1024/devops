#!/bin/bash

docker stop kfk-manager && docker rm kfk-manager

docker run -d \
    --name kfk-manager \
    -p 9000:9000 \
    -e ZK_HOSTS=192.168.1.193:2181 \
    -e APPLICATION_SECRET=letmein \
    sheepkiller/kafka-manager:latest
