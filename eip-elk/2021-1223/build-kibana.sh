#!/bin/bash

firewall-cmd --add-port=5601/tcp --permanent
firewall-cmd --reload
firewall-cmd --list-all

docker stop kibana && docker rm kibana

docker run --name kibana \
        --restart=always \
        -m 1024m --memory-reservation 200M \
        --cpus 1 \
        -p 5601:5601 \
        -v /home/kibana/config/kibana.yml:/usr/share/kibana/config/kibana.yml \
        -d kibana:7.14.0

docker logs -f kibana

#echo "http://192.168.2.151:5601"
