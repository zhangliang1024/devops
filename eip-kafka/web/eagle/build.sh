#!/bin/bash

docker build -t efak:1.0.0 .

docker stop efak && docker rm efak

docker run -d \
     --name efak\
     -p 8048:8048 \
     -v ${PWD}/system-config.properties:/opt/kafka-eagle/conf/system-config.properties \
     efak:1.0.0

docker logs -f efak
