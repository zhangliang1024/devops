#!/bin/bash
# 说明，4.8.0镜像版本，要求所有《映射本地目录logs权限一定要设置为 777 权限，否则启动不成功》

echo "${PWD}"

echo "pull images"
#docker pull foxiswho/rocketmq:4.8.0
#docker pull styletang/rocketmq-console-ng:latest

echo "mdkir files"
mkdir -p $(pwd)/rocketmq/nameserver-a/logs
mkdir -p $(pwd)/rocketmq/nameserver-b/logs
mkdir -p $(pwd)/rocketmq/nameserver-a/store
mkdir -p $(pwd)/rocketmq/nameserver-b/store
mkdir -p $(pwd)/rocketmq/broker-a/logs
mkdir -p $(pwd)/rocketmq/broker-b/logs
mkdir -p $(pwd)/rocketmq/broker-a/store
mkdir -p $(pwd)/rocketmq/broker-b/store

chmod 777 $(pwd)/rocketmq/*
chmod 777 $(pwd)/rocketmq/broker-b/*
chmod 777 $(pwd)/rocketmq/broker-a/*
chmod 777 $(pwd)/rocketmq/nameserver-a/*
chmod 777 $(pwd)/rocketmq/nameserver-b/*
chmod 777 $(pwd)/broker-a
chmod 777 $(pwd)/broker-b


echo "docker-compose up"
docker-compose -f docker-compose.yml up -d
#docker-compose -f docker-compose.yml up

# docker-compose down