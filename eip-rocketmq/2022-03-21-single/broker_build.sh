#!/bin/bash

docker stop rmqbroker && docker rm rmqbroker

docker run -d \
      --name rmqbroker \
      -p 10911:10911 -p 10912:10912 -p 10909:10909 \
      -v $(pwd)/conf/broker.conf:/home/rocketmq/rocketmq-4.8.0/conf/broker.conf \
      --link rmqnamesrv:namesrv \
      -v $(pwd)/logs:/home/rocketmq/logs \
      -v $(pwd)/store:/home/rocketmq/store \
      -e "NAMESRV_ADDR=namesrv:9876" \
      -e "JAVA_OPT_EXT=-Xms512M -Xmx512M -Xmn128m" \
      foxiswho/rocketmq:4.8.0 \
      sh mqbroker -c /home/rocketmq/rocketmq-4.8.0/conf/broker.conf
