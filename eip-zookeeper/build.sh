#!/bin/bash

docker stop myzk && docker rm myzk

docker run --name myzk \
        --restart always \
        -p 2181:2181 \
        -v /etc/timezone:/etc/timezone \
        -e JVMFLAGS="-Xmx1024m" \
        zookeeper:3.7.0