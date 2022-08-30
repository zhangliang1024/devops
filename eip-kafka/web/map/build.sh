#!/bin/bash

docker stop kafka-map && docker rm kafka-map

docker run -d \
    --name kafka-map \
    --restart always \
    -p 8081:8080 \
    -v ${PWD}/data:/usr/local/kafka-map/data \
    -e DEFAULT_USERNAME=admin \
    -e DEFAULT_PASSWORD=admin \
    dushixiang/kafka-map:latest

docker logs -f kafka-map