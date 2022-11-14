#!/bin/sh

docker stop gitlab && docker rm gitlab

GITLAB_HOME=/usr/local/gitlab

docker run -d --name gitlab \
    --hostname 140.246.xxx.99 \
    -p 3003:443 \
    -p 3080:3080 \
    -p 3002:22 \
    --restart always \
    --privileged=true \
    -v $GITLAB_HOME/config:/etc/gitlab \
    -v $GITLAB_HOME/logs:/var/log/gitlab \
    -v $GITLAB_HOME/data:/var/opt/gitlab \
    -e GITLAB_ROOT_PASSWORD=12345678 \
    gitlab/gitlab-ce:latest