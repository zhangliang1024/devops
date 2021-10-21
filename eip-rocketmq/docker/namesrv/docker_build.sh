#!/bin/bash

sudo docker build --build-arg version=4.2.0 -t apache/eip-rocketmq-namesrv:4.2.0 .