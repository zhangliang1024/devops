#!/bin/bash

docker stop elasticsearch && docker rm elasticsearch

docker run -d \
    --name='elasticsearch' \
    --restart=always \
    -p 9200:9200 \
    -p 9300:9300 \
    --cpus 3 \
    -m 40968m --memory-reservation 1024M \
    -e ES_JAVA_OPTS="-Xms4096m -Xmx4096m" \
    -e "discovery.type=single-node" \
    -v ${PWD}/data:/usr/share/elasticsearch/data \
    -v ${PWD}/plugins:/usr/share/elasticsearch/plugins \
    -v ${PWD}/config/elasticsearch.yml:/usr/share/elasticsearch/config/elasticsearch.yml \
    -v ${PWD}/logs:/usr/share/elasticsearch/logs \
    elasticsearch:7.6.2

docker logs -f elasticsearch
