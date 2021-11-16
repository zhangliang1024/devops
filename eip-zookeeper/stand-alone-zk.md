# 单机版zookeeper快速部署


### 一、docker部署zk
```bash
#!/bin/bash

docker stop myzk && docker rm myzk

docker run --name myzk \
        --restart always \
        -v /etc/timezone:/etc/timezone \
        -e JVMFLAGS="-Xmx1024m" \
        -p 2181:2181 \
        zookeeper:latest
```


### 二、进入到容器
```bash
docker exec -it myzk /bin/bash
```

### 三、连接zookeeper
```bash
docker exec -it myzk /bin/bash
cd bin/
.zkCli.sh 
```





### 九、参考文档
* [docker安装zookeeper的使用说明](https://www.cnblogs.com/zqllove/p/13724195.html)
* [docker安装zookeeper](https://blog.csdn.net/daziyuanazhen/article/details/106173509)
* []()