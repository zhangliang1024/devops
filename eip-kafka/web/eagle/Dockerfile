#kafka-eagle的Dockerfile镜像脚本

#引入依赖的java环境
FROM openjdk:8-alpine3.9

#环境变量配置
ENV KE_HOME=/opt/kafka-eagle

ENV EAGLE_VERSION=2.0.8

CMD ["/bin/bash"]

#工作目录
WORKDIR /opt/kafka-eagle

#作者信息
MAINTAINER yan.p "1551908978@qq.com"

#拷贝压缩包到临时目录
COPY kafka-eagle-bin-${EAGLE_VERSION}.tar.gz  /tmp

#将上传的kafka-eagle压缩包解压放入镜像中并授权
RUN mkdir /opt/kafka-eagle -p && cd /opt && \
    tar zxvf /tmp/kafka-eagle-bin-${EAGLE_VERSION}.tar.gz -C kafka-eagle --strip-components 1 && rm -f /tmp/kafka-eagle-bin-${EAGLE_VERSION}.tar.gz && \
    cd kafka-eagle;tar zxvf kafka-eagle-web-${EAGLE_VERSION}-bin.tar.gz --strip-components 1 && rm -f kafka-eagle-web-${EAGLE_VERSION}-bin.tar.gz  && \
    chmod +x /opt/kafka-eagle/bin/ke.sh && \
    mkdir -p /hadoop/kafka-eagle/db

#将kafka-eagle的启动文件拷贝到镜像中
COPY entrypoint.sh /opt/kafka-eagle/bin

#给启动文件授权
RUN chmod +x /opt/kafka-eagle/bin/entrypoint.sh

#暴露端口
EXPOSE 8048 8080

#镜像的启动命令
CMD ["sh","/opt/kafka-eagle/bin/entrypoint.sh"]