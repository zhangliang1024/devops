# Docker部署KafkaOffsetMonitor

### 一、`KafkaOffsetMonitor`介绍
> `KafkaOffsetMonitor`是一款客户端消费监控工具，用来实时监控`kafka`服务的`Consumer`以及它所在的
> `Partition`中的`Offset`。我们可以浏览当前的消费组，并且每个`Topic`的所有`Partition`的消费情况可以一目了然

### 二、脚本
- `build.sh`
> 这里使用`junxy/kafkaoffsetmonitor:latest`镜像
```bash
#!/bin/bash

docker stop kfk-offset-monitor && docker rm kfk-offset-monitor

docker run -d \
    --name kfk-offset-monitor \
    -p 8081:8080 \
    -e ZK_HOSTS=192.168.1.193:2181 \
    -e KAFKA_BROKERS=192.168.1.193:9092 \
    -e REFRESH_SECENDS=10 \
    -e RETAIN_DAYS=2 \
    junxy/kafkaoffsetmonitor

docker logs -f kfk-offset-monitor
```

### 三、启动
```bash
sh build.sh
```

### 四、访问
> http://xxx.xx.xx.x:8081


---
### 参考文档

* [DOCKER KAFKAOFFSETMONITOR](https://www.freesion.com/article/4574279716/)
* [KafkaOffsetMonitor：监控消费者和延迟的队列](https://www.orchome.com/54)
* []()