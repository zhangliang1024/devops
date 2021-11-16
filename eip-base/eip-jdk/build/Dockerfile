FROM centos:latest

MAINTAINER zhliang <zhangliang_job@126.com>

RUN mkdir /usr/local/jdk
WORKDIR /usr/local/jdk
ADD jdk-8u171-linux-x64.tar.gz /usr/local/jdk

ENV JAVA_HOME /usr/local/jdk/jdk1.8.0_171
ENV JRE_HOME /usr/local/jdk/jdk1.8.0_171/jre
ENV PATH $JAVA_HOME/bin:$PATH