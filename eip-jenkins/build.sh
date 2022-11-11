#!/bin/bash

docker stop jenkins && docker rm jenkins

docker run -d --name jenkins \
        -u root \
        -p 8080:8080 -p 5000:5000 \
        -v /toony/jenkins/jenkins_home:/var/jenkins_home \
        -v /usr/local/java/jdk1.8.0_171:/var/jenkins_home/jdk8 \
        -v /toony/server/apache-maven-3.6.3:/var/jenkins_home/maven \
        -v /toony/jenkins/jenkinsci:/usr/jenkinsci \
        -v /usr/bin/docker:/usr/bin/docker \
        -v /var/run/docker.sock:/var/run/docker.sock \
        jenkinsci/blueocean