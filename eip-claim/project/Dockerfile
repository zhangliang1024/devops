#FROM openjdk:8-jdk-alpine
FROM java:openjdk-8
MAINTAINER zhliang

ENV PARAMS=""
ENV ACTIVE=""

RUN mkdir /usr/local/jydata
ADD jycloud-claim-auprocess-server-*.jar /usr/local/jydata/app.jar

# 设置时区
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

WORKDIR /usr/local/jydata/

ENTRYPOINT ["sh","-c","java -jar $JAVA_OPTS $ACTIVE app.jar $PARAMS"]