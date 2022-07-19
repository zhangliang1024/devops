#!/bin/bash

docker stop rmqnamesrv && docker rm rmqnamesrv

docker run -d \
      --name rmqnamesrv \
      --restart always\
      -p 9876:9876 \
      -v $(pwd)/logs:/home/rocketmq/logs \
      -e "JAVA_OPT_EXT=-Xms512M -Xmx512M -Xmn128m" \
      foxiswho/rocketmq:4.8.0 \
      sh mqnamesrv
