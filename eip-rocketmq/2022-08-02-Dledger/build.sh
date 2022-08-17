#!/bin/bash
# 说明，4.8.0镜像版本，要求所有《映射本地目录logs权限一定要设置为 777 权限，否则启动不成功》

echo "${PWD}"

echo "pull images"
#docker pull foxiswho/rocketmq:4.8.0
#docker pull styletang/rocketmq-console-ng:latest

echo "mdkir files"

mkdir -p $(pwd)/rocketmq/dledger-n0/logs
mkdir -p $(pwd)/rocketmq/dledger-n0/store
mkdir -p $(pwd)/rocketmq/dledger-n0/store/commitlog
mkdir -p $(pwd)/rocketmq/dledger-n0/store/consumequeue

mkdir -p $(pwd)/rocketmq/dledger-n1/logs
mkdir -p $(pwd)/rocketmq/dledger-n1/store
mkdir -p $(pwd)/rocketmq/dledger-n1/store/commitlog
mkdir -p $(pwd)/rocketmq/dledger-n1/store/consumequeue

mkdir -p $(pwd)/rocketmq/dledger-n2/logs
mkdir -p $(pwd)/rocketmq/dledger-n2/store
mkdir -p $(pwd)/rocketmq/dledger-n2/store/commitlog
mkdir -p $(pwd)/rocketmq/dledger-n2/store/consumequeue

chmod 777 $(pwd)/rocketmq/*
chmod 777 $(pwd)/rocketmq/dledger-n0/*
chmod 777 $(pwd)/rocketmq/dledger-n1/*
chmod 777 $(pwd)/rocketmq/dledger-n2/*


echo "docker-compose up"
#docker-compose -f docker-compose.yml up -d
docker-compose -f docker-compose.yml up

# docker-compose down