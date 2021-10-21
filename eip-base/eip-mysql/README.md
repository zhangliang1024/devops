# `Dokcer`部署`Mysql`

### 一、`Docker部署`
```bash
# 下载镜像
docker pull mysql:5.7

# 启动mysql容器
docker run -p 3306:3306 --name mysql \
 -v /toony/mysql/log:/var/log/mysql \
 -v /toony/mysql/data:/var/lib/mysql \
 -v /toony/mysql/conf:/etc/mysql \
 -e MYSQL_ROOT_PASSWORD=123456 \
 -d mysql:5.7
```
> - 说明
```properties
-p 3306:3306： 将容器的3306端口映射到宿主机的3306端口
--name mysql：将容器名字设置为mysql
-v /toony/mysql/log:/var/log/mysql：将日志文件夹挂载到宿主机
-v /toony/mysql/data:/var/lib/mysql：将数据文件夹挂载到宿主机
-v /toony/mysql/conf:/etc/mysql：将配置文件夹挂载到宿主机
-e MYSQL_ROOT_PASSWORD=123456：初始化root用户的密码
-d mysql:5.7：后台运行容器，并返回容器ID
```


### 二、`Docker-compose`方式部署
```bash
version: '3'
services:
  mysql:
    container_name: mysql
    image: mysql:5.7
    ports:
      - "3306:3306"
    volumes:
      - /mydata/mysql/log:/var/log/mysql
      - /mydata/mysql/data:/var/lib/mysql
      - /mydata/mysql/conf:/etc/mysql
    restart: always
    environment:
      - MYSQL_ROOT_PASSWORD=123456
      - COMPOSE_PROJECT_NAME=mysql-server
```

### 三、配置`Mysql`配置文件
```bash
cat > my.cnf <<-EOF
[client]
default-character-set=utf8
[mysql]
default-character-set=utf8
[mysqld]
init_connect='SET collation_connection = utf8_unicode_ci'
init_connect='SET NAMES utf8'
character-set-server=utf8
collation-server=utf8_unicode_ci
skip-character-set-client-handshake
skip-name-resolve
EOF
```


### 四、操作
```bash
# 进入容器
docker ps|grep mysql
docker exec -it mysql /bin/bash
```


### 五、参考博客
* []()