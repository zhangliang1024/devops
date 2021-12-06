#!/bin/bash

redis_dir=/home/redis/

if [ ! -d redis_dir ];then
   echo "redis work file is not exit"
   mkdir -p $redis_dir/{data}
fi

docker stop redis && docker rm redis

docker run -d \
    --name redis \
    --restart=always \
    #--network own_network\
    -p 6379:6379 \
    -v /home/redis/redis.conf:/etc/redis/redis.conf \
    -v /home/redis/data:/data \
    redis redis-server /etc/redis/redis.conf \
    --requirepass "123456"

