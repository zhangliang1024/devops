#!/bin/bash

docker stop redis && docker rm redis

docker run -d \
    --name redis \
    --restart=always \
    -p 6379:6379 \
    -v ${PWD}/redis.conf:/etc/redis/redis.conf \
    -v ${PWD}/data:/data \
    redis:latest \
    redis-server /etc/redis/redis.conf \
    --requirepass "123456"

docker logs -f redis

sudo docker run -p 6379:6379
--name redis
-v /data/redis/data/redis.conf:/etc/redis/redis.conf  \
-v /data/redis/data:/data \
-d redis redis-server /etc/redis/redis.conf \
--appendonly yes
