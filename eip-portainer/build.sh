#!/bin/bash

docker stop portainer && docker rm portainer

docker run -d \
     --name portainer \
     --restart=always \
     -p 9000:9000 \
     -p 8000:8000 \
     -v /var/run/docker.sock:/var/run/docker.sock \
     -v ${PWD}/data:/data \
     portainer/portainer-ce:latest

docker logs -f portainer