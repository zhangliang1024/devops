Docker部署Kafak-Map

### 一、脚本
- `build.sh`
```bash
#!/bin/bash

docker stop kafka-map && docker rm kafka-map

docker run -d \
    --name kafka-map \
    --restart always \
    -p 8081:8080 \
    -v ${PWD}/data:/usr/local/kafka-map/data \
    -e DEFAULT_USERNAME=admin \
    -e DEFAULT_PASSWORD=admin \
    dushixiang/kafka-map:latest

docker logs -f kafka-map
```

### 二、部署
```bash
sh build.sh
```

### 三、访问 
> http:xx.xxx.xx.xx:8081

![企业微信截图_16618462994973.png](http://tva1.sinaimg.cn/large/d1b93a20ly1h5ouldlhz0j217a0kjgq7.jpg)