#!/bin/bash

docker stop rabbitmq && docker rm rabbitmq

docker run -dit \
    --name rabbitmq \
    -p 15672:15672 \
    -p 5672:5672 \
    -e RABBITMQ_DEFAULT_USER=admin \
    -e RABBITMQ_DEFAULT_PASS=admin \
    rabbitmq:management

docker logs -f rabbitmq