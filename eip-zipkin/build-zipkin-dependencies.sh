#!/bin/bash

docker stop zipkin-dependencies && docker rm zipkin-dependencies

docker run -d \
    --name zipkin-dependencies \
    --restart=always \
    -e STORAGE_TYPE=elasticsearch \
    -e ES_HOSTS=192.168.1.193:9200 \
    -e ES_INDEX=zipkin \
    -e ES_INDEX_REPLICAS=1 \
    -e ES_INDEX_SHARDS=3 \
    openzipkin/zipkin-dependencies:2.4.0

docker logs -f zipkin-dependencies
