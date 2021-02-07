# Dockerfile for apollo-adminservice
# 1. ./scripts/build.sh
# 2. Build with: mvn docker:build -pl apollo-adminservice
# 3. Run with: docker run -p 8090:8090 -e SPRING_DATASOURCE_URL="jdbc:mysql://fill-in-the-correct-server:3306/ApolloConfigDB?characterEncoding=utf8" -e SPRING_DATASOURCE_USERNAME=FillInCorrectUser -e SPRING_DATASOURCE_PASSWORD=FillInCorrectPassword -d -v /tmp/logs:/opt/logs --name apollo-adminservice apolloconfig/apollo-adminservice

FROM openjdk:8-jre-alpine
MAINTAINER ameizi <sxyx2008@163.com>

ARG ADMIN_SERVER_PORT

ENV APOLLO_RUN_MODE "Docker"
ENV VERSION JY-1.7.0
ENV SERVER_PORT $ADMIN_SERVER_PORT

RUN echo "http://mirrors.aliyun.com/alpine/v3.8/main" > /etc/apk/repositories \
    && echo "http://mirrors.aliyun.com/alpine/v3.8/community" >> /etc/apk/repositories \
    && apk update upgrade \
    && apk add --no-cache procps unzip curl bash tzdata \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone

ADD apollo-adminservice-${VERSION}-github.zip /apollo-adminservice/apollo-adminservice-${VERSION}-github.zip

RUN unzip /apollo-adminservice/apollo-adminservice-${VERSION}-github.zip -d /apollo-adminservice \
    && rm -rf /apollo-adminservice/apollo-adminservice-${VERSION}-github.zip \
    && chmod +x /apollo-adminservice/scripts/startup.sh 

EXPOSE $SERVER_PORT

CMD ["/apollo-adminservice/scripts/startup.sh"]
