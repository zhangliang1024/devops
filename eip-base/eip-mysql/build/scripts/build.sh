#!/usr/bin/env bash

docker pull mysql:5.7

docker run -p 3306:3306 --name mysql \
 -v /toony/mysql/log:/var/log/mysql \
 -v /toony/mysql/data:/var/lib/mysql \
 -v /toony/mysql/conf:/etc/mysql \
 -e MYSQL_ROOT_PASSWORD=123456 \
 -d mysql:5.7