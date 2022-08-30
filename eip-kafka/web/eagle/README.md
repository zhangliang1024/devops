# Docker部署Eagle

### 一、`Eagle`介绍
> [官网地址](http://download.kafka-eagle.org/) `Eagle`是一款`kafka`集群管理工具。
> 可以用来监控`kafka`集群的`broker`状态、`Topic`信息、(`IO`)、内存、`Consumer`线程、偏移量等信息。
> 独特的`KQL`还支持通过`SQL`在线查询`kafka`中的数据。



### 二、`Docker`部署
> `Eagle`本身不提供镜像，因此需要手动制作镜像

- 下载二进制包
> **注意**：不同版本解压后的目录不一致
```bash
#wget https://github.com/smartloli/kafka-eagle-bin/archive/v3.0.1.tar.gz
wget https://github.com/smartloli/kafka-eagle-bin/archive/v2.0.1.tar.gz
```

- `Dockerfile`
> `kafka-eagle`的`Dockerfile`镜像脚本，这里使用版本为：`2.0.1`
```bash
FROM openjdk:8-alpine3.9
MAINTAINER zhangsan "zhangsan@126.com"

#环境变量配置
ENV KE_HOME=/opt/kafka-eagle

ENV EAGLE_VERSION=2.0.1

CMD ["/bin/bash"]

#工作目录
WORKDIR /opt/kafka-eagle

#拷贝压缩包到临时目录
COPY kafka-eagle-bin-${EAGLE_VERSION}.tar.gz  /tmp

#将上传的kafka-eagle压缩包解压放入镜像中并授权
RUN mkdir -p /opt/kafka-eagle && \
    cd /opt && \
    tar zxvf /tmp/kafka-eagle-bin-${EAGLE_VERSION}.tar.gz -C kafka-eagle --strip-components 1 && \
    rm -f /tmp/kafka-eagle-bin-${EAGLE_VERSION}.tar.gz && \
    cd kafka-eagle;tar zxvf kafka-eagle-web-${EAGLE_VERSION}-bin.tar.gz --strip-components 1 && \
    rm -f kafka-eagle-web-${EAGLE_VERSION}-bin.tar.gz  && \
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
```

- `entrypoint.sh`
> 
```bash
#!/usr/bin

#kafka-eagle项目启动的命令
sh /opt/kafka-eagle/bin/ke.sh start

tail -f /dev/null
```

- `system-config.properties`
> **注意**：不同版本的配置一样
> - 配置`kafak`、`zk`、`数据库`即可，其余使用默认配置
```properties
######################################
# multi zookeeper & kafka cluster list
######################################
# kafka、zk的配置
kafka.eagle.zk.cluster.alias=cluster1
cluster1.zk.list=192.168.1.193:2181
######################################
# zookeeper enable acl
######################################
cluster1.zk.acl.enable=false
cluster1.zk.acl.schema=digest
cluster1.zk.acl.username=test
cluster1.zk.acl.password=test123
######################################
# broker size online list
######################################
cluster1.kafka.eagle.broker.size=20
######################################
# zk client thread limit
######################################
kafka.zk.limit.size=25
######################################
# kafka eagle webui port
######################################
kafka.eagle.webui.port=8048
######################################
# kafka offset storage
######################################
cluster1.kafka.eagle.offset.storage=kafka
cluster2.kafka.eagle.offset.storage=zk
######################################
# kafka metrics, 15 days by default
######################################
kafka.eagle.metrics.charts=true
kafka.eagle.metrics.retain=15
######################################
# kafka sql topic records max
######################################
kafka.eagle.sql.topic.records.max=5000
kafka.eagle.sql.fix.error=true
######################################
# delete kafka topic token
######################################
kafka.eagle.topic.token=keadmin
######################################
# kafka sasl authenticate
######################################
cluster1.kafka.eagle.sasl.enable=false
cluster1.kafka.eagle.sasl.protocol=SASL_PLAINTEXT
cluster1.kafka.eagle.sasl.mechanism=SCRAM-SHA-256
cluster1.kafka.eagle.sasl.jaas.config=org.apache.kafka.common.security.scram.ScramLoginModule required username="kafka" password="kafka-eagle";
cluster1.kafka.eagle.sasl.client.id=
cluster1.kafka.eagle.blacklist.topics=
cluster1.kafka.eagle.sasl.cgroup.enable=false
cluster1.kafka.eagle.sasl.cgroup.topics=
cluster2.kafka.eagle.sasl.enable=false
cluster2.kafka.eagle.sasl.protocol=SASL_PLAINTEXT
cluster2.kafka.eagle.sasl.mechanism=PLAIN
cluster2.kafka.eagle.sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username="kafka" password="kafka-eagle";
cluster2.kafka.eagle.sasl.client.id=
cluster2.kafka.eagle.blacklist.topics=
cluster2.kafka.eagle.sasl.cgroup.enable=false
cluster2.kafka.eagle.sasl.cgroup.topics=
######################################
# kafka ssl authenticate
######################################
cluster3.kafka.eagle.ssl.enable=false
cluster3.kafka.eagle.ssl.protocol=SSL
cluster3.kafka.eagle.ssl.truststore.location=
cluster3.kafka.eagle.ssl.truststore.password=
cluster3.kafka.eagle.ssl.keystore.location=
cluster3.kafka.eagle.ssl.keystore.password=
cluster3.kafka.eagle.ssl.key.password=
cluster3.kafka.eagle.ssl.cgroup.enable=false
cluster3.kafka.eagle.ssl.cgroup.topics=
######################################
# kafka sqlite jdbc driver address
######################################
kafka.eagle.driver=org.sqlite.JDBC
kafka.eagle.url=jdbc:sqlite:/hadoop/kafka-eagle/db/ke.db
kafka.eagle.username=root
kafka.eagle.password=www.kafka-eagle.org
######################################
# kafka mysql jdbc driver address
######################################
#kafka.eagle.driver=com.mysql.jdbc.Driver
#kafka.eagle.url=jdbc:mysql://127.0.0.1:3306/ke?useUnicode=true&characterEncoding=UTF-8&zeroDateTimeBehavior=convertToNull
#kafka.eagle.username=root
#kafka.eagle.password=123456
```

### 三、制作镜像
```bash
docker build -t efak:1.0.0 .
```


### 四、启动
- `build.sh`
```bash
docker stop efak && docker rm efak

docker run -d \
     --name efak\
     -p 8048:8048 \
     -v ${PWD}/system-config.properties:/opt/kafka-eagle/conf/system-config.properties \
     efak:1.0.0

docker logs -f efak

```

### 五、访问
> http://xx.xx.xx.x:8048

![企业微信截图_16618518701107.png](http://tva1.sinaimg.cn/large/d1b93a20ly1h5ox9yz9ouj21fu0rd178.jpg)

---

### 参考文档

* [docker制做kafka-eagle镜像](https://blog.csdn.net/yprufeng/article/details/121236167)
* [docker-compose一键式搭建kafka集群及kafka](https://blog.csdn.net/yprufeng/article/details/121246199)
* [docker-kafka-eagle](https://github.com/nick-zh/docker-kafka-eagle)
* []()
