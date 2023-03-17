#!/bin/bash

docker stop logstash && docker rm logstash

docker run --name logstash \
        --restart=always \
        -m 1024m --memory-reservation 200M \
        --cpus 1 \
        -p 5044:5044 \
        -e ES_JAVA_OPTS="-Xms512m -Xmx1024m" \
        -v $PWD/config/logstash.yml:/usr/share/logstash/config/logstash.yml \
        -v $PWD/config/logstash.conf:/usr/share/logstash/pipeline/logstash.conf \
        -d elastic/logstash:7.14.0

docker logs -f logstash