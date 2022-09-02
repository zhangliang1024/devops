# Docker部署Zookeeper
> [镜像地址](https://hub.docker.com/_/zookeeper)

### 一、说明
```properties
ZOO_MY_ID：节点ID，表示当前zk在集群中的编号，范围1-255。即zk集群最多255个节点。
ZOO_SERVERS：集群节点地址，多个节点之间使用空格隔开

Zookeeper共用到三个端口：
2181 ：对client端提供服务的端口
2888 ：选举leader使用
3888 ：集群内机器通讯使用(Leader监听此端口)
```

- 单机部署
> `build.sh`
```bahsh
#!/bin/bash

docker stop myzk && docker rm myzk

docker run --name myzk \
        --restart always \
        -p 2181:2181 \
        -v /etc/timezone:/etc/timezone \
        -e JVMFLAGS="-Xmx1024m" \
        zookeeper:3.7.0
```


### 二、查看集群节点状态
> 客户端连接
```bash
docker exec -it zoo1 /bin/bash ./bin/zkCli.sh 
```
> 查看当前节点是主从
```bash
docker exec -it zoo1 /bin/bash
sh bin/zkServer.sh status
```

### 三、访问`zk`控制台
> `zk`内嵌了`web`控制台，需要映射开放`8080`端口即可访问
```yaml
version: "3"

services:
  zoo1:
    image: zookeeper:3.7.0
    restart: always
    container_name: zoo1
    hostname: zoo1
    ports:
      - 2181:2181
      - 8081:8080
    volumes:
      - ${PWD}/zookeeper/zoo1/data:/data
      - ${PWD}/zookeeper/zoo1/logs:/datalog
    environment:
      ZOO_MY_ID: 1
      ZOO_SERVERS: server.1=zoo1:2888:3888
```
- 地址
> http://xx.xx.x.x:8081/commands

![企业微信截图_1662019621855.png](http://tva1.sinaimg.cn/large/d1b93a20ly1h5r62zhcqqj20km0hu0xe.jpg)


---
### 参考文档
* [docker安装zookeeper的使用说明](https://www.cnblogs.com/zqllove/p/13724195.html)
* [docker安装zookeeper](https://blog.csdn.net/daziyuanazhen/article/details/106173509)
* []()