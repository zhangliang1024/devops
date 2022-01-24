FROM openjdk:8-jdk-alpine
MAINTAINER zhliang <zhliang@gmail.com>

RUN mkdir -p usr/src/sentinel-dashboard

COPY sentinel/sentinel-dashboard.jar /usr/src/sentinel-dashboard
WORKDIR /usr/src/sentinel-dashboard

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "sentinel-dashboard.jar"]
#ENTRYPOINT ["java", "-Dserver.port=8080", "-Dcsp.sentinel.dashboard.server=localhost:8080", "-Dproject.name=sentinel-dashboard", "-jar", "sentinel-dashboard.jar"]