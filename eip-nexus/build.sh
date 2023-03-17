#!/bin/bash

docker stop nexus3 && docker rm nexus3

docker run -d \
	--name=nexus3 \
	--restart=always \
	--privileged=true \
	-p 8081:8081 \
	-p 8080:8080 \
	-p 8000:8000 \
	-e INSTALL4J_ADD_VM_PARAMS="-Xms4g -Xmx4g -XX:MaxDirectMemorySize=8g -Djava.util.prefs.userRoot=/nexus-data/javaprefs" \
	-v /etc/localtime:/etc/localtime \
	-v ${PWD}/nexus-data:/nexus-data \
	sonatype/nexus3:3.46.0

docker logs -f nexus3