FROM openjdk:8-alpine

ARG version

ENV ROCKETMQ_VERSION ${version}

ENV ROCKETMQ_HOME  /opt/rocketmq-${ROCKETMQ_VERSION}

WORKDIR  ${ROCKETMQ_HOME}

#设置时区
RUN /bin/cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
  && echo 'Asia/Shanghai' >/etc/timezone \


RUN mkdir -p /opt/logs /opt/store

RUN curl https://mirror.bit.edu.cn/apache/rocketmq/${ROCKETMQ_VERSION}/rocketmq-all-${ROCKETMQ_VERSION}-bin-release.zip -o rocketmq.zip \
          && unzip rocketmq.zip \
          && rm rocketmq.zip


RUN chmod +x bin/mqnamesrv

CMD cd ${ROCKETMQ_HOME}/bin && export JAVA_OPT=" -Duser.home=/opt" && sh mqnamesrv

EXPOSE 9876

VOLUME /opt/logs /opt/store