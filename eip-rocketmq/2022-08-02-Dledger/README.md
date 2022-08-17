# Docker`部署`RocketMQ Dledger`集群
> **注意**
> - 测试部署中，`docker-compose`使用网络为：`bridge`，可能与业务服务存在网络隔离，导致无法访问到。故需要修改网络配置为：`host模式`
> - 同时，需要修改`broker.conf`中的`dLegerPeers`连接配置，为`host模式`下可以访问到的地址

### 一、`docker-compose`部署`host`模式
> 这里调整为 Host网络模式：network_mode: host，调整后不能配置端口
```yaml
version: '3.5'
services:
  rmqnamesrv-a:
    image: foxiswho/rocketmq:4.8.0
    container_name: rmqnamesrv-a
    volumes:
    - ${PWD}/rocketmq/nameserver-a/logs:/home/rocketmq/logs
    - ${PWD}/rocketmq/nameserver-a/store:/home/rocketmq/store
    command: sh mqnamesrv
    network_mode: host

  rmqbroker-n0:
    image: foxiswho/rocketmq:4.8.0
    container_name: rmqbroker-n0
    volumes:
    - ${PWD}/rocketmq/dledger-n0/logs:/home/rocketmq/logs
    - ${PWD}/rocketmq/dledger-n0/store:/home/rocketmq/store
    - ${PWD}/rocketmq/dledger-n0/store/commitlog:/home/rocketmq/store/commitlog
    - ${PWD}/rocketmq/dledger-n0/store/consumequeue:/home/rocketmq/store/consumequeue
    - ${PWD}/rocketmq/dledger-n0/store/dledger-n0/data:/home/rocketmq/store/dledger-n0/data
    - ${PWD}/rocketmq/dledger-n0/broker-n0.conf:/home/rocketmq/rocketmq-4.8.0/conf/broker.conf
    environment:
      TZ: Asia/Shanghai
      NAMESRV_ADDR: "172.31.0.6:9876"
      JAVA_OPT_EXT: "-Xms512M -Xmx512M -Xmn128m"
    command: sh mqbroker -c /home/rocketmq/rocketmq-4.8.0/conf/broker.conf autoCreateTopicEnable=true &
    depends_on:
    - rmqnamesrv-a
    network_mode: host

  rmqbroker-n1:
    image: foxiswho/rocketmq:4.8.0
    container_name: rmqbroker-n1
    volumes:
    - ${PWD}/rocketmq/dledger-n1/logs:/home/rocketmq/logs
    - ${PWD}/rocketmq/dledger-n1/store:/home/rocketmq/store
    - ${PWD}/rocketmq/dledger-n1/store/commitlog:/home/rocketmq/store/commitlog
    - ${PWD}/rocketmq/dledger-n1/store/consumequeue:/home/rocketmq/store/consumequeue
    - ${PWD}/rocketmq/dledger-n1/store/dledger-n1/data:/home/rocketmq/store/dledger-n1/data
    - ${PWD}/rocketmq/dledger-n1/broker-n1.conf:/home/rocketmq/rocketmq-4.8.0/conf/broker.conf
    environment:
      TZ: Asia/Shanghai
      NAMESRV_ADDR: "172.31.0.6:9876"
      JAVA_OPT_EXT: "-Xms512M -Xmx512M -Xmn128m"
    command: sh mqbroker -c /home/rocketmq/rocketmq-4.8.0/conf/broker.conf autoCreateTopicEnable=true &
    depends_on:
    - rmqnamesrv-a
    network_mode: host

  rmqbroker-n2:
    image: foxiswho/rocketmq:4.8.0
    container_name: rmqbroker-n2
    volumes:
    - ${PWD}/rocketmq/dledger-n2/logs:/home/rocketmq/logs
    - ${PWD}/rocketmq/dledger-n2/store:/home/rocketmq/store
    - ${PWD}/rocketmq/dledger-n2/store/commitlog:/home/rocketmq/store/commitlog
    - ${PWD}/rocketmq/dledger-n2/store/consumequeue:/home/rocketmq/store/consumequeue
    - ${PWD}/rocketmq/dledger-n2/store/dledger-n2/data:/home/rocketmq/store/dledger-n2/data
    - ${PWD}/rocketmq/dledger-n2/broker-n2.conf:/home/rocketmq/rocketmq-4.8.0/conf/broker.conf
    environment:
      TZ: Asia/Shanghai
      NAMESRV_ADDR: "172.31.0.6:9876"
      JAVA_OPT_EXT: "-Xms512M -Xmx512M -Xmn128m"
    command: sh mqbroker -c /home/rocketmq/rocketmq-4.8.0/conf/broker.conf autoCreateTopicEnable=true &
    depends_on:
    - rmqnamesrv-a
    network_mode: host

  rmqconsole:
    image: styletang/rocketmq-console-ng
    container_name: rmqconsole
    ports:
    - 8180:8080
    environment:
      JAVA_OPTS: "-Drocketmq.namesrv.addr=rmqnamesrv-a:9876;rmqnamesrv-b:9876 -Dcom.rocketmq.sendMessageWithVIPChannel=false"
    network_mode: host

networks:
  rmq:
    name: rmq
    driver: bridge
```


