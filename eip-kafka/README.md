# docker部署kafka

### 一、`docker`部署`zookeeper`
```bash
#!/bin/bash

docker stop zookeeper && docker rm zookeeper

docker run -d \
    --name zookeeper \
    --restart="always" \
    -p 2181:2181 \
    -v /etc/localtime:/etc/localtime \
    wurstmeister/zookeeper

docker logs -f zookeeper 
```

### 二、`docker`部署`kafka`
> 说明：
> - `-e KAFKA_BROKER_ID=0`  在kafka集群中，每个kafka都有一个BROKER_ID来区分自己
> - `-e KAFKA_ZOOKEEPER_CONNECT=192.168.155.56:2181/kafka` 配置zookeeper管理kafka的路径192.168.155.56:2181/kafka
> - `-e KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://192.168.155.56:9092`  把kafka的地址端口注册给zookeeper
> - `-e KAFKA_LISTENERS=PLAINTEXT://0.0.0.0:9092` 配置kafka的监听端口
> - `-v /etc/localtime:/etc/localtime` 容器时间同步虚拟机的时间

```bash
#!/bin/bash

docker stop kafka && docker rm kafka

docker run -d \
    --name kafka\
    --restart="always" \
    -p 9092:9092 \
    -p 1099:1099 \
    -e KAFKA_BROKER_ID=0 \
    -e KAFKA_ZOOKEEPER_CONNECT=192.168.1.193:2181/kafka \
    -e KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://192.168.1.193:9092 \
    -e KAFKA_LISTENERS=PLAINTEXT://0.0.0.0:9092 \
    -e KAFKA_JMX_OPTS="-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -Djava.rmi.server.hostname=192.168.1.193 -Dcom.sun.management.jmxremote.rmi.port=1099" \
    -e JMX_PORT=1099 \
    -v /etc/localtime:/etc/localtime \
    wurstmeister/kafka:latest
    
docker logs -f kafka    
```


### 三、测试
> **注意** ：这里 `--zookeeper 192.168.1.193:2181/kafka`是因为上面启动时指定了`-e KAFKA_ZOOKEEPER_CONNECT=192.168.1.193:2181/kafka`

```bash
docker exec -it kafka /bin/sh
cd /opt/kafka_2.13-2.8.1/bin
/opt/kafka_2.13-2.8.1/bin # ./kafka-topics.sh --zookeeper 192.168.1.193:2181/kafka --create --replication-factor 1 --partitions 1 --topic test
Created topic test.
/opt/kafka_2.13-2.8.1/bin #
/opt/kafka_2.13-2.8.1/bin #
/opt/kafka_2.13-2.8.1/bin #
/opt/kafka_2.13-2.8.1/bin # ./kafka-topics.sh --bootstrap-server localhost:9092 --topic test --describe
Topic: test     TopicId: AAZOE_hfQW6iZzhoEgsTXg PartitionCount: 1       ReplicationFactor: 1    Configs: segment.bytes=1073741824
        Topic: test     Partition: 0    Leader: 0       Replicas: 0     Isr: 0
/opt/kafka_2.13-2.8.1/bin #
/opt/kafka_2.13-2.8.1/bin #
/opt/kafka_2.13-2.8.1/bin # ./kafka-topics.sh --zookeeper 192.168.1.193:2181 --list
/opt/kafka_2.13-2.8.1/bin # ./kafka-topics.sh --zookeeper 192.168.1.193:2181/kafka --list
test
/opt/kafka_2.13-2.8.1/bin #
/opt/kafka_2.13-2.8.1/bin # ./kafka-console-producer.sh --bootstrap-server localhost:9092 --topic test
>1
>2
>3
/opt/kafka_2.13-2.8.1/bin #
/opt/kafka_2.13-2.8.1/bin # ./kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic test --from-beginning
1
2
3
```

```bash
docker exec kafka kafka-topics.sh --zookeeper 192.168.1.193:2181 --create --partitions 3 --replication-factor 2 --topic topic001 


docker exec kafka kafka-topics.sh --zookeeper 192.168.1.193:2181 --list



```

### 四、`Kafka`监控页面
> `kafka-map`
```bash
#!/bin/bash

docker run -d \
    --name kafka-map \
    --restart always \
    -p 8081:8080 \
    -v /opt/kafka-map/data:/usr/local/kafka-map/data \
    -e DEFAULT_USERNAME=admin \
    -e DEFAULT_PASSWORD=admin \
    dushixiang/kafka-map:latest

docker logs -f kafka-map

```

####  `kafka-console-ui`

