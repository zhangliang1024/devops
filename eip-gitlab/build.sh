#!/bin/sh

docker stop gitlab && docker rm gitlab

GITLAB_HOME=/usr/local/gitlab

docker run -d --name gitlab \
    --hostname 140.xx.154.99 \
    -p 8443:443 \
    -p 9091:80 \
    -p 10080:22 \
    --restart always \
    --privileged=true \
    -v $GITLAB_HOME/config:/etc/gitlab \
    -v $GITLAB_HOME/logs:/var/log/gitlab \
    -v $GITLAB_HOME/data:/var/opt/gitlab \
    -e GITLAB_ROOT_PASSWORD=12345678 \
    gitlab/gitlab-ce:latest