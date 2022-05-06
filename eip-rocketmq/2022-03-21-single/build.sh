#!/bin/bash

docker pull foxiswho/rocketmq:4.8.0

mkdir -p $(pwd)/logs
mkdir -p $(pwd)/store
chmod -R 777 /data

fire-cmd --zone=public --add-port=8180/tcp --permanent