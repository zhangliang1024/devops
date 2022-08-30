#!/bin/bash

docker stop kafka-console-ui && docker rm kafka-console-ui

docker run -d \
    --name kafka-console-ui \
    --restart always \
    -p 7766:7766 \
    -v ${PWD}/data:/app/data \
    -v ${PWD}/log:/app/log \
    wdkang/kafka-console-ui

docker logs -f kafka-console-ui