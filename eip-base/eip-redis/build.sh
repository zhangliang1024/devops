#!/usr/bin/env bash

docker run -p 6379:6379 --name redis \
-v /toony/redis/data:/data \
-v /toony/redis/conf/redis.conf:/etc/redis/redis.conf \
-d redis redis-server /etc/redis/redis.conf