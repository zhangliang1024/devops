# docker部署kafka

### 一、`docker`部署`zookeeper`
```bash
docker run -d \
    --name zookeeper \
    --restart="always" \
    -p 2181:2181 \
    -v /etc/localtime:/etc/localtime \
    wurstmeister/zookeeper
 
```

### 二、`docker`部署`kafka`
> 说明：
> - `-e KAFKA_BROKER_ID=0`  在kafka集群中，每个kafka都有一个BROKER_ID来区分自己
> - `-e KAFKA_ZOOKEEPER_CONNECT=192.168.155.56:2181/kafka` 配置zookeeper管理kafka的路径192.168.155.56:2181/kafka
> - `-e KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://192.168.155.56:9092`  把kafka的地址端口注册给zookeeper
> - `-e KAFKA_LISTENERS=PLAINTEXT://0.0.0.0:9092` 配置kafka的监听端口
> - `-v /etc/localtime:/etc/localtime` 容器时间同步虚拟机的时间

```bash
docker run -d \
    --name kafka\
    --restart="always" \
    -p 9092:9092 \
    -e KAFKA_BROKER_ID=0 \
    -e KAFKA_ZOOKEEPER_CONNECT=192.168.1.36:2181/kafka \
    -e KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://192.168.1.36:9092 \
    -e KAFKA_LISTENERS=PLAINTEXT://0.0.0.0:9092 \
    -v /opt/etc/localtime:/etc/localtime \
    wurstmeister/kafka
```


### 三、测试
```bash
docker exec -it kafka /bin/sh
cd /opt/kafka_2.12-2.3.0/bin
./kafka-console-producer.sh --broker-list localhost:9092 --topic sun
```


###
```bash

```