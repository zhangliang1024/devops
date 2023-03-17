#!/bin/bash

docker stop filebeat && docker rm -f filebeat

docker run -d \
      --name=filebeat \
      --restart=always \
      -v /home/filebeat:/usr/share/filebeat \
      -v /home/log/messages:/var/log/messages \
      elastic/filebeat:7.14.0

docker logs -f filebeat



