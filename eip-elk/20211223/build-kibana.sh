#!/bin/bash

firewall-cmd --add-port=5601/tcp --permanent
firewall-cmd --reload
firewall-cmd --list-all

docker stop kibana && docker rm kibana

docker run -d \
    --name kibana \
    -p 5601:5601 \
    --net host  \
    -v `pwd`/kibana.yml:/usr/share/kibana/config/kibana.yml \
     kibana:7.14.0

echo "http://192.168.2.151:5601"
