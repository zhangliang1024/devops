#!/bin/bash

docker stop logstash && docker rm logstash

docker run -d \
    --name logstash \
    --restart=always \
    --cpus 3 \
    -m 2048m --memory-reservation 1024M \
    -p 5044:5044 \
    -v ${PWD}/conf/logstash.conf:/usr/share/logstash/pipeline/logstash.conf \
    logstash:7.6.2

docker logs -f logstash