![](https://pic3.zhimg.com/v2-533c35cc1fc533f2a392c5bbadbddab6_r.jpg?source=1940ef5c)

- `build.sh`
```bash
#!/bin/bash

docker stop kafka-console-ui && docker rm kafka-console-ui

docker run -d \
    --name kafka-console-ui \
    --restart always \
    -p 7766:7766 \
    -v ${PWD}/data:/app/data \
    -v ${PWD}/log:/app/log \
    wdkang/kafka-console-ui

docker logs -f kafka-console-ui
```

> `docker-compose.yaml`
```bash
version: '3'
services:
  kafka-console-ui:
    container_name: "kafka-console-ui"
    image: wdkang/kafka-console-ui
    ports:
      - "7766:7766"
    volumes:
      - ${PWD}/data:/app/data
      - ${PWD}/log:/app/log
    privileged: true # 防止读写文件有问题
    user: root
```

#### `ealge`
```bash
docker run  --name efak -p 8048:8048  -v ${PWD}/system-config.properties:/opt/kafka-eagle/conf/system-config.properties  efak:2.0.3
```

---
### 异常报错

#### ① 容器执行命令报错
> - 在部署`kafka`时，开启`Jmx_port`端口。则执行命令报如下错误。不开启`Jmx_port`端口则正常。
> - 按如下方式修复后，则`Jmx`失效。
```bash
/opt/kafka_2.13-2.8.1/bin # ./kafka-topics.sh --zookeeper 192.168.1.193:2181 --list
Error: JMX connector server communication error: service:jmx:rmi://d712c3ebcd30:2099
sun.management.AgentConfigurationError: java.rmi.server.ExportException: Port already in use: 1099; nested exception is:
        java.net.BindException: Address in use (Bind failed)
        at sun.management.jmxremote.ConnectorBootstrap.exportMBeanServer(ConnectorBootstrap.java:800)
        at sun.management.jmxremote.ConnectorBootstrap.startRemoteConnectorServer(ConnectorBootstrap.java:468)
        at sun.management.Agent.startAgent(Agent.java:262)
        at sun.management.Agent.startAgent(Agent.java:452)
Caused by: java.rmi.server.ExportException: Port already in use: 1099; nested exception is:
        java.net.BindException: Address in use (Bind failed)
        at sun.rmi.transport.tcp.TCPTransport.listen(TCPTransport.java:346)
        at sun.rmi.transport.tcp.TCPTransport.exportObject(TCPTransport.java:254)
        at sun.rmi.transport.tcp.TCPEndpoint.exportObject(TCPEndpoint.java:412)
        at sun.rmi.transport.LiveRef.exportObject(LiveRef.java:147)
        at sun.rmi.server.UnicastServerRef.exportObject(UnicastServerRef.java:237)
        at sun.management.jmxremote.ConnectorBootstrap$PermanentExporter.exportObject(ConnectorBootstrap.java:199)
        at javax.management.remote.rmi.RMIJRMPServerImpl.export(RMIJRMPServerImpl.java:146)
        at javax.management.remote.rmi.RMIJRMPServerImpl.export(RMIJRMPServerImpl.java:122)
        at javax.management.remote.rmi.RMIConnectorServer.start(RMIConnectorServer.java:404)
        at sun.management.jmxremote.ConnectorBootstrap.exportMBeanServer(ConnectorBootstrap.java:796)
        ... 3 more
Caused by: java.net.BindException: Address in use (Bind failed)
        at java.net.PlainSocketImpl.socketBind(Native Method)
        at java.net.AbstractPlainSocketImpl.bind(AbstractPlainSocketImpl.java:387)
        at java.net.ServerSocket.bind(ServerSocket.java:392)
        at java.net.ServerSocket.<init>(ServerSocket.java:254)
        at java.net.ServerSocket.<init>(ServerSocket.java:145)
        at sun.rmi.transport.proxy.RMIDirectSocketFactory.createServerSocket(RMIDirectSocketFactory.java:45)
        at sun.rmi.transport.proxy.RMIMasterSocketFactory.createServerSocket(RMIMasterSocketFactory.java:345)
        at sun.rmi.transport.tcp.TCPEndpoint.newServerSocket(TCPEndpoint.java:670)
        at sun.rmi.transport.tcp.TCPTransport.listen(TCPTransport.java:335)
        ... 12 more
/opt/kafka_2.13-2.8.1/bin # 
```

- 解决方案
> 进入容器，修改`kafka-run-class.sh`配置文件
```bash
docker exec -it kafka sh
cd /opt/kafka_2.1302.7.0/bin
vi kafka-run-class.hs
```
> 添加以下内容
```bash
ISKAFKASERVER="false"
if [[ "$*" =~ "kafka.Kafka" ]]; then
    ISKAFKASERVER="true"
fi

#修改：if [  $JMX_PORT ] 如下
if [  $JMX_PORT ] && [ -z "$ISKAFKASERVER" ]; then
```
> 退出重启容器
```bash
docker restart kafka
```

### 参考文档
* [Docker部署kafka-console-ui](https://github.com/xxd763795151/kafka-console-ui/blob/main/document/deploy/docker%E9%83%A8%E7%BD%B2.md)
* [kafka可视化web管理工具kafka-map ](https://blog.csdn.net/zhang641692786/article/details/125501444)
* [kafka-map监控kafka集群-k8s](https://www.cnblogs.com/klvchen/articles/15849334.html)
* [docker-kafka](https://www.jianshu.com/p/2ac5fd74e9bd)