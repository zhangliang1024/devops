# Docker安装SonarQube

### 一、简介
> [SonarQube](https://www.sonarqube.org/) 是一款用于代码质量管理的开源工具，主要用于源码的质量管理。通过插件形式，可以支持多种语言。


### 二、准备工作
-  创建自定义网络
> `SonarQube`安装需要用到`Postgres`数据库。故需要准备一个可以相互连通的网络

```bash
docker network create --driver bridge --subent 172.0.0./16 sonarqube
docker network ls 
```

- 下载镜像
```bash
docker pull postgres:latest
docker pull sonarqube:8.9.10-community
```

### 三、安装`Postgres`

- 创建日志/数据目录
```bash
mkdir -p /opt/postgresql/{logs,data}
```

- 安装脚本
> `build.sh`
```bash
#!/bin/bash

docker stop postgres && docker rm postgres

sudo docker run -d \
    -p 5432:5432 \
    --name postgres \
    --restart=always \
    --network sonarqube \
    --ip 172.0.0.54 \
    -v ${PWD}/data:/var/lib/postgresql/data \
    -e POSTGRES_USER=sonar \
    -e POSTGRES_PASSWORD=sonar \
    postgres

docker logs -f postgres
```

- 登录测试
```bash
docker exec -it postgresql /bin/bash

# postgres登录 
psql -U sonar -W 
```

### 四、安装`SonarQube`

- 修改Linux配置
> 不修改配置，启动报错：max virtual memory areas vm.max_map_count [65530] is too low, increase to at least [262144]
```bash
vim /etc/sysctl.conf

# 加入如下配置
vm.max_map_count = 26214
```

- 创建日志/数据/插件 目录
```bash
mkdir -p /opt/sonarqube/{logs,data,extensions}
```

- 安装脚本
> `build.sh`
```bash
#!/bin/bash

docker stop sonarqube && docker rm sonarqube

sudo docker run -d \
    -p 3009:9000 \
    --name sonarqube \
    --restart=always \
    --network sonarqube \
    --ip 172.0.0.59 \
    -v ${PWD}/extensions:/opt/sonarqube/extensions \
    -v ${PWD}/data:/opt/sonarqube/data \
    -v ${PWD}/logs:/opt/sonarqube/logs \
    --link postgresql \
    -e sonar.jdbc.url=jdbc:postgresql://postgresql:5432/sonar \
    -e sonar.jdbc.username=sonar \
    -e sonar.jdbc.password=sonar \
    sonarqube:8.9.10-community

docker logs -f sonarqube

```

- 访问
> http://xxx.xxx.xx:3009
> 
> admin/admin