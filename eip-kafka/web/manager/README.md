# Docker部署Kafka-Manger

### 一、脚本
- `build.sh`
```bash
#!/bin/bash

docker stop kfk-manager && docker rm kfk-manager

docker run -d \
    --name kfk-manager \
    -p 9000:9000 \
    -e ZK_HOSTS=192.168.1.193:2181 \
    -e APPLICATION_SECRET=letmein \
    sheepkiller/kafka-manager:latest

```

### 二、启动
```bash
sh build.sh
```

### 三、访问
> http://xxx.xxx.xx.xx:9000
> 添加监控节点
![企业微信截图_16618459707162.png](http://tva1.sinaimg.cn/large/d1b93a20ly1h5oufn5f2vj20ny0cwmzj.jpg)

### 参考文档
* [docker—commpse安装kafka-manager](https://dandelioncloud.cn/article/details/1534268494447407105/)
* [Docker安装Kafka和Kafka-Manager](https://blog.csdn.net/hunheidaode/article/details/121416949)