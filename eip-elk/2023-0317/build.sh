#/bin/bash

mkdir {elasticsearch,logstash,kibana}

chmod 777 ${PWD}/elasticsearch

docker-compose up -d