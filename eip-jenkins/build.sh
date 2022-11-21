#!/bin/bash

docker stop jenkins && docker rm jenkins

docker run -d --name jenkins \
        -u root \
        -p 3180:8080 -p 3005:5000 \
        -v ${PWD}/jenkins_home:/var/jenkins_home \
        -v /usr/local/jdk-8:/var/jenkins_home/jdk-8 \
        -v /usr/local/maveen-3.8.6:/var/jenkins_home/maveen-3.8.6 \
        -v /toony/jenkins/jenkinsci:/usr/jenkinsci \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -v /usr/bin/docker:/usr/bin/docker \
        -v /etc/docker/daemon.json:/etc/docker/daemon.json \
        jenkins/jenkins:2.361.4-lts

docker logs -f jenkins
