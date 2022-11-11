#!/bin/bash

docker stop nexus3 && docker rm nexus3

docker run -d --name nexus3 \
        --privileged=true \
        --restart always \
        -p 8081:8081 \
        -v /usr/local/nexus3/nexus-data:/var/nexus-data \
        sonatype/nexus3