# 基于`Docker`部署`skywalking`实现全链路追踪

### 一、环境说明
```properties
1. 操作系统：CentOS8.2 
2. docker版本：20.10.8
3. docker-compose版本：1.29.2
4. 配置：4c8g
```

#### - 环境安装
##### 1. 安装`docker`
```bash
sudo yum remove docker*
sudo yum install -y yum-utils

# 配置docker的yum地址
sudo yum-config-manager \
--add-repo \
http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

# 安装指定版本
sudo yum install -y docker-ce-20.10.8 docker-ce-cli-20.10.8 containerd.io-1.4.6

# 启动&开机启动docker
systemctl enable docker --now

# docker加速配置
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://82m9ar63.mirror.aliyuncs.com"],
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker
```

##### 2. 安装`docker-compose`
```bash
# 1.下载docker-compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
# 2.赋予执行权限
sudo chmod +x /usr/local/bin/docker-compose
# 3.建立软连接
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
# 4.查看版本
docker-compose --version
```


### 二、镜像下载
> 注意：版本之间要匹配，skywalking可以使用多种存储。这里使用es7版本
```bash
docker pull apache/skywalking-oap-server:8.7.0-es7
docker pull apache/skywalking-ui:8.7.0
docker pull elasticsearch:7.14.0
```

#### - 镜像查询
[hub.docker](https://hub.docker.com/search?type=image)


### 三、修改系统参数
> `elasticsearch`需要修改一些系统参数才可以启动
```bash
[root@cm3gy /]# vi /etc/sysctl.conf
vm.max_map_count=262144
[root@cm3g /]# sysctl -p


[root@cm3g /]# vi/etc/systemd/system.conf
DefaultLimitNOFILE=65536
DefaultLimitNPROC=32000
DefaultLimitMEMLOCK=infinity
[root@cm3g /]# systemctl daemon-reload


[root@cm3g /]# vi /etc/security/limits.conf
* soft nofile 65536
* hard nofile 65536
* soft nproc 4096
* hard nproc 4096
* hard memlock unlimited
* soft memlock unlimited
```

### 四、部署
#### 1. 部署`elasticsearch`
```bash
[root@cm3g /]# mkdir -p /home/elasticsearch/{config,data,logs}
[root@cm3g /]# chmod 777 /home/elasticsearch/*
[root@cm3g /]# echo "http.host: 0.0.0.0" >> /home/elasticsearch/config/elasticsearch.yml
[root@cm3g /]# cd /home/elasticsearch && vim build.sh
#!/bin/bash
  
docker stop elasticsearch && docker rm elasticsearch

docker run --name elasticsearch \
        --restart=always \
        -p 9200:9200 -p 9300:9300 \
        -e "discovery.type=single-node" \
        -e ES_JAVA_OPTS="-Xms512m -Xmx1024m" \
        -v /home/elasticsearch/config/elasticsearch.yml:/usr/share/elasticsearch/config/elasticsearch.yml \
        -v /home/elasticsearch/data:/usr/share/elasticsearch/data \
        -v /home/elasticsearch/logs:/usr/share/elasticsearch/logs \
        -d elasticsearch:7.14.0
[root@cm3g /]# sh build.sh
[root@cm3g /]# docker logs -f elasticsearch
```

#### 2. 部署`skywalking-oap`与`skywalking-ui`
> - 这里注意 `SW_STORAGE=elasticsearch7`这里需要指定 `es7`版本。
> - `SW_OAP_ADDRESS=http://oap:12800`这里要加`http://`否则会找不到`oap`服务。
```bash
[root@cm3g /]# mkdir -p /home/skywalking
[root@cm3g /]# cd /home/skywalking && vim build.sh
#!/bin/bash
  
docker stop oap && docker rm oap
docker run --name oap \
        --restart=always -d \
        -e TZ=Asia/Shanghai \
        -p 12800:12800 \
        -p 11800:11800 \
        --link elasticsearch:elasticsearch \
        -e SW_STORAGE=elasticsearch7 \
        -e SW_STORAGE_ES_CLUSTER_NODES=elasticsearch:9200 \
        apache/skywalking-oap-server:8.7.0-es7


docker stop skywalking-ui && docker rm skywalking-ui
docker run --name skywalking-ui \
        --restart always -d \
        -e TZ=Asia/Shanghai \
        -p 8090:8080 \
        --link oap:oap \
        -e SW_OAP_ADDRESS=http://oap:12800 \
        apache/skywalking-ui:8.7.0
```

### 五、访问
> http://ip:8090

![](https://ae05.alicdn.com/kf/H39d5a316790548ebaeabc6ea0f9b401dq.png)

### 六、`Agent`项目集成
> - [skywalking-agent下载](https://archive.apache.org/dist/skywalking/)
> - 启动参数说明：
>   - `-javaagent:home/skywalking/agent/skywalking-agent.jar` agent的位置
>   - `-Dskywalking.agent.service_name=` 指定服务在`skywalking`的名称
>   - `-Dskywalking.collector.backend_service=` 指定`skywalking`的`server`地址
```bash
[root@cm3g /]# cd /home/skywalking
[root@cm3g /]# wget https://archive.apache.org/dist/skywalking/8.7.0/apache-skywalking-apm-8.7.0.tar.gz
[root@cm3g /]# cp -r apache-skywalking-apm-bin/agent/ .
[root@cm3g /]# tar -zxvf apache-skywalking-apm-8.7.0.tar.gz
[root@cm3g /]# java -javaagent:home/skywalking/agent/skywalking-agent.jar -Dskywalking.agent.service_name=eureka-server -Dskywalking.collector.backend_service=192.168.x.130:11800 -jar eureka-server.jar
```
![](https://ae03.alicdn.com/kf/Hc6b5a560eba14e36918b771fecf7eeadc.png)



### 九、参考文档
[基于docker部署skywalking实现全链路监控](https://www.jianshu.com/p/a237d6e810c6)
[docker 安装 Skywalking](https://www.jianshu.com/p/cc16196df610)