### 二、`Docker`部署

#### ① `Docker`部署`NameSrv`
```bash
docker run -d --name rmqnamesr \
    --restart=always \
    --net host \
    -v ${PWD}/rocketmq/nameserver-a/logs:/home/rocketmq/logs \
    -v ${PWD}/rocketmq/nameserver-a/store:/home/rocketmq/store \
    -e "JAVA_OPT_EXT=-Xms512M -Xmx512M -Xmn128m" \
    -p 9876:9876 \
    foxiswho/rocketmq:4.8.0 \
    sh mqnamesrv
```

#### ② `Docker`部署`Broker`
```bash
docker run -d --name rmqbroker \
    --restart=always \
    --net host \
    -v - ${PWD}/rocketmq/dledger-n0/logs:/home/rocketmq/logs \
    -v - ${PWD}/rocketmq/dledger-n0/store:/home/rocketmq/store \
    -v - ${PWD}/rocketmq/dledger-n0/store/commitlog:/home/rocketmq/store/commitlog \
    -v - ${PWD}/rocketmq/dledger-n0/store/consumequeue:/home/rocketmq/store/consumequeue \
    -v - ${PWD}/rocketmq/dledger-n0/store/dledger-n0/data:/home/rocketmq/store/dledger-n0/data \
    -v - ${PWD}/rocketmq/dledger-n0/broker-n0.conf:/home/rocketmq/rocketmq-4.8.0/conf/broker.conf \
    -e "JAVA_OPT_EXT=-Xms512M -Xmx512M -Xmn128m" \
    -p 30909:30909 -p 30911:30911 -p 30912:30912 -p 40911:40911 \
    foxiswho/rocketmq:4.8.0 \
    sh mqbroker -c /home/rocketmq/rocketmq-4.8.0/conf/broker.conf autoCreateTopicEnable=true &

```

#### ③ `Docker`部署`Console`

```bash
docker run -d --name rmqconsole \
    --restart=always \
    -p 8080:8080 \
    -e "JAVA_OPTS=-Drocketmq.namesrv.addr=172.31.0.6:9876 -Dcom.rocketmq.sendMessageWithVIPChannel=false" \
    styletang/rocketmq-console-ng
```


### 三、二进制部署启动关闭脚本

#### ① 启动关闭`NameSrv`
> vim name_start.sh
```bash
#!/bin/bash

cd /usr/local/rocketmq-all-4.9.4-bin-release
nohup sh bin/mqnamesrv &
echo "nameserver 启动成功 .."
tail -f ~/logs/rocketmqlogs/namesrv.log
```

> vim name_stop.sh
```bash
#!/bin/bash

cd /usr/local/rocketmq-all-4.9.4-bin-release
sh bin/mqshutdown namesrv
echo "nameserver 关闭成功..."
echo "再次搜索结果为："
sleep 3
jps
```

#### ② 启动关闭`Broker`
> vim b_master1_start.sh
```bash
#!/bin/bash

cd /usr/local/rocketmq-all-4.9.4-bin-release
nohup sh bin/mqbroker -c conf/2m-2s-sync/broker-a.properties >/dev/null 2>&1 &
tail -f ~/logs/rocketmqlogs/broker.log
```

> vim b_slave1_start.sh
```bash
#!/bin/bash

cd /usr/local/rocketmq-all-4.9.4-bin-release
nohup sh bin/mqbroker -c conf/2m-2s-sync/broker-a-s.properties &
tail -f ~/logs/rocketmqlogs/broker.log
```

> vim broker_stop.sh
```bash
#!/bin/bash

cd /usr/local/rocketmq-all-4.9.4-bin-release
sh bin/mqshutdown broker
echo "broker 关闭成功..."
echo "再次搜索结果为："
sleep 3
jps
```

### 九、参考文档
* [Docker 部署 RocketMQ Dledger 集群模式（ 版本v4.7.0）](https://www.cnblogs.com/hahaha111122222/p/16112419.html)
* [Docker 安装 RocketMQ-DLedger 多副本集群(4.9.3)](https://blog.csdn.net/apple_csdn/article/details/125296236)
* [Docker搭建rocketmq的dledger模式集群](https://blog.csdn.net/ccgshigao/article/details/108841641)
* []()