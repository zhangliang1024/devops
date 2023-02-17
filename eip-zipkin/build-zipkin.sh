#!/bin/bash

docker stop zipkin && docker rm zipkin

docker run -d \
    --name zipkin \
    --restart=always \
    -c 128 \
    -m 400M --memory-reservation 100M \
    -p 9411:9411 \
    -v /etc/localtime:/etc/localtime \
    -e STORAGE_TYPE=elasticsearch \
    -e ES_HOSTS=192.168.1.193:9200 \
    -e ES_INDEX=zipkin \
    -e ES_INDEX_REPLICAS=1 \
    -e ES_INDEX_SHARDS=3 \
    openzipkin/zipkin:2.24.0

docker logs -f zipkin