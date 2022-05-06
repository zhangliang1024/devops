#!/bin/bash

docker stop rmqconsole && docker rm rmqconsole

docker run -d \
      --name rmqconsole \
      -p 8180:8080 \
      --link rmqnamesrv:namesrv \
      -e "JAVA_OPTS=-Drocketmq.namesrv.addr=namesrv:9876 -Dcom.rocketmq.sendMessageWithVIPChannel=false" \
      -t styletang/rocketmq-console-ng
