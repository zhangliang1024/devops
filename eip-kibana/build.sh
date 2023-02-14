#!/bin/bash

docker stop kibana && docker rm kibana

docker run -d \
    --name kibana \
    --restart=always \
    --cpus 3 \
    -m 2048m --memory-reservation 1024M \
    -p 5601:5601 \
    -v ${PWD}/config/kibana.yml:/usr/share/kibana/config/kibana.yml \
    kibana:7.6.2

docker logs -f kibana