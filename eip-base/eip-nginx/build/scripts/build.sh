#!/usr/bin/env bash

docker pull nginx

docker run -d --name nginx -p 80:80   -v /toony/nginx/conf/nginx.conf:/etc/nginx/nginx.conf  -v /toony/nginx/logs:/var/log/nginx nginx
