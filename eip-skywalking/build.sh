#!/bin/bash

echo "install docker-compose"

sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
docker-compose --version


ehco "pull images"
docker pull apache/skywalking-oap-server:8.7.0-es7
docker pull apache/skywalking-ui:8.7.0
docker pull elasticsearch:7.14.0